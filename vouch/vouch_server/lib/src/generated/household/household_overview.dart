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
import 'package:vouch_server/src/generated/protocol.dart' as _iii3n24o;
import '../household/household.dart' as _iyyunadd;
import '../identity/hub.dart' as _i52s3kbg;
import '../identity/member.dart' as _ie1reufq;

/// Everything the Flutter admin app needs for its household home screen in
/// one round trip: the household itself, all its members, and all its
/// registered hubs. Not a table — assembled on demand by
/// `HouseholdEndpoint.myHousehold`.
abstract class HouseholdOverview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  HouseholdOverview._({
    required this.household,
    required this.members,
    required this.hubs,
  });

  factory HouseholdOverview({
    required _iyyunadd.Household household,
    required List<_ie1reufq.Member> members,
    required List<_i52s3kbg.Hub> hubs,
  }) = _HouseholdOverviewImpl;

  factory HouseholdOverview.fromJson(Map<String, dynamic> jsonSerialization) {
    return HouseholdOverview(
      household: _iii3n24o.Protocol().deserialize<_iyyunadd.Household>(
        jsonSerialization['household'],
      ),
      members: _iii3n24o.Protocol().deserialize<List<_ie1reufq.Member>>(
        jsonSerialization['members'],
      ),
      hubs: _iii3n24o.Protocol().deserialize<List<_i52s3kbg.Hub>>(
        jsonSerialization['hubs'],
      ),
    );
  }

  _iyyunadd.Household household;

  List<_ie1reufq.Member> members;

  List<_i52s3kbg.Hub> hubs;

  /// Returns a shallow copy of this [HouseholdOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  HouseholdOverview copyWith({
    _iyyunadd.Household? household,
    List<_ie1reufq.Member>? members,
    List<_i52s3kbg.Hub>? hubs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HouseholdOverview',
      'household': household.toJson(),
      'members': members.toJson(valueToJson: (v) => v.toJson()),
      'hubs': hubs.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HouseholdOverview',
      'household': household.toJsonForProtocol(),
      'members': members.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'hubs': hubs.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _HouseholdOverviewImpl extends HouseholdOverview {
  _HouseholdOverviewImpl({
    required _iyyunadd.Household household,
    required List<_ie1reufq.Member> members,
    required List<_i52s3kbg.Hub> hubs,
  }) : super._(
         household: household,
         members: members,
         hubs: hubs,
       );

  /// Returns a shallow copy of this [HouseholdOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  HouseholdOverview copyWith({
    _iyyunadd.Household? household,
    List<_ie1reufq.Member>? members,
    List<_i52s3kbg.Hub>? hubs,
  }) {
    return HouseholdOverview(
      household: household ?? this.household.copyWith(),
      members: members ?? this.members.map((e0) => e0.copyWith()).toList(),
      hubs: hubs ?? this.hubs.map((e0) => e0.copyWith()).toList(),
    );
  }
}
