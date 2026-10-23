import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'attestation_service.dart';

/// Endpoint the hub calls to submit a freshly signed attestation.
///
/// Intentionally exposes only [submit]. [AttestationService.consumeMatching]
/// is deliberately NOT exposed here — it is called internally by the
/// (future) MCP guard, never directly by a client, since consumption must
/// always be paired with independent verification of the presented
/// attestation, not driven by an untrusted caller supplying arbitrary
/// command text.
class AttestationEndpoint extends Endpoint {
  Future<Attestation> submit(
    Session session, {
    required int hubId,
    required int memberId,
    required TrustTier tier,
    required double confidence,
    required SpoofRisk spoofRisk,
    required String transcriptNormalised,
    required DateTime capturedAt,
    required String signatureBase64,
  }) {
    return AttestationService.submit(
      session,
      hubId: hubId,
      memberId: memberId,
      tier: tier,
      confidence: confidence,
      spoofRisk: spoofRisk,
      transcriptNormalised: transcriptNormalised,
      capturedAt: capturedAt,
      signatureBase64: signatureBase64,
    );
  }
}
