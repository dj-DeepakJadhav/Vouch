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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:vouch_client/src/protocol/protocol.dart' as _iqe5q8gy;
import '../household/household.dart' as _iyyunadd;

/// A one-time, short-lived 6-digit code the hub prints (`python -m
/// vouch_hub pair`) so the household owner can link their anonymous
/// Flutter-app session to this household without ever creating a
/// password. Only the SHA-256 hash of the code is stored — the raw code
/// exists only in the hub's terminal output and the redeem request, never
/// at rest — mirroring `McpClient.tokenHash`'s treatment of bearer tokens.
abstract class PairingCode
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      codeHash: jsonSerialization['codeHash'] as String,
      ownerId: jsonSerialization['ownerId'] as int,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [PairingCode]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
