import 'package:test/test.dart';
import 'package:vouch_server/src/mcp/mcp_guard.dart';
import 'package:vouch_server/src/mcp/tools.dart';
import 'package:vouch_server/src/mcp/verdict_card.dart';

/// Unit coverage for the MCP Apps (`ui://vouch/verdict`) resource: pure
/// functions only, no server/DB needed (see mcp_guard_test.dart for the
/// full withServerpod integration coverage of tools/call itself).
void main() {
  group('verdict card resource', () {
    test('resources/list-style entry advertises ui://vouch/verdict', () {
      final entry = verdictResourceListEntry();
      expect(entry['uri'], 'ui://vouch/verdict');
      expect(entry['mimeType'], 'text/html;profile=mcp-app');
      expect(entry['name'], isNotEmpty);
    });

    test('resources/read-style result has correct MIME type and HTML body', () {
      final result = verdictResourceReadResult();
      final contents = result['contents'] as List;
      expect(contents, hasLength(1));
      final content = contents.single as Map<String, dynamic>;
      expect(content['uri'], 'ui://vouch/verdict');
      expect(content['mimeType'], 'text/html;profile=mcp-app');
      final html = content['text'] as String;
      expect(html, isNotEmpty);
      expect(html, contains('<!DOCTYPE html>'));
    });

    test('every tool definition carries the _meta.ui.resourceUri link', () {
      for (final tool in mcpTools) {
        final json = tool.toJson();
        final meta = json['_meta'] as Map<String, dynamic>;
        final ui = meta['ui'] as Map<String, dynamic>;
        expect(
          ui['resourceUri'],
          'ui://vouch/verdict',
          reason: 'tool ${tool.name} must link the verdict card',
        );
      }
    });

    test('card HTML has no form and no button that could act', () {
      final html = buildVerdictCardHtml(null);
      expect(html.contains('<form'), isFalse);
      expect(html.contains('<button'), isFalse);
      // No outbound tool-call: only lifecycle notifications are posted.
      expect(html.contains("'tools/call'"), isFalse);
      expect(html.contains('method: \'tools/call\''), isFalse);
    });

    test('card HTML embeds the real trace shape when a trace is supplied', () {
      const trace = VouchTrace(
        speaker: {'memberId': 1, 'displayName': 'Dana', 'role': 'owner'},
        confidence: 0.93,
        attestationMatched: true,
        matchedTranscript: 'unlock the front door',
        requiredTier: 't2',
        presentTier: 't1',
        decision: 'stepUp',
        reason: 'Front door requires owner step-up',
        ruleSource: null,
      );
      final html = buildVerdictCardHtml(trace);
      expect(html, contains('"displayName":"Dana"'));
      expect(html, contains('speaker.displayName'));
      expect(html, contains('toUpperCase'));
    });

    test('user speech in the trace cannot close the script tag', () {
      const trace = VouchTrace(
        speaker: null,
        confidence: null,
        attestationMatched: false,
        matchedTranscript: '</script><img src=x onerror=alert(1)>',
        requiredTier: 't1',
        presentTier: 't0',
        decision: 'stepUp',
        reason: 'command paraphrased',
        ruleSource: null,
      );
      final html = buildVerdictCardHtml(trace);
      expect('</script>'.allMatches(html).length, 1);
      expect(html, isNot(contains('<img src=x')));
    });
  });
}
