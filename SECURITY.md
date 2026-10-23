# Security and private data

Vouch is a prototype. Speaker recognition is not proof of identity, and no
deepfake detector ships with this project. Sensitive actions require an
owner approval in addition to speaker evidence. The no-hub demo simulates
speaker identity and the owner-phone interface.

## Files that must remain local

- Serverpod `config/passwords.yaml` and Firebase service-account files.
- AWS credentials and profiles, `.env` files, and private signing keys.
- Hub `data/`, `keys/`, recordings, and enrolled voiceprints.
- Model weights, virtual environments, and generated tool state.

The ignore rules exclude these files. Ignore rules do not remove files
already committed; review the staged diff and scan history before sharing
changes. Never paste credentials into submission text, screenshots, or logs.

## Public fixtures

`oss/utterance-attest/vectors/signed_payload.json` contains a fixed test key
with a seed of bytes 0 through 31. It exists for cross-language tests and
must never be used as a deployment key.

The Docker Compose and test workflow configurations contain local scaffold
development/test credentials. They are public fixtures, not production
secrets. Generate fresh deployment secrets with the supplied setup script;
never reuse fixture credentials for hosted services.

Video-production sources and synthetic narration stay local and are ignored.
Public gallery screenshots use the demo household, not real household data.
Recorded household speech is excluded.

## Before a public deployment

The optional AWS audit reporter uploads only allowlisted decision metadata
and derived risk flags. It does not upload audio, voiceprints, transcripts,
names, free-text reasons, or bearer tokens. Reports contain pseudonymous
household/member identifiers and are private, encrypted, and set to expire
after seven days. Its IAM-authenticated Lambda cannot change household
policy or approve requests. See `jobs/nightly_review/AWS.md`.

Use fresh secrets, production mode, and an explicit origin allowlist.
Keep development endpoints unavailable. Review the demo-session isolation
and rate limits before enabling a public judging demo. Read the setup
instructions and the limitations in the main README.

If a real credential is exposed, revoke or rotate it first. Removing a file
from the latest commit does not remove it from Git history.
