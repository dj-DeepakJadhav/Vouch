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

/// Result of `DemoEndpoint.start`: the ids the app needs to drive the
/// simulated Alexa tab. Carries no key material and no token (mint one with
/// `DemoEndpoint.mintMcpToken`).
abstract class DemoStart
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DemoStart._({
    required this.householdId,
    required this.hubId,
    required this.ownerMemberId,
    required this.childMemberId,
  });

  factory DemoStart({
    required int householdId,
    required int hubId,
    required int ownerMemberId,
    required int childMemberId,
  }) = _DemoStartImpl;

  factory DemoStart.fromJson(Map<String, dynamic> jsonSerialization) {
    return DemoStart(
      householdId: jsonSerialization['householdId'] as int,
      hubId: jsonSerialization['hubId'] as int,
      ownerMemberId: jsonSerialization['ownerMemberId'] as int,
      childMemberId: jsonSerialization['childMemberId'] as int,
    );
  }

  int householdId;

  int hubId;

  int ownerMemberId;

  int childMemberId;

  /// Returns a shallow copy of this [DemoStart]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DemoStart copyWith({
    int? householdId,
    int? hubId,
    int? ownerMemberId,
    int? childMemberId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemoStart',
      'householdId': householdId,
      'hubId': hubId,
      'ownerMemberId': ownerMemberId,
      'childMemberId': childMemberId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DemoStart',
      'householdId': householdId,
      'hubId': hubId,
      'ownerMemberId': ownerMemberId,
      'childMemberId': childMemberId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DemoStartImpl extends DemoStart {
  _DemoStartImpl({
    required int householdId,
    required int hubId,
    required int ownerMemberId,
    required int childMemberId,
  }) : super._(
         householdId: householdId,
         hubId: hubId,
         ownerMemberId: ownerMemberId,
         childMemberId: childMemberId,
       );

  /// Returns a shallow copy of this [DemoStart]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DemoStart copyWith({
    int? householdId,
    int? hubId,
    int? ownerMemberId,
    int? childMemberId,
  }) {
    return DemoStart(
      householdId: householdId ?? this.householdId,
      hubId: hubId ?? this.hubId,
      ownerMemberId: ownerMemberId ?? this.ownerMemberId,
      childMemberId: childMemberId ?? this.childMemberId,
    );
  }
}
