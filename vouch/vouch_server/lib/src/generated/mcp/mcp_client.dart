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

/// A bearer-token credential authorizing an MCP client (e.g. an Alexa+
/// skill instance) to call the MCP server (POST /mcp) on behalf of one
/// household. The raw token is issued out-of-band and never stored; only
/// its SHA-256 hash is kept, so a database compromise does not disclose
/// usable credentials.
abstract class McpClient
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  McpClient._({
    this.id,
    required this.householdId,
    this.household,
    required this.tokenHash,
    required this.label,
    required this.createdAt,
    required this.revoked,
  });

  factory McpClient({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String tokenHash,
    required String label,
    required DateTime createdAt,
    required bool revoked,
  }) = _McpClientImpl;

  factory McpClient.fromJson(Map<String, dynamic> jsonSerialization) {
    return McpClient(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      tokenHash: jsonSerialization['tokenHash'] as String,
      label: jsonSerialization['label'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revoked: _is.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
    );
  }

  static final t = McpClientTable();

  static const db = McpClientRepository._();

  @override
  int? id;

  int householdId;

  /// The household this token authorizes access to.
  _iyyunadd.Household? household;

  /// SHA-256 hex digest of the raw bearer token. Looked up directly (the
  /// digest is already uniformly distributed, so no additional salt/pepper
  /// is needed the way a low-entropy password would require).
  String tokenHash;

  /// Human-readable label for this credential (e.g. "Alexa+ skill —
  /// production"), shown in admin UI.
  String label;

  /// When this credential was issued.
  DateTime createdAt;

  /// Whether this credential has been revoked. Revoked tokens are rejected
  /// even if otherwise well-formed and unexpired (tokens do not expire on
  /// their own).
  bool revoked;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [McpClient]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  McpClient copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    String? tokenHash,
    String? label,
    DateTime? createdAt,
    bool? revoked,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'McpClient',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      'tokenHash': tokenHash,
      'label': label,
      'createdAt': createdAt.toJson(),
      'revoked': revoked,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'McpClient',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      'tokenHash': tokenHash,
      'label': label,
      'createdAt': createdAt.toJson(),
      'revoked': revoked,
    };
  }

  static McpClientInclude include({_iyyunadd.HouseholdInclude? household}) {
    return McpClientInclude._(household: household);
  }

  static McpClientIncludeList includeList({
    _is.WhereExpressionBuilder<McpClientTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    McpClientInclude? include,
  }) {
    return McpClientIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _McpClientImpl extends McpClient {
  _McpClientImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String tokenHash,
    required String label,
    required DateTime createdAt,
    required bool revoked,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         tokenHash: tokenHash,
         label: label,
         createdAt: createdAt,
         revoked: revoked,
       );

  /// Returns a shallow copy of this [McpClient]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  McpClient copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    String? tokenHash,
    String? label,
    DateTime? createdAt,
    bool? revoked,
  }) {
    return McpClient(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      tokenHash: tokenHash ?? this.tokenHash,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      revoked: revoked ?? this.revoked,
    );
  }
}

class McpClientUpdateTable extends _is.UpdateTable<McpClientTable> {
  McpClientUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<String, String> label(String value) => _is.ColumnValue(
    table.label,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<bool, bool> revoked(bool value) => _is.ColumnValue(
    table.revoked,
    value,
  );
}

class McpClientTable extends _is.Table<int?> {
  McpClientTable({super.tableRelation}) : super(tableName: 'mcp_client') {
    updateTable = McpClientUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    tokenHash = _is.ColumnString(
      'tokenHash',
      this,
    );
    label = _is.ColumnString(
      'label',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    revoked = _is.ColumnBool(
      'revoked',
      this,
    );
  }

  late final McpClientUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this token authorizes access to.
  _iyyunadd.HouseholdTable? _household;

  /// SHA-256 hex digest of the raw bearer token. Looked up directly (the
  /// digest is already uniformly distributed, so no additional salt/pepper
  /// is needed the way a low-entropy password would require).
  late final _is.ColumnString tokenHash;

  /// Human-readable label for this credential (e.g. "Alexa+ skill —
  /// production"), shown in admin UI.
  late final _is.ColumnString label;

  /// When this credential was issued.
  late final _is.ColumnDateTime createdAt;

  /// Whether this credential has been revoked. Revoked tokens are rejected
  /// even if otherwise well-formed and unexpired (tokens do not expire on
  /// their own).
  late final _is.ColumnBool revoked;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: McpClient.t.householdId,
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
    tokenHash,
    label,
    createdAt,
    revoked,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'household') {
      return household;
    }
    return null;
  }
}

class McpClientInclude extends _is.IncludeObject {
  McpClientInclude._({_iyyunadd.HouseholdInclude? household}) {
    _household = household;
  }

  _iyyunadd.HouseholdInclude? _household;

