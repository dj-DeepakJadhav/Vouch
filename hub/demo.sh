#!/bin/sh
# Vouch terminal demo. Needs the dev server running (cd vouch && serverpod start).
# First run: ./demo.sh setup   — keys, demo household, synthetic voices, enrolment.
# Then:      ./demo.sh         — the four scenes.
set -e
cd "$(dirname "$0")"
# Drop NeMo/OneLogger load-time noise (config dumps are indented 4+ spaces; the
# hub's own output lines are never indented). Behaviour is unchanged.
export NEMO_LOG_LEVEL=ERROR
V() {
  .venv/bin/python -m vouch_hub "$@" 2>&1 |
    grep -vE "^\[NeMo|^\s*$|^ {4}|^\s*(Train|Validation|Test) config|^OneLogger|^No exporters|super\(\)\.__init__"
}
pause() { printf "\n— press Enter —"; read _ || true; }

if [ "$1" = "setup" ]; then
  # Fresh start: a hub key can only be registered once (unique), so re-running
  # setup needs a new key and a new demo household.
  rm -rf keys data/config.json data/voiceprints data/pending.json data/last_used.json
  V keygen
  V register --owner Priya --child Ana
  V demo-voices
  V enrol --member owner --wav data/demo/owner_enrol_*.wav
  V enrol --member child --wav data/demo/child_enrol_*.wav
  echo "Setup done. Run ./demo.sh"
  echo "To link the Flutter admin app to this household: open the app (it"
  echo "signs in anonymously with no UI and shows 'Pair with your hub'),"
  echo "then run ./demo.sh pair to mint a code and enter it there."
  exit 0
fi

if [ "$1" = "pair" ]; then
  # Mints a fresh 6-digit code the Flutter app's "Pair with your hub"
  # screen redeems (replaces the old dev-only email sign-in). Single-use,
  # expires in 10 minutes.
  V pair
  exit 0
fi

echo "=== Scene 1: Ana (12) tries to order a PlayStation ==="
V attest --wav data/demo/child_cmd_order.wav
V alexa "Alexa, order the new PlayStation for 500 euros."; pause

echo "=== Scene 2: Priya unlocks the front door (needs her phone) ==="
V attest --wav data/demo/owner_cmd_unlock.wav
V alexa "Alexa, unlock the front door."
ID=$(.venv/bin/python -c 'import json;print(json.load(open("data/pending.json")).get("approvalId",""))' 2>/dev/null || true)
echo "Approving on Priya's 'phone' (approval $ID)…"; V approve "$ID"; pause

echo "=== Scene 3: someone replays that approval ==="
V alexa --retry; pause

echo "=== Scene 4: an unrecognised voice ==="
V alexa "Alexa, unlock the front door."
V alexa "Alexa, what's the weather?"
