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
import '../enums/trust_tier.dart' as _i6oty1c9;

/// A cached risk classification for an MCP tool the household has no
/// explicit rule for and that has no built-in default tier (see
/// `ToolRiskClassifier` and `PolicyEngine`). Computed once (owner-triggered,
/// via `RulesEndpoint.classifyTool`) and reused thereafter rather than
/// calling Nemotron on every guard evaluation.
abstract class ToolClassification
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ToolClassification._({
    this.id,
    required this.toolName,
    required this.tier,
    required this.reason,
    required this.model,
    required this.createdAt,
  });

  factory ToolClassification({
    int? id,
    required String toolName,
    required _i6oty1c9.TrustTier tier,
    required String reason,
    required String model,
    required DateTime createdAt,
  }) = _ToolClassificationImpl;

  factory ToolClassification.fromJson(Map<String, dynamic> jsonSerialization) {
    return ToolClassification(
      id: jsonSerialization['id'] as int?,
      toolName: jsonSerialization['toolName'] as String,
      tier: _i6oty1c9.TrustTier.fromJson((jsonSerialization['tier'] as String)),
      reason: jsonSerialization['reason'] as String,
      model: jsonSerialization['model'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = ToolClassificationTable();

  static const db = ToolClassificationRepository._();

  @override
  int? id;

  /// The tool name this classification applies to (global — tool names are
  /// not household-scoped, since the MCP tool catalogue is shared).
  String toolName;

  /// The minimum trust tier this tool was classified as requiring.
  _i6oty1c9.TrustTier tier;

  /// Plain-English reason for the classification, from the model.
  String reason;

  /// The model name that produced this classification.
  String model;

  /// When this classification was computed.
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ToolClassification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ToolClassification copyWith({
    int? id,
    String? toolName,
    _i6oty1c9.TrustTier? tier,
    String? reason,
    String? model,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ToolClassification',
      if (id != null) 'id': id,
      'toolName': toolName,
      'tier': tier.toJson(),
      'reason': reason,
      'model': model,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ToolClassification',
      if (id != null) 'id': id,
      'toolName': toolName,
      'tier': tier.toJson(),
      'reason': reason,
      'model': model,
      'createdAt': createdAt.toJson(),
    };
  }

  static ToolClassificationInclude include() {
    return ToolClassificationInclude._();
  }

  static ToolClassificationIncludeList includeList({
    _is.WhereExpressionBuilder<ToolClassificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    ToolClassificationInclude? include,
  }) {
    return ToolClassificationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ToolClassificationImpl extends ToolClassification {
  _ToolClassificationImpl({
    int? id,
    required String toolName,
    required _i6oty1c9.TrustTier tier,
    required String reason,
    required String model,
    required DateTime createdAt,
  }) : super._(
         id: id,
         toolName: toolName,
         tier: tier,
         reason: reason,
         model: model,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ToolClassification]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ToolClassification copyWith({
    Object? id = _Undefined,
    String? toolName,
    _i6oty1c9.TrustTier? tier,
    String? reason,
    String? model,
    DateTime? createdAt,
  }) {
    return ToolClassification(
      id: id is int? ? id : this.id,
      toolName: toolName ?? this.toolName,
      tier: tier ?? this.tier,
      reason: reason ?? this.reason,
      model: model ?? this.model,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ToolClassificationUpdateTable
    extends _is.UpdateTable<ToolClassificationTable> {
  ToolClassificationUpdateTable(super.table);

  _is.ColumnValue<String, String> toolName(String value) => _is.ColumnValue(
    table.toolName,
    value,
  );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> tier(
    _i6oty1c9.TrustTier value,
  ) => _is.ColumnValue(
    table.tier,
    value,
  );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<String, String> model(String value) => _is.ColumnValue(
    table.model,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class ToolClassificationTable extends _is.Table<int?> {
  ToolClassificationTable({super.tableRelation})
    : super(tableName: 'tool_classification') {
    updateTable = ToolClassificationUpdateTable(this);
    toolName = _is.ColumnString(
      'toolName',
      this,
    );
    tier = _is.ColumnEnum(
      'tier',
      this,
      _is.EnumSerialization.byName,
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    model = _is.ColumnString(
      'model',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final ToolClassificationUpdateTable updateTable;

  /// The tool name this classification applies to (global — tool names are
  /// not household-scoped, since the MCP tool catalogue is shared).
  late final _is.ColumnString toolName;

  /// The minimum trust tier this tool was classified as requiring.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> tier;

  /// Plain-English reason for the classification, from the model.
  late final _is.ColumnString reason;

  /// The model name that produced this classification.
  late final _is.ColumnString model;

  /// When this classification was computed.
  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    toolName,
    tier,
    reason,
    model,
    createdAt,
  ];
}

class ToolClassificationInclude extends _is.IncludeObject {
  ToolClassificationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ToolClassification.t;
}

class ToolClassificationIncludeList extends _is.IncludeList {
  ToolClassificationIncludeList._({
    _is.WhereExpressionBuilder<ToolClassificationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ToolClassification.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ToolClassification.t;
}

class ToolClassificationRepository {
  const ToolClassificationRepository._();

  /// Returns a list of [ToolClassification]s matching the given query parameters.
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
  Future<List<ToolClassification>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ToolClassificationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ToolClassification>(
      where: where?.call(ToolClassification.t),
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ToolClassification] matching the given query parameters.
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
  Future<ToolClassification?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ToolClassificationTable>? where,
    int? offset,
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ToolClassification>(
      where: where?.call(ToolClassification.t),
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ToolClassification] by its [id] or null if no such row exists.
  Future<ToolClassification?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ToolClassification>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ToolClassification]s in the list and returns the inserted rows.
  ///
  /// The returned [ToolClassification]s will have their `id` fields set.
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
  Future<List<ToolClassification>> insert(
    _is.DatabaseSession session,
    List<ToolClassification> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ToolClassification>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ToolClassification] and returns the inserted row.
  ///
  /// The returned [ToolClassification] will have its `id` field set.
  Future<ToolClassification> insertRow(
    _is.DatabaseSession session,
    ToolClassification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ToolClassification>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ToolClassification]s in the list and returns the resulting rows.
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
  /// The returned [ToolClassification]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ToolClassification>> upsert(
    _is.DatabaseSession session,
    List<ToolClassification> rows, {
    required _is.ColumnSelections<ToolClassificationTable> conflictColumns,
    _is.ColumnSelections<ToolClassificationTable>? updateColumns,
    _is.WhereExpressionBuilder<ToolClassificationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ToolClassification>(
      rows,
      conflictColumns: conflictColumns(ToolClassification.t),
      updateColumns: updateColumns?.call(ToolClassification.t),
      updateWhere: updateWhere?.call(ToolClassification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ToolClassification] and returns the resulting row.
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
  /// The returned [ToolClassification] will have its `id` field set.
  Future<ToolClassification?> upsertRow(
    _is.DatabaseSession session,
    ToolClassification row, {
    required _is.ColumnSelections<ToolClassificationTable> conflictColumns,
    _is.ColumnSelections<ToolClassificationTable>? updateColumns,
    _is.WhereExpressionBuilder<ToolClassificationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ToolClassification>(
      row,
      conflictColumns: conflictColumns(ToolClassification.t),
      updateColumns: updateColumns?.call(ToolClassification.t),
      updateWhere: updateWhere?.call(ToolClassification.t),
      transaction: transaction,
    );
  }

  /// Updates all [ToolClassification]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ToolClassification>> update(
    _is.DatabaseSession session,
    List<ToolClassification> rows, {
    _is.ColumnSelections<ToolClassificationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ToolClassification>(
      rows,
      columns: columns?.call(ToolClassification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ToolClassification]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ToolClassification> updateRow(
    _is.DatabaseSession session,
    ToolClassification row, {
    _is.ColumnSelections<ToolClassificationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ToolClassification>(
      row,
      columns: columns?.call(ToolClassification.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ToolClassification] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ToolClassification?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ToolClassificationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ToolClassification>(
      id,
      columnValues: columnValues(ToolClassification.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ToolClassification]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ToolClassification>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ToolClassificationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ToolClassificationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ToolClassification>(
      columnValues: columnValues(ToolClassification.t.updateTable),
      where: where(ToolClassification.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ToolClassification]s in the list and returns the deleted rows.
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
  Future<List<ToolClassification>> delete(
    _is.DatabaseSession session,
    List<ToolClassification> rows, {
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ToolClassification>(
      rows,
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ToolClassification].
  Future<ToolClassification> deleteRow(
    _is.DatabaseSession session,
    ToolClassification row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ToolClassification>(
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
  Future<List<ToolClassification>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ToolClassificationTable> where,
    _is.OrderByBuilder<ToolClassificationTable>? orderBy,
    _is.OrderByListBuilder<ToolClassificationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ToolClassification>(
      where: where(ToolClassification.t),
      orderBy: orderBy?.call(ToolClassification.t),
      orderByList: orderByList?.call(ToolClassification.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ToolClassificationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ToolClassification>(
      where: where?.call(ToolClassification.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ToolClassification] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ToolClassificationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ToolClassification>(
      where: where(ToolClassification.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
