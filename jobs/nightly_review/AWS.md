# Vouch AWS audit reporter

The audit-review CLI invokes an AWS Lambda function. The function groups
blocked requests, flags repeated denials and unknown-speaker sensitive
requests, and writes an advisory JSON report to a private S3 bucket.
The caller can download and verify that report.

This is a deterministic reviewer, not an LLM or a deepfake detector. It
cannot approve requests, change policy, or run household tools. Bedrock
remains an optional, separately blocked provider; successful Lambda/S3
execution is not presented as successful Bedrock inference.

## Deploy and test

Prerequisites: Python 3.9+, AWS CLI v2, and an authenticated AWS profile
permitted to deploy CloudFormation, Lambda, S3, IAM, and CloudWatch Logs.
The deployed function uses Python 3.12 and its runtime-provided boto3 SDK.
No Python dependencies are bundled into the inline deployment package.

From the repository root:

```sh
python3 jobs/nightly_review/deploy_aws.py --profile YOUR_PROFILE
python3 jobs/nightly_review/main.py --provider aws-lambda \
  --aws-profile YOUR_PROFILE --input jobs/nightly_review/sample_export.json
python3 jobs/nightly_review/verify_aws.py --profile YOUR_PROFILE
```

Replace `YOUR_PROFILE` with your own local AWS profile. The default region
is Frankfurt (`eu-central-1`). `deploy_aws.py --template-only` emits the
CloudFormation template under the ignored `build/` folder for inspection.
The verification command invokes the actual function, compares the result
to expected findings, downloads the stored report, and verifies its SHA-256.

The included sample is synthetic audit data. To review an authorised audit
export, pass its filename with `--input`. Authenticated headless collection
from a live Serverpod household remains a separate, unverified path; this
AWS integration uses the supported file-export path.

Offline check, with no AWS request:

```sh
python3 jobs/nightly_review/main.py --provider aws-lambda \
  --input jobs/nightly_review/sample_export.json --dry-run
```

## Privacy and access

The CLI strips everything except household/member identifiers, action
identifiers, decisions, required tier, the export timestamp, and two
derived risk flags before invocation. Free-text reasons, transcripts,
names, audio, voiceprints, and bearer tokens are not uploaded. Identifiers
are pseudonymous metadata, not a claim of anonymisation.

Lambda requires AWS-authenticated invocation. There is no public endpoint.
Its execution role can only write under this stack's `reports/` prefix
and write to its own log group. It cannot read or modify Vouch's database.
The bucket blocks public access, requires TLS, and uses SSE-S3 encryption.
The handler does not log the input or report content.

## Retention, cost, and removal

There is no schedule, provisioned concurrency, database, VPC, gateway, or
public API. Lambda executes only when invoked. Requests, compute time,
S3 objects/requests, and logs can incur small usage-based charges; this is
not a guarantee of zero cost. Reports expire after seven days and logs
after three days. Repeating the same export on the same day overwrites
the same report key; bucket versioning is not enabled.

To stop future use, stop invoking the function. To remove the deployment,
get `ReportBucket` from the `vouch-audit-review` CloudFormation outputs,
empty only that bucket's `reports/` prefix, then delete that stack. Emptying
the prefix permanently deletes these Vouch reports; inspect them first.
The CloudFormation template owns all resources for this integration.

## Verification

Live verification on October 22, 2026 succeeded: four sample events yielded
two blocked requests and the expected repeated-denial and unknown-speaker
findings. The S3 download matched the returned report and SHA-256.
See `submission/aws-verification.json` for the saved synthetic-data result.

Local tests cover private-field removal, deterministic findings, malformed
inputs, input limits, encrypted report writes, and storage failures.
