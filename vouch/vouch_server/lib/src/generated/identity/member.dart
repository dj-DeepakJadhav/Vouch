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
import '../enums/member_role.dart' as _iw6qhlck;
import '../enums/member_status.dart' as _i7h4j7gq;
import '../household/household.dart' as _iyyunadd;

/// A person belonging to a household who can be voice-enrolled and issued
/// attestations.
abstract class Member implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Member._({
    this.id,
    required this.householdId,
    this.household,
    required this.displayName,
    required this.role,
    required this.status,
    this.authUserId,
  });

  factory Member({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String displayName,
    required _iw6qhlck.MemberRole role,
    required _i7h4j7gq.MemberStatus status,
    String? authUserId,
  }) = _MemberImpl;

  factory Member.fromJson(Map<String, dynamic> jsonSerialization) {
    return Member(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      role: _iw6qhlck.MemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: _i7h4j7gq.MemberStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      authUserId: jsonSerialization['authUserId'] as String?,
    );
  }

  static final t = MemberTable();

  static const db = MemberRepository._();

  @override
  int? id;

  int householdId;

  /// The household this member belongs to.
  _iyyunadd.Household? household;

  /// The member's display name, shown in admin UI and audit logs.
  String displayName;

  /// The member's role within the household.
  _iw6qhlck.MemberRole role;

  /// The current lifecycle status of the member's enrolment.
  _i7h4j7gq.MemberStatus status;

  /// The Serverpod auth `userIdentifier` (UUID string) of the signed-in
  /// user this member corresponds to, if this member has a linked login
  /// (e.g. the household owner, who signs in to the Flutter admin app).
  /// Null for members with no login of their own (e.g. a child who is
  /// never expected to sign in). Used to resolve `session.authenticated`
  /// to a `Member` row for owner-only authorization checks (see
  /// ApprovalEndpoint).
  String? authUserId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Member copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    String? displayName,
    _iw6qhlck.MemberRole? role,
    _i7h4j7gq.MemberStatus? status,
    String? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'status': status.toJson(),
      if (authUserId != null) 'authUserId': authUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      'displayName': displayName,
      'role': role.toJson(),
      'status': status.toJson(),
      if (authUserId != null) 'authUserId': authUserId,
    };
  }

  static MemberInclude include({_iyyunadd.HouseholdInclude? household}) {
    return MemberInclude._(household: household);
  }

  static MemberIncludeList includeList({
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    MemberInclude? include,
  }) {
    return MemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberImpl extends Member {
  _MemberImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String displayName,
    required _iw6qhlck.MemberRole role,
    required _i7h4j7gq.MemberStatus status,
    String? authUserId,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         displayName: displayName,
         role: role,
         status: status,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Member copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    String? displayName,
    _iw6qhlck.MemberRole? role,
    _i7h4j7gq.MemberStatus? status,
    Object? authUserId = _Undefined,
  }) {
    return Member(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      authUserId: authUserId is String? ? authUserId : this.authUserId,
    );
  }
}

class MemberUpdateTable extends _is.UpdateTable<MemberTable> {
  MemberUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<_iw6qhlck.MemberRole, _iw6qhlck.MemberRole> role(
    _iw6qhlck.MemberRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<_i7h4j7gq.MemberStatus, _i7h4j7gq.MemberStatus> status(
    _i7h4j7gq.MemberStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<String, String> authUserId(String? value) => _is.ColumnValue(
    table.authUserId,
    value,
  );
}

class MemberTable extends _is.Table<int?> {
  MemberTable({super.tableRelation}) : super(tableName: 'member') {
    updateTable = MemberUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    authUserId = _is.ColumnString(
      'authUserId',
      this,
    );
  }

  late final MemberUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this member belongs to.
  _iyyunadd.HouseholdTable? _household;

  /// The member's display name, shown in admin UI and audit logs.
  late final _is.ColumnString displayName;

  /// The member's role within the household.
  late final _is.ColumnEnum<_iw6qhlck.MemberRole> role;

  /// The current lifecycle status of the member's enrolment.
  late final _is.ColumnEnum<_i7h4j7gq.MemberStatus> status;

  /// The Serverpod auth `userIdentifier` (UUID string) of the signed-in
  /// user this member corresponds to, if this member has a linked login
  /// (e.g. the household owner, who signs in to the Flutter admin app).
  /// Null for members with no login of their own (e.g. a child who is
  /// never expected to sign in). Used to resolve `session.authenticated`
  /// to a `Member` row for owner-only authorization checks (see
  /// ApprovalEndpoint).
  late final _is.ColumnString authUserId;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: Member.t.householdId,
      foreignField: _iyyunadd.Household.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iyyunadd.HouseholdTable(tableRelation: foreignTableRelation),
    );
    return _household!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    displayName,
    role,
    status,
    authUserId,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'household') {
      return household;
    }
    return null;
  }
}

