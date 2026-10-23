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
import '../household/household.dart' as _iyyunadd;

/// A one-time, short-lived 6-digit code the hub prints (`python -m
/// vouch_hub pair`) so the household owner can link their anonymous
/// Flutter-app session to this household without ever creating a
/// password. Only the SHA-256 hash of the code is stored — the raw code
/// exists only in the hub's terminal output and the redeem request, never
/// at rest — mirroring `McpClient.tokenHash`'s treatment of bearer tokens.
abstract class PairingCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PairingCode._({
    this.id,
    required this.householdId,
    this.household,
    required this.codeHash,
    required this.ownerId,
    required this.createdAt,
    required this.expiresAt,
    this.usedAt,
  });

  factory PairingCode({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String codeHash,
    required int ownerId,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) = _PairingCodeImpl;

  factory PairingCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return PairingCode(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      codeHash: jsonSerialization['codeHash'] as String,
      ownerId: jsonSerialization['ownerId'] as int,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  static final t = PairingCodeTable();

  static const db = PairingCodeRepository._();

  @override
  int? id;

  int householdId;

  /// The household this code pairs a new owner session into.
  _iyyunadd.Household? household;

  /// SHA-256 hex digest of the raw 6-digit code.
  String codeHash;

  /// The owner `Member` whose `authUserId` gets set when this code is
  /// redeemed.
  int ownerId;

  /// When this code was created (also the hub's Ed25519-signed
  /// `capturedAt`).
  DateTime createdAt;

  /// When this code stops being redeemable (createdAt + 10 minutes).
  DateTime expiresAt;

  /// When this code was redeemed, if ever. Null while still usable.
  DateTime? usedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PairingCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PairingCode copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    String? codeHash,
    int? ownerId,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PairingCode',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      'codeHash': codeHash,
      'ownerId': ownerId,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PairingCode',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      'codeHash': codeHash,
      'ownerId': ownerId,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  static PairingCodeInclude include({_iyyunadd.HouseholdInclude? household}) {
    return PairingCodeInclude._(household: household);
  }

  static PairingCodeIncludeList includeList({
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    PairingCodeInclude? include,
  }) {
    return PairingCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PairingCodeImpl extends PairingCode {
  _PairingCodeImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String codeHash,
    required int ownerId,
    required DateTime createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         codeHash: codeHash,
         ownerId: ownerId,
         createdAt: createdAt,
         expiresAt: expiresAt,
         usedAt: usedAt,
       );

  /// Returns a shallow copy of this [PairingCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PairingCode copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    String? codeHash,
    int? ownerId,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
  }) {
    return PairingCode(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      codeHash: codeHash ?? this.codeHash,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
    );
  }
}

class PairingCodeUpdateTable extends _is.UpdateTable<PairingCodeTable> {
  PairingCodeUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<String, String> codeHash(String value) => _is.ColumnValue(
    table.codeHash,
    value,
  );

  _is.ColumnValue<int, int> ownerId(int value) => _is.ColumnValue(
    table.ownerId,
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

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );
}

class PairingCodeTable extends _is.Table<int?> {
  PairingCodeTable({super.tableRelation}) : super(tableName: 'pairing_code') {
    updateTable = PairingCodeUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    codeHash = _is.ColumnString(
      'codeHash',
      this,
    );
    ownerId = _is.ColumnInt(
      'ownerId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    usedAt = _is.ColumnDateTime(
      'usedAt',
      this,
    );
  }

  late final PairingCodeUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this code pairs a new owner session into.
  _iyyunadd.HouseholdTable? _household;

  /// SHA-256 hex digest of the raw 6-digit code.
  late final _is.ColumnString codeHash;

  /// The owner `Member` whose `authUserId` gets set when this code is
  /// redeemed.
  late final _is.ColumnInt ownerId;

  /// When this code was created (also the hub's Ed25519-signed
  /// `capturedAt`).
  late final _is.ColumnDateTime createdAt;

  /// When this code stops being redeemable (createdAt + 10 minutes).
  late final _is.ColumnDateTime expiresAt;

