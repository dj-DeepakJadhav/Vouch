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

/// A physical hub device (mic, VAD, TitaNet embeddings, attestation signing)
/// deployed for a household.
abstract class Hub
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      publicKey: jsonSerialization['publicKey'] as String,
      lastSeen: jsonSerialization['lastSeen'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeen']),
      version: jsonSerialization['version'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [Hub]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
