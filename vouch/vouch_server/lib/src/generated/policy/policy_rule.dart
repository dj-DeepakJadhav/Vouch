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
import '../enums/policy_effect.dart' as _imwidqua;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../household/household.dart' as _iyyunadd;
import '../identity/member.dart' as _ie1reufq;

/// A household-configured rule mapping an action pattern to the minimum
/// trust tier required to permit it.
abstract class PolicyRule
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PolicyRule._({
    this.id,
    required this.householdId,
    this.household,
    this.memberId,
    this.member,
    this.role,
    required this.actionPattern,
    required this.requiredTier,
    _imwidqua.PolicyEffect? effect,
    this.sourceText,
    this.argConditions,
    required this.enabled,
  }) : effect = effect ?? _imwidqua.PolicyEffect.require;

  factory PolicyRule({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    _iw6qhlck.MemberRole? role,
    required String actionPattern,
    required _i6oty1c9.TrustTier requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? sourceText,
    String? argConditions,
    required bool enabled,
  }) = _PolicyRuleImpl;

  factory PolicyRule.fromJson(Map<String, dynamic> jsonSerialization) {
    return PolicyRule(
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
      role: jsonSerialization['role'] == null
          ? null
          : _iw6qhlck.MemberRole.fromJson(
              (jsonSerialization['role'] as String),
            ),
      actionPattern: jsonSerialization['actionPattern'] as String,
      requiredTier: _i6oty1c9.TrustTier.fromJson(
        (jsonSerialization['requiredTier'] as String),
      ),
      effect: jsonSerialization['effect'] == null
          ? null
          : _imwidqua.PolicyEffect.fromJson(
              (jsonSerialization['effect'] as String),
            ),
      sourceText: jsonSerialization['sourceText'] as String?,
      argConditions: jsonSerialization['argConditions'] as String?,
      enabled: _is.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
    );
  }

  static final t = PolicyRuleTable();

  static const db = PolicyRuleRepository._();

  @override
  int? id;

  int householdId;

  /// The household this rule applies to.
  _iyyunadd.Household? household;

  int? memberId;

  /// The specific member this rule applies to, if it is member-specific.
  /// Member-specific rules are more specific than role rules, which are
  /// more specific than household-wide rules (no member, no role).
  _ie1reufq.Member? member;

  /// The member role this rule applies to, if it is role-specific (and not
  /// member-specific).
  _iw6qhlck.MemberRole? role;

  /// Pattern matched against the requested action/tool name (e.g. a glob or
  /// prefix such as "payments.*").
  String actionPattern;

  /// The minimum trust tier required for actions matching this pattern.
  _i6oty1c9.TrustTier requiredTier;

  /// Whether a match requires the tier to be met, or denies the action
  /// outright. Defaults to `require` (an unquoted enum value name is a
  /// valid `default=` literal in Serverpod 4 model yaml).
  _imwidqua.PolicyEffect effect;

  /// The original plain-language rule text this rule was derived from, if
  /// any (e.g. as entered by a household admin).
  String? sourceText;

  /// Additional argument conditions for this rule, serialized as a JSON
  /// string (e.g. `{"maxAmount":10,"currency":"EUR"}`).
  String? argConditions;

  /// Whether this rule is currently active.
  bool enabled;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PolicyRule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PolicyRule copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    _iw6qhlck.MemberRole? role,
    String? actionPattern,
    _i6oty1c9.TrustTier? requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? sourceText,
    String? argConditions,
    bool? enabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PolicyRule',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      if (role != null) 'role': role?.toJson(),
      'actionPattern': actionPattern,
      'requiredTier': requiredTier.toJson(),
      'effect': effect.toJson(),
      if (sourceText != null) 'sourceText': sourceText,
      if (argConditions != null) 'argConditions': argConditions,
      'enabled': enabled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PolicyRule',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      if (memberId != null) 'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      if (role != null) 'role': role?.toJson(),
      'actionPattern': actionPattern,
      'requiredTier': requiredTier.toJson(),
      'effect': effect.toJson(),
      if (sourceText != null) 'sourceText': sourceText,
      if (argConditions != null) 'argConditions': argConditions,
      'enabled': enabled,
    };
  }

  static PolicyRuleInclude include({
    _iyyunadd.HouseholdInclude? household,
    _ie1reufq.MemberInclude? member,
  }) {
    return PolicyRuleInclude._(
      household: household,
      member: member,
    );
  }

  static PolicyRuleIncludeList includeList({
    _is.WhereExpressionBuilder<PolicyRuleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    PolicyRuleInclude? include,
  }) {
    return PolicyRuleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PolicyRuleImpl extends PolicyRule {
  _PolicyRuleImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    int? memberId,
    _ie1reufq.Member? member,
    _iw6qhlck.MemberRole? role,
    required String actionPattern,
    required _i6oty1c9.TrustTier requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? sourceText,
    String? argConditions,
    required bool enabled,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         memberId: memberId,
         member: member,
         role: role,
         actionPattern: actionPattern,
         requiredTier: requiredTier,
         effect: effect,
         sourceText: sourceText,
         argConditions: argConditions,
         enabled: enabled,
       );

  /// Returns a shallow copy of this [PolicyRule]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PolicyRule copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    Object? memberId = _Undefined,
    Object? member = _Undefined,
    Object? role = _Undefined,
    String? actionPattern,
    _i6oty1c9.TrustTier? requiredTier,
    _imwidqua.PolicyEffect? effect,
    Object? sourceText = _Undefined,
    Object? argConditions = _Undefined,
    bool? enabled,
  }) {
    return PolicyRule(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      memberId: memberId is int? ? memberId : this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      role: role is _iw6qhlck.MemberRole? ? role : this.role,
      actionPattern: actionPattern ?? this.actionPattern,
      requiredTier: requiredTier ?? this.requiredTier,
      effect: effect ?? this.effect,
      sourceText: sourceText is String? ? sourceText : this.sourceText,
      argConditions: argConditions is String?
          ? argConditions
          : this.argConditions,
      enabled: enabled ?? this.enabled,
    );
  }
}

