import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'verdict_card_view_native.dart'
    if (dart.library.html) 'verdict_card_view_web.dart'
    as impl;

/// Renders the `ui://vouch/verdict` MCP Apps card next to the existing
/// decision-trace panel. On Flutter web this embeds the real HTML resource
/// in a sandboxed iframe (`sandbox="allow-scripts"`, no
/// `allow-same-origin`) and pushes per-call data in with the spec's
/// `ui/notifications/tool-result` postMessage, per SEP-1865 (stable spec
/// 2026-01-26 — see vouch_server's verdict_card.dart doc comment for the
/// exact field names and source URL). On other platforms (no iframe host
/// available) it falls back to rendering the same fields as native Flutter
/// widgets — see verdict_card_view_native.dart.
class VerdictCardView extends StatelessWidget {
  const VerdictCardView({super.key, required this.html, required this.vouch});

  /// The card's self-contained HTML, from `resources/read`. Null while it
  /// hasn't been fetched yet.
  final String? html;

  /// The latest `structuredContent.vouch` map to render/push into the card.
  final Map<String, dynamic>? vouch;

  @override
  Widget build(BuildContext context) {
    if (vouch == null) return const SizedBox.shrink();
    final c = context.v;
    return Padding(
      key: const Key('mcp-apps-verdict-card'),
      padding: const EdgeInsets.only(top: VSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: VSpace.s2,
            children: [
              Text(
                'MCP Apps verdict card',
                style: VType.label.copyWith(color: c.textPrimary),
              ),
              Text(
                'ui://vouch/verdict · read-only',
                style: VType.codeSm.copyWith(color: c.textSecondary),
              ),
            ],
          ),
          impl.buildVerdictCard(context, html: html, vouch: vouch!),
        ],
      ),
    );
  }
}
