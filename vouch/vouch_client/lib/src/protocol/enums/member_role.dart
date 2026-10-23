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

/// The role a household member holds. Governs default policy expectations,
/// not authorization itself — authorization is decided by PolicyRule + tier.
enum MemberRole implements _isc.SerializableModel {
  /// Administers the household: manages members, policies, and enrolments.
  owner,

  /// A full adult member of the household.
  adult,

  /// A minor member of the household; typically subject to stricter policy.
  child,

  /// A non-resident occasional user (e.g. visiting relative, sitter).
  guest;

  static MemberRole fromJson(String name) {
    switch (name) {
      case 'owner':
        return MemberRole.owner;
      case 'adult':
        return MemberRole.adult;
      case 'child':
        return MemberRole.child;
      case 'guest':
        return MemberRole.guest;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "MemberRole"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
