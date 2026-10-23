// Prints [{input, normalised, hash}] JSON for a set of tricky transcript
// inputs, using the real TranscriptMatcher implementation, so the Python
// hub's port (hub/vouch_hub/normalise.py) can be checked byte-for-byte
// against it. Run from vouch/vouch_server:
//
//   dart run tool/gen_transcript_vectors.dart > ../../hub/tests/transcript_vectors.json
import 'dart:convert';

import 'package:vouch_server/src/attestation/transcript_matcher.dart';

const List<String> _inputs = [
  'Alexa, add milk to the list',
  'Echo, what is the weather',
  'Computer, set a timer for ten minutes',
  'Amazon, play some music',
  'ALEXA ADD TWENTY FIVE DOLLARS TO THE BUDGET',
  'alexa buy two hundred stickers',
  'alexa transfer a thousand euros',
  'add ten euros to the list',
  'buy 25 stickers', // digits already present
  'Alexa,    add   milk   to   the   list', // extra spaces
  "alexa what's the time?",
  'Alexa -- add eggs, milk, and bread!',
  'twenty two apples',
  'one hundred and one balloons',
  'nineteen ninety nine',
  'order three thousand five hundred bricks',
  'no wake word here just numbers seven eight nine',
  'Alexa',
  '   ',
  'ALEXA',
  'echo echo test',
  'alexa set volume to zero',
  'a thousand thanks',
  'twenty',
  'thirty four',
  'nineteen',
  'alexa buy eleven twelve thirteen',
  'Compute the answer', // starts with "compute", not wake word "computer"
  'Alexa: what time is it?!',
  'ALEXA, add café au lait to the list', // unicode letters
];

void main() {
  final vectors = _inputs.map((input) {
    final normalised = TranscriptMatcher.normalise(input);
    final hash = TranscriptMatcher.hash(normalised);
    return {'input': input, 'normalised': normalised, 'hash': hash};
  }).toList();

  print(const JsonEncoder.withIndent('  ').convert(vectors));
}
