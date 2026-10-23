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
import '../enums/audit_decision.dart' as _izqcj77q;
import '../enums/household_event_kind.dart' as _iba9xdsp;
import '../enums/trust_tier.dart' as _i6oty1c9;

/// A single live update for a household's status stream
/// (HouseholdEndpoint.householdStatus), published to the Flutter admin app
/// over `session.messages` as it happens. NOT a table — this is a
/// transient wire event, not persisted state. The durable record of the
/// same fact is the [AuditEvent] row written alongside it; AuditService
/// .append is the single place that derives and publishes one of these
/// per audited event (see audit_service.dart).
abstract class HouseholdEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  HouseholdEvent._({
    required this.householdId,
    required this.kind,
    this.memberId,
    this.action,
    this.decision,
    required this.reason,
    this.tierPresent,
    required this.at,
    this.transcript,
    this.eventType,
  });

  factory HouseholdEvent({
    required int householdId,
    required _iba9xdsp.HouseholdEventKind kind,
    int? memberId,
    String? action,
    _izqcj77q.AuditDecision? decision,
    required String reason,
    _i6oty1c9.TrustTier? tierPresent,
    required DateTime at,
    String? transcript,
    String? eventType,
  }) = _HouseholdEventImpl;

  factory HouseholdEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return HouseholdEvent(
      householdId: jsonSerialization['householdId'] as int,
      kind: _iba9xdsp.HouseholdEventKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      memberId: jsonSerialization['memberId'] as int?,
      action: jsonSerialization['action'] as String?,
      decision: jsonSerialization['decision'] == null
          ? null
          : _izqcj77q.AuditDecision.fromJson(
              (jsonSerialization['decision'] as String),
            ),
      reason: jsonSerialization['reason'] as String,
      tierPresent: jsonSerialization['tierPresent'] == null
          ? null
          : _i6oty1c9.TrustTier.fromJson(
              (jsonSerialization['tierPresent'] as String),
            ),
      at: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      transcript: jsonSerialization['transcript'] as String?,
      eventType: jsonSerialization['eventType'] as String?,
    );
  }

  /// The household this event occurred within.
  int householdId;

  /// What kind of update this is.
  _iba9xdsp.HouseholdEventKind kind;

  /// The member the event concerns, if one was identified.
  int? memberId;

  /// The action/tool call the event concerns, if applicable.
  String? action;

  /// The underlying audit decision, if applicable.
  _izqcj77q.AuditDecision? decision;

  /// Human-readable reason, mirrors the underlying AuditEvent.reason.
  String reason;

  /// The trust tier presented for this event, if any — mirrors the
  /// underlying AuditEvent.tierPresent. Lets the Flutter admin app colour
  /// its live feed by tier (T0 grey · T1 blue · T2 amber) consistently
  /// with everywhere else (VOUCH-DESIGN.md §6.3).
  _i6oty1c9.TrustTier? tierPresent;

  /// When the event occurred.
  DateTime at;

  /// The normalised transcript bound to this event, if applicable (set for
  /// attestation events only). Lets the Flutter admin app's simulated
  /// Alexa+ surface "follow the hub": on `attestationAccepted`, it replays
  /// this exact utterance as the Alexa command over the real MCP endpoint.
  String? transcript;

  /// The underlying AuditEvent.eventType (e.g. "mcp.tool_call",
  /// "policy.rule_created"), so the feed can describe administrative
  /// events (a rule naming a member) differently from a member's own
  /// command. Null on events published before this field existed.
  String? eventType;

  /// Returns a shallow copy of this [HouseholdEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  HouseholdEvent copyWith({
    int? householdId,
    _iba9xdsp.HouseholdEventKind? kind,
    int? memberId,
    String? action,
    _izqcj77q.AuditDecision? decision,
    String? reason,
    _i6oty1c9.TrustTier? tierPresent,
    DateTime? at,
    String? transcript,
    String? eventType,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HouseholdEvent',
      'householdId': householdId,
      'kind': kind.toJson(),
      if (memberId != null) 'memberId': memberId,
      if (action != null) 'action': action,
      if (decision != null) 'decision': decision?.toJson(),
      'reason': reason,
      if (tierPresent != null) 'tierPresent': tierPresent?.toJson(),
      'at': at.toJson(),
      if (transcript != null) 'transcript': transcript,
      if (eventType != null) 'eventType': eventType,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HouseholdEvent',
      'householdId': householdId,
      'kind': kind.toJson(),
      if (memberId != null) 'memberId': memberId,
      if (action != null) 'action': action,
      if (decision != null) 'decision': decision?.toJson(),
      'reason': reason,
      if (tierPresent != null) 'tierPresent': tierPresent?.toJson(),
      'at': at.toJson(),
      if (transcript != null) 'transcript': transcript,
      if (eventType != null) 'eventType': eventType,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HouseholdEventImpl extends HouseholdEvent {
  _HouseholdEventImpl({
    required int householdId,
    required _iba9xdsp.HouseholdEventKind kind,
    int? memberId,
    String? action,
    _izqcj77q.AuditDecision? decision,
    required String reason,
    _i6oty1c9.TrustTier? tierPresent,
    required DateTime at,
    String? transcript,
    String? eventType,
  }) : super._(
         householdId: householdId,
         kind: kind,
         memberId: memberId,
         action: action,
         decision: decision,
         reason: reason,
         tierPresent: tierPresent,
         at: at,
         transcript: transcript,
         eventType: eventType,
       );

  /// Returns a shallow copy of this [HouseholdEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  HouseholdEvent copyWith({
    int? householdId,
    _iba9xdsp.HouseholdEventKind? kind,
    Object? memberId = _Undefined,
    Object? action = _Undefined,
    Object? decision = _Undefined,
    String? reason,
    Object? tierPresent = _Undefined,
    DateTime? at,
    Object? transcript = _Undefined,
    Object? eventType = _Undefined,
  }) {
    return HouseholdEvent(
      householdId: householdId ?? this.householdId,
      kind: kind ?? this.kind,
      memberId: memberId is int? ? memberId : this.memberId,
      action: action is String? ? action : this.action,
      decision: decision is _izqcj77q.AuditDecision? ? decision : this.decision,
      reason: reason ?? this.reason,
      tierPresent: tierPresent is _i6oty1c9.TrustTier?
          ? tierPresent
          : this.tierPresent,
      at: at ?? this.at,
      transcript: transcript is String? ? transcript : this.transcript,
      eventType: eventType is String? ? eventType : this.eventType,
    );
  }
}
