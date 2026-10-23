import 'dart:convert';

import 'mcp_guard.dart';

/// MCP Apps (SEP-1865, stable spec 2026-01-26) `ui://` verdict card.
///
/// Field names below are taken verbatim from the spec file fetched from
/// https://raw.githubusercontent.com/modelcontextprotocol/ext-apps/main/specification/2026-01-26/apps.mdx
/// (also published at specification/2026-01-26/apps.mdx in
/// github.com/modelcontextprotocol/ext-apps), not guessed:
///   - MIME type MUST be `text/html;profile=mcp-app` ("Content Requirements").
///   - A tool links to its UI resource via `_meta.ui.resourceUri` (the flat
///     `_meta["ui/resourceUri"]` form is explicitly deprecated).
///   - `resources/read` returns `{ contents: [{ uri, mimeType, text, _meta? }] }`.
///   - The View/Host handshake is `ui/initialize` -> `ui/notifications/initialized`,
///     after which the Host sends `ui/notifications/tool-input` and then
///     `ui/notifications/tool-result` (method names quoted verbatim from the
///     "Communication Protocol" section).
///
/// This card is READ-ONLY by design (hard security requirement): it never
/// renders a `<form`, a `<button` that
/// posts or calls a tool, or any script that calls `postMessage` back into
/// the host with a tool-call request. It only *receives* the trace and
/// paints it. That is a deliberate subset of the full MCP Apps bidirectional
/// protocol — we still speak the View->Host `ui/initialize` handshake and
/// accept `ui/notifications/tool-result` so a spec-compliant host can embed
/// it, but the card never sends anything back except (harmlessly) its own
/// `ui/notifications/initialized` and `ui/notifications/size-changed`.
const String verdictResourceUri = 'ui://vouch/verdict';
const String verdictResourceName = 'vouch_verdict';
const String verdictResourceMimeType = 'text/html;profile=mcp-app';

/// `_meta.ui` block to attach to every guarded tool's definition, per the
/// spec's "Resource Discovery" section (`McpUiToolMeta.resourceUri`).
Map<String, dynamic> get verdictUiMeta => {
  'ui': {
    'resourceUri': verdictResourceUri,
    // Visible to both the agent ("model") and the calling app/host ("app"),
    // which is the spec's own default — listed explicitly for clarity.
    'visibility': ['model', 'app'],
  },
};

/// `resources/list` entry for the verdict card (spec `UIResource` shape).
Map<String, dynamic> verdictResourceListEntry() => {
  'uri': verdictResourceUri,
  'name': verdictResourceName,
  'description':
      'Read-only per-command verdict: who spoke, match, tier, decision.',
  'mimeType': verdictResourceMimeType,
};

/// `resources/read` result for the verdict card (spec `resources/read`
/// response shape: `{ contents: [{ uri, mimeType, text, _meta }] }`).
/// The HTML is generic (spec allows a single template resource reused for
/// every tool call; per-call data arrives later via
/// `ui/notifications/tool-result`), so it does not depend on [trace] — the
/// [trace] parameter only lets a caller ship it pre-rendered as a fallback
/// for hosts that don't implement the postMessage protocol at all.
Map<String, dynamic> verdictResourceReadResult({VouchTrace? trace}) => {
  'contents': [
    {
      'uri': verdictResourceUri,
      'mimeType': verdictResourceMimeType,
      'text': buildVerdictCardHtml(trace),
      // Restrictive CSP per spec default (no declared csp -> Host must use
      // its own restrictive default; we declare an explicit empty one so
      // there's no ambiguity that this card makes no outbound calls at all).
      '_meta': {
        'ui': {'csp': <String, dynamic>{}, 'prefersBorder': true},
      },
    },
  ],
};

