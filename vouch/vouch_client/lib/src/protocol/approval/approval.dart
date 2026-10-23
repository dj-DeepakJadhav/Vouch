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
import '../enums/approval_status.dart' as _ir2xy31z;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../household/household.dart' as _iyyunadd;
import '../identity/member.dart' as _ie1reufq;

/// A pending, approved, denied or expired T2 step-up request, created when
/// the MCP guard (see mcp/mcp_route.dart) determines a tool call requires
/// fresh owner confirmation. The Flutter admin app lists pending rows for
/// its household (ApprovalEndpoint.listPending) and decides them
/// (ApprovalEndpoint.decide); ApprovalExpiryFutureCall expires stale rows.
abstract class Approval
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Approval._({
    this.id,
    required this.householdId,
    this.household,
    this.memberId,
    this.member,
    required this.action,
    required this.argsJson,
    required this.utterance,
    this.speakerConfidence,
    this.transcriptMatch,
    this.heardTranscript,
    this.transcriptSimilarity,
    this.requiredTier,
    this.presentTier,
    this.policyReason,
    this.ruleSource,
    _ir2xy31z.ApprovalStatus? status,
    bool? used,
    required this.createdAt,
    required this.expiresAt,
    this.decidedAt,
  }) : status = status ?? _ir2xy31z.ApprovalStatus.pending,
       used = used ?? false;

  factory Approval({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    required String action,
    required String argsJson,
    required String utterance,
    double? speakerConfidence,
    String? transcriptMatch,
    String? heardTranscript,
    double? transcriptSimilarity,
    _i6oty1c9.TrustTier? requiredTier,
    _i6oty1c9.TrustTier? presentTier,
    String? policyReason,
    String? ruleSource,
    _ir2xy31z.ApprovalStatus? status,
    bool? used,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? decidedAt,
  }) = _ApprovalImpl;

  factory Approval.fromJson(Map<String, dynamic> jsonSerialization) {
    return Approval(
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
      action: jsonSerialization['action'] as String,
      argsJson: jsonSerialization['argsJson'] as String,
      utterance: jsonSerialization['utterance'] as String,
      speakerConfidence: (jsonSerialization['speakerConfidence'] as num?)
          ?.toDouble(),
      transcriptMatch: jsonSerialization['transcriptMatch'] as String?,
      heardTranscript: jsonSerialization['heardTranscript'] as String?,
      transcriptSimilarity: (jsonSerialization['transcriptSimilarity'] as num?)
          ?.toDouble(),
      requiredTier: jsonSerialization['requiredTier'] == null
          ? null
          : _i6oty1c9.TrustTier.fromJson(
              (jsonSerialization['requiredTier'] as String),
            ),
      presentTier: jsonSerialization['presentTier'] == null
          ? null
          : _i6oty1c9.TrustTier.fromJson(
              (jsonSerialization['presentTier'] as String),
            ),
      policyReason: jsonSerialization['policyReason'] as String?,
      ruleSource: jsonSerialization['ruleSource'] as String?,
      status: jsonSerialization['status'] == null
          ? null
          : _ir2xy31z.ApprovalStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      used: jsonSerialization['used'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['used']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      decidedAt: jsonSerialization['decidedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['decidedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  /// The household this approval belongs to.
  _iyyunadd.Household? household;

  int? memberId;

  /// The speaker attested for this call, if any was resolved before the
  /// step-up was requested (null if the speaker was unrecognised — step-up
  /// can still be requested for an unrecognised speaker on a T2 action,
  /// since PolicyEngine always sends T2 through step-up regardless of
  /// attested tier).
  _ie1reufq.Member? member;

  /// The tool/action name this approval covers (e.g. "unlock_front_door").
  String action;

  /// The tool call's arguments, canonical-JSON-encoded (same encoding used
  /// to compute the requestState argsHash, so the two can be cross-checked).
  String argsJson;

  /// The utterance text this approval covers, for display in the admin UI
  /// ("Allow: 'unlock the front door'?").
  String utterance;

  /// The speaker-verification confidence (0-1) from the attestation
  /// consumed to trigger this step-up, if any was resolved before the
  /// step-up was requested. `null` when the speaker was unrecognised (see
  /// `member` doc above).
  double? speakerConfidence;

  /// How the hub attestation related to Alexa's command text when the guard
  /// opened this step-up: "matched" (bound to this exact command),
  /// "near_miss" (Alexa's wording differed from what the hub heard; the
  /// speaker is plausible but NOT bound to this command) or "none" (no
  /// attestation at all). Shown on the approval card so the owner never
  /// approves a reworded command believing it was verified. Null on rows
  /// created before this field existed.
  String? transcriptMatch;

  /// The (normalised) transcript the hub heard, from the attestation
  /// consumed for this step-up. Null when there was no attestation.
  String? heardTranscript;

  /// Token-set similarity (0-1) between [heardTranscript] and Alexa's text.
  double? transcriptSimilarity;

  /// Tier the policy required at the original call (normally t2).
  _i6oty1c9.TrustTier? requiredTier;

  /// Tier presented by the attestation at the original call.
  _i6oty1c9.TrustTier? presentTier;

  /// The policy engine's reason at the original call (for display/audit;
  /// retry legs report their own retry-specific reason).
  String? policyReason;

  /// sourceText of the PolicyRule that matched at the original call.
  String? ruleSource;

  /// Current lifecycle status.
  _ir2xy31z.ApprovalStatus status;

  /// Whether this approval has already been consumed to execute a tool
  /// call. An approved row may be consumed at most once — this is the
  /// replay guard for a repeated MRTR retry with the same requestState.
  bool used;

  /// When this approval was created.
  DateTime createdAt;

  /// When this approval expires if not decided (createdAt + 60s).
  DateTime expiresAt;

  /// When the owner decided (approved/denied), if they have.
  DateTime? decidedAt;

  /// Returns a shallow copy of this [Approval]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Approval copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    String? action,
    String? argsJson,
    String? utterance,
    double? speakerConfidence,
    String? transcriptMatch,
    String? heardTranscript,
    double? transcriptSimilarity,
    _i6oty1c9.TrustTier? requiredTier,
    _i6oty1c9.TrustTier? presentTier,
    String? policyReason,
    String? ruleSource,
    _ir2xy31z.ApprovalStatus? status,
    bool? used,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? decidedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Approval',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'action': action,
      'argsJson': argsJson,
      'utterance': utterance,
      if (speakerConfidence != null) 'speakerConfidence': speakerConfidence,
      if (transcriptMatch != null) 'transcriptMatch': transcriptMatch,
      if (heardTranscript != null) 'heardTranscript': heardTranscript,
      if (transcriptSimilarity != null)
        'transcriptSimilarity': transcriptSimilarity,
      if (requiredTier != null) 'requiredTier': requiredTier?.toJson(),
      if (presentTier != null) 'presentTier': presentTier?.toJson(),
      if (policyReason != null) 'policyReason': policyReason,
      if (ruleSource != null) 'ruleSource': ruleSource,
      'status': status.toJson(),
      'used': used,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (decidedAt != null) 'decidedAt': decidedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Approval',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'action': action,
      'argsJson': argsJson,
      'utterance': utterance,
      if (speakerConfidence != null) 'speakerConfidence': speakerConfidence,
      if (transcriptMatch != null) 'transcriptMatch': transcriptMatch,
      if (heardTranscript != null) 'heardTranscript': heardTranscript,
      if (transcriptSimilarity != null)
        'transcriptSimilarity': transcriptSimilarity,
      if (requiredTier != null) 'requiredTier': requiredTier?.toJson(),
      if (presentTier != null) 'presentTier': presentTier?.toJson(),
      if (policyReason != null) 'policyReason': policyReason,
      if (ruleSource != null) 'ruleSource': ruleSource,
      'status': status.toJson(),
      'used': used,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (decidedAt != null) 'decidedAt': decidedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ApprovalImpl extends Approval {
  _ApprovalImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    required String action,
    required String argsJson,
    required String utterance,
    double? speakerConfidence,
    String? transcriptMatch,
    String? heardTranscript,
    double? transcriptSimilarity,
    _i6oty1c9.TrustTier? requiredTier,
    _i6oty1c9.TrustTier? presentTier,
    String? policyReason,
    String? ruleSource,
    _ir2xy31z.ApprovalStatus? status,
    bool? used,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? decidedAt,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         memberId: memberId,
         member: member,
         action: action,
         argsJson: argsJson,
         utterance: utterance,
         speakerConfidence: speakerConfidence,
         transcriptMatch: transcriptMatch,
         heardTranscript: heardTranscript,
         transcriptSimilarity: transcriptSimilarity,
         requiredTier: requiredTier,
         presentTier: presentTier,
         policyReason: policyReason,
         ruleSource: ruleSource,
         status: status,
         used: used,
         createdAt: createdAt,
         expiresAt: expiresAt,
         decidedAt: decidedAt,
       );

  /// Returns a shallow copy of this [Approval]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Approval copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    Object? memberId = _Undefined,
    Object? member = _Undefined,
    String? action,
    String? argsJson,
    String? utterance,
    Object? speakerConfidence = _Undefined,
    Object? transcriptMatch = _Undefined,
    Object? heardTranscript = _Undefined,
    Object? transcriptSimilarity = _Undefined,
    Object? requiredTier = _Undefined,
    Object? presentTier = _Undefined,
    Object? policyReason = _Undefined,
    Object? ruleSource = _Undefined,
    _ir2xy31z.ApprovalStatus? status,
    bool? used,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? decidedAt = _Undefined,
  }) {
    return Approval(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      memberId: memberId is int? ? memberId : this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      action: action ?? this.action,
      argsJson: argsJson ?? this.argsJson,
      utterance: utterance ?? this.utterance,
      speakerConfidence: speakerConfidence is double?
          ? speakerConfidence
          : this.speakerConfidence,
      transcriptMatch: transcriptMatch is String?
          ? transcriptMatch
          : this.transcriptMatch,
      heardTranscript: heardTranscript is String?
          ? heardTranscript
          : this.heardTranscript,
      transcriptSimilarity: transcriptSimilarity is double?
          ? transcriptSimilarity
          : this.transcriptSimilarity,
      requiredTier: requiredTier is _i6oty1c9.TrustTier?
          ? requiredTier
          : this.requiredTier,
      presentTier: presentTier is _i6oty1c9.TrustTier?
          ? presentTier
          : this.presentTier,
      policyReason: policyReason is String? ? policyReason : this.policyReason,
      ruleSource: ruleSource is String? ? ruleSource : this.ruleSource,
      status: status ?? this.status,
      used: used ?? this.used,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      decidedAt: decidedAt is DateTime? ? decidedAt : this.decidedAt,
    );
  }
}
