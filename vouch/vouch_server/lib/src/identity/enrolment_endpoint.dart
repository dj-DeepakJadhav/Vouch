import 'package:serverpod/serverpod.dart';

import '../attestation/attestation_signature.dart';
import '../generated/protocol.dart';
import 'enrolment_signature.dart';

/// Raised by [EnrolmentEndpoint.report] when a hub-signed enrolment report
/// is rejected. Mirrors `AttestationRejected`'s shape.
class EnrolmentRejected implements Exception {
  const EnrolmentRejected(this.reason);
  final String reason;

  @override
  String toString() => 'EnrolmentRejected: $reason';
}

/// Endpoint the hub calls right after it saves a local voiceprint centroid,
/// so the server (and Flutter admin app) can show enrolment status without
/// ever seeing the voiceprint itself — only an opaque `embeddingRef` plus
/// quality metadata is stored. Reuses the pre-existing `Enrolment` model
/// (identity/enrolment.spy.yaml) rather than adding a new table.
///
/// Ed25519-signed by the hub over the canonical payload built from exactly
/// the reported fields (see [EnrolmentSignature.canonicalPayload]), the
/// same signing discipline as attestation submission.
class EnrolmentEndpoint extends Endpoint {
  Future<Enrolment> report(
    Session session, {
    required int hubId,
    required int memberId,
    required String embeddingRef,
    required double qualityScore,
    required int sampleCount,
    required DateTime capturedAt,
    required String signatureBase64,
  }) async {
    final hub = await Hub.db.findById(session, hubId);
    if (hub == null) {
      throw const EnrolmentRejected('unknown_hub');
    }

    final member = await Member.db.findById(session, memberId);
    if (member == null || member.householdId != hub.householdId) {
      throw const EnrolmentRejected('member_not_in_household');
    }

    final capturedAtUtc = capturedAt.toUtc();
    final payload = EnrolmentSignature.canonicalPayload(
      hubId: hubId,
      memberId: memberId,
      embeddingRef: embeddingRef,
      qualityScore: qualityScore,
      sampleCount: sampleCount,
      capturedAt: capturedAtUtc,
    );

    final signatureValid = await AttestationSignature.verify(
      payload: payload,
      signatureBase64: signatureBase64,
      publicKeyBase64: hub.publicKey,
    );
    if (!signatureValid) {
      throw const EnrolmentRejected('invalid_signature');
    }

    final existing = await Enrolment.db.findFirstRow(
      session,
      where: (t) => t.memberId.equals(memberId),
    );

    if (existing == null) {
      return Enrolment.db.insertRow(
        session,
        Enrolment(
          memberId: memberId,
          hubId: hubId,
          embeddingRef: embeddingRef,
          qualityScore: qualityScore,
          sampleCount: sampleCount,
          enrolledAt: capturedAtUtc,
        ),
      );
    }

    // Re-enrolment: replace the previous enrolment outright (clearing any
    // prior revocation) rather than inserting a second row — see the
    // model's unique `enrolment_member_idx`.
    return Enrolment.db.updateRow(
      session,
      existing.copyWith(
        hubId: hubId,
        embeddingRef: embeddingRef,
        qualityScore: qualityScore,
        sampleCount: sampleCount,
        enrolledAt: capturedAtUtc,
        revokedAt: null,
      ),
    );
  }
}