  /// When this code was redeemed, if ever. Null while still usable.
  late final _is.ColumnDateTime usedAt;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: PairingCode.t.householdId,
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
    codeHash,
    ownerId,
    createdAt,
    expiresAt,
    usedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'household') {
      return household;
    }
    return null;
  }
}

class PairingCodeInclude extends _is.IncludeObject {
  PairingCodeInclude._({_iyyunadd.HouseholdInclude? household}) {
    _household = household;
  }

  _iyyunadd.HouseholdInclude? _household;

  @override
  Map<String, _is.Include?> get includes => {'household': _household};

  @override
  _is.Table<int?> get table => PairingCode.t;
}

class PairingCodeIncludeList extends _is.IncludeList {
  PairingCodeIncludeList._({
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PairingCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PairingCode.t;
}

class PairingCodeRepository {
  const PairingCodeRepository._();

  final attachRow = const PairingCodeAttachRowRepository._();

  /// Returns a list of [PairingCode]s matching the given query parameters.
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
  Future<List<PairingCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    PairingCodeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PairingCode>(
      where: where?.call(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PairingCode] matching the given query parameters.
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
  Future<PairingCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    PairingCodeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PairingCode>(
      where: where?.call(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PairingCode] by its [id] or null if no such row exists.
  Future<PairingCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    PairingCodeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PairingCode>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PairingCode]s in the list and returns the inserted rows.
  ///
  /// The returned [PairingCode]s will have their `id` fields set.
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
  Future<List<PairingCode>> insert(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PairingCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PairingCode] and returns the inserted row.
  ///
  /// The returned [PairingCode] will have its `id` field set.
  Future<PairingCode> insertRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PairingCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PairingCode]s in the list and returns the resulting rows.
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
  /// The returned [PairingCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> upsert(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    required _is.ColumnSelections<PairingCodeTable> conflictColumns,
    _is.ColumnSelections<PairingCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<PairingCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PairingCode>(
      rows,
      conflictColumns: conflictColumns(PairingCode.t),
      updateColumns: updateColumns?.call(PairingCode.t),
      updateWhere: updateWhere?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PairingCode] and returns the resulting row.
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
  /// The returned [PairingCode] will have its `id` field set.
  Future<PairingCode?> upsertRow(
    _is.DatabaseSession session,
    PairingCode row, {
    required _is.ColumnSelections<PairingCodeTable> conflictColumns,
    _is.ColumnSelections<PairingCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<PairingCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PairingCode>(
      row,
      conflictColumns: conflictColumns(PairingCode.t),
      updateColumns: updateColumns?.call(PairingCode.t),
      updateWhere: updateWhere?.call(PairingCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [PairingCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> update(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.ColumnSelections<PairingCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PairingCode>(
      rows,
      columns: columns?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PairingCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PairingCode> updateRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.ColumnSelections<PairingCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PairingCode>(
      row,
      columns: columns?.call(PairingCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PairingCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PairingCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PairingCodeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PairingCode>(
      id,
      columnValues: columnValues(PairingCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PairingCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PairingCodeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PairingCode>(
      columnValues: columnValues(PairingCode.t.updateTable),
      where: where(PairingCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PairingCode]s in the list and returns the deleted rows.
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
  Future<List<PairingCode>> delete(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PairingCode>(
      rows,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PairingCode].
  Future<PairingCode> deleteRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PairingCode>(
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
  Future<List<PairingCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PairingCode>(
      where: where(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PairingCode>(
      where: where?.call(PairingCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PairingCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PairingCode>(
      where: where(PairingCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PairingCodeAttachRowRepository {
  const PairingCodeAttachRowRepository._();

  /// Creates a relation between the given [PairingCode] and [Household]
  /// by setting the [PairingCode]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    PairingCode pairingCode,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (pairingCode.id == null) {
      throw ArgumentError.notNull('pairingCode.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $pairingCode = pairingCode.copyWith(householdId: household.id);
    await session.db.updateRow<PairingCode>(
      $pairingCode,
      columns: [PairingCode.t.householdId],
      transaction: transaction,
    );
  }
}
