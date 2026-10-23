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
import 'package:vouch_client/src/protocol/protocol.dart' as _iqe5q8gy;
import '../enums/audit_decision.dart' as _izqcj77q;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../household/household.dart' as _iyyunadd;
import '../identity/member.dart' as _ie1reufq;

/// A record of a single access decision. APPEND-ONLY BY DESIGN: no update or
/// delete endpoint may ever be exposed for this table. This satisfies a
/// GDPR Art. 30 record-of-processing requirement (see VOUCH-DESIGN.md §8).
abstract class AuditEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AuditEvent._({
    this.id,
    required this.householdId,
    this.household,
    this.memberId,
    this.member,
    required this.eventType,
    required this.action,
    required this.decision,
    this.tierRequired,
    this.tierPresent,
    required this.reason,
    this.confidence,
    required this.createdAt,
    this.metadata,
  });

  factory AuditEvent({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    required String eventType,
    required String action,
    required _izqcj77q.AuditDecision decision,
    _i6oty1c9.TrustTier? tierRequired,
    _i6oty1c9.TrustTier? tierPresent,
    required String reason,
    double? confidence,
    required DateTime createdAt,
    String? metadata,
  }) = _AuditEventImpl;

  factory AuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEvent(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      memberId: jsonSerialization['memberId'] as int?,
      member: jsonSerialization['member'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      eventType: jsonSerialization['eventType'] as String,
      action: jsonSerialization['action'] as String,
      decision: _izqcj77q.AuditDecision.fromJson(
        (jsonSerialization['decision'] as String),
      ),
      tierRequired: jsonSerialization['tierRequired'] == null
          ? null
          : _i6oty1c9.TrustTier.fromJson(
              (jsonSerialization['tierRequired'] as String),
            ),
      tierPresent: jsonSerialization['tierPresent'] == null
          ? null
          : _i6oty1c9.TrustTier.fromJson(
              (jsonSerialization['tierPresent'] as String),
            ),
      reason: jsonSerialization['reason'] as String,
      confidence: (jsonSerialization['confidence'] as num?)?.toDouble(),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      metadata: jsonSerialization['metadata'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  /// The household this event occurred within.
  _iyyunadd.Household? household;

  int? memberId;

  /// The member the decision was made about, if one was identified.
  _ie1reufq.Member? member;

  /// The kind of event being recorded (e.g. "attestation.issued",
  /// "policy.check").
  String eventType;

  /// The action or tool call that was being authorized.
  String action;

  /// The decision reached for this event.
  _izqcj77q.AuditDecision decision;

  /// The trust tier required by policy for this action, if applicable.
  _i6oty1c9.TrustTier? tierRequired;

  /// The trust tier actually presented, if any.
  _i6oty1c9.TrustTier? tierPresent;

  /// Human-readable reason for the decision, for audit review.
  String reason;

  /// Confidence score associated with the decision, if applicable.
  double? confidence;

  /// When the event was recorded.
  DateTime createdAt;

  /// Arbitrary additional context serialized as JSON text, if any.
  String? metadata;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuditEvent copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    String? eventType,
    String? action,
    _izqcj77q.AuditDecision? decision,
    _i6oty1c9.TrustTier? tierRequired,
    _i6oty1c9.TrustTier? tierPresent,
    String? reason,
    double? confidence,
    DateTime? createdAt,
    String? metadata,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'eventType': eventType,
      'action': action,
      'decision': decision.toJson(),
      if (tierRequired != null) 'tierRequired': tierRequired?.toJson(),
      if (tierPresent != null) 'tierPresent': tierPresent?.toJson(),
      'reason': reason,
      if (confidence != null) 'confidence': confidence,
      'createdAt': createdAt.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'eventType': eventType,
      'action': action,
      'decision': decision.toJson(),
      if (tierRequired != null) 'tierRequired': tierRequired?.toJson(),
      if (tierPresent != null) 'tierPresent': tierPresent?.toJson(),
      'reason': reason,
      if (confidence != null) 'confidence': confidence,
      'createdAt': createdAt.toJson(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEventImpl extends AuditEvent {
  _AuditEventImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    required String eventType,
    required String action,
    required _izqcj77q.AuditDecision decision,
    _i6oty1c9.TrustTier? tierRequired,
    _i6oty1c9.TrustTier? tierPresent,
    required String reason,
    double? confidence,
    required DateTime createdAt,
    String? metadata,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         memberId: memberId,
         member: member,
         eventType: eventType,
         action: action,
         decision: decision,
         tierRequired: tierRequired,
         tierPresent: tierPresent,
         reason: reason,
         confidence: confidence,
         createdAt: createdAt,
         metadata: metadata,
       );

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AuditEvent copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    Object? memberId = _Undefined,
    Object? member = _Undefined,
    String? eventType,
    String? action,
    _izqcj77q.AuditDecision? decision,
    Object? tierRequired = _Undefined,
    Object? tierPresent = _Undefined,
    String? reason,
    Object? confidence = _Undefined,
    DateTime? createdAt,
    Object? metadata = _Undefined,
  }) {
    return AuditEvent(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      memberId: memberId is int? ? memberId : this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      eventType: eventType ?? this.eventType,
      action: action ?? this.action,
      decision: decision ?? this.decision,
      tierRequired: tierRequired is _i6oty1c9.TrustTier?
          ? tierRequired
          : this.tierRequired,
      tierPresent: tierPresent is _i6oty1c9.TrustTier?
          ? tierPresent
          : this.tierPresent,
      reason: reason ?? this.reason,
      confidence: confidence is double? ? confidence : this.confidence,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata is String? ? metadata : this.metadata,
    );
  }
}
