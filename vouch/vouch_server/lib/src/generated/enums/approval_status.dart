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

/// Lifecycle status of a T2 step-up [Approval] request, decided by the
/// household owner from the Flutter admin app while an MCP `tools/call`
/// is paused awaiting input (see mcp/requestState in the MCP guard).
enum ApprovalStatus implements _is.SerializableModel {
  /// Awaiting an owner decision; still within [Approval.expiresAt].
  pending,

  /// Owner approved the action. May still be consumed at most once (see
  /// [Approval.used]) — approval alone does not re-run the tool.
  approved,

  /// Owner explicitly denied the action.
  denied,

  /// [Approval.expiresAt] passed with no owner decision (marked by
  /// ApprovalExpiryFutureCall).
  expired;

  static ApprovalStatus fromJson(String name) {
    switch (name) {
      case 'pending':
        return ApprovalStatus.pending;
      case 'approved':
        return ApprovalStatus.approved;
      case 'denied':
        return ApprovalStatus.denied;
      case 'expired':
        return ApprovalStatus.expired;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ApprovalStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
