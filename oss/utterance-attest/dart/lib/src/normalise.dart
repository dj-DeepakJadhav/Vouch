import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Transcript normalisation: lowercase, strip punctuation, strip a leading
/// wake word, collapse number words into digit tokens, collapse whitespace.
///
/// See `SPEC.md` at the repository root for the exact rules. Kept
/// byte-for-byte equivalent to the Python implementation in
/// `python/utterance_attest/normalise.py` — both are tested against the
/// shared vectors in `vectors/normalise.json`.
class Normalise {
  const Normalise._();

  static const Set<String> wakeWords = {'alexa', 'echo', 'computer', 'amazon'};

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
    // Strip punctuation (anything that's not an ASCII word char or
    // whitespace). `\w` stays ASCII-only ([a-zA-Z0-9_]) even with the
    // `unicode` flag: that flag only changes how character classes handle
    // surrogate pairs, not which characters `\w` matches. So accented
    // letters (e.g. "café") are stripped as punctuation, not kept.
    lower = lower.replaceAll(RegExp(r'[^\w\s]', unicode: true), ' ');
    var tokens = lower
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isNotEmpty && wakeWords.contains(tokens.first)) {
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

  /// SHA-256 hex digest of an already-normalised transcript.
  static String hash(String normalisedText) {
    return sha256.convert(utf8.encode(normalisedText)).toString();
  }
}
