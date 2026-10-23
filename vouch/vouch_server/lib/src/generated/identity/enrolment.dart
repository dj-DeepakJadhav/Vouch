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
import '../identity/hub.dart' as _i52s3kbg;
import '../identity/member.dart' as _ie1reufq;

/// A voice enrolment linking a member to a hub. Records only an opaque
/// pointer to the voiceprint, never the biometric data itself.
abstract class Enrolment
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Enrolment._({
    this.id,
    required this.memberId,
    this.member,
    required this.hubId,
    this.hub,
    required this.embeddingRef,
    required this.qualityScore,
    required this.sampleCount,
    required this.enrolledAt,
    this.revokedAt,
  });

  factory Enrolment({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required int hubId,
    _i52s3kbg.Hub? hub,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime enrolledAt,
    DateTime? revokedAt,
  }) = _EnrolmentImpl;

  factory Enrolment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Enrolment(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      hubId: jsonSerialization['hubId'] as int,
      hub: jsonSerialization['hub'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_i52s3kbg.Hub>(
              jsonSerialization['hub'],
            ),
      embeddingRef: jsonSerialization['embeddingRef'] as String,
      qualityScore: (jsonSerialization['qualityScore'] as num).toDouble(),
      sampleCount: jsonSerialization['sampleCount'] as int,
      enrolledAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['enrolledAt'],
      ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = EnrolmentTable();

  static const db = EnrolmentRepository._();

  @override
  int? id;

  int memberId;

  /// The member this enrolment belongs to.
  _ie1reufq.Member? member;

  int hubId;

  /// The hub this enrolment was captured on and is stored against.
  _i52s3kbg.Hub? hub;

  /// Opaque pointer to the enrolled voiceprint, kept on the hub. This is
  /// NEVER a biometric vector or embedding — Serverpod stores only a
  /// reference, and even full database compromise yields no biometric data
  /// (see VOUCH-DESIGN.md §8).
  String embeddingRef;

  /// Quality score of the enrolment sample(s), used to decide whether
  /// re-enrolment is needed.
  double qualityScore;

  /// Number of voice samples used to build this enrolment.
  int sampleCount;

  /// When the enrolment was completed.
  DateTime enrolledAt;

  /// When the enrolment was revoked, if it has been.
  DateTime? revokedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Enrolment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Enrolment copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    int? hubId,
    _i52s3kbg.Hub? hub,
    String? embeddingRef,
    double? qualityScore,
    int? sampleCount,
    DateTime? enrolledAt,
    DateTime? revokedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Enrolment',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'hubId': hubId,
      if (hub != null) 'hub': hub?.toJson(),
      'embeddingRef': embeddingRef,
      'qualityScore': qualityScore,
      'sampleCount': sampleCount,
      'enrolledAt': enrolledAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Enrolment',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'hubId': hubId,
      if (hub != null) 'hub': hub?.toJsonForProtocol(),
      'embeddingRef': embeddingRef,
      'qualityScore': qualityScore,
      'sampleCount': sampleCount,
      'enrolledAt': enrolledAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  static EnrolmentInclude include({
    _ie1reufq.MemberInclude? member,
    _i52s3kbg.HubInclude? hub,
  }) {
    return EnrolmentInclude._(
      member: member,
      hub: hub,
    );
  }

  static EnrolmentIncludeList includeList({
    _is.WhereExpressionBuilder<EnrolmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    EnrolmentInclude? include,
  }) {
    return EnrolmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnrolmentImpl extends Enrolment {
  _EnrolmentImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required int hubId,
    _i52s3kbg.Hub? hub,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime enrolledAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         hubId: hubId,
         hub: hub,
         embeddingRef: embeddingRef,
         qualityScore: qualityScore,
         sampleCount: sampleCount,
         enrolledAt: enrolledAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [Enrolment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Enrolment copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    int? hubId,
    Object? hub = _Undefined,
    String? embeddingRef,
    double? qualityScore,
    int? sampleCount,
    DateTime? enrolledAt,
    Object? revokedAt = _Undefined,
  }) {
    return Enrolment(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      hubId: hubId ?? this.hubId,
      hub: hub is _i52s3kbg.Hub? ? hub : this.hub?.copyWith(),
      embeddingRef: embeddingRef ?? this.embeddingRef,
      qualityScore: qualityScore ?? this.qualityScore,
      sampleCount: sampleCount ?? this.sampleCount,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}

class EnrolmentUpdateTable extends _is.UpdateTable<EnrolmentTable> {
  EnrolmentUpdateTable(super.table);

  _is.ColumnValue<int, int> memberId(int value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<int, int> hubId(int value) => _is.ColumnValue(
    table.hubId,
    value,
  );

  _is.ColumnValue<String, String> embeddingRef(String value) => _is.ColumnValue(
    table.embeddingRef,
    value,
  );

  _is.ColumnValue<double, double> qualityScore(double value) => _is.ColumnValue(
    table.qualityScore,
    value,
  );

  _is.ColumnValue<int, int> sampleCount(int value) => _is.ColumnValue(
    table.sampleCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> enrolledAt(DateTime value) =>
      _is.ColumnValue(
        table.enrolledAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class EnrolmentTable extends _is.Table<int?> {
  EnrolmentTable({super.tableRelation}) : super(tableName: 'enrolment') {
    updateTable = EnrolmentUpdateTable(this);
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    hubId = _is.ColumnInt(
      'hubId',
      this,
    );
    embeddingRef = _is.ColumnString(
      'embeddingRef',
      this,
    );
    qualityScore = _is.ColumnDouble(
      'qualityScore',
      this,
    );
    sampleCount = _is.ColumnInt(
      'sampleCount',
      this,
    );
    enrolledAt = _is.ColumnDateTime(
      'enrolledAt',
      this,
    );
    revokedAt = _is.ColumnDateTime(
      'revokedAt',
      this,
    );
  }

  late final EnrolmentUpdateTable updateTable;

  late final _is.ColumnInt memberId;

  /// The member this enrolment belongs to.
  _ie1reufq.MemberTable? _member;

  late final _is.ColumnInt hubId;

  /// The hub this enrolment was captured on and is stored against.
  _i52s3kbg.HubTable? _hub;

  /// Opaque pointer to the enrolled voiceprint, kept on the hub. This is
  /// NEVER a biometric vector or embedding — Serverpod stores only a
  /// reference, and even full database compromise yields no biometric data
  /// (see VOUCH-DESIGN.md §8).
  late final _is.ColumnString embeddingRef;

  /// Quality score of the enrolment sample(s), used to decide whether
  /// re-enrolment is needed.
  late final _is.ColumnDouble qualityScore;

  /// Number of voice samples used to build this enrolment.
  late final _is.ColumnInt sampleCount;

  /// When the enrolment was completed.
  late final _is.ColumnDateTime enrolledAt;

  /// When the enrolment was revoked, if it has been.
  late final _is.ColumnDateTime revokedAt;

  _ie1reufq.MemberTable get member {
    if (_member != null) return _member!;
    _member = _is.createRelationTable(
      relationFieldName: 'member',
      field: Enrolment.t.memberId,
      foreignField: _ie1reufq.Member.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ie1reufq.MemberTable(tableRelation: foreignTableRelation),
    );
    return _member!;
  }

  _i52s3kbg.HubTable get hub {
    if (_hub != null) return _hub!;
    _hub = _is.createRelationTable(
      relationFieldName: 'hub',
      field: Enrolment.t.hubId,
      foreignField: _i52s3kbg.Hub.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i52s3kbg.HubTable(tableRelation: foreignTableRelation),
    );
    return _hub!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    memberId,
    hubId,
    embeddingRef,
    qualityScore,
    sampleCount,
    enrolledAt,
    revokedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'member') {
      return member;
    }
    if (relationField == 'hub') {
      return hub;
    }
    return null;
  }
}

class EnrolmentInclude extends _is.IncludeObject {
  EnrolmentInclude._({
    _ie1reufq.MemberInclude? member,
    _i52s3kbg.HubInclude? hub,
  }) {
    _member = member;
    _hub = hub;
  }

  _ie1reufq.MemberInclude? _member;

  _i52s3kbg.HubInclude? _hub;

  @override
  Map<String, _is.Include?> get includes => {
    'member': _member,
    'hub': _hub,
  };

  @override
  _is.Table<int?> get table => Enrolment.t;
}

class EnrolmentIncludeList extends _is.IncludeList {
  EnrolmentIncludeList._({
    _is.WhereExpressionBuilder<EnrolmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Enrolment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Enrolment.t;
}

class EnrolmentRepository {
  const EnrolmentRepository._();

  final attachRow = const EnrolmentAttachRowRepository._();

  /// Returns a list of [Enrolment]s matching the given query parameters.
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
  Future<List<Enrolment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnrolmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    _is.Transaction? transaction,
    EnrolmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Enrolment>(
      where: where?.call(Enrolment.t),
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Enrolment] matching the given query parameters.
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
  Future<Enrolment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnrolmentTable>? where,
    int? offset,
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    _is.Transaction? transaction,
    EnrolmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Enrolment>(
      where: where?.call(Enrolment.t),
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Enrolment] by its [id] or null if no such row exists.
  Future<Enrolment?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    EnrolmentInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Enrolment>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Enrolment]s in the list and returns the inserted rows.
  ///
  /// The returned [Enrolment]s will have their `id` fields set.
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
  Future<List<Enrolment>> insert(
    _is.DatabaseSession session,
    List<Enrolment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Enrolment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Enrolment] and returns the inserted row.
  ///
  /// The returned [Enrolment] will have its `id` field set.
  Future<Enrolment> insertRow(
    _is.DatabaseSession session,
    Enrolment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Enrolment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Enrolment]s in the list and returns the resulting rows.
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
  /// The returned [Enrolment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Enrolment>> upsert(
    _is.DatabaseSession session,
    List<Enrolment> rows, {
    required _is.ColumnSelections<EnrolmentTable> conflictColumns,
    _is.ColumnSelections<EnrolmentTable>? updateColumns,
    _is.WhereExpressionBuilder<EnrolmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Enrolment>(
      rows,
      conflictColumns: conflictColumns(Enrolment.t),
      updateColumns: updateColumns?.call(Enrolment.t),
      updateWhere: updateWhere?.call(Enrolment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Enrolment] and returns the resulting row.
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
  /// The returned [Enrolment] will have its `id` field set.
  Future<Enrolment?> upsertRow(
    _is.DatabaseSession session,
    Enrolment row, {
    required _is.ColumnSelections<EnrolmentTable> conflictColumns,
    _is.ColumnSelections<EnrolmentTable>? updateColumns,
    _is.WhereExpressionBuilder<EnrolmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Enrolment>(
      row,
      conflictColumns: conflictColumns(Enrolment.t),
      updateColumns: updateColumns?.call(Enrolment.t),
      updateWhere: updateWhere?.call(Enrolment.t),
      transaction: transaction,
    );
  }

  /// Updates all [Enrolment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Enrolment>> update(
    _is.DatabaseSession session,
    List<Enrolment> rows, {
    _is.ColumnSelections<EnrolmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Enrolment>(
      rows,
      columns: columns?.call(Enrolment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Enrolment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Enrolment> updateRow(
    _is.DatabaseSession session,
    Enrolment row, {
    _is.ColumnSelections<EnrolmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Enrolment>(
      row,
      columns: columns?.call(Enrolment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Enrolment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Enrolment?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<EnrolmentUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Enrolment>(
      id,
      columnValues: columnValues(Enrolment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Enrolment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Enrolment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<EnrolmentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<EnrolmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Enrolment>(
      columnValues: columnValues(Enrolment.t.updateTable),
      where: where(Enrolment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Enrolment]s in the list and returns the deleted rows.
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
  Future<List<Enrolment>> delete(
    _is.DatabaseSession session,
    List<Enrolment> rows, {
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Enrolment>(
      rows,
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Enrolment].
  Future<Enrolment> deleteRow(
    _is.DatabaseSession session,
    Enrolment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Enrolment>(
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
  Future<List<Enrolment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EnrolmentTable> where,
    _is.OrderByBuilder<EnrolmentTable>? orderBy,
    _is.OrderByListBuilder<EnrolmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Enrolment>(
      where: where(Enrolment.t),
      orderBy: orderBy?.call(Enrolment.t),
      orderByList: orderByList?.call(Enrolment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<EnrolmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Enrolment>(
      where: where?.call(Enrolment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Enrolment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<EnrolmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Enrolment>(
      where: where(Enrolment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class EnrolmentAttachRowRepository {
  const EnrolmentAttachRowRepository._();

  /// Creates a relation between the given [Enrolment] and [Member]
  /// by setting the [Enrolment]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    Enrolment enrolment,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (enrolment.id == null) {
      throw ArgumentError.notNull('enrolment.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $enrolment = enrolment.copyWith(memberId: member.id);
    await session.db.updateRow<Enrolment>(
      $enrolment,
      columns: [Enrolment.t.memberId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [Enrolment] and [Hub]
  /// by setting the [Enrolment]'s foreign key `hubId` to refer to the [Hub].
  Future<void> hub(
    _is.DatabaseSession session,
    Enrolment enrolment,
    _i52s3kbg.Hub hub, {
    _is.Transaction? transaction,
  }) async {
    if (enrolment.id == null) {
      throw ArgumentError.notNull('enrolment.id');
    }
    if (hub.id == null) {
      throw ArgumentError.notNull('hub.id');
    }

    var $enrolment = enrolment.copyWith(hubId: hub.id);
    await session.db.updateRow<Enrolment>(
      $enrolment,
      columns: [Enrolment.t.hubId],
      transaction: transaction,
    );
  }
}
