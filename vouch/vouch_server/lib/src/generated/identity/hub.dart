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

/// A physical hub device (mic, VAD, TitaNet embeddings, attestation signing)
/// deployed for a household.
abstract class Hub implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Hub._({
    this.id,
    required this.householdId,
    this.household,
    required this.publicKey,
    this.lastSeen,
    required this.version,
  });

  factory Hub({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String publicKey,
    DateTime? lastSeen,
    required String version,
  }) = _HubImpl;

  factory Hub.fromJson(Map<String, dynamic> jsonSerialization) {
    return Hub(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      publicKey: jsonSerialization['publicKey'] as String,
      lastSeen: jsonSerialization['lastSeen'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeen']),
      version: jsonSerialization['version'] as String,
    );
  }

  static final t = HubTable();

  static const db = HubRepository._();

  @override
  int? id;

  int householdId;

  /// The household this hub is deployed for.
  _iyyunadd.Household? household;

  /// The hub's public key, used to verify signatures on the attestations and
  /// hub signatures it issues.
  String publicKey;

  /// The last time the hub was observed to be online.
  DateTime? lastSeen;

  /// The hub's software version string.
  String version;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Hub]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Hub copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    String? publicKey,
    DateTime? lastSeen,
    String? version,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Hub',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      'publicKey': publicKey,
      if (lastSeen != null) 'lastSeen': lastSeen?.toJson(),
      'version': version,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Hub',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      'publicKey': publicKey,
      if (lastSeen != null) 'lastSeen': lastSeen?.toJson(),
      'version': version,
    };
  }

  static HubInclude include({_iyyunadd.HouseholdInclude? household}) {
    return HubInclude._(household: household);
  }

  static HubIncludeList includeList({
    _is.WhereExpressionBuilder<HubTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    HubInclude? include,
  }) {
    return HubIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HubImpl extends Hub {
  _HubImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String publicKey,
    DateTime? lastSeen,
    required String version,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         publicKey: publicKey,
         lastSeen: lastSeen,
         version: version,
       );

  /// Returns a shallow copy of this [Hub]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Hub copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    String? publicKey,
    Object? lastSeen = _Undefined,
    String? version,
  }) {
    return Hub(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      publicKey: publicKey ?? this.publicKey,
      lastSeen: lastSeen is DateTime? ? lastSeen : this.lastSeen,
      version: version ?? this.version,
    );
  }
}

class HubUpdateTable extends _is.UpdateTable<HubTable> {
  HubUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<String, String> publicKey(String value) => _is.ColumnValue(
    table.publicKey,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> lastSeen(DateTime? value) =>
      _is.ColumnValue(
        table.lastSeen,
        value,
      );

  _is.ColumnValue<String, String> version(String value) => _is.ColumnValue(
    table.version,
    value,
  );
}

class HubTable extends _is.Table<int?> {
  HubTable({super.tableRelation}) : super(tableName: 'hub') {
    updateTable = HubUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    publicKey = _is.ColumnString(
      'publicKey',
      this,
    );
    lastSeen = _is.ColumnDateTime(
      'lastSeen',
      this,
    );
    version = _is.ColumnString(
      'version',
      this,
    );
  }

  late final HubUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this hub is deployed for.
  _iyyunadd.HouseholdTable? _household;

  /// The hub's public key, used to verify signatures on the attestations and
  /// hub signatures it issues.
  late final _is.ColumnString publicKey;

  /// The last time the hub was observed to be online.
  late final _is.ColumnDateTime lastSeen;

  /// The hub's software version string.
  late final _is.ColumnString version;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: Hub.t.householdId,
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
    publicKey,
    lastSeen,
    version,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'household') {
      return household;
    }
    return null;
  }
}

class HubInclude extends _is.IncludeObject {
  HubInclude._({_iyyunadd.HouseholdInclude? household}) {
    _household = household;
  }

  _iyyunadd.HouseholdInclude? _household;

  @override
  Map<String, _is.Include?> get includes => {'household': _household};

  @override
  _is.Table<int?> get table => Hub.t;
}

