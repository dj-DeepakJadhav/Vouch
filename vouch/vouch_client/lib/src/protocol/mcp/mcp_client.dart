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

/// A bearer-token credential authorizing an MCP client (e.g. an Alexa+
/// skill instance) to call the MCP server (POST /mcp) on behalf of one
/// household. The raw token is issued out-of-band and never stored; only
/// its SHA-256 hash is kept, so a database compromise does not disclose
/// usable credentials.
abstract class McpClient
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      tokenHash: jsonSerialization['tokenHash'] as String,
      label: jsonSerialization['label'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      revoked: _isc.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [McpClient]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
