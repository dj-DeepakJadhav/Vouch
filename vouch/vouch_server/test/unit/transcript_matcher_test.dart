import 'package:test/test.dart';
import 'package:vouch_server/src/attestation/transcript_matcher.dart';

void main() {
  group('Given TranscriptMatcher.normalise', () {
    test('when given a wake-word-prefixed command then strips it', () {
      expect(
        TranscriptMatcher.normalise('Alexa, unlock the front door'),
        'unlock the front door',
      );
    });

    test('when given punctuation and mixed case then normalises them', () {
      expect(
        TranscriptMatcher.normalise('Unlock  the FRONT-door!!'),
        'unlock the front door',
      );
    });

    test('when given number words then converts them to digits', () {
      expect(TranscriptMatcher.normalise('order two packs'), 'order 2 packs');
      expect(TranscriptMatcher.normalise('send ten euros'), 'send 10 euros');
      expect(
        TranscriptMatcher.normalise('send one thousand euros'),
        'send 1000 euros',
      );
      expect(
        TranscriptMatcher.normalise('set a timer for twenty two minutes'),
        'set a timer for 22 minutes',
      );
    });
  });

  group('Given TranscriptMatcher.hash', () {
    test('when hashing the same normalised text then produces same hash', () {
      final a = TranscriptMatcher.hash('unlock the front door');
      final b = TranscriptMatcher.hash('unlock the front door');
      expect(a, b);
      expect(a, hasLength(64));
    });

    test('when hashing different text then produces different hash', () {
      expect(
        TranscriptMatcher.hash('unlock the front door'),
        isNot(TranscriptMatcher.hash('unlock the back door')),
      );
    });
  });

  group('Given TranscriptMatcher.match', () {
    test(
      'when wake word is present on one side only then still matches',
      () {
        expect(
          TranscriptMatcher.match(
            'Alexa, unlock the front door',
            'unlock the front door',
          ),
          isTrue,
        );
      },
    );

    test('when punctuation and case differ then still matches', () {
      expect(
        TranscriptMatcher.match(
          'unlock the front door',
          'Unlock THE front-door!',
        ),
        isTrue,
      );
    });

    test('when numeric tokens differ then does not match', () {
      expect(
        TranscriptMatcher.match(
          'set a timer for 10 minutes',
          'set a timer for 5 minutes',
        ),
        isFalse,
      );
    });

    test(
      'when a number word and a differing digit refer to different '
      'amounts then does not match',
      () {
        expect(
          TranscriptMatcher.match(
            'send ten euros to Tom',
            'send 1000 euros to Tom',
          ),
          isFalse,
        );
      },
    );

    test(
      'when a number word and the equivalent digit are used then matches',
      () {
        expect(
          TranscriptMatcher.match(
            'order two packs of batteries',
            'order 2 packs of batteries',
          ),
          isTrue,
        );
      },
    );

    test('when commands are unrelated then does not match', () {
      expect(
        TranscriptMatcher.match(
          'unlock the front door',
          'what is the weather today',
        ),
        isFalse,
      );
    });
  });

  group('Given TranscriptMatcher.isNearMiss', () {
    test(
      'when Alexa paraphrases with the same amount then it is a near-miss',
      () {
        expect(
          TranscriptMatcher.isNearMiss(
            'order the new playstation for 500 euros',
            'buy the new playstation for 500 euros',
          ),
          isTrue,
        );
      },
    );

    test('when the amount differs then it is not a near-miss', () {
      expect(
        TranscriptMatcher.isNearMiss(
          'order the new playstation for 500 euros',
          'buy the new playstation for 50 euros',
        ),
        isFalse,
      );
    });

    test('when the texts fully match then it is a match, not a near-miss', () {
      const hub = 'unlock the front door';
      expect(
        TranscriptMatcher.match(hub, 'Alexa, unlock the front door.'),
        isTrue,
      );
      expect(
        TranscriptMatcher.isNearMiss(hub, 'Alexa, unlock the front door.'),
        isFalse,
      );
    });

    test('when the command is unrelated then it is not a near-miss', () {
      expect(
        TranscriptMatcher.isNearMiss(
          'whats the weather',
          'unlock the front door',
        ),
        isFalse,
      );
    });
  });
}
