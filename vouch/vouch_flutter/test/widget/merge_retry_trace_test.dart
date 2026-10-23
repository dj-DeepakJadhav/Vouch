import 'package:flutter_test/flutter_test.dart';
import 'package:vouch_flutter/data/mcp/mcp_gateway.dart';

void main() {
  const fresh = [
    TraceStep(label: 'Request', status: TraceStepStatus.ok),
    TraceStep(
      label: 'Transcript matches Alexa',
      status: TraceStepStatus.fail,
      detail: '"add chocolate to the shopping list"',
    ),
    TraceStep(label: 'Owner approval', status: TraceStepStatus.pending),
    TraceStep(label: 'Result', status: TraceStepStatus.fail),
  ];
  // What the server's retry leg reports: it cannot know the match result.
  const retry = [
    TraceStep(label: 'Transcript matches Alexa', status: TraceStepStatus.ok),
    TraceStep(label: 'Owner approval', status: TraceStepStatus.ok),
    TraceStep(label: 'Result', status: TraceStepStatus.ok),
  ];

  test('a retry keeps the fresh call evidence, takes its verdict', () {
    final merged = mergeRetryTrace(fresh, retry);
    expect(merged.map((s) => s.label), fresh.map((s) => s.label));
    expect(merged[1].status, TraceStepStatus.fail);
    expect(merged[2].status, TraceStepStatus.ok);
    expect(merged[3].status, TraceStepStatus.ok);
  });

  test('no fresh trace falls back to the retry trace', () {
    expect(mergeRetryTrace(const [], retry), retry);
  });

  test('vouch map keeps evidence, takes decision and reason', () {
    final m = mergeRetryVouch(
      {'attestationMatched': false, 'decision': 'stepUp', 'reason': 'a'},
      {'attestationMatched': true, 'decision': 'approved', 'reason': 'b'},
    )!;
    expect(m['attestationMatched'], false);
    expect(m['decision'], 'approved');
    expect(m['reason'], 'b');
  });
}
