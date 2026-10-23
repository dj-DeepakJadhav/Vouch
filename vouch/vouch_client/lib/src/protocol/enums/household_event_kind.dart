/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// The kind of live update carried by a [HouseholdEvent], as published to
/// the Flutter admin app's household status stream
/// (HouseholdEndpoint.householdStatus). Derived once, in
/// AuditService.append, from the underlying AuditEvent's `eventType` +
/// `decision` — see household_event.spy.yaml.
enum HouseholdEventKind implements _isc.SerializableModel {
  /// A hub-issued voice attestation was accepted.
  attestationAccepted,

  /// A hub-issued voice attestation was rejected.
  attestationRejected,

  /// A policy decision (permit/deny) was reached for a tool call.
  decision,

  /// A T2 step-up approval request is now pending an owner decision.
  approvalPending,

  /// A pending step-up approval was decided (approved/denied/expired).
  approvalDecided;

  static HouseholdEventKind fromJson(String name) {
    switch (name) {
      case 'attestationAccepted':
        return HouseholdEventKind.attestationAccepted;
      case 'attestationRejected':
        return HouseholdEventKind.attestationRejected;
      case 'decision':
        return HouseholdEventKind.decision;
      case 'approvalPending':
        return HouseholdEventKind.approvalPending;
      case 'approvalDecided':
        return HouseholdEventKind.approvalDecided;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "HouseholdEventKind"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
