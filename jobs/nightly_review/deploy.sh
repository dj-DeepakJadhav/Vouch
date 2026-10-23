#!/usr/bin/env bash
# Build, push, and submit the Vouch nightly-review job to Nebius AI Cloud
# Serverless Jobs. NOT executed in this environment — no Nebius project or
# credentials were used to produce this script. Verify every command
# against `nebius <subcommand> --help` for your installed CLI version
# before running against a real project.
#
# Sources consulted (fetched during authoring, not executed):
#   https://docs.nebius.com/cli/reference/ai/job
#   https://docs.nebius.com/serverless/jobs/manage
#   https://docs.nebius.com/container-registry/authentication
#
# Usage:
#   PROJECT_ID=... REGION=eu-north1 REGISTRY_ID=... ./deploy.sh
#
# Required env vars (fill in with your own Nebius project details; never
# hardcode them here):
#   PROJECT_ID   Nebius project id that owns the registry and the job.
#   REGISTRY_ID  Container Registry id (or registry hostname component),
#                see: https://docs.nebius.com/container-registry/registries/manage
#   REGION       Nebius region for the registry host, e.g. eu-north1.
#   NEBIUS_API_KEY_SECRET_ID
#                id of a SecretStash secret already holding the Nebius
#                Token Factory API key (create it via the console, or
#                `nebius ... secret create` — flag name unverified, check
#                `nebius --help` for the current secrets subcommand).
#
# This script never reads or prints NEBIUS_API_KEY itself — the key lives
# only inside the Nebius secret referenced by NEBIUS_API_KEY_SECRET_ID.

set -euo pipefail

: "${PROJECT_ID:?set PROJECT_ID}"
: "${REGISTRY_ID:?set REGISTRY_ID}"
: "${REGION:?set REGION, e.g. eu-north1}"
: "${NEBIUS_API_KEY_SECRET_ID:?set NEBIUS_API_KEY_SECRET_ID (a SecretStash secret id, not the key itself)}"

IMAGE="cr.${REGION}.nebius.cloud/${REGISTRY_ID}/vouch-nightly-review:latest"

echo "== 1. Build image =="
docker build -t "${IMAGE}" "$(dirname "$0")"

echo "== 2. Authenticate docker against Nebius Container Registry =="
# See https://docs.nebius.com/container-registry/authentication
nebius iam get-access-token | docker login "cr.${REGION}.nebius.cloud" \
  --username iam --password-stdin

echo "== 3. Push image =="
docker push "${IMAGE}"

echo "== 4. Submit the job =="
# Flags confirmed against https://docs.nebius.com/cli/reference/ai/job and
# https://docs.nebius.com/serverless/jobs/manage as of authoring time:
#   --name, --image, --container-command, --args, --env, --env-secret,
#   --platform, --preset, --timeout. CPU-only (--platform here is a
# placeholder; check `nebius ai job create --help` for the current
# CPU-only platform/preset names — the examples in the docs above are all
# GPU platforms and this job needs no GPU).
nebius ai job create \
  --name vouch-nightly-review \
  --image "${IMAGE}" \
  --container-command python \
  --args "main.py,--input,/app/sample_export.json" \
  --env-secret "NEBIUS_API_KEY=${NEBIUS_API_KEY_SECRET_ID}" \
  --timeout 15m
  # --platform/--preset intentionally omitted: pick the smallest CPU-only
  # option your project offers (this job does no local inference, only an
  # HTTPS call to Token Factory) — run `nebius ai job create --help` to
  # list them, this repo does not assert specific names.

echo "== 5. Read logs =="
echo "nebius ai job list                      # find the job id"
echo "nebius ai job logs <job_ID> --follow    # stream logs"

echo "== 6. Recurring (nightly) execution =="
echo "The Nebius docs fetched for this script did not surface a native"
echo "cron/schedule flag for Serverless AI Jobs. Until that is confirmed,"
echo "trigger this job nightly from any external scheduler capable of"
echo "shelling out (e.g. a cron entry or CI schedule) running the"
echo "'nebius ai job create ...' command above with --args pointed at a"
echo "freshly exported audit file, or re-run this script."
