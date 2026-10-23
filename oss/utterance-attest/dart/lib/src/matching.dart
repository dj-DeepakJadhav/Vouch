import 'normalise.dart';

/// Fuzzy transcript matching: token-set similarity plus an exact-numeric-
/// token guard, so "send 10" can never be matched against "send 1000".
///
/// Pure-Dart, no dependencies beyond `normalise.dart`.
class Matching {
  const Matching._();

  /// Minimum token-set similarity (0..1) for two transcripts to be
  /// considered the same utterance, in addition to the numeric-token check.
  static const double similarityThreshold = 0.90;

  /// Token-set similarity, modelled on rapidfuzz's `token_set_ratio`:
  /// tokenise both strings, take the sorted intersection and the sorted
  /// remainders of each side, then score the best Levenshtein ratio among
  /// {intersection vs intersection+remainderA, intersection vs
  /// intersection+remainderB, intersection+remainderA vs
  /// intersection+remainderB}.
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

  static List<String> _numericTokens(String normalisedText) {
    return normalisedText
        .split(' ')
        .where((t) => t.isNotEmpty && RegExp(r'^\d+$').hasMatch(t))
        .toList();
  }

  static bool _sameNumberMultiset(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();
    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }

  /// True iff [a] and [b] describe the same utterance: token-set similarity
  /// >= [similarityThreshold] AND the multiset of numeric tokens is
  /// identical in both (after normalisation).
  static bool transcriptsMatch(String a, String b) {
    final normA = Normalise.normalise(a);
    final normB = Normalise.normalise(b);

    final similarity = tokenSetSimilarity(normA, normB);
    if (similarity < similarityThreshold) return false;

    final numbersA = _numericTokens(normA);
    final numbersB = _numericTokens(normB);
    return _sameNumberMultiset(numbersA, numbersB);
  }
}
