/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:vouch_server/src/generated/protocol.dart' as _iii3n24o;
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
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      memberId: jsonSerialization['memberId'] as int?,
      member: jsonSerialization['member'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_ie1reufq.Member>(
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
          : _is.BoolJsonExtension.fromJson(jsonSerialization['used']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      decidedAt: jsonSerialization['decidedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['decidedAt']),
    );
  }

  static final t = ApprovalTable();

  static const db = ApprovalRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Approval]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static ApprovalInclude include({
    _iyyunadd.HouseholdInclude? household,
    _ie1reufq.MemberInclude? member,
  }) {
    return ApprovalInclude._(
      household: household,
      member: member,
    );
  }

  static ApprovalIncludeList includeList({
    _is.WhereExpressionBuilder<ApprovalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    ApprovalInclude? include,
  }) {
    return ApprovalIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class ApprovalUpdateTable extends _is.UpdateTable<ApprovalTable> {
  ApprovalUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> memberId(int? value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<String, String> argsJson(String value) => _is.ColumnValue(
    table.argsJson,
    value,
  );

  _is.ColumnValue<String, String> utterance(String value) => _is.ColumnValue(
    table.utterance,
    value,
  );

  _is.ColumnValue<double, double> speakerConfidence(double? value) =>
      _is.ColumnValue(
        table.speakerConfidence,
        value,
      );

  _is.ColumnValue<String, String> transcriptMatch(String? value) =>
      _is.ColumnValue(
        table.transcriptMatch,
        value,
      );

  _is.ColumnValue<String, String> heardTranscript(String? value) =>
      _is.ColumnValue(
        table.heardTranscript,
        value,
      );

  _is.ColumnValue<double, double> transcriptSimilarity(double? value) =>
      _is.ColumnValue(
        table.transcriptSimilarity,
        value,
      );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> requiredTier(
    _i6oty1c9.TrustTier? value,
  ) => _is.ColumnValue(
    table.requiredTier,
    value,
  );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> presentTier(
    _i6oty1c9.TrustTier? value,
  ) => _is.ColumnValue(
    table.presentTier,
    value,
  );

  _is.ColumnValue<String, String> policyReason(String? value) =>
      _is.ColumnValue(
        table.policyReason,
        value,
      );

  _is.ColumnValue<String, String> ruleSource(String? value) => _is.ColumnValue(
    table.ruleSource,
    value,
  );

  _is.ColumnValue<_ir2xy31z.ApprovalStatus, _ir2xy31z.ApprovalStatus> status(
    _ir2xy31z.ApprovalStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<bool, bool> used(bool value) => _is.ColumnValue(
    table.used,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> decidedAt(DateTime? value) =>
      _is.ColumnValue(
        table.decidedAt,
        value,
      );
}

class ApprovalTable extends _is.Table<int?> {
  ApprovalTable({super.tableRelation}) : super(tableName: 'approval') {
    updateTable = ApprovalUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    argsJson = _is.ColumnString(
      'argsJson',
      this,
    );
    utterance = _is.ColumnString(
      'utterance',
      this,
    );
    speakerConfidence = _is.ColumnDouble(
      'speakerConfidence',
      this,
    );
    transcriptMatch = _is.ColumnString(
      'transcriptMatch',
      this,
    );
    heardTranscript = _is.ColumnString(
      'heardTranscript',
      this,
    );
    transcriptSimilarity = _is.ColumnDouble(
      'transcriptSimilarity',
      this,
    );
    requiredTier = _is.ColumnEnum(
      'requiredTier',
      this,
      _is.EnumSerialization.byName,
    );
    presentTier = _is.ColumnEnum(
      'presentTier',
      this,
      _is.EnumSerialization.byName,
    );
    policyReason = _is.ColumnString(
      'policyReason',
      this,
    );
    ruleSource = _is.ColumnString(
      'ruleSource',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    used = _is.ColumnBool(
      'used',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    decidedAt = _is.ColumnDateTime(
      'decidedAt',
      this,
    );
  }

  late final ApprovalUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this approval belongs to.
  _iyyunadd.HouseholdTable? _household;

  late final _is.ColumnInt memberId;

  /// The speaker attested for this call, if any was resolved before the
  /// step-up was requested (null if the speaker was unrecognised — step-up
  /// can still be requested for an unrecognised speaker on a T2 action,
  /// since PolicyEngine always sends T2 through step-up regardless of
  /// attested tier).
  _ie1reufq.MemberTable? _member;

  /// The tool/action name this approval covers (e.g. "unlock_front_door").
  late final _is.ColumnString action;

  /// The tool call's arguments, canonical-JSON-encoded (same encoding used
  /// to compute the requestState argsHash, so the two can be cross-checked).
  late final _is.ColumnString argsJson;

  /// The utterance text this approval covers, for display in the admin UI
  /// ("Allow: 'unlock the front door'?").
  late final _is.ColumnString utterance;

  /// The speaker-verification confidence (0-1) from the attestation
  /// consumed to trigger this step-up, if any was resolved before the
  /// step-up was requested. `null` when the speaker was unrecognised (see
  /// `member` doc above).
  late final _is.ColumnDouble speakerConfidence;

  /// How the hub attestation related to Alexa's command text when the guard
  /// opened this step-up: "matched" (bound to this exact command),
  /// "near_miss" (Alexa's wording differed from what the hub heard; the
  /// speaker is plausible but NOT bound to this command) or "none" (no
  /// attestation at all). Shown on the approval card so the owner never
  /// approves a reworded command believing it was verified. Null on rows
  /// created before this field existed.
  late final _is.ColumnString transcriptMatch;

  /// The (normalised) transcript the hub heard, from the attestation
  /// consumed for this step-up. Null when there was no attestation.
  late final _is.ColumnString heardTranscript;

  /// Token-set similarity (0-1) between [heardTranscript] and Alexa's text.
  late final _is.ColumnDouble transcriptSimilarity;

  /// Tier the policy required at the original call (normally t2).
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> requiredTier;

  /// Tier presented by the attestation at the original call.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> presentTier;

  /// The policy engine's reason at the original call (for display/audit;
  /// retry legs report their own retry-specific reason).
  late final _is.ColumnString policyReason;

  /// sourceText of the PolicyRule that matched at the original call.
  late final _is.ColumnString ruleSource;

  /// Current lifecycle status.
  late final _is.ColumnEnum<_ir2xy31z.ApprovalStatus> status;

  /// Whether this approval has already been consumed to execute a tool
  /// call. An approved row may be consumed at most once — this is the
  /// replay guard for a repeated MRTR retry with the same requestState.
  late final _is.ColumnBool used;

  /// When this approval was created.
  late final _is.ColumnDateTime createdAt;

  /// When this approval expires if not decided (createdAt + 60s).
  late final _is.ColumnDateTime expiresAt;

  /// When the owner decided (approved/denied), if they have.
  late final _is.ColumnDateTime decidedAt;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: Approval.t.householdId,
      foreignField: _iyyunadd.Household.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iyyunadd.HouseholdTable(tableRelation: foreignTableRelation),
    );
    return _household!;
  }

  _ie1reufq.MemberTable get member {
    if (_member != null) return _member!;
    _member = _is.createRelationTable(
      relationFieldName: 'member',
      field: Approval.t.memberId,
      foreignField: _ie1reufq.Member.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ie1reufq.MemberTable(tableRelation: foreignTableRelation),
    );
    return _member!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    memberId,
    action,
    argsJson,
    utterance,
    speakerConfidence,
    transcriptMatch,
    heardTranscript,
    transcriptSimilarity,
    requiredTier,
    presentTier,
    policyReason,
    ruleSource,
    status,
    used,
    createdAt,
    expiresAt,
    decidedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'household') {
      return household;
    }
    if (relationField == 'member') {
      return member;
    }
    return null;
  }
}

class ApprovalInclude extends _is.IncludeObject {
  ApprovalInclude._({
    _iyyunadd.HouseholdInclude? household,
    _ie1reufq.MemberInclude? member,
  }) {
    _household = household;
    _member = member;
  }

  _iyyunadd.HouseholdInclude? _household;

  _ie1reufq.MemberInclude? _member;

  @override
  Map<String, _is.Include?> get includes => {
    'household': _household,
    'member': _member,
  };

  @override
  _is.Table<int?> get table => Approval.t;
}

class ApprovalIncludeList extends _is.IncludeList {
  ApprovalIncludeList._({
    _is.WhereExpressionBuilder<ApprovalTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Approval.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Approval.t;
}

class ApprovalRepository {
  const ApprovalRepository._();

  final attachRow = const ApprovalAttachRowRepository._();

  final detachRow = const ApprovalDetachRowRepository._();

  /// Returns a list of [Approval]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Approval>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ApprovalTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    _is.Transaction? transaction,
    ApprovalInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Approval>(
      where: where?.call(Approval.t),
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Approval] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Approval?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ApprovalTable>? where,
    int? offset,
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    _is.Transaction? transaction,
    ApprovalInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Approval>(
      where: where?.call(Approval.t),
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Approval] by its [id] or null if no such row exists.
  Future<Approval?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ApprovalInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Approval>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Approval]s in the list and returns the inserted rows.
  ///
  /// The returned [Approval]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> insert(
    _is.DatabaseSession session,
    List<Approval> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Approval>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Approval] and returns the inserted row.
  ///
  /// The returned [Approval] will have its `id` field set.
  Future<Approval> insertRow(
    _is.DatabaseSession session,
    Approval row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Approval>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Approval]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Approval]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> upsert(
    _is.DatabaseSession session,
    List<Approval> rows, {
    required _is.ColumnSelections<ApprovalTable> conflictColumns,
    _is.ColumnSelections<ApprovalTable>? updateColumns,
    _is.WhereExpressionBuilder<ApprovalTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Approval>(
      rows,
      conflictColumns: conflictColumns(Approval.t),
      updateColumns: updateColumns?.call(Approval.t),
      updateWhere: updateWhere?.call(Approval.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Approval] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Approval] will have its `id` field set.
  Future<Approval?> upsertRow(
    _is.DatabaseSession session,
    Approval row, {
    required _is.ColumnSelections<ApprovalTable> conflictColumns,
    _is.ColumnSelections<ApprovalTable>? updateColumns,
    _is.WhereExpressionBuilder<ApprovalTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Approval>(
      row,
      conflictColumns: conflictColumns(Approval.t),
      updateColumns: updateColumns?.call(Approval.t),
      updateWhere: updateWhere?.call(Approval.t),
      transaction: transaction,
    );
  }

  /// Updates all [Approval]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> update(
    _is.DatabaseSession session,
    List<Approval> rows, {
    _is.ColumnSelections<ApprovalTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Approval>(
      rows,
      columns: columns?.call(Approval.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Approval]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Approval> updateRow(
    _is.DatabaseSession session,
    Approval row, {
    _is.ColumnSelections<ApprovalTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Approval>(
      row,
      columns: columns?.call(Approval.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Approval] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Approval?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ApprovalUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Approval>(
      id,
      columnValues: columnValues(Approval.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Approval]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ApprovalUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ApprovalTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Approval>(
      columnValues: columnValues(Approval.t.updateTable),
      where: where(Approval.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Approval]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> delete(
    _is.DatabaseSession session,
    List<Approval> rows, {
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Approval>(
      rows,
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Approval].
  Future<Approval> deleteRow(
    _is.DatabaseSession session,
    Approval row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Approval>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Approval>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ApprovalTable> where,
    _is.OrderByBuilder<ApprovalTable>? orderBy,
    _is.OrderByListBuilder<ApprovalTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Approval>(
      where: where(Approval.t),
      orderBy: orderBy?.call(Approval.t),
      orderByList: orderByList?.call(Approval.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ApprovalTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Approval>(
      where: where?.call(Approval.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Approval] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ApprovalTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Approval>(
      where: where(Approval.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ApprovalAttachRowRepository {
  const ApprovalAttachRowRepository._();

  /// Creates a relation between the given [Approval] and [Household]
  /// by setting the [Approval]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    Approval approval,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (approval.id == null) {
      throw ArgumentError.notNull('approval.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $approval = approval.copyWith(householdId: household.id);
    await session.db.updateRow<Approval>(
      $approval,
      columns: [Approval.t.householdId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Approval] and [Member]
  /// by setting the [Approval]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    Approval approval,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (approval.id == null) {
      throw ArgumentError.notNull('approval.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $approval = approval.copyWith(memberId: member.id);
    await session.db.updateRow<Approval>(
      $approval,
      columns: [Approval.t.memberId],
      transaction: transaction,
    );
  }
}

class ApprovalDetachRowRepository {
  const ApprovalDetachRowRepository._();

  /// Detaches the relation between this [Approval] and the [Member] set in `member`
  /// by setting the [Approval]'s foreign key `memberId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> member(
    _is.DatabaseSession session,
    Approval approval, {
    _is.Transaction? transaction,
  }) async {
    if (approval.id == null) {
      throw ArgumentError.notNull('approval.id');
    }

    var $approval = approval.copyWith(memberId: null);
    await session.db.updateRow<Approval>(
      $approval,
      columns: [Approval.t.memberId],
      transaction: transaction,
    );
  }
}
