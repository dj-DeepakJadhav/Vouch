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
import '../enums/audit_decision.dart' as _izqcj77q;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../household/household.dart' as _iyyunadd;
import '../identity/member.dart' as _ie1reufq;

/// A record of a single access decision. APPEND-ONLY BY DESIGN: no update or
/// delete endpoint may ever be exposed for this table. This satisfies a
/// GDPR Art. 30 record-of-processing requirement (see VOUCH-DESIGN.md §8).
abstract class AuditEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      memberId: jsonSerialization['memberId'] as int?,
      member: jsonSerialization['member'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_ie1reufq.Member>(
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      metadata: jsonSerialization['metadata'] as String?,
    );
  }

  static final t = AuditEventTable();

  static const db = AuditEventRepository._();

  @override
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

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static AuditEventInclude include({
    _iyyunadd.HouseholdInclude? household,
    _ie1reufq.MemberInclude? member,
  }) {
    return AuditEventInclude._(
      household: household,
      member: member,
    );
  }

  static AuditEventIncludeList includeList({
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    AuditEventInclude? include,
  }) {
    return AuditEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class AuditEventUpdateTable extends _is.UpdateTable<AuditEventTable> {
  AuditEventUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> memberId(int? value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<String, String> eventType(String value) => _is.ColumnValue(
    table.eventType,
    value,
  );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<_izqcj77q.AuditDecision, _izqcj77q.AuditDecision> decision(
    _izqcj77q.AuditDecision value,
  ) => _is.ColumnValue(
    table.decision,
    value,
  );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> tierRequired(
    _i6oty1c9.TrustTier? value,
  ) => _is.ColumnValue(
    table.tierRequired,
    value,
  );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> tierPresent(
    _i6oty1c9.TrustTier? value,
  ) => _is.ColumnValue(
    table.tierPresent,
    value,
  );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<double, double> confidence(double? value) => _is.ColumnValue(
    table.confidence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<String, String> metadata(String? value) => _is.ColumnValue(
    table.metadata,
    value,
  );
}

class AuditEventTable extends _is.Table<int?> {
  AuditEventTable({super.tableRelation}) : super(tableName: 'audit_event') {
    updateTable = AuditEventUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    eventType = _is.ColumnString(
      'eventType',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    decision = _is.ColumnEnum(
      'decision',
      this,
      _is.EnumSerialization.byName,
    );
    tierRequired = _is.ColumnEnum(
      'tierRequired',
      this,
      _is.EnumSerialization.byName,
    );
    tierPresent = _is.ColumnEnum(
      'tierPresent',
      this,
      _is.EnumSerialization.byName,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    confidence = _is.ColumnDouble(
      'confidence',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    metadata = _is.ColumnString(
      'metadata',
      this,
    );
  }

  late final AuditEventUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this event occurred within.
  _iyyunadd.HouseholdTable? _household;

  late final _is.ColumnInt memberId;

  /// The member the decision was made about, if one was identified.
  _ie1reufq.MemberTable? _member;

  /// The kind of event being recorded (e.g. "attestation.issued",
  /// "policy.check").
  late final _is.ColumnString eventType;

  /// The action or tool call that was being authorized.
  late final _is.ColumnString action;

  /// The decision reached for this event.
  late final _is.ColumnEnum<_izqcj77q.AuditDecision> decision;

  /// The trust tier required by policy for this action, if applicable.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> tierRequired;

  /// The trust tier actually presented, if any.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> tierPresent;

  /// Human-readable reason for the decision, for audit review.
  late final _is.ColumnString reason;

  /// Confidence score associated with the decision, if applicable.
  late final _is.ColumnDouble confidence;

  /// When the event was recorded.
  late final _is.ColumnDateTime createdAt;

  /// Arbitrary additional context serialized as JSON text, if any.
  late final _is.ColumnString metadata;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: AuditEvent.t.householdId,
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
      field: AuditEvent.t.memberId,
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
    eventType,
    action,
    decision,
    tierRequired,
    tierPresent,
    reason,
    confidence,
    createdAt,
    metadata,
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

class AuditEventInclude extends _is.IncludeObject {
  AuditEventInclude._({
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
  _is.Table<int?> get table => AuditEvent.t;
}

class AuditEventIncludeList extends _is.IncludeList {
  AuditEventIncludeList._({
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AuditEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => AuditEvent.t;
}

class AuditEventRepository {
  const AuditEventRepository._();

  final attachRow = const AuditEventAttachRowRepository._();

  final detachRow = const AuditEventDetachRowRepository._();

  /// Returns a list of [AuditEvent]s matching the given query parameters.
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
  Future<List<AuditEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    AuditEventInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AuditEvent>(
      where: where?.call(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AuditEvent] matching the given query parameters.
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
  Future<AuditEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    AuditEventInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AuditEvent>(
      where: where?.call(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AuditEvent] by its [id] or null if no such row exists.
  Future<AuditEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    AuditEventInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AuditEvent>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AuditEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [AuditEvent]s will have their `id` fields set.
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
  Future<List<AuditEvent>> insert(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AuditEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AuditEvent] and returns the inserted row.
  ///
  /// The returned [AuditEvent] will have its `id` field set.
  Future<AuditEvent> insertRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AuditEvent]s in the list and returns the resulting rows.
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
  /// The returned [AuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> upsert(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    required _is.ColumnSelections<AuditEventTable> conflictColumns,
    _is.ColumnSelections<AuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AuditEvent>(
      rows,
      conflictColumns: conflictColumns(AuditEvent.t),
      updateColumns: updateColumns?.call(AuditEvent.t),
      updateWhere: updateWhere?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AuditEvent] and returns the resulting row.
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
  /// The returned [AuditEvent] will have its `id` field set.
  Future<AuditEvent?> upsertRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    required _is.ColumnSelections<AuditEventTable> conflictColumns,
    _is.ColumnSelections<AuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AuditEvent>(
      row,
      conflictColumns: conflictColumns(AuditEvent.t),
      updateColumns: updateColumns?.call(AuditEvent.t),
      updateWhere: updateWhere?.call(AuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> update(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.ColumnSelections<AuditEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AuditEvent>(
      rows,
      columns: columns?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AuditEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AuditEvent> updateRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.ColumnSelections<AuditEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AuditEvent>(
      row,
      columns: columns?.call(AuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuditEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AuditEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AuditEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AuditEvent>(
      id,
      columnValues: columnValues(AuditEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AuditEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AuditEvent>(
      columnValues: columnValues(AuditEvent.t.updateTable),
      where: where(AuditEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AuditEvent]s in the list and returns the deleted rows.
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
  Future<List<AuditEvent>> delete(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AuditEvent>(
      rows,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AuditEvent].
  Future<AuditEvent> deleteRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AuditEvent>(
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
  Future<List<AuditEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AuditEvent>(
      where: where(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AuditEvent>(
      where: where?.call(AuditEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AuditEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AuditEvent>(
      where: where(AuditEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AuditEventAttachRowRepository {
  const AuditEventAttachRowRepository._();

  /// Creates a relation between the given [AuditEvent] and [Household]
  /// by setting the [AuditEvent]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    AuditEvent auditEvent,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (auditEvent.id == null) {
      throw ArgumentError.notNull('auditEvent.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $auditEvent = auditEvent.copyWith(householdId: household.id);
    await session.db.updateRow<AuditEvent>(
      $auditEvent,
      columns: [AuditEvent.t.householdId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [AuditEvent] and [Member]
  /// by setting the [AuditEvent]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    AuditEvent auditEvent,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (auditEvent.id == null) {
      throw ArgumentError.notNull('auditEvent.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $auditEvent = auditEvent.copyWith(memberId: member.id);
    await session.db.updateRow<AuditEvent>(
      $auditEvent,
      columns: [AuditEvent.t.memberId],
      transaction: transaction,
    );
  }
}

class AuditEventDetachRowRepository {
  const AuditEventDetachRowRepository._();

  /// Detaches the relation between this [AuditEvent] and the [Member] set in `member`
  /// by setting the [AuditEvent]'s foreign key `memberId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> member(
    _is.DatabaseSession session,
    AuditEvent auditEvent, {
    _is.Transaction? transaction,
  }) async {
    if (auditEvent.id == null) {
      throw ArgumentError.notNull('auditEvent.id');
    }

    var $auditEvent = auditEvent.copyWith(memberId: null);
    await session.db.updateRow<AuditEvent>(
      $auditEvent,
      columns: [AuditEvent.t.memberId],
      transaction: transaction,
    );
  }
}
