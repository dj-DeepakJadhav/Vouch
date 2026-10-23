import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Normalises a spoken command transcript and fuzzy-matches two transcripts
/// against each other for the purpose of pairing a hub attestation with the
/// text Alexa+ actually recognised.
///
/// This is a pure, DB-free module so it can be unit-tested in isolation.
class TranscriptMatcher {
  const TranscriptMatcher._();

  /// Minimum token-set similarity (0..1) for two transcripts to be
  /// considered the same utterance, in addition to the numeric-token check.
  static const double similarityThreshold = 0.90;

  static const Set<String> _wakeWords = {'alexa', 'echo', 'computer', 'amazon'};

  static const Map<String, int> _units = {
    'zero': 0,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
  };

  static const Map<String, int> _tens = {
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };

  static const Map<String, int> _scales = {
    'hundred': 100,
    'thousand': 1000,
  };

  /// Normalises [text]: lowercases, strips punctuation, strips a leading
  /// wake word, converts number words to digits, and collapses whitespace.
  static String normalise(String text) {
    var lower = text.toLowerCase();
    // Strip punctuation (anything that's not a letter, digit or whitespace).
    lower = lower.replaceAll(RegExp(r'[^\w\s]', unicode: true), ' ');
    var tokens = lower
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isNotEmpty && _wakeWords.contains(tokens.first)) {
      tokens = tokens.sublist(1);
    }

    tokens = _collapseNumberWords(tokens);

    return tokens.join(' ').trim();
  }

  /// Walks [tokens] left to right, combining consecutive number words (e.g.
  /// "two", "packs" is untouched but "one", "thousand" -> "1000", and
  /// "twenty", "two" -> "22") into single digit-string tokens.
  static List<String> _collapseNumberWords(List<String> tokens) {
    final result = <String>[];
    var i = 0;
    while (i < tokens.length) {
      final token = tokens[i];
      if (_units.containsKey(token) ||
          _tens.containsKey(token) ||
          _scales.containsKey(token)) {
        var value = 0;
        var current = 0;
        var consumedAny = false;
        while (i < tokens.length) {
          final t = tokens[i];
          if (_units.containsKey(t) && !_tens.containsKey(t)) {
            current += _units[t]!;
            i++;
            consumedAny = true;
          } else if (_tens.containsKey(t)) {
            current += _tens[t]!;
            i++;
            consumedAny = true;
          } else if (_scales.containsKey(t)) {
            final scale = _scales[t]!;
            if (current == 0) current = 1;
            if (scale >= 1000) {
              value += current * scale;
              current = 0;
            } else {
              current *= scale;
            }
            i++;
            consumedAny = true;
          } else {
            break;
          }
        }
        if (consumedAny) {
          value += current;
          result.add(value.toString());
          continue;
        }
      }
      result.add(token);
      i++;
    }
    return result;
  }

  /// SHA-256 hex digest of the normalised transcript.
  static String hash(String normalisedText) {
    return sha256.convert(utf8.encode(normalisedText)).toString();
  }

  /// Extracts the numeric tokens (already digit strings after normalisation)
  /// from a normalised transcript, preserving multiplicity and order.
  static List<String> _numericTokens(String normalisedText) {
    return normalisedText
        .split(' ')
        .where((t) => t.isNotEmpty && RegExp(r'^\d+$').hasMatch(t))
        .toList();
  }

  /// True iff [numbersA] and [numbersB] contain exactly the same multiset of
  /// numeric tokens, regardless of order.
  static bool _sameNumberMultiset(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();
    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }

  /// Token-set similarity, modelled on rapidfuzz's `token_set_ratio`:
  /// tokenise both strings, take the sorted intersection and the sorted
  /// remainders of each side, then score the best Levenshtein ratio among
  /// {intersection vs intersection+remainderA, intersection vs
  /// intersection+remainderB, intersection+remainderA vs
  /// intersection+remainderB}. This makes the score robust to one side
  /// having extra or missing words (e.g. the wake word already stripped, or
  /// filler words) as long as the shared core matches.
  static double tokenSetSimilarity(String a, String b) {
    final tokensA = a.split(' ').where((t) => t.isNotEmpty).toSet();
    final tokensB = b.split(' ').where((t) => t.isNotEmpty).toSet();

    if (tokensA.isEmpty && tokensB.isEmpty) return 1.0;
    if (tokensA.isEmpty || tokensB.isEmpty) return 0.0;

    final intersection = tokensA.intersection(tokensB);
    final remainderA = tokensA.difference(tokensB);
    final remainderB = tokensB.difference(tokensA);

    final sortedIntersection = (intersection.toList()..sort()).join(' ');
    final combinedA = ([...intersection, ...remainderA]..sort()).join(' ');
    final combinedB = ([...intersection, ...remainderB]..sort()).join(' ');

    final scores = [
      _levenshteinRatio(sortedIntersection, combinedA),
      _levenshteinRatio(sortedIntersection, combinedB),
      _levenshteinRatio(combinedA, combinedB),
    ];

    return scores.reduce((x, y) => x > y ? x : y);
  }

  /// Levenshtein similarity ratio in [0, 1]: `1 - editDistance / maxLength`.
  static double _levenshteinRatio(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    final distance = _levenshteinDistance(a, b);
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - (distance / maxLen);
  }

  static int _levenshteinDistance(String a, String b) {
    final m = a.length;
    final n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;

    var previous = List<int>.generate(n + 1, (j) => j);
    var current = List<int>.filled(n + 1, 0);

    for (var i = 1; i <= m; i++) {
      current[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        current[j] = [
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      final tmp = previous;
      previous = current;
      current = tmp;
    }
    return previous[n];
  }

  /// True iff [hubTranscript] and [alexaText] describe the same utterance:
  /// token-set similarity ≥ [similarityThreshold] AND the multiset of
  /// numeric tokens is identical in both (after normalisation).
  static bool match(String hubTranscript, String alexaText) {
    final normA = normalise(hubTranscript);
    final normB = normalise(alexaText);

    final similarity = tokenSetSimilarity(normA, normB);
    if (similarity < similarityThreshold) return false;

    final numbersA = _numericTokens(normA);
    final numbersB = _numericTokens(normB);
    return _sameNumberMultiset(numbersA, numbersB);
  }

  /// Lower bound for [isNearMiss]: close enough to be a paraphrase of the
  /// attested utterance, too far to bind the speaker to this command.
  static const double nearMissThreshold = 0.70;

  /// True iff [alexaText] is plausibly Alexa's paraphrase of
  /// [hubTranscript]: similarity in [[nearMissThreshold], [similarityThreshold])
  /// with identical numbers. Never grounds for an allow on its own.
  static bool isNearMiss(String hubTranscript, String alexaText) {
    final normA = normalise(hubTranscript);
    final normB = normalise(alexaText);

    final similarity = tokenSetSimilarity(normA, normB);
    if (similarity < nearMissThreshold || similarity >= similarityThreshold) {
      return false;
    }
    return _sameNumberMultiset(_numericTokens(normA), _numericTokens(normB));
  }
}
