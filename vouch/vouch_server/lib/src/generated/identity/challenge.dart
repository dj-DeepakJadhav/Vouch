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
import '../enums/challenge_outcome.dart' as _ib8tgtzr;
import '../identity/member.dart' as _ie1reufq;

/// A knowledge-grounded step-up challenge issued to a member. Passing it
/// proves household knowledge that a voice clone alone would not have.
abstract class Challenge
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Challenge._({
    this.id,
    required this.memberId,
    this.member,
    required this.question,
    required this.answerHash,
    required this.contextSource,
    required this.issuedAt,
    required this.expiresAt,
    this.consumedAt,
    this.outcome,
  });

  factory Challenge({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required String question,
    required String answerHash,
    required String contextSource,
    required DateTime issuedAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  }) = _ChallengeImpl;

  factory Challenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return Challenge(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      question: jsonSerialization['question'] as String,
      answerHash: jsonSerialization['answerHash'] as String,
      contextSource: jsonSerialization['contextSource'] as String,
      issuedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['issuedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
      outcome: jsonSerialization['outcome'] == null
          ? null
          : _ib8tgtzr.ChallengeOutcome.fromJson(
              (jsonSerialization['outcome'] as String),
            ),
    );
  }

  static final t = ChallengeTable();

  static const db = ChallengeRepository._();

  @override
  int? id;

  int memberId;

  /// The member this challenge was issued to.
  _ie1reufq.Member? member;

  /// The question text presented to the member.
  String question;

  /// Hash of the expected answer; the plaintext answer is never stored.
  String answerHash;

  /// Identifier of the source used to ground the question (e.g. which
  /// household fact / record it was derived from).
  String contextSource;

  /// When the challenge was issued.
  DateTime issuedAt;

  /// When the challenge expires if left unanswered.
  DateTime expiresAt;

  /// When the challenge was answered/consumed, if it has been.
  DateTime? consumedAt;

  /// The result of the challenge, once resolved.
  _ib8tgtzr.ChallengeOutcome? outcome;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Challenge copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    String? question,
    String? answerHash,
    String? contextSource,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Challenge',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'question': question,
      'answerHash': answerHash,
      'contextSource': contextSource,
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      if (outcome != null) 'outcome': outcome?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Challenge',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'question': question,
      'answerHash': answerHash,
      'contextSource': contextSource,
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      if (outcome != null) 'outcome': outcome?.toJson(),
    };
  }

  static ChallengeInclude include({_ie1reufq.MemberInclude? member}) {
    return ChallengeInclude._(member: member);
  }

  static ChallengeIncludeList includeList({
    _is.WhereExpressionBuilder<ChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    ChallengeInclude? include,
  }) {
    return ChallengeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChallengeImpl extends Challenge {
  _ChallengeImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required String question,
    required String answerHash,
    required String contextSource,
    required DateTime issuedAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         question: question,
         answerHash: answerHash,
         contextSource: contextSource,
         issuedAt: issuedAt,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
         outcome: outcome,
       );

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Challenge copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    String? question,
    String? answerHash,
    String? contextSource,
    DateTime? issuedAt,
    DateTime? expiresAt,
    Object? consumedAt = _Undefined,
    Object? outcome = _Undefined,
  }) {
    return Challenge(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      question: question ?? this.question,
      answerHash: answerHash ?? this.answerHash,
      contextSource: contextSource ?? this.contextSource,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      outcome: outcome is _ib8tgtzr.ChallengeOutcome? ? outcome : this.outcome,
    );
  }
}

class ChallengeUpdateTable extends _is.UpdateTable<ChallengeTable> {
  ChallengeUpdateTable(super.table);

