/// Not a correctness test (see audit_endpoint_test.dart for that) — this is
/// a one-off local demonstration harness for `jobs/nightly_review/main.py`:
/// it seeds a household with a mix of ordinary and "unusual" audit events
/// (repeated denials, an unrecognised-speaker attempt, a new/unclassified
/// tool) via the exact same [AuditService.append] every real guard
/// decision goes through, then dumps [AuditEvent]s the same shape
/// `audit.exportSince` returns to a JSON file the Python job can read with
/// `--input`. Writes to a fresh system temp dir (path printed) so it
/// doesn't leave demo data in version control.
///
/// Run with: `dart test -t live -N "writes a sample export"` (no live
/// Nebius call happens here — tagged 'live' only to keep it out of the
/// default `dart test -x live` run, since it writes a file as a side
/// effect rather than asserting behaviour).
@Tags(['live'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:vouch_server/src/audit/audit_service.dart';
import 'package:vouch_server/src/generated/protocol.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given a household with a mix of ordinary and unusual activity', (
    sessionBuilder,
    endpoints,
  ) {
    var session = sessionBuilder.build();

    test('writes a sample audit export for the nightly review job', () async {
      final household = await Household.db.insertRow(
        session,
        Household(
          name: 'Nightly Review Demo Household',
          createdAt: DateTime.now().toUtc(),
        ),
      );
      final owner = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Dana',
          role: MemberRole.owner,
          status: MemberStatus.active,
        ),
      );
      final child = await Member.db.insertRow(
        session,
        Member(
          householdId: household.id!,
          displayName: 'Sam',
          role: MemberRole.child,
          status: MemberStatus.active,
        ),
      );

      final now = DateTime.now().toUtc();

      // Ordinary, unremarkable traffic.
      await AuditService.append(
        session,
        householdId: household.id!,
        memberId: owner.id,
        eventType: 'mcp.tool_call',
        action: 'get_weather',
        decision: AuditDecision.permitted,
        tierRequired: TrustTier.t0,
        tierPresent: TrustTier.t0,
        reason: 'default tier t0 applied for "get_weather"',
        createdAt: now.subtract(const Duration(hours: 20)),
      );
      await AuditService.append(
        session,
        householdId: household.id!,
        memberId: owner.id,
        eventType: 'mcp.tool_call',
        action: 'add_to_list',
        decision: AuditDecision.permitted,
        tierRequired: TrustTier.t1,
        tierPresent: TrustTier.t1,
        reason: 'default tier t1 applied for "add_to_list"',
        createdAt: now.subtract(const Duration(hours: 18)),
      );

      // Unusual: repeated denials for the same action/member in a short
      // window — the kind of pattern a nightly review should surface.
      for (var i = 0; i < 4; i++) {
        await AuditService.append(
          session,
          householdId: household.id!,
          memberId: child.id,
          eventType: 'mcp.tool_call',
          action: 'place_order',
          decision: AuditDecision.denied,
          tierRequired: TrustTier.t2,
          tierPresent: TrustTier.t0,
          reason:
              'Denied by policy rule for "place_order" (children may never place orders)',
          createdAt: now.subtract(Duration(hours: 10, minutes: i * 5)),
        );
      }

      // Unusual: an unrecognised-speaker attempt at a sensitive action.
      await AuditService.append(
        session,
        householdId: household.id!,
        eventType: 'mcp.tool_call',
        action: 'unlock_front_door',
        decision: AuditDecision.denied,
        tierRequired: TrustTier.t2,
        tierPresent: TrustTier.t0,
        reason: 'speaker not recognised',
        createdAt: now.subtract(const Duration(hours: 6)),
      );

      // Unusual: a brand-new, never-seen-before tool name with no rule and
      // no built-in default — exactly what ToolRiskClassifier exists for.
      await AuditService.append(
        session,
        householdId: household.id!,
        memberId: owner.id,
        eventType: 'mcp.tool_call',
        action: 'transfer_funds',
        decision: AuditDecision.challenged,
        tierRequired: TrustTier.t2,
        tierPresent: TrustTier.t1,
        reason:
            'No matching rule and no built-in default; cached risk '
            'classification tier t2 applied for "transfer_funds"',
        createdAt: now.subtract(const Duration(hours: 2)),
      );

      final events = await AuditEvent.db.find(
        session,
        where: (t) =>
            t.householdId.equals(household.id!) &
            (t.createdAt >= now.subtract(const Duration(hours: 24))),
        orderBy: (t) => t.createdAt,
      );

      final outDir = Directory.systemTemp.createTempSync('vouch_nightly_');
      final outFile = File('${outDir.path}/nightly_review_sample_export.json');
      outFile.writeAsStringSync(
        jsonEncode({
          'householdId': household.id,
          'since': now.subtract(const Duration(hours: 24)).toIso8601String(),
          'events': events
              .map(
                (e) => {
                  'id': e.id,
                  'memberId': e.memberId,
                  'eventType': e.eventType,
                  'action': e.action,
                  'decision': e.decision.name,
                  'tierRequired': e.tierRequired?.name,
                  'tierPresent': e.tierPresent?.name,
                  'reason': e.reason,
                  'createdAt': e.createdAt.toIso8601String(),
                },
              )
              .toList(),
        }),
      );

      expect(events, hasLength(8));
      // ignore: avoid_print
      print('wrote ${events.length} events to ${outFile.path}');
    });
  });
}
