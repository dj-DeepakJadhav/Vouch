import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web implementation: renders the real `ui://vouch/verdict` HTML resource
/// in a sandboxed iframe, per MCP Apps (SEP-1865, stable spec 2026-01-26).
///
/// Sandbox: `allow-scripts` only — deliberately WITHOUT `allow-same-origin`,
/// so the iframe's origin stays opaque/null and it cannot read this page's
/// DOM, cookies or storage even though it can run its own inline script.
/// This is a stricter subset of what the spec's own reference
/// implementation uses (spec section "Sandbox Attributes" quotes
/// `allow-scripts allow-same-origin` together with a *dedicated,
/// cross-origin sandbox domain* to make that combination safe — we don't
/// have that separate domain in this dev setup, so we drop
/// `allow-same-origin` rather than accept the same-origin risk).
///
/// Messaging: the spec's Host->View protocol
/// (`ui/notifications/tool-input` / `ui/notifications/tool-result`) is
/// implemented as plain `postMessage` JSON-RPC-shaped notifications, sent
/// once the iframe loads. The view (verdict_card.dart) only ever answers
/// with its own lifecycle notifications — no tool-call ever crosses this
/// boundary, satisfying the read-only requirement.
Widget buildVerdictCard(
  BuildContext context, {
  required String? html,
  required Map<String, dynamic> vouch,
}) {
  if (html == null) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text('Loading verdict card…'),
    );
  }

  // One view type per distinct HTML payload (the resource is a static
  // template, so in practice this registers once and is reused).
  final viewType = 'vouch-verdict-${html.hashCode}';
  // The factory below runs once per view type, so it must not capture this
  // call's [vouch]: read the latest one, and push it to live iframes.
  _latestVouch = vouch;
  for (final iframe in _iframes) {
    _postVouch(iframe, vouch);
  }

  if (!_registered.contains(viewType)) {
    _registered.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe = web.HTMLIFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '220px'
        ..setAttribute('sandbox', 'allow-scripts')
        ..srcdoc = html.toJS;

      _iframes.add(iframe);
      iframe.onLoad.listen((_) {
        final latest = _latestVouch;
        if (latest != null) _postVouch(iframe, latest);
      });
      return iframe;
    });
  }

  return SizedBox(
    height: 220,
    child: HtmlElementView(viewType: viewType),
  );
}

final Set<String> _registered = {};
Map<String, dynamic>? _latestVouch;
final Set<web.HTMLIFrameElement> _iframes = {};

void _postVouch(web.HTMLIFrameElement iframe, Map<String, dynamic> vouch) {
  final message = {
    'jsonrpc': '2.0',
    'method': 'ui/notifications/tool-result',
    'params': {
      'structuredContent': {'vouch': vouch},
    },
  };
  final contentWindow = iframe.contentWindow;
  if (contentWindow == null) return;
  // '*' target origin: the iframe is `srcdoc`-loaded (origin "null"), so a
  // specific target origin can't be named; the card contains no secret
  // data beyond what the calling app already displays in its own
  // decision-trace panel.
  contentWindow.postMessage(jsonEncode(message).toJS, '*'.toJS);
}