  _is.ColumnValue<int, int> memberId(int value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<String, String> question(String value) => _is.ColumnValue(
    table.question,
    value,
  );

  _is.ColumnValue<String, String> answerHash(String value) => _is.ColumnValue(
    table.answerHash,
    value,
  );

  _is.ColumnValue<String, String> contextSource(String value) =>
      _is.ColumnValue(
        table.contextSource,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> issuedAt(DateTime value) =>
      _is.ColumnValue(
        table.issuedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );

  _is.ColumnValue<_ib8tgtzr.ChallengeOutcome, _ib8tgtzr.ChallengeOutcome>
  outcome(_ib8tgtzr.ChallengeOutcome? value) => _is.ColumnValue(
    table.outcome,
    value,
  );
}

class ChallengeTable extends _is.Table<int?> {
  ChallengeTable({super.tableRelation}) : super(tableName: 'challenge') {
    updateTable = ChallengeUpdateTable(this);
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    question = _is.ColumnString(
      'question',
      this,
    );
    answerHash = _is.ColumnString(
      'answerHash',
      this,
    );
    contextSource = _is.ColumnString(
      'contextSource',
      this,
    );
    issuedAt = _is.ColumnDateTime(
      'issuedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
    outcome = _is.ColumnEnum(
      'outcome',
      this,
      _is.EnumSerialization.byName,
    );
  }

  late final ChallengeUpdateTable updateTable;

  late final _is.ColumnInt memberId;

  /// The member this challenge was issued to.
  _ie1reufq.MemberTable? _member;

  /// The question text presented to the member.
  late final _is.ColumnString question;

  /// Hash of the expected answer; the plaintext answer is never stored.
  late final _is.ColumnString answerHash;

  /// Identifier of the source used to ground the question (e.g. which
  /// household fact / record it was derived from).
  late final _is.ColumnString contextSource;

  /// When the challenge was issued.
  late final _is.ColumnDateTime issuedAt;

  /// When the challenge expires if left unanswered.
  late final _is.ColumnDateTime expiresAt;

  /// When the challenge was answered/consumed, if it has been.
  late final _is.ColumnDateTime consumedAt;

  /// The result of the challenge, once resolved.
  late final _is.ColumnEnum<_ib8tgtzr.ChallengeOutcome> outcome;

  _ie1reufq.MemberTable get member {
    if (_member != null) return _member!;
    _member = _is.createRelationTable(
      relationFieldName: 'member',
      field: Challenge.t.memberId,
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
    memberId,
    question,
    answerHash,
    contextSource,
    issuedAt,
    expiresAt,
    consumedAt,
    outcome,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'member') {
      return member;
    }
    return null;
  }
}

class ChallengeInclude extends _is.IncludeObject {
  ChallengeInclude._({_ie1reufq.MemberInclude? member}) {
    _member = member;
  }

  _ie1reufq.MemberInclude? _member;

  @override
  Map<String, _is.Include?> get includes => {'member': _member};

  @override
  _is.Table<int?> get table => Challenge.t;
}

class ChallengeIncludeList extends _is.IncludeList {
  ChallengeIncludeList._({
    _is.WhereExpressionBuilder<ChallengeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Challenge.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Challenge.t;
}

class ChallengeRepository {
  const ChallengeRepository._();

  final attachRow = const ChallengeAttachRowRepository._();

  /// Returns a list of [Challenge]s matching the given query parameters.
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
  Future<List<Challenge>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    _is.Transaction? transaction,
    ChallengeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Challenge>(
      where: where?.call(Challenge.t),
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Challenge] matching the given query parameters.
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
  Future<Challenge?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeTable>? where,
    int? offset,
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    _is.Transaction? transaction,
    ChallengeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Challenge>(
      where: where?.call(Challenge.t),
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Challenge] by its [id] or null if no such row exists.
  Future<Challenge?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ChallengeInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Challenge>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Challenge]s in the list and returns the inserted rows.
  ///
  /// The returned [Challenge]s will have their `id` fields set.
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
  Future<List<Challenge>> insert(
    _is.DatabaseSession session,
    List<Challenge> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Challenge>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Challenge] and returns the inserted row.
  ///
  /// The returned [Challenge] will have its `id` field set.
  Future<Challenge> insertRow(
    _is.DatabaseSession session,
    Challenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Challenge>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Challenge]s in the list and returns the resulting rows.
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
  /// The returned [Challenge]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Challenge>> upsert(
    _is.DatabaseSession session,
    List<Challenge> rows, {
    required _is.ColumnSelections<ChallengeTable> conflictColumns,
    _is.ColumnSelections<ChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Challenge>(
      rows,
      conflictColumns: conflictColumns(Challenge.t),
      updateColumns: updateColumns?.call(Challenge.t),
      updateWhere: updateWhere?.call(Challenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Challenge] and returns the resulting row.
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
  /// The returned [Challenge] will have its `id` field set.
  Future<Challenge?> upsertRow(
    _is.DatabaseSession session,
    Challenge row, {
    required _is.ColumnSelections<ChallengeTable> conflictColumns,
    _is.ColumnSelections<ChallengeTable>? updateColumns,
    _is.WhereExpressionBuilder<ChallengeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Challenge>(
      row,
      conflictColumns: conflictColumns(Challenge.t),
      updateColumns: updateColumns?.call(Challenge.t),
      updateWhere: updateWhere?.call(Challenge.t),
      transaction: transaction,
    );
  }

  /// Updates all [Challenge]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Challenge>> update(
    _is.DatabaseSession session,
    List<Challenge> rows, {
    _is.ColumnSelections<ChallengeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Challenge>(
      rows,
      columns: columns?.call(Challenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Challenge]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Challenge> updateRow(
    _is.DatabaseSession session,
    Challenge row, {
    _is.ColumnSelections<ChallengeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Challenge>(
      row,
      columns: columns?.call(Challenge.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Challenge] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Challenge?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ChallengeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Challenge>(
      id,
      columnValues: columnValues(Challenge.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Challenge]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Challenge>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ChallengeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ChallengeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Challenge>(
      columnValues: columnValues(Challenge.t.updateTable),
      where: where(Challenge.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Challenge]s in the list and returns the deleted rows.
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
  Future<List<Challenge>> delete(
    _is.DatabaseSession session,
    List<Challenge> rows, {
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Challenge>(
      rows,
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Challenge].
  Future<Challenge> deleteRow(
    _is.DatabaseSession session,
    Challenge row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Challenge>(
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
  Future<List<Challenge>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeTable> where,
    _is.OrderByBuilder<ChallengeTable>? orderBy,
    _is.OrderByListBuilder<ChallengeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Challenge>(
      where: where(Challenge.t),
      orderBy: orderBy?.call(Challenge.t),
      orderByList: orderByList?.call(Challenge.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ChallengeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Challenge>(
      where: where?.call(Challenge.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Challenge] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ChallengeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Challenge>(
      where: where(Challenge.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ChallengeAttachRowRepository {
  const ChallengeAttachRowRepository._();

  /// Creates a relation between the given [Challenge] and [Member]
  /// by setting the [Challenge]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    Challenge challenge,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (challenge.id == null) {
      throw ArgumentError.notNull('challenge.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $challenge = challenge.copyWith(memberId: member.id);
    await session.db.updateRow<Challenge>(
      $challenge,
      columns: [Challenge.t.memberId],
      transaction: transaction,
    );
  }
}