class PolicyRuleUpdateTable extends _is.UpdateTable<PolicyRuleTable> {
  PolicyRuleUpdateTable(super.table);

  _is.ColumnValue<int, int> householdId(int value) => _is.ColumnValue(
    table.householdId,
    value,
  );

  _is.ColumnValue<int, int> memberId(int? value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<_iw6qhlck.MemberRole, _iw6qhlck.MemberRole> role(
    _iw6qhlck.MemberRole? value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> actionPattern(String value) =>
      _is.ColumnValue(
        table.actionPattern,
        value,
      );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> requiredTier(
    _i6oty1c9.TrustTier value,
  ) => _is.ColumnValue(
    table.requiredTier,
    value,
  );

  _is.ColumnValue<_imwidqua.PolicyEffect, _imwidqua.PolicyEffect> effect(
    _imwidqua.PolicyEffect value,
  ) => _is.ColumnValue(
    table.effect,
    value,
  );

  _is.ColumnValue<String, String> sourceText(String? value) => _is.ColumnValue(
    table.sourceText,
    value,
  );

  _is.ColumnValue<String, String> argConditions(String? value) =>
      _is.ColumnValue(
        table.argConditions,
        value,
      );

  _is.ColumnValue<bool, bool> enabled(bool value) => _is.ColumnValue(
    table.enabled,
    value,
  );
}

class PolicyRuleTable extends _is.Table<int?> {
  PolicyRuleTable({super.tableRelation}) : super(tableName: 'policy_rule') {
    updateTable = PolicyRuleUpdateTable(this);
    householdId = _is.ColumnInt(
      'householdId',
      this,
    );
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    actionPattern = _is.ColumnString(
      'actionPattern',
      this,
    );
    requiredTier = _is.ColumnEnum(
      'requiredTier',
      this,
      _is.EnumSerialization.byName,
    );
    effect = _is.ColumnEnum(
      'effect',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    sourceText = _is.ColumnString(
      'sourceText',
      this,
    );
    argConditions = _is.ColumnString(
      'argConditions',
      this,
    );
    enabled = _is.ColumnBool(
      'enabled',
      this,
    );
  }

  late final PolicyRuleUpdateTable updateTable;

  late final _is.ColumnInt householdId;

  /// The household this rule applies to.
  _iyyunadd.HouseholdTable? _household;

  late final _is.ColumnInt memberId;

  /// The specific member this rule applies to, if it is member-specific.
  /// Member-specific rules are more specific than role rules, which are
  /// more specific than household-wide rules (no member, no role).
  _ie1reufq.MemberTable? _member;

  /// The member role this rule applies to, if it is role-specific (and not
  /// member-specific).
  late final _is.ColumnEnum<_iw6qhlck.MemberRole> role;

  /// Pattern matched against the requested action/tool name (e.g. a glob or
  /// prefix such as "payments.*").
  late final _is.ColumnString actionPattern;

  /// The minimum trust tier required for actions matching this pattern.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> requiredTier;

  /// Whether a match requires the tier to be met, or denies the action
  /// outright. Defaults to `require` (an unquoted enum value name is a
  /// valid `default=` literal in Serverpod 4 model yaml).
  late final _is.ColumnEnum<_imwidqua.PolicyEffect> effect;

  /// The original plain-language rule text this rule was derived from, if
  /// any (e.g. as entered by a household admin).
  late final _is.ColumnString sourceText;

  /// Additional argument conditions for this rule, serialized as a JSON
  /// string (e.g. `{"maxAmount":10,"currency":"EUR"}`).
  late final _is.ColumnString argConditions;

  /// Whether this rule is currently active.
  late final _is.ColumnBool enabled;

  _iyyunadd.HouseholdTable get household {
    if (_household != null) return _household!;
    _household = _is.createRelationTable(
      relationFieldName: 'household',
      field: PolicyRule.t.householdId,
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
      field: PolicyRule.t.memberId,
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
    role,
    actionPattern,
    requiredTier,
    effect,
    sourceText,
    argConditions,
    enabled,
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

class PolicyRuleInclude extends _is.IncludeObject {
  PolicyRuleInclude._({
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
  _is.Table<int?> get table => PolicyRule.t;
}

class PolicyRuleIncludeList extends _is.IncludeList {
  PolicyRuleIncludeList._({
    _is.WhereExpressionBuilder<PolicyRuleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PolicyRule.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PolicyRule.t;
}

class PolicyRuleRepository {
  const PolicyRuleRepository._();

  final attachRow = const PolicyRuleAttachRowRepository._();

  final detachRow = const PolicyRuleDetachRowRepository._();

  /// Returns a list of [PolicyRule]s matching the given query parameters.
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
  Future<List<PolicyRule>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PolicyRuleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    _is.Transaction? transaction,
    PolicyRuleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PolicyRule>(
      where: where?.call(PolicyRule.t),
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PolicyRule] matching the given query parameters.
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
  Future<PolicyRule?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PolicyRuleTable>? where,
    int? offset,
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    _is.Transaction? transaction,
    PolicyRuleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PolicyRule>(
      where: where?.call(PolicyRule.t),
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PolicyRule] by its [id] or null if no such row exists.
  Future<PolicyRule?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    PolicyRuleInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PolicyRule>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PolicyRule]s in the list and returns the inserted rows.
  ///
  /// The returned [PolicyRule]s will have their `id` fields set.
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
  Future<List<PolicyRule>> insert(
    _is.DatabaseSession session,
    List<PolicyRule> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PolicyRule>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PolicyRule] and returns the inserted row.
  ///
  /// The returned [PolicyRule] will have its `id` field set.
  Future<PolicyRule> insertRow(
    _is.DatabaseSession session,
    PolicyRule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PolicyRule>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PolicyRule]s in the list and returns the resulting rows.
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
  /// The returned [PolicyRule]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PolicyRule>> upsert(
    _is.DatabaseSession session,
    List<PolicyRule> rows, {
    required _is.ColumnSelections<PolicyRuleTable> conflictColumns,
    _is.ColumnSelections<PolicyRuleTable>? updateColumns,
    _is.WhereExpressionBuilder<PolicyRuleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PolicyRule>(
      rows,
      conflictColumns: conflictColumns(PolicyRule.t),
      updateColumns: updateColumns?.call(PolicyRule.t),
      updateWhere: updateWhere?.call(PolicyRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PolicyRule] and returns the resulting row.
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
  /// The returned [PolicyRule] will have its `id` field set.
  Future<PolicyRule?> upsertRow(
    _is.DatabaseSession session,
    PolicyRule row, {
    required _is.ColumnSelections<PolicyRuleTable> conflictColumns,
    _is.ColumnSelections<PolicyRuleTable>? updateColumns,
    _is.WhereExpressionBuilder<PolicyRuleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PolicyRule>(
      row,
      conflictColumns: conflictColumns(PolicyRule.t),
      updateColumns: updateColumns?.call(PolicyRule.t),
      updateWhere: updateWhere?.call(PolicyRule.t),
      transaction: transaction,
    );
  }

  /// Updates all [PolicyRule]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PolicyRule>> update(
    _is.DatabaseSession session,
    List<PolicyRule> rows, {
    _is.ColumnSelections<PolicyRuleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PolicyRule>(
      rows,
      columns: columns?.call(PolicyRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PolicyRule]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PolicyRule> updateRow(
    _is.DatabaseSession session,
    PolicyRule row, {
    _is.ColumnSelections<PolicyRuleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PolicyRule>(
      row,
      columns: columns?.call(PolicyRule.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PolicyRule] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PolicyRule?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PolicyRuleUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PolicyRule>(
      id,
      columnValues: columnValues(PolicyRule.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PolicyRule]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PolicyRule>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PolicyRuleUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PolicyRuleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PolicyRule>(
      columnValues: columnValues(PolicyRule.t.updateTable),
      where: where(PolicyRule.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PolicyRule]s in the list and returns the deleted rows.
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
  Future<List<PolicyRule>> delete(
    _is.DatabaseSession session,
    List<PolicyRule> rows, {
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PolicyRule>(
      rows,
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PolicyRule].
  Future<PolicyRule> deleteRow(
    _is.DatabaseSession session,
    PolicyRule row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PolicyRule>(
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
  Future<List<PolicyRule>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PolicyRuleTable> where,
    _is.OrderByBuilder<PolicyRuleTable>? orderBy,
    _is.OrderByListBuilder<PolicyRuleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PolicyRule>(
      where: where(PolicyRule.t),
      orderBy: orderBy?.call(PolicyRule.t),
      orderByList: orderByList?.call(PolicyRule.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PolicyRuleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PolicyRule>(
      where: where?.call(PolicyRule.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PolicyRule] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PolicyRuleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PolicyRule>(
      where: where(PolicyRule.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class PolicyRuleAttachRowRepository {
  const PolicyRuleAttachRowRepository._();

  /// Creates a relation between the given [PolicyRule] and [Household]
  /// by setting the [PolicyRule]'s foreign key `householdId` to refer to the [Household].
  Future<void> household(
    _is.DatabaseSession session,
    PolicyRule policyRule,
    _iyyunadd.Household household, {
    _is.Transaction? transaction,
  }) async {
    if (policyRule.id == null) {
      throw ArgumentError.notNull('policyRule.id');
    }
    if (household.id == null) {
      throw ArgumentError.notNull('household.id');
    }

    var $policyRule = policyRule.copyWith(householdId: household.id);
    await session.db.updateRow<PolicyRule>(
      $policyRule,
      columns: [PolicyRule.t.householdId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [PolicyRule] and [Member]
  /// by setting the [PolicyRule]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    PolicyRule policyRule,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (policyRule.id == null) {
      throw ArgumentError.notNull('policyRule.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $policyRule = policyRule.copyWith(memberId: member.id);
    await session.db.updateRow<PolicyRule>(
      $policyRule,
      columns: [PolicyRule.t.memberId],
      transaction: transaction,
    );
  }
}

class PolicyRuleDetachRowRepository {
  const PolicyRuleDetachRowRepository._();

  /// Detaches the relation between this [PolicyRule] and the [Member] set in `member`
  /// by setting the [PolicyRule]'s foreign key `memberId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> member(
    _is.DatabaseSession session,
    PolicyRule policyRule, {
    _is.Transaction? transaction,
  }) async {
    if (policyRule.id == null) {
      throw ArgumentError.notNull('policyRule.id');
    }

    var $policyRule = policyRule.copyWith(memberId: null);
    await session.db.updateRow<PolicyRule>(
      $policyRule,
      columns: [PolicyRule.t.memberId],
      transaction: transaction,
    );
  }
}