class MemberInclude extends _is.IncludeObject {
  MemberInclude._({_iyyunadd.HouseholdInclude? household}) {
    _household = household;
  }

  _iyyunadd.HouseholdInclude? _household;

  @override
  Map<String, _is.Include?> get includes => {'household': _household};

  @override
  _is.Table<int?> get table => Member.t;
}

class MemberIncludeList extends _is.IncludeList {
  MemberIncludeList._({
    _is.WhereExpressionBuilder<MemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Member.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Member.t;
}

class MemberRepository {
  const MemberRepository._();

  final attachRow = const MemberAttachRowRepository._();

  /// Returns a list of [Member]s matching the given query parameters.
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
  Future<List<Member>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Member>(
      where: where?.call(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Member] matching the given query parameters.
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
  Future<Member?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Member>(
      where: where?.call(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Member] by its [id] or null if no such row exists.
  Future<Member?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Member>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Member]s in the list and returns the inserted rows.
  ///
  /// The returned [Member]s will have their `id` fields set.
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
  Future<List<Member>> insert(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Member>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Member] and returns the inserted row.
  ///
  /// The returned [Member] will have its `id` field set.
  Future<Member> insertRow(
    _is.DatabaseSession session,
    Member row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Member>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Member]s in the list and returns the resulting rows.
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
  /// The returned [Member]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> upsert(
    _is.DatabaseSession session,
    List<Member> rows, {
    required _is.ColumnSelections<MemberTable> conflictColumns,
    _is.ColumnSelections<MemberTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Member>(
      rows,
      conflictColumns: conflictColumns(Member.t),
      updateColumns: updateColumns?.call(Member.t),
      updateWhere: updateWhere?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Member] and returns the resulting row.
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
  /// The returned [Member] will have its `id` field set.
  Future<Member?> upsertRow(
    _is.DatabaseSession session,
    Member row, {
    required _is.ColumnSelections<MemberTable> conflictColumns,
    _is.ColumnSelections<MemberTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Member>(
      row,
      conflictColumns: conflictColumns(Member.t),
      updateColumns: updateColumns?.call(Member.t),
      updateWhere: updateWhere?.call(Member.t),
      transaction: transaction,
    );
  }

  /// Updates all [Member]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> update(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.ColumnSelections<MemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Member>(
      rows,
      columns: columns?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Member]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Member> updateRow(
    _is.DatabaseSession session,
    Member row, {
    _is.ColumnSelections<MemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Member>(
      row,
      columns: columns?.call(Member.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Member] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Member?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Member>(
      id,
      columnValues: columnValues(Member.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Member]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Member>(
      columnValues: columnValues(Member.t.updateTable),
      where: where(Member.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Member]s in the list and returns the deleted rows.
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
  Future<List<Member>> delete(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Member>(
      rows,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Member].
  Future<Member> deleteRow(
    _is.DatabaseSession session,
    Member row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Member>(
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
  Future<List<Member>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberTable> where,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Member>(
      where: where(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Member>(
      where: where?.call(Member.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Member] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Member>(
      where: where(Member.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MemberAttachRowRepository {
  const MemberAttachRowRepository._();

  /// Creates a relation between the given [Member] and [Household]
  /// by setting the [Member]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    Member member,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $member = member.copyWith(householdId: household.id);
    await session.db.updateRow<Member>(
      $member,
      columns: [Member.t.householdId],
      transaction: transaction,
    );
  }
}
