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
import '../enums/challenge_outcome.dart' as _ib8tgtzr;
import '../identity/member.dart' as _ie1reufq;

/// A knowledge-grounded step-up challenge issued to a member. Passing it
/// proves household knowledge that a voice clone alone would not have.
abstract class Challenge
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Challenge._({
    this.id,
    required this.memberId,
    this.member,
    required this.question,
    required this.answerHash,
    required this.contextSource,
    required this.issuedAt,
    required this.expiresAt,
    this.consumedAt,
    this.outcome,
  });

  factory Challenge({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required String question,
    required String answerHash,
    required String contextSource,
    required DateTime issuedAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  }) = _ChallengeImpl;

  factory Challenge.fromJson(Map<String, dynamic> jsonSerialization) {
    return Challenge(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      question: jsonSerialization['question'] as String,
      answerHash: jsonSerialization['answerHash'] as String,
      contextSource: jsonSerialization['contextSource'] as String,
      issuedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['issuedAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['consumedAt'],
            ),
      outcome: jsonSerialization['outcome'] == null
          ? null
          : _ib8tgtzr.ChallengeOutcome.fromJson(
              (jsonSerialization['outcome'] as String),
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int memberId;

  /// The member this challenge was issued to.
  _ie1reufq.Member? member;

  /// The question text presented to the member.
  String question;

  /// Hash of the expected answer; the plaintext answer is never stored.
  String answerHash;

  /// Identifier of the source used to ground the question (e.g. which
  /// household fact / record it was derived from).
  String contextSource;

  /// When the challenge was issued.
  DateTime issuedAt;

  /// When the challenge expires if left unanswered.
  DateTime expiresAt;

  /// When the challenge was answered/consumed, if it has been.
  DateTime? consumedAt;

  /// The result of the challenge, once resolved.
  _ib8tgtzr.ChallengeOutcome? outcome;

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Challenge copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    String? question,
    String? answerHash,
    String? contextSource,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Challenge',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'question': question,
      'answerHash': answerHash,
      'contextSource': contextSource,
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      if (outcome != null) 'outcome': outcome?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Challenge',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'question': question,
      'answerHash': answerHash,
      'contextSource': contextSource,
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      if (outcome != null) 'outcome': outcome?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChallengeImpl extends Challenge {
  _ChallengeImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required String question,
    required String answerHash,
    required String contextSource,
    required DateTime issuedAt,
    required DateTime expiresAt,
    DateTime? consumedAt,
    _ib8tgtzr.ChallengeOutcome? outcome,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         question: question,
         answerHash: answerHash,
         contextSource: contextSource,
         issuedAt: issuedAt,
         expiresAt: expiresAt,
         consumedAt: consumedAt,
         outcome: outcome,
       );

  /// Returns a shallow copy of this [Challenge]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Challenge copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    String? question,
    String? answerHash,
    String? contextSource,
    DateTime? issuedAt,
    DateTime? expiresAt,
    Object? consumedAt = _Undefined,
    Object? outcome = _Undefined,
  }) {
    return Challenge(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      question: question ?? this.question,
      answerHash: answerHash ?? this.answerHash,
      contextSource: contextSource ?? this.contextSource,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      outcome: outcome is _ib8tgtzr.ChallengeOutcome? ? outcome : this.outcome,
    );
  }
}