/// Self-contained HTML for the verdict card: inline CSS/JS only, no
/// external network fetches (CSP-friendly — see `csp: {}` above). Tier
/// colors are ported by hex from
/// vouch/vouch_flutter/lib/design/tokens.dart's `VColors.light`/`.dark`
/// (t0/t1/t2), switched with `prefers-color-scheme` the same way the
/// Flutter app switches themes.
///
/// If [trace] is given the HTML is pre-rendered with its fields baked in
/// (used for a plain resources/read with no follow-up messaging); the
/// embedded script also listens for `ui/notifications/tool-result` and
/// re-renders itself from `structuredContent.vouch` when a compliant host
/// sends it, per the spec's Host->View messaging.
String buildVerdictCardHtml(VouchTrace? trace) {
  // `<` escaped so user speech inside the trace can't close the <script>.
  final initialJson = trace == null
      ? 'null'
      : jsonEncode(trace.toJson()).replaceAll('<', r'\u003c');
  return '''
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Vouch verdict</title>
<style>
  :root {
    --t0: #6E6B82; --t0-bg: #1F6E6B82; --t0-text: #3A3850;
    --t1: #5B57A6; --t1-bg: #247D7ABC; --t1-text: #38348A;
    --t2: #C9A800; --t2-bg: #40FFE347; --t2-text: #6B5500;
    --fg: #15131F; --muted: #55526A; --bg: #FFFFFF; --border: #D2D0E0;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --t0: #8C8A9C; --t0-bg: #2E6E6B82; --t0-text: #CBC9D6;
      --t1: #8E8BD0; --t1-bg: #2E7D7ABC; --t1-text: #C3C1EE;
      --t2: #FFE347; --t2-bg: #24FFE347; --t2-text: #FFEC85;
      --fg: #ECEAF3; --muted: #A19EB2; --bg: #17161D; --border: #38354A;
    }
  }
  * { box-sizing: border-box; }
  body {
    margin: 0; padding: 12px; background: var(--bg); color: var(--fg);
    font: 13px/1.4 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  }
  .card {
    border: 1px solid var(--border); border-radius: 12px; padding: 12px;
  }
  .row { display: flex; justify-content: space-between; gap: 8px; margin: 6px 0; }
  .label { color: var(--muted); }
  .value { font-weight: 600; text-align: right; }
  .chip {
    display: inline-block; padding: 2px 8px; border-radius: 999px;
    font-weight: 700; font-size: 11px; letter-spacing: 0.02em;
  }
  .chip-t0 { background: var(--t0-bg); color: var(--t0-text); }
  .chip-t1 { background: var(--t1-bg); color: var(--t1-text); }
  .chip-t2 { background: var(--t2-bg); color: var(--t2-text); }
  .reason { margin-top: 8px; color: var(--muted); font-style: italic; }
  .stepup {
    margin-top: 8px; padding: 8px; border-radius: 8px;
    background: var(--t2-bg); color: var(--t2-text); font-weight: 600;
  }
  .empty { color: var(--muted); }
</style>
</head>
<body>
<div class="card" id="card"><span class="empty">Waiting for a verdict…</span></div>
<script>
  // MCP Apps (SEP-1865) View<->Host messaging, per the spec's
  // "Communication Protocol" section. READ-ONLY: this view only ever sends
  // its own lifecycle notifications (initialized, size-changed). It never
  // sends a tool-call request and renders no interactive control that
  // could trigger one.
  (function () {
    var HOST = window.parent;
    function post(method, params) {
      try {
        HOST.postMessage({ jsonrpc: '2.0', method: method, params: params || {} }, '*');
      } catch (e) { /* no-op: read-only view, nothing depends on delivery */ }
    }

    function tierChipClass(tier) {
      var t = String(tier || '').toUpperCase();
      if (t === 'T2') return 'chip-t2';
      if (t === 'T1') return 'chip-t1';
      return 'chip-t0';
    }

    // Plain-language tier names, matching the admin app's TierChip.
    function tierLabel(tier) {
      var t = String(tier || '').toUpperCase();
      if (t === 'T2') return 'Owner approves';
      if (t === 'T1') return 'Known voice';
      if (t === 'T0') return 'Anyone';
      return '—';
    }

    // Internal approval ids mean nothing to the person reading the card.
    function cleanReason(reason) {
      return String(reason).replace(/\\s*\\(approval \\d+\\)/g, '');
    }

    // attestationMatched = strict match; a matchedTranscript without it is
    // a near-miss the guard routed to the owner (Alexa reworded the command).
    function matchType(vouch) {
      if (vouch.attestationMatched) return 'matched';
      return vouch.matchedTranscript ? 'paraphrased' : 'none';
    }

    function render(vouch) {
      if (!vouch) return;
      var speakerName = (vouch.speaker && vouch.speaker.displayName) || 'not recognised';
      var match = matchType(vouch);
      var tier = vouch.requiredTier || vouch.presentTier;
      var confidencePct = (typeof vouch.confidence === 'number')
        ? Math.round(vouch.confidence * 100) + '%' : '—';
      var stepUp = vouch.decision === 'stepUp' || vouch.decision === 'pending';

      var html = ''
        + '<div class="row"><span class="label">Speaker</span>'
        + '<span class="value">' + escapeHtml(speakerName) + '</span></div>'
        + '<div class="row"><span class="label">Match</span>'
        + '<span class="value">' + escapeHtml(match) + '</span></div>'
        + '<div class="row"><span class="label">Confidence</span>'
        + '<span class="value">' + confidencePct + '</span></div>'
        + '<div class="row"><span class="label">Tier</span>'
        + '<span class="chip ' + tierChipClass(tier) + '">'
        + escapeHtml(tierLabel(tier)) + '</span></div>'
        + '<div class="row"><span class="label">Decision</span>'
        + '<span class="value">' + escapeHtml(vouch.decision || '—') + '</span></div>'
        + (vouch.reason ? '<div class="reason">' + escapeHtml(cleanReason(vouch.reason)) + '</div>' : '')
        + (stepUp ? '<div class="stepup">Waiting for the owner\\'s approval on their phone</div>' : '');
      document.getElementById('card').innerHTML = html;
    }

    function escapeHtml(s) {
      return String(s).replace(/[&<>"']/g, function (c) {
        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
      });
    }

    window.addEventListener('message', function (ev) {
      var msg = ev.data;
      if (typeof msg === 'string') {
        try { msg = JSON.parse(msg); } catch (e) { return; }
      }
      if (!msg || typeof msg !== 'object') return;
      if (msg.method === 'ui/notifications/tool-result') {
        var sc = msg.params && msg.params.structuredContent;
        if (sc && sc.vouch) render(sc.vouch);
      }
    });

    // View->Host handshake: ui/initialize then wait for
    // ui/notifications/initialized is host-driven in the full spec; a
    // minimal, read-only view can simply announce readiness.
    post('ui/notifications/initialized', {});

    var initial = $initialJson;
    if (initial) render(initial);
  })();
</script>
</body>
</html>
''';
}
