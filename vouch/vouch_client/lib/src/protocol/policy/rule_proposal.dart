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
import '../enums/member_role.dart' as _iw6qhlck;
import '../enums/policy_effect.dart' as _imwidqua;
import '../enums/trust_tier.dart' as _i6oty1c9;

/// A rule proposed by the Nemotron rule compiler from plain-language text,
/// mirroring [PolicyRule]'s fields plus a plain-English [explanation]. Not a
/// database table: a proposal only exists in memory between `preview` and
/// `confirm` (see RulesEndpoint) and is never persisted on its own.
abstract class RuleProposal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RuleProposal._({
    this.memberId,
    this.role,
    required this.actionPattern,
    required this.requiredTier,
    _imwidqua.PolicyEffect? effect,
    this.argConditions,
    required this.explanation,
  }) : effect = effect ?? _imwidqua.PolicyEffect.require;

  factory RuleProposal({
    int? memberId,
    _iw6qhlck.MemberRole? role,
    required String actionPattern,
    required _i6oty1c9.TrustTier requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? argConditions,
    required String explanation,
  }) = _RuleProposalImpl;

  factory RuleProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleProposal(
      memberId: jsonSerialization['memberId'] as int?,
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
      argConditions: jsonSerialization['argConditions'] as String?,
      explanation: jsonSerialization['explanation'] as String,
    );
  }

  /// The member this rule applies to, if it is member-specific. Must
  /// belong to the household the proposal was generated for.
  int? memberId;

  /// The member role this rule applies to, if it is role-specific (and
  /// not member-specific).
  _iw6qhlck.MemberRole? role;

  /// Pattern matched against the requested action/tool name — must be
  /// exactly a known tool name, or a known tool name prefix ending `*`.
  String actionPattern;

  /// The minimum trust tier required for actions matching this pattern.
  _i6oty1c9.TrustTier requiredTier;

  /// Whether a match requires the tier to be met, or denies the action
  /// outright.
  _imwidqua.PolicyEffect effect;

  /// Additional argument conditions, serialized as a JSON string (e.g.
  /// `{"maxAmount":10,"currency":"EUR"}`).
  String? argConditions;

  /// Plain-English explanation of what this rule does, for the household
  /// admin to confirm before it is saved.
  String explanation;

  /// Returns a shallow copy of this [RuleProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RuleProposal copyWith({
    int? memberId,
    _iw6qhlck.MemberRole? role,
    String? actionPattern,
    _i6oty1c9.TrustTier? requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? argConditions,
    String? explanation,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleProposal',
      if (memberId != null) 'memberId': memberId,
      if (role != null) 'role': role?.toJson(),
      'actionPattern': actionPattern,
      'requiredTier': requiredTier.toJson(),
      'effect': effect.toJson(),
      if (argConditions != null) 'argConditions': argConditions,
      'explanation': explanation,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleProposal',
      if (memberId != null) 'memberId': memberId,
      if (role != null) 'role': role?.toJson(),
      'actionPattern': actionPattern,
      'requiredTier': requiredTier.toJson(),
      'effect': effect.toJson(),
      if (argConditions != null) 'argConditions': argConditions,
      'explanation': explanation,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RuleProposalImpl extends RuleProposal {
  _RuleProposalImpl({
    int? memberId,
    _iw6qhlck.MemberRole? role,
    required String actionPattern,
    required _i6oty1c9.TrustTier requiredTier,
    _imwidqua.PolicyEffect? effect,
    String? argConditions,
    required String explanation,
  }) : super._(
         memberId: memberId,
         role: role,
         actionPattern: actionPattern,
         requiredTier: requiredTier,
         effect: effect,
         argConditions: argConditions,
         explanation: explanation,
       );

  /// Returns a shallow copy of this [RuleProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RuleProposal copyWith({
    Object? memberId = _Undefined,
    Object? role = _Undefined,
    String? actionPattern,
    _i6oty1c9.TrustTier? requiredTier,
    _imwidqua.PolicyEffect? effect,
    Object? argConditions = _Undefined,
    String? explanation,
  }) {
    return RuleProposal(
      memberId: memberId is int? ? memberId : this.memberId,
      role: role is _iw6qhlck.MemberRole? ? role : this.role,
      actionPattern: actionPattern ?? this.actionPattern,
      requiredTier: requiredTier ?? this.requiredTier,
      effect: effect ?? this.effect,
      argConditions: argConditions is String?
          ? argConditions
          : this.argConditions,
      explanation: explanation ?? this.explanation,
    );
  }
}
