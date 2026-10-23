import 'package:flutter/material.dart';
import 'package:vouch_client/vouch_client.dart';

import '../app/theme.dart';

/// Native-Flutter fallback rendering of the `ui://vouch/verdict` fields,
/// used on platforms without an iframe host (see verdict_card_view.dart).
/// Same fields as the HTML card, same tier colours as the rest of the app
/// (`app/theme.dart`'s `tierColor`), and equally read-only: no buttons, no
/// actions.
Widget buildVerdictCard(
  BuildContext context, {
  required String? html,
  required Map<String, dynamic> vouch,
}) {
  final speaker = vouch['speaker'] as Map<String, dynamic>?;
  final speakerName = speaker?['displayName'] as String? ?? 'Not recognised';
  final confidence = (vouch['confidence'] as num?)?.toDouble();
  final attestationMatched = vouch['attestationMatched'] as bool? ?? false;
  final matchedTranscript = vouch['matchedTranscript'] as String?;
  final presentTierName = vouch['presentTier'] as String?;
  final decision = vouch['decision'] as String? ?? '—';
  final reason = vouch['reason'] as String?;
  final tier = _tierFromName(presentTierName);
  final stepUp = decision == 'stepUp' || decision == 'pending';

  final match = !attestationMatched
      ? 'none'
      : (matchedTranscript?.isNotEmpty ?? false)
      ? 'matched'
      : 'none';

  return Card(
    margin: const EdgeInsets.only(top: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Speaker', speakerName),
          _row('Match', match),
          _row(
            'Confidence',
            confidence != null ? '${(confidence * 100).round()}%' : '—',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tier'),
              if (tier != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tierColor(tier).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tierLabel(tier),
                    style: TextStyle(
                      color: tierColor(tier),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          _row('Decision', decision),
          if (reason != null) ...[
            const SizedBox(height: 4),
            Text(
              reason,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          if (stepUp) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tierColor(TrustTier.t2).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Waiting for the owner's approval on their phone",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _row(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 2),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  ),
);

TrustTier? _tierFromName(String? name) {
  if (name == null) return null;
  for (final t in TrustTier.values) {
    if (t.name == name) return t;
  }
  return null;
}
