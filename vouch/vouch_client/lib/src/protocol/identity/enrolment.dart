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
import '../identity/hub.dart' as _i52s3kbg;
import '../identity/member.dart' as _ie1reufq;

/// A voice enrolment linking a member to a hub. Records only an opaque
/// pointer to the voiceprint, never the biometric data itself.
abstract class Enrolment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Enrolment._({
    this.id,
    required this.memberId,
    this.member,
    required this.hubId,
    this.hub,
    required this.embeddingRef,
    required this.qualityScore,
    required this.sampleCount,
    required this.enrolledAt,
    this.revokedAt,
  });

  factory Enrolment({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required int hubId,
    _i52s3kbg.Hub? hub,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime enrolledAt,
    DateTime? revokedAt,
  }) = _EnrolmentImpl;

  factory Enrolment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Enrolment(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      hubId: jsonSerialization['hubId'] as int,
      hub: jsonSerialization['hub'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_i52s3kbg.Hub>(
              jsonSerialization['hub'],
            ),
      embeddingRef: jsonSerialization['embeddingRef'] as String,
      qualityScore: (jsonSerialization['qualityScore'] as num).toDouble(),
      sampleCount: jsonSerialization['sampleCount'] as int,
      enrolledAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['enrolledAt'],
      ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int memberId;

  /// The member this enrolment belongs to.
  _ie1reufq.Member? member;

  int hubId;

  /// The hub this enrolment was captured on and is stored against.
  _i52s3kbg.Hub? hub;

  /// Opaque pointer to the enrolled voiceprint, kept on the hub. This is
  /// NEVER a biometric vector or embedding — Serverpod stores only a
  /// reference, and even full database compromise yields no biometric data
  /// (see VOUCH-DESIGN.md §8).
  String embeddingRef;

  /// Quality score of the enrolment sample(s), used to decide whether
  /// re-enrolment is needed.
  double qualityScore;

  /// Number of voice samples used to build this enrolment.
  int sampleCount;

  /// When the enrolment was completed.
  DateTime enrolledAt;

  /// When the enrolment was revoked, if it has been.
  DateTime? revokedAt;

  /// Returns a shallow copy of this [Enrolment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Enrolment copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    int? hubId,
    _i52s3kbg.Hub? hub,
    String? embeddingRef,
    double? qualityScore,
    int? sampleCount,
    DateTime? enrolledAt,
    DateTime? revokedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Enrolment',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'hubId': hubId,
      if (hub != null) 'hub': hub?.toJson(),
      'embeddingRef': embeddingRef,
      'qualityScore': qualityScore,
      'sampleCount': sampleCount,
      'enrolledAt': enrolledAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Enrolment',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'hubId': hubId,
      if (hub != null) 'hub': hub?.toJsonForProtocol(),
      'embeddingRef': embeddingRef,
      'qualityScore': qualityScore,
      'sampleCount': sampleCount,
      'enrolledAt': enrolledAt.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnrolmentImpl extends Enrolment {
  _EnrolmentImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required int hubId,
    _i52s3kbg.Hub? hub,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime enrolledAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         hubId: hubId,
         hub: hub,
         embeddingRef: embeddingRef,
         qualityScore: qualityScore,
         sampleCount: sampleCount,
         enrolledAt: enrolledAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [Enrolment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Enrolment copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    int? hubId,
    Object? hub = _Undefined,
    String? embeddingRef,
    double? qualityScore,
    int? sampleCount,
    DateTime? enrolledAt,
    Object? revokedAt = _Undefined,
  }) {
    return Enrolment(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      hubId: hubId ?? this.hubId,
      hub: hub is _i52s3kbg.Hub? ? hub : this.hub?.copyWith(),
      embeddingRef: embeddingRef ?? this.embeddingRef,
      qualityScore: qualityScore ?? this.qualityScore,
      sampleCount: sampleCount ?? this.sampleCount,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
    );
  }
}
