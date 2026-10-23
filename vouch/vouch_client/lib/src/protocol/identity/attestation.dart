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
import '../enums/spoof_risk.dart' as _i9uqnoc2;
import '../enums/trust_tier.dart' as _i6oty1c9;
import '../identity/member.dart' as _ie1reufq;

/// A short-lived, hub-signed proof that a member was verified at a given
/// trust tier. Presented by clients to authorize privileged actions.
///
/// Covers exactly ONE utterance: it is minted for a single spoken request
/// and is not a general-purpose session credential. [expiresAt] is a short
/// validity window (~3 seconds after [capturedAt]) and it is single-use —
/// once consumed it may not be presented again (see [singleUse],
/// [consumedAt]).
abstract class Attestation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Attestation._({
    this.id,
    required this.memberId,
    this.member,
    required this.tier,
    required this.issuedAt,
    required this.expiresAt,
    required this.confidence,
    required this.spoofRisk,
    required this.hubSig,
    required this.singleUse,
    this.consumedAt,
    required this.revoked,
    required this.transcriptHash,
    required this.transcriptNormalised,
    required this.capturedAt,
  });

  factory Attestation({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required _i6oty1c9.TrustTier tier,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required double confidence,
    required _i9uqnoc2.SpoofRisk spoofRisk,
    required String hubSig,
    required bool singleUse,
    DateTime? consumedAt,
    required bool revoked,
    required String transcriptHash,
    required String transcriptNormalised,
    required DateTime capturedAt,
  }) = _AttestationImpl;

  factory Attestation.fromJson(Map<String, dynamic> jsonSerialization) {
    return Attestation(
      id: jsonSerialization['id'] as int?,
      memberId: jsonSerialization['memberId'] as int,
      member: jsonSerialization['member'] == null
          ? null
          : _iqe5q8gy.Protocol().deserialize<_ie1reufq.Member>(
              jsonSerialization['member'],
            ),
      tier: _i6oty1c9.TrustTier.fromJson((jsonSerialization['tier'] as String)),
      issuedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['issuedAt'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      confidence: (jsonSerialization['confidence'] as num).toDouble(),
      spoofRisk: _i9uqnoc2.SpoofRisk.fromJson(
        (jsonSerialization['spoofRisk'] as String),
      ),
      hubSig: jsonSerialization['hubSig'] as String,
      singleUse: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['singleUse'],
      ),
      consumedAt: jsonSerialization['consumedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['consumedAt'],
            ),
      revoked: _isc.BoolJsonExtension.fromJson(jsonSerialization['revoked']),
      transcriptHash: jsonSerialization['transcriptHash'] as String,
      transcriptNormalised: jsonSerialization['transcriptNormalised'] as String,
      capturedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['capturedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int memberId;

  /// The member this attestation asserts the identity of.
  _ie1reufq.Member? member;

  /// The trust tier proven by this attestation.
  _i6oty1c9.TrustTier tier;

  /// When the attestation was issued.
  DateTime issuedAt;

  /// When the attestation expires and can no longer be used. A short
  /// validity window — approximately 3 seconds after [capturedAt] — since
  /// the attestation covers exactly one utterance.
  DateTime expiresAt;

  /// Confidence score of the underlying voice match.
  double confidence;

  /// Anti-spoof risk signal recorded at issuance time.
  _i9uqnoc2.SpoofRisk spoofRisk;

  /// The hub's signature over the attestation payload, used to verify it
  /// was actually issued by the household's hub.
  String hubSig;

  /// Whether this attestation may only be consumed (used) once.
  bool singleUse;

  /// When a single-use attestation was consumed, if it has been.
  DateTime? consumedAt;

  /// Whether the attestation has been explicitly revoked before expiry.
  bool revoked;

  /// SHA-256 hash of the normalised transcript of the single utterance this
  /// attestation covers. Never the plaintext transcript.
  String transcriptHash;

  /// The normalised transcript text itself (see [TranscriptMatcher.normalise]),
  /// stored so the server can fuzzy-match it against the text Alexa+ hands
  /// back for the same utterance. Not biometric data — it is the spoken
  /// command text, already stripped of the wake word. [transcriptHash] must
  /// equal sha256(transcriptNormalised).
  String transcriptNormalised;

  /// When the underlying utterance audio was captured by the hub. The
  /// attestation's short validity window is measured from this timestamp.
  DateTime capturedAt;

  /// Returns a shallow copy of this [Attestation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Attestation copyWith({
    int? id,
    int? memberId,
    _ie1reufq.Member? member,
    _i6oty1c9.TrustTier? tier,
    DateTime? issuedAt,
    DateTime? expiresAt,
    double? confidence,
    _i9uqnoc2.SpoofRisk? spoofRisk,
    String? hubSig,
    bool? singleUse,
    DateTime? consumedAt,
    bool? revoked,
    String? transcriptHash,
    String? transcriptNormalised,
    DateTime? capturedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Attestation',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJson(),
      'tier': tier.toJson(),
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'confidence': confidence,
      'spoofRisk': spoofRisk.toJson(),
      'hubSig': hubSig,
      'singleUse': singleUse,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'revoked': revoked,
      'transcriptHash': transcriptHash,
      'transcriptNormalised': transcriptNormalised,
      'capturedAt': capturedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Attestation',
      if (id != null) 'id': id,
      'memberId': memberId,
      if (member != null) 'member': member?.toJsonForProtocol(),
      'tier': tier.toJson(),
      'issuedAt': issuedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      'confidence': confidence,
      'spoofRisk': spoofRisk.toJson(),
      'hubSig': hubSig,
      'singleUse': singleUse,
      if (consumedAt != null) 'consumedAt': consumedAt?.toJson(),
      'revoked': revoked,
      'transcriptHash': transcriptHash,
      'transcriptNormalised': transcriptNormalised,
      'capturedAt': capturedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AttestationImpl extends Attestation {
  _AttestationImpl({
    int? id,
    required int memberId,
    _ie1reufq.Member? member,
    required _i6oty1c9.TrustTier tier,
    required DateTime issuedAt,
    required DateTime expiresAt,
    required double confidence,
    required _i9uqnoc2.SpoofRisk spoofRisk,
    required String hubSig,
    required bool singleUse,
    DateTime? consumedAt,
    required bool revoked,
    required String transcriptHash,
    required String transcriptNormalised,
    required DateTime capturedAt,
  }) : super._(
         id: id,
         memberId: memberId,
         member: member,
         tier: tier,
         issuedAt: issuedAt,
         expiresAt: expiresAt,
         confidence: confidence,
         spoofRisk: spoofRisk,
         hubSig: hubSig,
         singleUse: singleUse,
         consumedAt: consumedAt,
         revoked: revoked,
         transcriptHash: transcriptHash,
         transcriptNormalised: transcriptNormalised,
         capturedAt: capturedAt,
       );

  /// Returns a shallow copy of this [Attestation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Attestation copyWith({
    Object? id = _Undefined,
    int? memberId,
    Object? member = _Undefined,
    _i6oty1c9.TrustTier? tier,
    DateTime? issuedAt,
    DateTime? expiresAt,
    double? confidence,
    _i9uqnoc2.SpoofRisk? spoofRisk,
    String? hubSig,
    bool? singleUse,
    Object? consumedAt = _Undefined,
    bool? revoked,
    String? transcriptHash,
    String? transcriptNormalised,
    DateTime? capturedAt,
  }) {
    return Attestation(
      id: id is int? ? id : this.id,
      memberId: memberId ?? this.memberId,
      member: member is _ie1reufq.Member? ? member : this.member?.copyWith(),
      tier: tier ?? this.tier,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      confidence: confidence ?? this.confidence,
      spoofRisk: spoofRisk ?? this.spoofRisk,
      hubSig: hubSig ?? this.hubSig,
      singleUse: singleUse ?? this.singleUse,
      consumedAt: consumedAt is DateTime? ? consumedAt : this.consumedAt,
      revoked: revoked ?? this.revoked,
      transcriptHash: transcriptHash ?? this.transcriptHash,
      transcriptNormalised: transcriptNormalised ?? this.transcriptNormalised,
      capturedAt: capturedAt ?? this.capturedAt,
    );
  }
}
