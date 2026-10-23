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
import '../enums/policy_effect.dart' as _imwidqua;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../household/household.dart' as _iyyunadd;
import '../identity/member.dart' as _ie1reufq;

/// A household-configured rule mapping an action pattern to the minimum
/// trust tier required to permit it.
abstract class PolicyRule
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
          : _iqe5q8gy.Protocol().deserialize<_iyyunadd.Household>(
              jsonSerialization['household'],
            ),
      memberId: jsonSerialization['memberId'] as int?,
      member: jsonSerialization['member'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_ie1reufq.Member>(
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
      enabled: _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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

  /// Returns a shallow copy of this [PolicyRule]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
