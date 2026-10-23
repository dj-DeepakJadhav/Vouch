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
import 'package:serverpod/serverpod.dart' as _is;

/// Server-side marker + key store for a hosted "demo household" created by
/// `DemoEndpoint.start`. Its existence is the ONLY thing that makes a
/// household a demo household: `DemoEndpoint.attest` refuses any household
/// without a row here, so a real hub-paired household can never be signed
/// for by the demo path. serverOnly: never serialised to the client, so the
/// hub private key below cannot leave the server through the protocol.
abstract class DemoHousehold
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DemoHousehold._({
    this.id,
    required this.householdId,
    required this.hubId,
    required this.ownerAuthUserId,
    required this.hubPrivateKeySeed,
    required this.createdAt,
  });

  factory DemoHousehold({
    int? id,
    required int householdId,
    required int hubId,
    required String ownerAuthUserId,
    required String hubPrivateKeySeed,
    required DateTime createdAt,
  }) = _DemoHouseholdImpl;

  factory DemoHousehold.fromJson(Map<String, dynamic> jsonSerialization) {
    return DemoHousehold(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      hubId: jsonSerialization['hubId'] as int,
      ownerAuthUserId: jsonSerialization['ownerAuthUserId'] as String,
      hubPrivateKeySeed: jsonSerialization['hubPrivateKeySeed'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = DemoHouseholdTable();

  static const db = DemoHouseholdRepository._();

  @override
  int? id;

  /// The demo household this row marks.
  int householdId;

  /// The demo hub whose key [hubPrivateKeySeed] is.
  int hubId;

  /// The Serverpod auth `userIdentifier` of the caller who started it. One
  /// demo household per caller (unique), which makes `start` idempotent.
  String ownerAuthUserId;

  /// Base64 32-byte Ed25519 seed of the demo hub's signing key. Generated
  /// per household on the server and never returned by any endpoint. It
  /// can only sign for this demo hub, which only serves this demo household.
  String hubPrivateKeySeed;

  /// When the demo household was created (drives the hourly rate limit).
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DemoHousehold]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DemoHousehold copyWith({
    int? id,
    int? householdId,
    int? hubId,
    String? ownerAuthUserId,
    String? hubPrivateKeySeed,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemoHousehold',
      if (id != null) 'id': id,
      'householdId': householdId,
      'hubId': hubId,
      'ownerAuthUserId': ownerAuthUserId,
      'hubPrivateKeySeed': hubPrivateKeySeed,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DemoHouseholdInclude include() {
    return DemoHouseholdInclude._();
  }

  static DemoHouseholdIncludeList includeList({
    _is.WhereExpressionBuilder<DemoHouseholdTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    DemoHouseholdInclude? include,
  }) {
    return DemoHouseholdIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DemoHouseholdImpl extends DemoHousehold {
  _DemoHouseholdImpl({
    int? id,
    required int householdId,
    required int hubId,
    required String ownerAuthUserId,
    required String hubPrivateKeySeed,
    required DateTime createdAt,
  }) : super._(
         id: id,
         householdId: householdId,
         hubId: hubId,
         ownerAuthUserId: ownerAuthUserId,
         hubPrivateKeySeed: hubPrivateKeySeed,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DemoHousehold]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DemoHousehold copyWith({
    Object? id = _Undefined,
    int? householdId,
    int? hubId,
    String? ownerAuthUserId,
    String? hubPrivateKeySeed,
    DateTime? createdAt,
  }) {
    return DemoHousehold(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      hubId: hubId ?? this.hubId,
      ownerAuthUserId: ownerAuthUserId ?? this.ownerAuthUserId,
      hubPrivateKeySeed: hubPrivateKeySeed ?? this.hubPrivateKeySeed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DemoHouseholdUpdateTable extends _is.UpdateTable<DemoHouseholdTable> {
  DemoHouseholdUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> hubId(int value) => _is.ColumnValue(
    table.hubId,
    value,
  );

  _is.ColumnValue<String, String> ownerAuthUserId(String value) =>
      _is.ColumnValue(
        table.ownerAuthUserId,
        value,
      );

  _is.ColumnValue<String, String> hubPrivateKeySeed(String value) =>
      _is.ColumnValue(
        table.hubPrivateKeySeed,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class DemoHouseholdTable extends _is.Table<int?> {
  DemoHouseholdTable({super.tableRelation})
    : super(tableName: 'demo_household') {
    updateTable = DemoHouseholdUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    hubId = _is.ColumnInt(
      'hubId',
      this,
    );
    ownerAuthUserId = _is.ColumnString(
      'ownerAuthUserId',
      this,
    );
    hubPrivateKeySeed = _is.ColumnString(
      'hubPrivateKeySeed',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DemoHouseholdUpdateTable updateTable;

  /// The demo household this row marks.
  late final _is.ColumnInt householdId;

  /// The demo hub whose key [hubPrivateKeySeed] is.
  late final _is.ColumnInt hubId;

  /// The Serverpod auth `userIdentifier` of the caller who started it. One
  /// demo household per caller (unique), which makes `start` idempotent.
  late final _is.ColumnString ownerAuthUserId;

  /// Base64 32-byte Ed25519 seed of the demo hub's signing key. Generated
  /// per household on the server and never returned by any endpoint. It
  /// can only sign for this demo hub, which only serves this demo household.
  late final _is.ColumnString hubPrivateKeySeed;

  /// When the demo household was created (drives the hourly rate limit).
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    householdId,
    hubId,
    ownerAuthUserId,
    hubPrivateKeySeed,
    createdAt,
  ];
}

class DemoHouseholdInclude extends _is.IncludeObject {
  DemoHouseholdInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DemoHousehold.t;
}

class DemoHouseholdIncludeList extends _is.IncludeList {
  DemoHouseholdIncludeList._({
    _is.WhereExpressionBuilder<DemoHouseholdTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DemoHousehold.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DemoHousehold.t;
}

class DemoHouseholdRepository {
  const DemoHouseholdRepository._();

  /// Returns a list of [DemoHousehold]s matching the given query parameters.
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
  Future<List<DemoHousehold>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DemoHouseholdTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DemoHousehold>(
      where: where?.call(DemoHousehold.t),
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DemoHousehold] matching the given query parameters.
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
  Future<DemoHousehold?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DemoHouseholdTable>? where,
    int? offset,
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DemoHousehold>(
      where: where?.call(DemoHousehold.t),
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DemoHousehold] by its [id] or null if no such row exists.
  Future<DemoHousehold?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DemoHousehold>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DemoHousehold]s in the list and returns the inserted rows.
  ///
  /// The returned [DemoHousehold]s will have their `id` fields set.
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
  Future<List<DemoHousehold>> insert(
    _is.DatabaseSession session,
    List<DemoHousehold> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DemoHousehold>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DemoHousehold] and returns the inserted row.
  ///
  /// The returned [DemoHousehold] will have its `id` field set.
  Future<DemoHousehold> insertRow(
    _is.DatabaseSession session,
    DemoHousehold row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DemoHousehold>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DemoHousehold]s in the list and returns the resulting rows.
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
  /// The returned [DemoHousehold]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DemoHousehold>> upsert(
    _is.DatabaseSession session,
    List<DemoHousehold> rows, {
    required _is.ColumnSelections<DemoHouseholdTable> conflictColumns,
    _is.ColumnSelections<DemoHouseholdTable>? updateColumns,
    _is.WhereExpressionBuilder<DemoHouseholdTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DemoHousehold>(
      rows,
      conflictColumns: conflictColumns(DemoHousehold.t),
      updateColumns: updateColumns?.call(DemoHousehold.t),
      updateWhere: updateWhere?.call(DemoHousehold.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DemoHousehold] and returns the resulting row.
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
  /// The returned [DemoHousehold] will have its `id` field set.
  Future<DemoHousehold?> upsertRow(
    _is.DatabaseSession session,
    DemoHousehold row, {
    required _is.ColumnSelections<DemoHouseholdTable> conflictColumns,
    _is.ColumnSelections<DemoHouseholdTable>? updateColumns,
    _is.WhereExpressionBuilder<DemoHouseholdTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DemoHousehold>(
      row,
      conflictColumns: conflictColumns(DemoHousehold.t),
      updateColumns: updateColumns?.call(DemoHousehold.t),
      updateWhere: updateWhere?.call(DemoHousehold.t),
      transaction: transaction,
    );
  }

  /// Updates all [DemoHousehold]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DemoHousehold>> update(
    _is.DatabaseSession session,
    List<DemoHousehold> rows, {
    _is.ColumnSelections<DemoHouseholdTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DemoHousehold>(
      rows,
      columns: columns?.call(DemoHousehold.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DemoHousehold]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DemoHousehold> updateRow(
    _is.DatabaseSession session,
    DemoHousehold row, {
    _is.ColumnSelections<DemoHouseholdTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DemoHousehold>(
      row,
      columns: columns?.call(DemoHousehold.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DemoHousehold] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DemoHousehold?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DemoHouseholdUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DemoHousehold>(
      id,
      columnValues: columnValues(DemoHousehold.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DemoHousehold]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DemoHousehold>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DemoHouseholdUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DemoHouseholdTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DemoHousehold>(
      columnValues: columnValues(DemoHousehold.t.updateTable),
      where: where(DemoHousehold.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DemoHousehold]s in the list and returns the deleted rows.
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
  Future<List<DemoHousehold>> delete(
    _is.DatabaseSession session,
    List<DemoHousehold> rows, {
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DemoHousehold>(
      rows,
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DemoHousehold].
  Future<DemoHousehold> deleteRow(
    _is.DatabaseSession session,
    DemoHousehold row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DemoHousehold>(
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
  Future<List<DemoHousehold>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DemoHouseholdTable> where,
    _is.OrderByBuilder<DemoHouseholdTable>? orderBy,
    _is.OrderByListBuilder<DemoHouseholdTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DemoHousehold>(
      where: where(DemoHousehold.t),
      orderBy: orderBy?.call(DemoHousehold.t),
      orderByList: orderByList?.call(DemoHousehold.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DemoHouseholdTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DemoHousehold>(
      where: where?.call(DemoHousehold.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DemoHousehold] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DemoHouseholdTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DemoHousehold>(
      where: where(DemoHousehold.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
