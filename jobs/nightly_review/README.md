# Audit review job

This Python CLI reads a Vouch audit export and prints a JSON report. It runs separately from the permission guard. Reports cannot approve requests or change household rules.

Run the commands below from the repository root with Python 3.9 or later.

## AWS Lambda and S3

```sh
python3 jobs/nightly_review/main.py --provider aws-lambda \
  --input jobs/nightly_review/sample_export.json --dry-run
```

The offline command validates and reviews the synthetic sample without an AWS request. Remove `--dry-run` after deployment to invoke Lambda and save a private S3 report. Live invocation and report download were verified on October 22, 2026. See [AWS setup and verification](AWS.md) for the deployment commands, retained fields, costs and removal steps.

The Lambda reviewer uses deterministic rules for repeated denials and unknown-speaker sensitive requests. It does not require model access. Use the source CLI for this provider; the current Nebius container does not include `aws_audit.py`.

## Nebius model review

Set `NEBIUS_API_KEY` in your local environment, then run:

```sh
python3 jobs/nightly_review/main.py \
  --input jobs/nightly_review/sample_export.json
```

The default provider asks Nemotron Super to summarise unusual activity. `--dry-run` prints a stub report without calling the model. The CLI uses Python's standard library; credentials are read at runtime.

Input follows the `audit.exportSince` response in [audit_endpoint.dart](../../vouch/vouch_server/lib/src/audit/audit_endpoint.dart). The included sample is synthetic. Only send exports you are authorised to upload.

[deploy.sh](deploy.sh) builds a container and submits a Nebius Serverless Job. That deployment path has not been run against a live Nebius project. Review the script and check its commands against your installed CLI before use. It requires `PROJECT_ID`, `REGISTRY_ID`, `REGION` and `NEBIUS_API_KEY_SECRET_ID`. The last value identifies a stored secret, not the API key itself.

The script submits one job over the bundled sample. An external scheduler and a fresh export are needed for recurring reviews. The repository does not deploy a nightly schedule.

## Bedrock model review

The optional `--provider bedrock` calls the Amazon Bedrock Converse API through AWS CLI v2. The default model is `eu.amazon.nova-micro-v1:0`; `--model` selects another model. Choose your credentials with `--aws-profile` and region with `--aws-region`.

Live calls failed with `ValidationException: Operation not allowed`. Account/model authorisation was `NOT_AUTHORIZED`, with zero applied Nova Micro inference quota. Successful Bedrock inference has not been verified. This restriction is separate from the working Lambda/S3 path.

## Live collection status

`--server-url`, `--owner-token` and `--household-id` request a live export instead of reading a file. This authenticated HTTP path is unverified. The project does not provision a headless owner session for scheduled collection. Use `--input` with an export produced by an authorised caller.

## Report and tests

Model reports contain a summary, findings, household ID, export timestamp, event count and model usage. Lambda reports contain deterministic findings and an S3 artifact reference. Inspect `sample_export.json` and the [saved AWS result](../../submission/aws-verification.json) for the actual data shapes.

```sh
python3 -m pytest jobs/nightly_review -q
```

The tests cover private-field removal, malformed inputs, finding thresholds and report storage failures. They do not make live AWS calls.
