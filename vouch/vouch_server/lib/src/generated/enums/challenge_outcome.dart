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

/// The result of a knowledge-grounded challenge issued as a step-up check.
enum ChallengeOutcome implements _is.SerializableModel {
  /// The member answered correctly and the challenge was consumed.
  passed,

  /// The member answered incorrectly.
  failed,

  /// The challenge was not answered before its expiry and lapsed unused.
  expired;

  static ChallengeOutcome fromJson(String name) {
    switch (name) {
      case 'passed':
        return ChallengeOutcome.passed;
      case 'failed':
        return ChallengeOutcome.failed;
      case 'expired':
        return ChallengeOutcome.expired;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ChallengeOutcome"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
