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
import '../enums/member_role.dart' as _iw6qhlck;
import '../enums/member_status.dart' as _i7h4j7gq;
import '../household/household.dart' as _iyyunadd;

/// A person belonging to a household who can be voice-enrolled and issued
/// attestations.
abstract class Member
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Member._({
    this.id,
    required this.householdId,
    this.household,
    required this.displayName,
    required this.role,
    required this.status,
    this.authUserId,
  });

  factory Member({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String displayName,
    required _iw6qhlck.MemberRole role,
    required _i7h4j7gq.MemberStatus status,
    String? authUserId,
  }) = _MemberImpl;

  factory Member.fromJson(Map<String, dynamic> jsonSerialization) {
    return Member(
      id: jsonSerialization['id'] as int?,
      householdId: jsonSerialization['householdId'] as int,
      household: jsonSerialization['household'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      displayName: jsonSerialization['displayName'] as String,
      role: _iw6qhlck.MemberRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: _i7h4j7gq.MemberStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      authUserId: jsonSerialization['authUserId'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int householdId;

  /// The household this member belongs to.
  _iyyunadd.Household? household;

  /// The member's display name, shown in admin UI and audit logs.
  String displayName;

  /// The member's role within the household.
  _iw6qhlck.MemberRole role;

  /// The current lifecycle status of the member's enrolment.
  _i7h4j7gq.MemberStatus status;

  /// The Serverpod auth `userIdentifier` (UUID string) of the signed-in
  /// user this member corresponds to, if this member has a linked login
  /// (e.g. the household owner, who signs in to the Flutter admin app).
  /// Null for members with no login of their own (e.g. a child who is
  /// never expected to sign in). Used to resolve `session.authenticated`
  /// to a `Member` row for owner-only authorization checks (see
  /// ApprovalEndpoint).
  String? authUserId;

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Member copyWith({
    int? id,
    int? householdId,
    _iyyunadd.Household? household,
    String? displayName,
    _iw6qhlck.MemberRole? role,
    _i7h4j7gq.MemberStatus? status,
    String? authUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJson(),
      'displayName': displayName,
      'role': role.toJson(),
      'status': status.toJson(),
      if (authUserId != null) 'authUserId': authUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'householdId': householdId,
      if (household != null) 'household': household?.toJsonForProtocol(),
      'displayName': displayName,
      'role': role.toJson(),
      'status': status.toJson(),
      if (authUserId != null) 'authUserId': authUserId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberImpl extends Member {
  _MemberImpl({
    int? id,
    required int householdId,
    _iyyunadd.Household? household,
    required String displayName,
    required _iw6qhlck.MemberRole role,
    required _i7h4j7gq.MemberStatus status,
    String? authUserId,
  }) : super._(
         id: id,
         householdId: householdId,
         household: household,
         displayName: displayName,
         role: role,
         status: status,
         authUserId: authUserId,
       );

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Member copyWith({
    Object? id = _Undefined,
    int? householdId,
    Object? household = _Undefined,
    String? displayName,
    _iw6qhlck.MemberRole? role,
    _i7h4j7gq.MemberStatus? status,
    Object? authUserId = _Undefined,
  }) {
    return Member(
      id: id is int? ? id : this.id,
      householdId: householdId ?? this.householdId,
      household: household is _iyyunadd.Household?
          ? household
          : this.household?.copyWith(),
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      status: status ?? this.status,
      authUserId: authUserId is String? ? authUserId : this.authUserId,
    );
  }
}
