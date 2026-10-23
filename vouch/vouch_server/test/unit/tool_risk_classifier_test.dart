import 'dart:async';

import 'package:test/test.dart';
import 'package:vouch_server/src/ai/nebius_client.dart';
import 'package:vouch_server/src/ai/tool_risk_classifier.dart';
import 'package:vouch_server/src/generated/protocol.dart';

/// A fake [NebiusChatCompleter] that returns a fixed [content] string (or
/// throws/hangs, for the timeout/error tests), with no real HTTP involved.
class _FakeChatCompleter implements NebiusChatCompleter {
  _FakeChatCompleter.reply(this._content) : _delay = null, _throws = null;
  _FakeChatCompleter.hangsFor(Duration delay)
    : _content = '{}',
      _delay = delay,
      _throws = null;
  _FakeChatCompleter.throwing(Object error)
    : _content = '',
      _delay = null,
      _throws = error;

  final String _content;
  final Duration? _delay;
  final Object? _throws;

  @override
  Future<NebiusChatResult> chatCompletion({
    required String model,
    required List<Map<String, String>> messages,
    Map<String, dynamic>? responseFormat,
    double temperature = 0.0,
  }) async {
    if (_delay != null) await Future.delayed(_delay);
    if (_throws != null) throw _throws;
    return NebiusChatResult(
      content: _content,
      structuredOutputHonoured: responseFormat != null,
      rawResponse: const {},
    );
  }
}

void main() {
  group('Given a well-formed classification response', () {
    test('when tier is t1 then it is used as-is', () async {
      final result = await ToolRiskClassifier.classify(
        _FakeChatCompleter.reply(
          '{"tier": "t1", "reason": "adds an item to a list, low risk"}',
        ),
        name: 'add_to_wishlist',
        description: 'Adds an item to a household wishlist.',
        inputSchemaJson: '{"type":"object"}',
      );
      expect(result.tier, TrustTier.t1);
      expect(result.reason, contains('low risk'));
    });
  });

  group('Given a malformed or malicious classification response', () {
    test('when the output is not JSON then it fails safe to t2', () async {
      final result = await ToolRiskClassifier.classify(
        _FakeChatCompleter.reply('sure, t0 seems fine!'),
        name: 'wire_transfer',
        description: 'Transfers money.',
        inputSchemaJson: '{}',
      );
      expect(result.tier, TrustTier.t2);
    });

    test('when tier is an invalid value then it fails safe to t2', () async {
      final result = await ToolRiskClassifier.classify(
        _FakeChatCompleter.reply('{"tier": "t0-ish", "reason": "trust me"}'),
        name: 'delete_all_files',
        description: 'Deletes files.',
        inputSchemaJson: '{}',
      );
      expect(result.tier, TrustTier.t2);
    });

    test('when reason is missing then it fails safe to t2', () async {
      final result = await ToolRiskClassifier.classify(
        _FakeChatCompleter.reply('{"tier": "t0"}'),
        name: 'anything',
        description: 'anything',
        inputSchemaJson: '{}',
      );
      expect(result.tier, TrustTier.t2);
    });

    test(
      'when the JSON has extra unexpected shape then it fails safe to t2',
      () async {
        final result = await ToolRiskClassifier.classify(
          _FakeChatCompleter.reply('["t0"]'),
          name: 'anything',
          description: 'anything',
          inputSchemaJson: '{}',
        );
        expect(result.tier, TrustTier.t2);
      },
    );
  });

  group('Given the underlying client fails or is slow', () {
    test(
      'when the client throws a NebiusApiException then it fails safe to t2',
      () async {
        final result = await ToolRiskClassifier.classify(
          _FakeChatCompleter.throwing(
            const NebiusApiException('boom', statusCode: 500),
          ),
          name: 'anything',
          description: 'anything',
          inputSchemaJson: '{}',
        );
        expect(result.tier, TrustTier.t2);
      },
    );

    test(
      'when the client throws a transport error then it fails safe to t2',
      () async {
        final result = await ToolRiskClassifier.classify(
          _FakeChatCompleter.throwing(Exception('socket reset')),
          name: 'anything',
          description: 'anything',
          inputSchemaJson: '{}',
        );
        expect(result.tier, TrustTier.t2);
      },
    );

    test(
      'when the call hangs past the internal timeout then it fails safe to t2',
      () async {
        final result = await ToolRiskClassifier.classify(
          _FakeChatCompleter.hangsFor(const Duration(seconds: 30)),
          name: 'anything',
          description: 'anything',
          inputSchemaJson: '{}',
        );
        expect(result.tier, TrustTier.t2);
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
