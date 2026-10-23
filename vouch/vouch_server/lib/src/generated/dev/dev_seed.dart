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

/// Result of `DevEndpoint.seedDemoHousehold`: the ids of everything just
/// created, plus the raw MCP bearer token (returned once — only its hash
/// is persisted). Not a database table; a plain transfer object for the
/// dev-only seeding endpoint.
abstract class DemoSeed
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DemoSeed._({
    required this.householdId,
    required this.hubId,
    required this.ownerMemberId,
    required this.childMemberId,
    required this.mcpToken,
  });

  factory DemoSeed({
    required int householdId,
    required int hubId,
    required int ownerMemberId,
    required int childMemberId,
    required String mcpToken,
  }) = _DemoSeedImpl;

  factory DemoSeed.fromJson(Map<String, dynamic> jsonSerialization) {
    return DemoSeed(
      householdId: jsonSerialization['householdId'] as int,
      hubId: jsonSerialization['hubId'] as int,
      ownerMemberId: jsonSerialization['ownerMemberId'] as int,
      childMemberId: jsonSerialization['childMemberId'] as int,
      mcpToken: jsonSerialization['mcpToken'] as String,
    );
  }

  /// The newly created household's id.
  int householdId;

  /// The newly created hub's id.
  int hubId;

  /// The newly created owner member's id.
  int ownerMemberId;

  /// The newly created child member's id.
  int childMemberId;

  /// The raw (unhashed) MCP bearer token for the new `McpClient` row.
  /// Shown once here; only its SHA-256 hash is stored server-side.
  String mcpToken;

  /// Returns a shallow copy of this [DemoSeed]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DemoSeed copyWith({
    int? householdId,
    int? hubId,
    int? ownerMemberId,
    int? childMemberId,
    String? mcpToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemoSeed',
      'householdId': householdId,
      'hubId': hubId,
      'ownerMemberId': ownerMemberId,
      'childMemberId': childMemberId,
      'mcpToken': mcpToken,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DemoSeed',
      'householdId': householdId,
      'hubId': hubId,
      'ownerMemberId': ownerMemberId,
      'childMemberId': childMemberId,
      'mcpToken': mcpToken,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DemoSeedImpl extends DemoSeed {
  _DemoSeedImpl({
    required int householdId,
    required int hubId,
    required int ownerMemberId,
    required int childMemberId,
    required String mcpToken,
  }) : super._(
         householdId: householdId,
         hubId: hubId,
         ownerMemberId: ownerMemberId,
         childMemberId: childMemberId,
         mcpToken: mcpToken,
       );

  /// Returns a shallow copy of this [DemoSeed]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DemoSeed copyWith({
    int? householdId,
    int? hubId,
    int? ownerMemberId,
    int? childMemberId,
    String? mcpToken,
  }) {
    return DemoSeed(
      householdId: householdId ?? this.householdId,
      hubId: hubId ?? this.hubId,
      ownerMemberId: ownerMemberId ?? this.ownerMemberId,
      childMemberId: childMemberId ?? this.childMemberId,
      mcpToken: mcpToken ?? this.mcpToken,
    );
  }
}
