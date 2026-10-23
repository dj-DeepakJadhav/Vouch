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

/// The outcome recorded for an access decision in the append-only audit log.
enum AuditDecision implements _is.SerializableModel {
  /// The action was allowed to proceed at the presented trust tier.
  permitted,

  /// The action required step-up verification (a knowledge challenge) before
  /// being allowed to proceed.
  challenged,

  /// The action was refused because the required trust tier was not met.
  denied,

  /// The action was refused because the presented attestation had been
  /// revoked.
  revoked;

  static AuditDecision fromJson(String name) {
    switch (name) {
      case 'permitted':
        return AuditDecision.permitted;
      case 'challenged':
        return AuditDecision.challenged;
      case 'denied':
        return AuditDecision.denied;
      case 'revoked':
        return AuditDecision.revoked;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "AuditDecision"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