class HubIncludeList extends _is.IncludeList {
  HubIncludeList._({
    _is.WhereExpressionBuilder<HubTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Hub.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Hub.t;
}

class HubRepository {
  const HubRepository._();

  final attachRow = const HubAttachRowRepository._();

  /// Returns a list of [Hub]s matching the given query parameters.
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
  Future<List<Hub>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HubTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    _is.Transaction? transaction,
    HubInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Hub>(
      where: where?.call(Hub.t),
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Hub] matching the given query parameters.
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
  Future<Hub?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HubTable>? where,
    int? offset,
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    _is.Transaction? transaction,
    HubInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Hub>(
      where: where?.call(Hub.t),
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Hub] by its [id] or null if no such row exists.
  Future<Hub?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    HubInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Hub>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Hub]s in the list and returns the inserted rows.
  ///
  /// The returned [Hub]s will have their `id` fields set.
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
  Future<List<Hub>> insert(
    _is.DatabaseSession session,
    List<Hub> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Hub>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Hub] and returns the inserted row.
  ///
  /// The returned [Hub] will have its `id` field set.
  Future<Hub> insertRow(
    _is.DatabaseSession session,
    Hub row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Hub>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Hub]s in the list and returns the resulting rows.
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
  /// The returned [Hub]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Hub>> upsert(
    _is.DatabaseSession session,
    List<Hub> rows, {
    required _is.ColumnSelections<HubTable> conflictColumns,
    _is.ColumnSelections<HubTable>? updateColumns,
    _is.WhereExpressionBuilder<HubTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Hub>(
      rows,
      conflictColumns: conflictColumns(Hub.t),
      updateColumns: updateColumns?.call(Hub.t),
      updateWhere: updateWhere?.call(Hub.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Hub] and returns the resulting row.
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
  /// The returned [Hub] will have its `id` field set.
  Future<Hub?> upsertRow(
    _is.DatabaseSession session,
    Hub row, {
    required _is.ColumnSelections<HubTable> conflictColumns,
    _is.ColumnSelections<HubTable>? updateColumns,
    _is.WhereExpressionBuilder<HubTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Hub>(
      row,
      conflictColumns: conflictColumns(Hub.t),
      updateColumns: updateColumns?.call(Hub.t),
      updateWhere: updateWhere?.call(Hub.t),
      transaction: transaction,
    );
  }

  /// Updates all [Hub]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Hub>> update(
    _is.DatabaseSession session,
    List<Hub> rows, {
    _is.ColumnSelections<HubTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Hub>(
      rows,
      columns: columns?.call(Hub.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Hub]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Hub> updateRow(
    _is.DatabaseSession session,
    Hub row, {
    _is.ColumnSelections<HubTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Hub>(
      row,
      columns: columns?.call(Hub.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Hub] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Hub?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<HubUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Hub>(
      id,
      columnValues: columnValues(Hub.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Hub]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Hub>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<HubUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<HubTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Hub>(
      columnValues: columnValues(Hub.t.updateTable),
      where: where(Hub.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Hub]s in the list and returns the deleted rows.
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
  Future<List<Hub>> delete(
    _is.DatabaseSession session,
    List<Hub> rows, {
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Hub>(
      rows,
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Hub].
  Future<Hub> deleteRow(
    _is.DatabaseSession session,
    Hub row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Hub>(
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
  Future<List<Hub>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<HubTable> where,
    _is.OrderByBuilder<HubTable>? orderBy,
    _is.OrderByListBuilder<HubTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Hub>(
      where: where(Hub.t),
      orderBy: orderBy?.call(Hub.t),
      orderByList: orderByList?.call(Hub.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<HubTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Hub>(
      where: where?.call(Hub.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Hub] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<HubTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Hub>(
      where: where(Hub.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class HubAttachRowRepository {
  const HubAttachRowRepository._();

  /// Creates a relation between the given [Hub] and [Household]
  /// by setting the [Hub]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    Hub hub,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (hub.id == null) {
      throw ArgumentError.notNull('hub.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $hub = hub.copyWith(householdId: household.id);
    await session.db.updateRow<Hub>(
      $hub,
      columns: [Hub.t.householdId],
      transaction: transaction,
    );
  }
}
