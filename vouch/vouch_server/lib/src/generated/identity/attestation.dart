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
import '../enums/spoof_risk.dart' as _i9uqnoc2;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../identity/member.dart' as _ie1reufq;

/// A short-lived, hub-signed proof that a member was verified at a given
/// trust tier. Presented by clients to authorize privileged actions.
///
/// Covers exactly ONE utterance: it is minted for a single spoken request
/// and is not a general-purpose session credential. [expiresAt] is a short
/// validity window (~3 seconds after [capturedAt]) and it is single-use —
/// once consumed it may not be presented again (see [singleUse],
/// [consumedAt]).
abstract class Attestation
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Attestation._({
    this.id,
    required this.memberId,
    this.member,
    required this.tier,
    required this.issuedAt,
    required this.expiresAt,
    required this.confidence,
    required this.spoofRisk,
    required this.hubSig,
    required this.singleUse,
    this.consumedAt,
    required this.revoked,
    required this.transcriptHash,
    required this.transcriptNormalised,
    required this.capturedAt,
  });

  factory Attestation({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required _i6oty1c9.TrustTier tier,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required double confidence,
    required _i9uqnoc2.SpoofRisk spoofRisk,
    required String hubSig,
    required bool singleUse,
    DateTime? consumedAt,
    required bool revoked,
    required String transcriptHash,
    required String transcriptNormalised,
    required DateTime capturedAt,
  }) = _AttestationImpl;

  factory Attestation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Attestation(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iii3n24o.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      tier: _i6oty1c9.TrustTier.fromJson((jsonSerialization['tier'] as String)),
      issuedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['issuedAt'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      confidence: (jsonSerialization['confidence'] as num).toDouble(),
      spoofRisk: _i9uqnoc2.SpoofRisk.fromJson(
        (jsonSerialization['spoofRisk'] as String),
      ),
      hubSig: jsonSerialization['hubSig'] as String,
      singleUse: _is.BoolJsonExtension.fromJson(jsonSerialization['singleUse']),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['consumedAt']),
      revoked: _is.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
      transcriptHash: jsonSerialization['transcriptHash'] as String,
      transcriptNormalised: jsonSerialization['transcriptNormalised'] as String,
      capturedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
    );
  }

  static final t = AttestationTable();

  static const db = AttestationRepository._();

  @override
  int? id;

  int memberId;

  /// The member this attestation asserts the identity of.
  _ie1reufq.Member? member;

  /// The trust tier proven by this attestation.
  _i6oty1c9.TrustTier tier;

  /// When the attestation was issued.
  DateTime issuedAt;

  /// When the attestation expires and can no longer be used. A short
  /// validity window — approximately 3 seconds after [capturedAt] — since
  /// the attestation covers exactly one utterance.
  DateTime expiresAt;

  /// Confidence score of the underlying voice match.
  double confidence;

  /// Anti-spoof risk signal recorded at issuance time.
  _i9uqnoc2.SpoofRisk spoofRisk;

  /// The hub's signature over the attestation payload, used to verify it
  /// was actually issued by the household's hub.
  String hubSig;

  /// Whether this attestation may only be consumed (used) once.
  bool singleUse;

  /// When a single-use attestation was consumed, if it has been.
  DateTime? consumedAt;

  /// Whether the attestation has been explicitly revoked before expiry.
  bool revoked;

  /// SHA-256 hash of the normalised transcript of the single utterance this
  /// attestation covers. Never the plaintext transcript.
  String transcriptHash;

  /// The normalised transcript text itself (see [TranscriptMatcher.normalise]),
  /// stored so the server can fuzzy-match it against the text Alexa+ hands
  /// back for the same utterance. Not biometric data — it is the spoken
  /// command text, already stripped of the wake word. [transcriptHash] must
  /// equal sha256(transcriptNormalised).
  String transcriptNormalised;

  /// When the underlying utterance audio was captured by the hub. The
  /// attestation's short validity window is measured from this timestamp.
  DateTime capturedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Attestation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Attestation copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    _i6oty1c9.TrustTier? tier,
    DateTime? issuedAt,
    DateTime? expiresAt,
    double? confidence,
    _i9uqnoc2.SpoofRisk? spoofRisk,
    String? hubSig,
    bool? singleUse,
    DateTime? consumedAt,
    bool? revoked,
    String? transcriptHash,
    String? transcriptNormalised,
    DateTime? capturedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Attestation',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'tier': tier.toJson(),
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'confidence': confidence,
      'spoofRisk': spoofRisk.toJson(),
      'hubSig': hubSig,
      'singleUse': singleUse,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'revoked': revoked,
      'transcriptHash': transcriptHash,
      'transcriptNormalised': transcriptNormalised,
      'capturedAt': capturedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Attestation',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'tier': tier.toJson(),
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'confidence': confidence,
      'spoofRisk': spoofRisk.toJson(),
      'hubSig': hubSig,
      'singleUse': singleUse,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'revoked': revoked,
      'transcriptHash': transcriptHash,
      'transcriptNormalised': transcriptNormalised,
      'capturedAt': capturedAt.toJson(),
    };
  }

  static AttestationInclude include({_ie1reufq.MemberInclude? member}) {
    return AttestationInclude._(member: member);
  }

  static AttestationIncludeList includeList({
    _is.WhereExpressionBuilder<AttestationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    AttestationInclude? include,
  }) {
    return AttestationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AttestationImpl extends Attestation {
  _AttestationImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required _i6oty1c9.TrustTier tier,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required double confidence,
    required _i9uqnoc2.SpoofRisk spoofRisk,
    required String hubSig,
    required bool singleUse,
    DateTime? consumedAt,
    required bool revoked,
    required String transcriptHash,
    required String transcriptNormalised,
    required DateTime capturedAt,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         tier: tier,
         issuedAt: issuedAt,
         expiresAt: expiresAt,
         confidence: confidence,
         spoofRisk: spoofRisk,
         hubSig: hubSig,
         singleUse: singleUse,
         consumedAt: consumedAt,
         revoked: revoked,
         transcriptHash: transcriptHash,
         transcriptNormalised: transcriptNormalised,
         capturedAt: capturedAt,
       );

  /// Returns a shallow copy of this [Attestation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Attestation copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    _i6oty1c9.TrustTier? tier,
    DateTime? issuedAt,
    DateTime? expiresAt,
    double? confidence,
    _i9uqnoc2.SpoofRisk? spoofRisk,
    String? hubSig,
    bool? singleUse,
    Object? consumedAt = _Undefined,
    bool? revoked,
    String? transcriptHash,
    String? transcriptNormalised,
    DateTime? capturedAt,
  }) {
    return Attestation(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      tier: tier ?? this.tier,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      confidence: confidence ?? this.confidence,
      spoofRisk: spoofRisk ?? this.spoofRisk,
      hubSig: hubSig ?? this.hubSig,
      singleUse: singleUse ?? this.singleUse,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      revoked: revoked ?? this.revoked,
      transcriptHash: transcriptHash ?? this.transcriptHash,
      transcriptNormalised: transcriptNormalised ?? this.transcriptNormalised,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}

class AttestationUpdateTable extends _is.UpdateTable<AttestationTable> {
  AttestationUpdateTable(super.table);

  _is.ColumnValue<int, int> memberId(int value) => _is.ColumnValue(
    table.memberId,
    value,
  );

  _is.ColumnValue<_i6oty1c9.TrustTier, _i6oty1c9.TrustTier> tier(
    _i6oty1c9.TrustTier value,
  ) => _is.ColumnValue(
    table.tier,
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

  _is.ColumnValue<double, double> confidence(double value) => _is.ColumnValue(
    table.confidence,
    value,
  );

  _is.ColumnValue<_i9uqnoc2.SpoofRisk, _i9uqnoc2.SpoofRisk> spoofRisk(
    _i9uqnoc2.SpoofRisk value,
  ) => _is.ColumnValue(
    table.spoofRisk,
    value,
  );

  _is.ColumnValue<String, String> hubSig(String value) => _is.ColumnValue(
    table.hubSig,
    value,
  );

  _is.ColumnValue<bool, bool> singleUse(bool value) => _is.ColumnValue(
    table.singleUse,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> consumedAt(DateTime? value) =>
      _is.ColumnValue(
        table.consumedAt,
        value,
      );

  _is.ColumnValue<bool, bool> revoked(bool value) => _is.ColumnValue(
    table.revoked,
    value,
  );

  _is.ColumnValue<String, String> transcriptHash(String value) =>
      _is.ColumnValue(
        table.transcriptHash,
        value,
      );

  _is.ColumnValue<String, String> transcriptNormalised(String value) =>
      _is.ColumnValue(
        table.transcriptNormalised,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> capturedAt(DateTime value) =>
      _is.ColumnValue(
        table.capturedAt,
        value,
      );
}

class AttestationTable extends _is.Table<int?> {
  AttestationTable({super.tableRelation}) : super(tableName: 'attestation') {
    updateTable = AttestationUpdateTable(this);
    memberId = _is.ColumnInt(
      'memberId',
      this,
    );
    tier = _is.ColumnEnum(
      'tier',
      this,
      _is.EnumSerialization.byName,
    );
    issuedAt = _is.ColumnDateTime(
      'issuedAt',
      this,
    );
    expiresAt = _is.ColumnDateTime(
      'expiresAt',
      this,
    );
    confidence = _is.ColumnDouble(
      'confidence',
      this,
    );
    spoofRisk = _is.ColumnEnum(
      'spoofRisk',
      this,
      _is.EnumSerialization.byName,
    );
    hubSig = _is.ColumnString(
      'hubSig',
      this,
    );
    singleUse = _is.ColumnBool(
      'singleUse',
      this,
    );
    consumedAt = _is.ColumnDateTime(
      'consumedAt',
      this,
    );
    revoked = _is.ColumnBool(
      'revoked',
      this,
    );
    transcriptHash = _is.ColumnString(
      'transcriptHash',
      this,
    );
    transcriptNormalised = _is.ColumnString(
      'transcriptNormalised',
      this,
    );
    capturedAt = _is.ColumnDateTime(
      'capturedAt',
      this,
    );
  }

  late final AttestationUpdateTable updateTable;

  late final _is.ColumnInt memberId;

  /// The member this attestation asserts the identity of.
  _ie1reufq.MemberTable? _member;

  /// The trust tier proven by this attestation.
  late final _is.ColumnEnum<_i6oty1c9.TrustTier> tier;

  /// When the attestation was issued.
  late final _is.ColumnDateTime issuedAt;

  /// When the attestation expires and can no longer be used. A short
  /// validity window — approximately 3 seconds after [capturedAt] — since
  /// the attestation covers exactly one utterance.
  late final _is.ColumnDateTime expiresAt;

  /// Confidence score of the underlying voice match.
  late final _is.ColumnDouble confidence;

  /// Anti-spoof risk signal recorded at issuance time.
  late final _is.ColumnEnum<_i9uqnoc2.SpoofRisk> spoofRisk;

  /// The hub's signature over the attestation payload, used to verify it
  /// was actually issued by the household's hub.
  late final _is.ColumnString hubSig;

  /// Whether this attestation may only be consumed (used) once.
  late final _is.ColumnBool singleUse;

  /// When a single-use attestation was consumed, if it has been.
  late final _is.ColumnDateTime consumedAt;

  /// Whether the attestation has been explicitly revoked before expiry.
  late final _is.ColumnBool revoked;

  /// SHA-256 hash of the normalised transcript of the single utterance this
  /// attestation covers. Never the plaintext transcript.
  late final _is.ColumnString transcriptHash;

  /// The normalised transcript text itself (see [TranscriptMatcher.normalise]),
  /// stored so the server can fuzzy-match it against the text Alexa+ hands
  /// back for the same utterance. Not biometric data — it is the spoken
  /// command text, already stripped of the wake word. [transcriptHash] must
  /// equal sha256(transcriptNormalised).
  late final _is.ColumnString transcriptNormalised;

  /// When the underlying utterance audio was captured by the hub. The
  /// attestation's short validity window is measured from this timestamp.
  late final _is.ColumnDateTime capturedAt;

  _ie1reufq.MemberTable get member {
    if (_member != null) return _member!;
    _member = _is.createRelationTable(
      relationFieldName: 'member',
      field: Attestation.t.memberId,
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
    tier,
    issuedAt,
    expiresAt,
    confidence,
    spoofRisk,
    hubSig,
    singleUse,
    consumedAt,
    revoked,
    transcriptHash,
    transcriptNormalised,
    capturedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'member') {
      return member;
    }
    return null;
  }
}

class AttestationInclude extends _is.IncludeObject {
  AttestationInclude._({_ie1reufq.MemberInclude? member}) {
    _member = member;
  }

  _ie1reufq.MemberInclude? _member;

  @override
  Map<String, _is.Include?> get includes => {'member': _member};

  @override
  _is.Table<int?> get table => Attestation.t;
}

class AttestationIncludeList extends _is.IncludeList {
  AttestationIncludeList._({
    _is.WhereExpressionBuilder<AttestationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Attestation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Attestation.t;
}

class AttestationRepository {
  const AttestationRepository._();

  final attachRow = const AttestationAttachRowRepository._();

  /// Returns a list of [Attestation]s matching the given query parameters.
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
  Future<List<Attestation>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttestationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    _is.Transaction? transaction,
    AttestationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Attestation>(
      where: where?.call(Attestation.t),
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Attestation] matching the given query parameters.
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
  Future<Attestation?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttestationTable>? where,
    int? offset,
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    _is.Transaction? transaction,
    AttestationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Attestation>(
      where: where?.call(Attestation.t),
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Attestation] by its [id] or null if no such row exists.
  Future<Attestation?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    AttestationInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Attestation>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Attestation]s in the list and returns the inserted rows.
  ///
  /// The returned [Attestation]s will have their `id` fields set.
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
  Future<List<Attestation>> insert(
    _is.DatabaseSession session,
    List<Attestation> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Attestation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Attestation] and returns the inserted row.
  ///
  /// The returned [Attestation] will have its `id` field set.
  Future<Attestation> insertRow(
    _is.DatabaseSession session,
    Attestation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Attestation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Attestation]s in the list and returns the resulting rows.
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
  /// The returned [Attestation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Attestation>> upsert(
    _is.DatabaseSession session,
    List<Attestation> rows, {
    required _is.ColumnSelections<AttestationTable> conflictColumns,
    _is.ColumnSelections<AttestationTable>? updateColumns,
    _is.WhereExpressionBuilder<AttestationTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Attestation>(
      rows,
      conflictColumns: conflictColumns(Attestation.t),
      updateColumns: updateColumns?.call(Attestation.t),
      updateWhere: updateWhere?.call(Attestation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Attestation] and returns the resulting row.
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
  /// The returned [Attestation] will have its `id` field set.
  Future<Attestation?> upsertRow(
    _is.DatabaseSession session,
    Attestation row, {
    required _is.ColumnSelections<AttestationTable> conflictColumns,
    _is.ColumnSelections<AttestationTable>? updateColumns,
    _is.WhereExpressionBuilder<AttestationTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Attestation>(
      row,
      conflictColumns: conflictColumns(Attestation.t),
      updateColumns: updateColumns?.call(Attestation.t),
      updateWhere: updateWhere?.call(Attestation.t),
      transaction: transaction,
    );
  }

  /// Updates all [Attestation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Attestation>> update(
    _is.DatabaseSession session,
    List<Attestation> rows, {
    _is.ColumnSelections<AttestationTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Attestation>(
      rows,
      columns: columns?.call(Attestation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Attestation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Attestation> updateRow(
    _is.DatabaseSession session,
    Attestation row, {
    _is.ColumnSelections<AttestationTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Attestation>(
      row,
      columns: columns?.call(Attestation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Attestation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Attestation?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<AttestationUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Attestation>(
      id,
      columnValues: columnValues(Attestation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Attestation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Attestation>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AttestationUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AttestationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Attestation>(
      columnValues: columnValues(Attestation.t.updateTable),
      where: where(Attestation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Attestation]s in the list and returns the deleted rows.
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
  Future<List<Attestation>> delete(
    _is.DatabaseSession session,
    List<Attestation> rows, {
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Attestation>(
      rows,
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Attestation].
  Future<Attestation> deleteRow(
    _is.DatabaseSession session,
    Attestation row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Attestation>(
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
  Future<List<Attestation>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AttestationTable> where,
    _is.OrderByBuilder<AttestationTable>? orderBy,
    _is.OrderByListBuilder<AttestationTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Attestation>(
      where: where(Attestation.t),
      orderBy: orderBy?.call(Attestation.t),
      orderByList: orderByList?.call(Attestation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AttestationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Attestation>(
      where: where?.call(Attestation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Attestation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AttestationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Attestation>(
      where: where(Attestation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AttestationAttachRowRepository {
  const AttestationAttachRowRepository._();

  /// Creates a relation between the given [Attestation] and [Member]
  /// by setting the [Attestation]'s foreign key `memberId` to refer to the [Member].
  Future<void> member(
    _is.DatabaseSession session,
    Attestation attestation,
    _ie1reufq.Member member, {
    _is.Transaction? transaction,
  }) async {
    if (attestation.id == null) {
      throw ArgumentError.notNull('attestation.id');
    }
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }

    var $attestation = attestation.copyWith(memberId: member.id);
    await session.db.updateRow<Attestation>(
      $attestation,
      columns: [Attestation.t.memberId],
      transaction: transaction,
    );
  }
}
