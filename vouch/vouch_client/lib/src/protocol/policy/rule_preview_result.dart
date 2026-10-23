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
import '../policy/rule_proposal.dart' as _i7uf0u5r;

/// The result of compiling plain-language rule text into proposals (see
/// RulesEndpoint.preview). Nothing here is ever persisted — proposals only
/// become PolicyRule rows via RulesEndpoint.confirm.
abstract class RulePreviewResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RulePreviewResult._({
    required this.proposals,
    required this.rejected,
    required this.rawModelOutput,
  });

  factory RulePreviewResult({
    required List<_i7uf0u5r.RuleProposal> proposals,
    required List<String> rejected,
    required String rawModelOutput,
  }) = _RulePreviewResultImpl;

  factory RulePreviewResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return RulePreviewResult(
      proposals: _iqe5q8gy.Protocol().deserialize<List<_i7uf0u5r.RuleProposal>>(
        jsonSerialization['proposals'],
      ),
      rejected: _iqe5q8gy.Protocol().deserialize<List<String>>(
        jsonSerialization['rejected'],
      ),
      rawModelOutput: jsonSerialization['rawModelOutput'] as String,
    );
  }

  /// Proposals that passed strict server-side validation.
  List<_i7uf0u5r.RuleProposal> proposals;

  /// A human-readable rejection reason for every proposal (well-formed or
  /// not) that failed validation.
  List<String> rejected;

  /// The raw text Nemotron returned, for debugging/reporting.
  String rawModelOutput;

  /// Returns a shallow copy of this [RulePreviewResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RulePreviewResult copyWith({
    List<_i7uf0u5r.RuleProposal>? proposals,
    List<String>? rejected,
    String? rawModelOutput,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RulePreviewResult',
      'proposals': proposals.toJson(valueToJson: (v) => v.toJson()),
      'rejected': rejected.toJson(),
      'rawModelOutput': rawModelOutput,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RulePreviewResult',
      'proposals': proposals.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'rejected': rejected.toJson(),
      'rawModelOutput': rawModelOutput,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RulePreviewResultImpl extends RulePreviewResult {
  _RulePreviewResultImpl({
    required List<_i7uf0u5r.RuleProposal> proposals,
    required List<String> rejected,
    required String rawModelOutput,
  }) : super._(
         proposals: proposals,
         rejected: rejected,
         rawModelOutput: rawModelOutput,
       );

  /// Returns a shallow copy of this [RulePreviewResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RulePreviewResult copyWith({
    List<_i7uf0u5r.RuleProposal>? proposals,
    List<String>? rejected,
    String? rawModelOutput,
  }) {
    return RulePreviewResult(
      proposals:
          proposals ?? this.proposals.map((e0) => e0.copyWith()).toList(),
      rejected: rejected ?? this.rejected.map((e0) => e0).toList(),
      rawModelOutput: rawModelOutput ?? this.rawModelOutput,
    );
  }
}
