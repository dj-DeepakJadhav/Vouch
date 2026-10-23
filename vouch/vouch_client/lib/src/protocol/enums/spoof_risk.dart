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

/// Output of the anti-spoof classifier run on the hub at enrolment/attestation
/// time. This is a signal, not a security boundary — see VOUCH-DESIGN.md §8.
enum SpoofRisk implements _isc.SerializableModel {
  /// No indicators of a replayed, synthetic, or cloned voice sample.
  low,

  /// Some indicators present; attestation may still be issued but should be
  /// weighed alongside other signals (e.g. requiring a challenge).
  medium,

  /// Strong indicators of spoofing. Attestation issuance should be refused.
  high;

  static SpoofRisk fromJson(String name) {
    switch (name) {
      case 'low':
        return SpoofRisk.low;
      case 'medium':
        return SpoofRisk.medium;
      case 'high':
        return SpoofRisk.high;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "SpoofRisk"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
