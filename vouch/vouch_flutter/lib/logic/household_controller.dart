import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:vouch_client/vouch_client.dart';

import '../data/repositories/audit_repository.dart';
import '../data/repositories/household_repository.dart';

/// Backs the Home screen: household overview (name, members) plus a rolling,
/// newest-first live feed from the household event stream. Also the single
/// place the Alexa screen's "Follow hub" mode listens for
/// `attestationAccepted` events, via [events].
class HouseholdController extends ChangeNotifier {
  HouseholdController({
    required HouseholdRepository repository,
    required this.householdId,
    AuditRepository? auditRepository,
  }) : _repository = repository,
       _audit = auditRepository;

  final HouseholdRepository _repository;

  /// When given, the feed is seeded from the audit log on load. The live
  /// stream only carries events from the moment of subscribing, so without
  /// this a freshly loaded Home read "Nothing has happened yet" until the
  /// next utterance.
  final AuditRepository? _audit;
  Future<void>? _inFlight;
  final int householdId;

  static const int _maxFeed = 50;

  HouseholdOverview? overview;
  bool loading = true;
  Object? error;

  final ListQueue<HouseholdEvent> _feed = ListQueue<HouseholdEvent>();
  StreamSubscription<HouseholdEvent>? _sub;

  List<HouseholdEvent> get events => _feed.toList();

  /// Concurrent callers (the provider's eager load and the Home tab's own)
  /// share one in-flight load instead of racing each other.
  Future<void> load() => _inFlight ??= _load().whenComplete(() {
    _inFlight = null;
  });

  Future<void> _load() async {
    loading = true;
    notifyListeners();
    try {
      overview = await _repository.myHousehold();
      error = null;
      loading = false;
      notifyListeners();
      _sub ??= _repository
          .householdStatus(householdId)
          .listen(
            (event) {
              _feed.addFirst(event);
              while (_feed.length > _maxFeed) {
                _feed.removeLast();
              }
              notifyListeners();
            },
            // A dropped stream must not wedge the feed: forget it so the
            // next load() subscribes again.
            onError: (Object _) => _sub = null,
            onDone: () => _sub = null,
          );
      await _seedFromAudit();
    } catch (e) {
      error = e;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _seedFromAudit() async {
    final audit = _audit;
    if (audit == null) return;
    try {
      final rows = await audit.listRecent(householdId, pageSize: _maxFeed);
      final seen = {
        for (final e in _feed) '${e.at.microsecondsSinceEpoch}-${e.kind.name}',
      };
      final merged = [..._feed];
      for (final row in rows) {
        final kind = _kindOf(row);
        if (kind == null) continue;
        final event = HouseholdEvent(
          householdId: householdId,
          kind: kind,
          memberId: row.memberId,
          action: row.action,
          decision: row.decision,
          reason: row.reason,
          tierPresent: row.tierPresent,
          at: row.createdAt,
          eventType: row.eventType,
        );
        if (seen.add('${event.at.microsecondsSinceEpoch}-${event.kind.name}')) {
          merged.add(event);
        }
      }
      merged.sort((a, b) => b.at.compareTo(a.at));
      _feed
        ..clear()
        ..addAll(merged.take(_maxFeed));
      notifyListeners();
    } catch (_) {
      // History is a nicety; the live stream still works.
    }
  }

  static HouseholdEventKind? _kindOf(AuditEvent e) => switch (e.eventType) {
    'attestation.submit' =>
      e.decision == AuditDecision.permitted
          ? HouseholdEventKind.attestationAccepted
          : HouseholdEventKind.attestationRejected,
    'approval.decide' => HouseholdEventKind.approvalDecided,
    'mcp.tool_call' => HouseholdEventKind.decision,
    _ => null,
  };

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
