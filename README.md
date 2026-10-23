# Vouch

Vouch checks household permissions before a connected tool runs. It combines speaker evidence, household rules and owner approval for sensitive requests.

Alexa already has purchase controls and parental approvals. Vouch explores permissions for custom tools behind its MCP server. It cannot intercept native Alexa actions.

## Demo video

[![Watch the Vouch demo](https://img.youtube.com/vi/jYufozuG1n8/hqdefault.jpg)](https://www.youtube.com/watch?v=jYufozuG1n8)

[Watch on YouTube](https://www.youtube.com/watch?v=jYufozuG1n8). The video shows the simulated Alexa+ client, household permission checks and owner approval flow.

## Fastest way to try it: no hub, no mic

Install Dart 3.12.2, Flutter and the Serverpod CLI. From the repository root:

```sh
export PATH="$PATH:$HOME/.pub-cache/bin"
cd vouch
dart pub get
./vouch_server/tool/setup_passwords.sh
serverpod start
```

The password script creates local secrets from the committed template and preserves an existing password file. Serverpod starts embedded PostgreSQL, generates the client and launches the Flutter app. The first run needs network access to download dependencies and PostgreSQL. No Python setup or model key is needed for the preset demo.

Select **Try the demo household (no hub)**, open the Alexa tab and choose a scenario. Requests reach the backend through MCP `tools/call`. The decision trace shows the policy result.

For the door scenario, approve the pending request and then select **Replay the used approval**. The backend rejects the second attempt. Speaker identity and the owner-phone interface are simulated; the demo tool actions are mocks. Policy checks, approval state and audit records run in the backend.

## How permissions work

| Tier | Example actions | Required evidence |
|---|---|---|
| T0 | Weather, time, music | No recognised speaker |
| T1 | Shopping list, calendar read | Recognised speaker matched to the command |
| T2 | Locks, purchases, messages | Recognised speaker and owner approval |

Household rules can deny a request even when its tier requirements are met. For example, the demo denies Ana's purchase request. Approval applies to a specific request and is consumed after use.

An optional local hub runs TitaNet speaker verification and Parakeet transcription. It signs short-lived Ed25519 evidence for the backend. Audio and enrolled voiceprints stay on the hub; transcript text and signed metadata reach the server.

Plain-language rules use Nemotron on Nebius. The backend validates the generated policy, and the owner confirms it before activation. A Nebius key is required for rule compilation and unknown-tool classification, but not for the preset demo.

## Architecture

![Vouch architecture: simulated client, backend permission checks, optional local hub and separate AWS audit reporting](submission/gallery/07-architecture.png)

The Flutter client sends requests to the Serverpod MCP guard. PostgreSQL stores household policy, approvals and audit records. AWS audit reporting runs separately on an exported file and cannot grant permissions.

The [interactive diagram](submission/architecture/README.md) links components to source on `main`. Amazon's restricted developer access prevents live Alexa+ testing; the [friction log](submission/developer-feedback.md) records the restriction and simulation workaround. The simulated client exercises Streamable HTTP and approval continuation against Vouch's MCP implementation.

## Run with the local hub

Use Python 3.12 for the NeMo dependencies. The hub also needs a microphone or WAV files, an `HF_TOKEN` for model access and model downloads. On macOS, `demo.sh` uses system text-to-speech to generate synthetic demo voices.

Start the app with the commands above. In a separate terminal, from the repository root:

```sh
cd hub
python3.12 -m venv .venv
.venv/bin/pip install torch --index-url https://download.pytorch.org/whl/cpu
.venv/bin/pip install -r requirements.txt
./demo.sh setup
./demo.sh pair
```

Set `HF_TOKEN` in your local environment before setup. Enter the printed six-digit code in the app within ten minutes, then run `./demo.sh`. The hub guide covers [microphone input, enrolment and evaluation](hub/README.md).

To enable plain-language rules, add a Nebius Token Factory key as `nebiusApiKey` in `vouch/vouch_server/config/passwords.yaml`. That file is ignored by Git. Never put the key in a tracked configuration file.

## Models

| Model | Location | Purpose |
|---|---|---|
| `nvidia/speakerverification_en_titanet_large` | Local hub | Compare speech with enrolled speakers |
| `nvidia/parakeet-tdt-0.6b-v2` | Local hub | Transcribe speech |
| `nvidia/nemotron-3-super-120b-a12b` | Nebius Token Factory | Compile rules and review audit exports |
| `nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B` | Nebius Token Factory | Classify tools without an explicit tier |

## Optional AWS audit reports

The verified AWS path invokes Lambda over allowlisted audit metadata and saves an encrypted, private S3 report with seven-day expiry. It flags repeated denials and unknown-speaker sensitive requests. Reports are advisory.

The [AWS guide](jobs/nightly_review/AWS.md) covers deployment, privacy, verification and removal. The [saved result](submission/aws-verification.json) records a live Lambda invocation and report download over four synthetic events on October 22, 2026. The optional Bedrock provider is implemented but live inference remains blocked by account access restrictions.

## Limits

- The owner-phone interface is simulated. The demo does not prove approval on a separate authenticated device or live Alexa+ interoperability.
- Speaker recognition can accept a cloned voice. No deepfake detector ships; the default spoof scorer always returns zero.
- Speaker evaluation uses synthetic demo voices. Real-room false-accept, false-reject and equal-error rates have not been established. See [measuring accuracy](hub/README.md#measuring-accuracy).
- Transcript matching uses token overlap and matching numeric tokens. It does not establish semantic equivalence. Real Alexa+ paraphrasing has not been measured. The standalone Vouch Attest command verifier uses exact normalised hash equality; applications must still validate action parameters and enforce replay protection.
- The app is a prototype. Review [security and deployment requirements](SECURITY.md) before exposing it publicly.

## Repository layout

```text
vouch/                   Dart workspace
  vouch_server/          Serverpod backend, MCP guard, migrations and tests
  vouch_client/          Generated Dart client
  vouch_flutter/         Household admin app and simulated Alexa+ client
hub/                     Local speaker verification, transcription and signing
jobs/nightly_review/     File-based audit review; AWS, Nebius and Bedrock providers
oss/utterance-attest/    Vouch Attest library for Dart and Python
submission/              Public architecture, screenshots, friction log and AWS evidence
```

## Tests

Run each command from the repository root in a separate terminal, or return to the root between commands. Server tests require the local password file created during setup. The audit-review tests require pytest.

```sh
cd vouch/vouch_server && dart test
```

```sh
cd vouch/vouch_flutter && flutter analyze && flutter test
```

```sh
cd hub && .venv/bin/python -m pytest -m "not live" -q
```

```sh
cd oss/utterance-attest/dart && dart pub get && dart test
```

```sh
cd oss/utterance-attest/python
python3.12 -m venv .venv
.venv/bin/pip install -e '.[test]'
.venv/bin/python -m pytest
```

```sh
python3 -m pytest jobs/nightly_review -q
```

Serverpod manages an embedded test PostgreSQL instance. Hub tests marked `live` require a running backend and are excluded by the command above.

## Licence

MIT. [Vouch Attest](oss/utterance-attest/README.md) is included in this repository. Its fixed test keys are public fixtures, never deployment credentials.
