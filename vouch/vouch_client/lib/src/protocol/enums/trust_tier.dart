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

/// The trust tier proven by a valid attestation. Higher tiers require stronger
/// verification (voice match + liveness + optional knowledge challenge).
enum TrustTier implements _isc.SerializableModel {
  /// No verified speaker identity. Baseline / anonymous access only.
  t0,

  /// Voice match against an enrolled member, above the confidence threshold.
  t1,

  /// Voice match plus a passed knowledge-grounded challenge, or equivalent
  /// step-up. Required for privileged actions.
  t2;

  static TrustTier fromJson(String name) {
    switch (name) {
      case 't0':
        return TrustTier.t0;
      case 't1':
        return TrustTier.t1;
      case 't2':
        return TrustTier.t2;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "TrustTier"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
