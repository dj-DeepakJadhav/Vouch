import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vouch_client/vouch_client.dart';

/// Who can "speak" in the simulated Alexa+ when there is no hub and no
/// microphone. Set once by the "Try the demo household" flow; null means a
/// real, hub-paired household, where the Alexa tab behaves as before.
class DemoSession {
  const DemoSession({
    required this.hubId,
    required this.ownerMemberId,
    required this.childMemberId,
    this.ownerName = 'Priya',
    this.childName = 'Ana',
  });

  final int hubId;
  final int ownerMemberId;
  final int childMemberId;
  final String ownerName;
  final String childName;

  static DemoSession? current;

  /// Marker both demo paths write on their hub (`DemoEndpoint.start` and
  /// `DevEndpoint.seedDemoHousehold`). Only a UI hint: the server decides
  /// what is a demo household (DemoEndpoint refuses anything else).
  static const seedHubVersion = '0.0.1-dev-seed';

  static const _storageKey = 'vouch.demoHouseholdId';

  /// Remembers that [householdId] was created by "Try the demo household"
  /// on this device. A hub registered with `demo.sh setup` is ALSO
  /// dev-seeded (same hub version marker), so the marker alone can't tell
  /// them apart, and the dev fallback re-signs attestations with a fresh hub
  /// key, which would break a real hub's signatures.
  static Future<void> remember(int householdId) async {
    try {
      await const FlutterSecureStorage().write(
        key: _storageKey,
        value: '$householdId',
      );
    } catch (_) {
      // Storage unavailable: demo mode just won't survive a refresh.
    }
  }

  /// True iff [householdId] is the one [remember] stored on this device.
  static Future<bool> isRemembered(int householdId) async {
    try {
      return await const FlutterSecureStorage().read(key: _storageKey) ==
          '$householdId';
    } catch (_) {
      return false;
    }
  }

  /// Rebuilds the session from a household overview so a page refresh keeps
  /// demo mode. Returns null for anything that isn't a dev-seeded household
  /// (a real, hub-paired household has a real hub version).
  static DemoSession? fromOverview(HouseholdOverview overview) {
    final hub = overview.hubs.where((h) => h.version == seedHubVersion);
    if (hub.isEmpty) return null;
    final owner = overview.members.where((m) => m.role == MemberRole.owner);
    final child = overview.members.where((m) => m.role == MemberRole.child);
    if (owner.isEmpty || child.isEmpty) return null;
    return DemoSession(
      hubId: hub.first.id!,
      ownerMemberId: owner.first.id!,
      childMemberId: child.first.id!,
      ownerName: owner.first.displayName,
      childName: child.first.displayName,
    );
  }
}

/// The voice behind a simulated command. [tv] stands for any voice the hub
/// has no voiceprint for (a TV, a guest, a clone that fails the check):
/// nothing is attested, so the guard sees an unrecognised speaker.
enum DemoSpeaker { owner, child, tv }
