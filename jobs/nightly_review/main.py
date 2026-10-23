#!/usr/bin/env python3
"""Vouch nightly review job.

Pulls the last 24h of a household's audit events and asks Nemotron Super
(via the Nebius Token Factory OpenAI-compatible API) to summarise unusual
activity — repeated denials, unrecognised-speaker attempts, new/unclassified
tools being probed, and anything else that looks worth a household owner's
attention. Prints a single JSON report to stdout.

Two ways to get audit events in:

  --input <file.json>   A JSON file shaped like the vouch_server
                         `audit.exportSince` response (see
                         vouch_server/lib/src/audit/audit_endpoint.dart):
                         {"householdId": ..., "since": "...", "events": [...]}.
                         This is the offline/demo mode — see README.md for
                         how the accompanying export was produced.

  --server-url + --owner-token + --household-id
                         Calls the live `audit.exportSince` Serverpod
                         endpoint directly over HTTP. NOTE: the exact
                         request/response wire format used here was derived
                         by reading the `serverpod_client` package source
                         (POST {server-url}/audit/exportSince, JSON body,
                         `Authorization: Bearer <owner-token>`) and has not
                         been verified against a live authenticated call in
                         this environment — see README.md "Unverified"
                         section. Treat --input as the supported path until
                         that's confirmed against your deployment.

Nemotron model and API key:
  --model            defaults to nvidia/nemotron-3-super-120b-a12b (Super —
                      see vouch_server/lib/src/ai/model_routing.dart; this
                      job's summarisation task is exactly the kind of
                      higher-quality, low-frequency reasoning task that
                      warrants Super rather than Nano).
  NEBIUS_API_KEY      environment variable, required. Never pass the key on
                      the command line (it would leak into shell history /
                      process listings) and never print or log it.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
import sys
import urllib.request
from datetime import datetime, timedelta, timezone

NEBIUS_BASE_URL = "https://api.tokenfactory.nebius.com/v1"
DEFAULT_MODEL = "nvidia/nemotron-3-super-120b-a12b"
BEDROCK_MODEL = "eu.amazon.nova-micro-v1:0"


def call_bedrock(model: str, prompt: str, region: str, profile: str | None) -> dict:
    """Use the AWS CLI credential chain; never handle access keys in this job."""
    command = ["aws", "bedrock-runtime", "converse", "--region", region,
               "--model-id", model, "--messages", json.dumps([
                   {"role": "user", "content": [{"text": prompt}]}]),
               "--inference-config", json.dumps({"maxTokens": 1000, "temperature": 0}),
               "--output", "json", "--no-cli-pager"]
    if profile:
        command.extend(["--profile", profile])
    result = subprocess.run(command, capture_output=True, text=True, timeout=90, check=True)
    raw = json.loads(result.stdout)
    content = "".join(part.get("text", "") for part in raw["output"]["message"]["content"])
    report = json.loads(content)
    if not isinstance(report, dict) or not isinstance(report.get("summary"), str) or not isinstance(report.get("findings"), list):
        raise ValueError("Bedrock returned an invalid review report")
    return {"report": report, "usage": raw.get("usage", {}), "stopReason": raw.get("stopReason")}


def load_events_from_file(path: str) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_events_from_server(server_url: str, owner_token: str, household_id: int, since: str) -> dict:
    """Calls the live `audit.exportSince` endpoint. See the module docstring
    for the "unverified wire format" caveat — this follows the
    `serverpod_client` request shape (POST {url}/audit/exportSince with a
    JSON body of the method's named arguments, Bearer auth), but has not
    been exercised against a real Serverpod auth session in this repo. If
    it doesn't work against your server, prefer --input with a file
    produced by a trusted Dart caller (see README.md).
    """
    url = f"{server_url.rstrip('/')}/audit/exportSince"
    body = json.dumps({"householdId": household_id, "since": since}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": f"Bearer {owner_token}",
        },
    )
    with urllib.request.urlopen(req, timeout=30) as resp:
        events = json.loads(resp.read().decode("utf-8"))
    return {"householdId": household_id, "since": since, "events": events}


def build_prompt(export: dict) -> str:
    events = export.get("events", [])
    lines = []
    for e in events:
        lines.append(
            f"- {e.get('createdAt')} member={e.get('memberId')} "
            f"action={e.get('action')} decision={e.get('decision')} "
            f"tierRequired={e.get('tierRequired')} tierPresent={e.get('tierPresent')} "
            f"reason={e.get('reason')!r}"
        )
    events_text = "\n".join(lines) if lines else "(no events in this window)"

    return f"""You review the last 24 hours of a household's Vouch access-control
audit log (a step-up voice authentication gateway sitting in front of an
Alexa+ MCP tool integration). Vouch's security model: an MCP server cannot
verify who is speaking on its own (Alexa+ only hands it text), so a
separate hub verifies the speaker's voice and issues short-lived signed
attestations; every tool call is checked against household policy rules and
a trust tier (t0 = no verification, t1 = voice match, t2 = voice match +
step-up approval).

Household {export.get('householdId')}, events since {export.get('since')}:
{events_text}

Summarise anything UNUSUAL an owner should know about — e.g. repeated
denials for the same action or member, any "speaker not recognised"
attempt (especially for a t2 action), a brand-new tool/action never seen
before, or an unusually high volume of step-up challenges. Do not simply
restate every event; focus on patterns and anomalies. If nothing is
unusual, say so plainly rather than inventing concern.

Reply with ONLY a JSON object of the exact form:
{{"summary": "<2-4 sentence plain-English summary for the household owner>",
"findings": [{{"pattern": "<short label>", "detail": "<one sentence>",
"severity": "info"|"notice"|"warning"}}]}}
No prose outside the JSON object.
"""


def call_nemotron(model: str, prompt: str, api_key: str) -> dict:
    url = f"{NEBIUS_BASE_URL}/chat/completions"
    body = json.dumps(
        {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 0.0,
            "response_format": {"type": "json_object"},
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=body,
        method="POST",
        headers={
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": f"Bearer {api_key}",
        },
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--input", help="Path to a JSON export file (audit.exportSince shape).")
    parser.add_argument("--server-url", help="Live server base URL, e.g. http://localhost:8080.")
    parser.add_argument("--owner-token", help="Owner bearer token for --server-url mode.")
    parser.add_argument("--household-id", type=int, help="Household id for --server-url mode.")
    parser.add_argument(
        "--since-hours", type=float, default=24.0, help="Lookback window in hours (default 24)."
    )
    parser.add_argument("--provider", choices=["nebius", "bedrock", "aws-lambda"], default="nebius")
    parser.add_argument("--aws-function", default="vouch-audit-review")
    parser.add_argument("--model", help="Model ID; defaults to the selected provider's model.")
    parser.add_argument("--aws-region", default="eu-central-1")
    parser.add_argument("--aws-profile", help="Optional AWS CLI profile; otherwise use the default credential chain.")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help=(
            "Skip the Nemotron/Token Factory network call entirely (no NEBIUS_API_KEY "
            "required). Loads --input, builds the prompt, and prints a stub report. "
            "For local smoke-testing the container/CLI plumbing only."
        ),
    )
    args = parser.parse_args()
    args.model = args.model or (BEDROCK_MODEL if args.provider == "bedrock" else DEFAULT_MODEL)

    api_key = os.environ.get("NEBIUS_API_KEY")
    if not api_key and not args.dry_run and args.provider == "nebius":
        print("error: NEBIUS_API_KEY environment variable is not set", file=sys.stderr)
        return 2

    since = (datetime.now(timezone.utc) - timedelta(hours=args.since_hours)).isoformat()

    if args.input:
        export = load_events_from_file(args.input)
    elif args.server_url and args.owner_token and args.household_id is not None:
        export = load_events_from_server(args.server_url, args.owner_token, args.household_id, since)
    else:
        print(
            "error: pass either --input <file.json>, or all of --server-url/--owner-token/--household-id",
            file=sys.stderr,
        )
        return 2

    if args.provider == "aws-lambda":
        from aws_audit import sanitise_export, review_export
        try:
            # Reduce the upload to allowlisted metadata before it leaves this process.
            clean = sanitise_export(export)
        except (ValueError, TypeError):
            print("error: invalid audit export metadata", file=sys.stderr)
            return 2
        if args.dry_run:
            report = review_export(clean)
            report["dryRun"] = True
            print(json.dumps(report, indent=2))
            return 0
        with tempfile.TemporaryDirectory(prefix="vouch-audit-") as directory:
            from pathlib import Path
            payload = Path(directory) / "input.json"
            output = Path(directory) / "report.json"
            payload.write_text(json.dumps(clean))
            command = ["aws", "lambda", "invoke", "--region", args.aws_region,
                       "--function-name", args.aws_function, "--invocation-type", "RequestResponse",
                       "--cli-binary-format", "raw-in-base64-out", "--payload", f"file://{payload}",
                       "--output", "json", "--no-cli-pager"]
            if args.aws_profile:
                command.extend(["--profile", args.aws_profile])
            command.append(str(output))
            try:
                response = subprocess.run(command, capture_output=True, text=True, timeout=45, check=True)
                metadata = json.loads(response.stdout)
                if metadata.get("FunctionError"):
                    raise ValueError("Lambda rejected the review")
                result = json.loads(output.read_text())
                if result["report"].get("inputSha256") != review_export(clean)["inputSha256"]:
                    raise ValueError("Lambda report does not match the submitted metadata")
            except (subprocess.SubprocessError, OSError, ValueError, KeyError):
                print("error: AWS Lambda audit review failed; check deployment and permissions", file=sys.stderr)
                return 1
        print(json.dumps(result, indent=2))
        return 0

    prompt = build_prompt(export)

    if args.dry_run:
        report = {
            "summary": "[dry-run] No model was called; prompt built successfully.",
            "findings": [],
            "householdId": export.get("householdId"),
            "since": export.get("since"),
            "eventCount": len(export.get("events", [])),
            "model": args.model,
            "dryRun": True,
        }
        print(json.dumps(report, indent=2))
        return 0

    if args.provider == "bedrock":
        try:
            result = call_bedrock(args.model, prompt, args.aws_region, args.aws_profile)
        except (subprocess.SubprocessError, OSError, ValueError, KeyError) as exc:
            print(f"error: Bedrock review failed ({type(exc).__name__}); check AWS credentials, model access and region", file=sys.stderr)
            return 1
        report = result["report"]
        report.update(householdId=export.get("householdId"), since=export.get("since"),
                      eventCount=len(export.get("events", [])), model=args.model,
                      provider="amazon-bedrock", region=args.aws_region,
                      usage=result["usage"], stopReason=result["stopReason"])
        print(json.dumps(report, indent=2))
        return 0

    raw = call_nemotron(args.model, prompt, api_key)

    choices = raw.get("choices") or []
    if not choices:
        print(json.dumps({"error": "no choices in Nemotron response", "raw": raw}))
        return 1
    content = choices[0].get("message", {}).get("content", "")

    try:
        report = json.loads(content)
    except json.JSONDecodeError:
        report = {"summary": content, "findings": []}

    report["householdId"] = export.get("householdId")
    report["since"] = export.get("since")
    report["eventCount"] = len(export.get("events", []))
    report["model"] = args.model
    usage = raw.get("usage")
    if usage:
        report["usage"] = usage

    print(json.dumps(report, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