  @override
  Map<String, _is.Include?> get includes => {'household': _household};

  @override
  _is.Table<int?> get table => McpClient.t;
}

class McpClientIncludeList extends _is.IncludeList {
  McpClientIncludeList._({
    _is.WhereExpressionBuilder<McpClientTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(McpClient.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => McpClient.t;
}

class McpClientRepository {
  const McpClientRepository._();

  final attachRow = const McpClientAttachRowRepository._();

  /// Returns a list of [McpClient]s matching the given query parameters.
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
  Future<List<McpClient>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<McpClientTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    _is.Transaction? transaction,
    McpClientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<McpClient>(
      where: where?.call(McpClient.t),
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [McpClient] matching the given query parameters.
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
  Future<McpClient?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<McpClientTable>? where,
    int? offset,
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    _is.Transaction? transaction,
    McpClientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<McpClient>(
      where: where?.call(McpClient.t),
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [McpClient] by its [id] or null if no such row exists.
  Future<McpClient?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    McpClientInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<McpClient>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [McpClient]s in the list and returns the inserted rows.
  ///
  /// The returned [McpClient]s will have their `id` fields set.
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
  Future<List<McpClient>> insert(
    _is.DatabaseSession session,
    List<McpClient> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<McpClient>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [McpClient] and returns the inserted row.
  ///
  /// The returned [McpClient] will have its `id` field set.
  Future<McpClient> insertRow(
    _is.DatabaseSession session,
    McpClient row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<McpClient>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [McpClient]s in the list and returns the resulting rows.
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
  /// The returned [McpClient]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<McpClient>> upsert(
    _is.DatabaseSession session,
    List<McpClient> rows, {
    required _is.ColumnSelections<McpClientTable> conflictColumns,
    _is.ColumnSelections<McpClientTable>? updateColumns,
    _is.WhereExpressionBuilder<McpClientTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<McpClient>(
      rows,
      conflictColumns: conflictColumns(McpClient.t),
      updateColumns: updateColumns?.call(McpClient.t),
      updateWhere: updateWhere?.call(McpClient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [McpClient] and returns the resulting row.
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
  /// The returned [McpClient] will have its `id` field set.
  Future<McpClient?> upsertRow(
    _is.DatabaseSession session,
    McpClient row, {
    required _is.ColumnSelections<McpClientTable> conflictColumns,
    _is.ColumnSelections<McpClientTable>? updateColumns,
    _is.WhereExpressionBuilder<McpClientTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<McpClient>(
      row,
      conflictColumns: conflictColumns(McpClient.t),
      updateColumns: updateColumns?.call(McpClient.t),
      updateWhere: updateWhere?.call(McpClient.t),
      transaction: transaction,
    );
  }

  /// Updates all [McpClient]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<McpClient>> update(
    _is.DatabaseSession session,
    List<McpClient> rows, {
    _is.ColumnSelections<McpClientTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<McpClient>(
      rows,
      columns: columns?.call(McpClient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [McpClient]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<McpClient> updateRow(
    _is.DatabaseSession session,
    McpClient row, {
    _is.ColumnSelections<McpClientTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<McpClient>(
      row,
      columns: columns?.call(McpClient.t),
      transaction: transaction,
    );
  }

  /// Updates a single [McpClient] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<McpClient?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<McpClientUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<McpClient>(
      id,
      columnValues: columnValues(McpClient.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [McpClient]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<McpClient>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<McpClientUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<McpClientTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<McpClient>(
      columnValues: columnValues(McpClient.t.updateTable),
      where: where(McpClient.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [McpClient]s in the list and returns the deleted rows.
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
  Future<List<McpClient>> delete(
    _is.DatabaseSession session,
    List<McpClient> rows, {
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<McpClient>(
      rows,
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [McpClient].
  Future<McpClient> deleteRow(
    _is.DatabaseSession session,
    McpClient row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<McpClient>(
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
  Future<List<McpClient>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<McpClientTable> where,
    _is.OrderByBuilder<McpClientTable>? orderBy,
    _is.OrderByListBuilder<McpClientTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<McpClient>(
      where: where(McpClient.t),
      orderBy: orderBy?.call(McpClient.t),
      orderByList: orderByList?.call(McpClient.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<McpClientTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<McpClient>(
      where: where?.call(McpClient.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [McpClient] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<McpClientTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<McpClient>(
      where: where(McpClient.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class McpClientAttachRowRepository {
  const McpClientAttachRowRepository._();

  /// Creates a relation between the given [McpClient] and [Household]
  /// by setting the [McpClient]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    McpClient mcpClient,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (mcpClient.id == null) {
      throw ArgumentError.notNull('mcpClient.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $mcpClient = mcpClient.copyWith(householdId: household.id);
    await session.db.updateRow<McpClient>(
      $mcpClient,
      columns: [McpClient.t.householdId],
      transaction: transaction,
    );
  }
}
