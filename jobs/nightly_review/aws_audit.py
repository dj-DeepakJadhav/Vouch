"""Deterministic, advisory audit review for AWS Lambda.

Only allowlisted metadata is retained. This module has no permission or
code path to approve a request, alter policy, or invoke a household tool.
"""

from __future__ import annotations

from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import os
import re

MAX_EVENTS = 1000
MAX_BYTES = 256_000


def sanitise_export(export: dict) -> dict:
    if not isinstance(export, dict):
        raise ValueError("Expected an audit export object")
    household = export.get("householdId")
    if type(household) is not int or household < 1:
        raise ValueError("Expected a positive householdId")
    since = export.get("since")
    if not isinstance(since, str) or len(since) > 64:
        raise ValueError("Expected an export timestamp")
    datetime.fromisoformat(since.replace("Z", "+00:00"))
    events = export.get("events")
    if not isinstance(events, list) or len(events) > MAX_EVENTS:
        raise ValueError("Expected at most 1000 audit events")
    clean = []
    for event in events:
        if not isinstance(event, dict):
            raise ValueError("Expected audit event objects")
        action = event.get("action", "unknown")
        if not isinstance(action, str) or not re.fullmatch(r"[\w.:-]{1,100}", action, re.ASCII):
            raise ValueError("Invalid action identifier")
        member = event.get("memberId")
        if member is not None and (type(member) is not int or member < 1):
            raise ValueError("Invalid member identifier")
        decision = event.get("decision", "unknown")
        if not isinstance(decision, str) or decision not in {"allowed", "permitted", "denied", "deny", "blocked",
                            "approved", "challenged", "stepUp", "expired", "unknown"}:
            raise ValueError("Invalid audit decision")
        tier = event.get("tierRequired")
        if tier is not None and (not isinstance(tier, str) or tier not in {"t0", "t1", "t2"}):
            raise ValueError("Invalid trust tier")
        reason = str(event.get("reason", "")).lower()
        signals = event.get("signals", [])
        if not isinstance(signals, list) or not all(isinstance(s, str) for s in signals):
            raise ValueError("Invalid risk signals")
        clean_signals = set(signals) & {"unrecognised_speaker", "replayed_approval"}
        if "speaker not recognised" in reason or "speaker not recognized" in reason:
            clean_signals.add("unrecognised_speaker")
        if "replayed requeststate" in reason or "already-used approval" in reason:
            clean_signals.add("replayed_approval")
        # Deliberately exclude utterances, reasons, names, tokens, and audio.
        clean.append({"memberId": member, "action": action,
                      "decision": decision, "tierRequired": tier,
                      "signals": sorted(clean_signals)})
    result = {"householdId": household, "since": since, "events": clean}
    if len(json.dumps(result).encode()) > MAX_BYTES:
        raise ValueError("Audit export exceeds metadata size limit")
    return result


def review_export(export: dict) -> dict:
    clean = sanitise_export(export)
    decisions = Counter(e["decision"] for e in clean["events"])
    denied = [e for e in clean["events"] if e["decision"] in {"denied", "deny", "blocked"}]
    repeats = Counter((e["memberId"], e["action"]) for e in denied)
    findings = []
    for (member, action), count in sorted(repeats.items(), key=lambda x: (str(x[0][0]), x[0][1])):
        if count >= 2:
            findings.append({"pattern": "repeated_denial", "memberId": member,
                             "action": action, "count": count, "severity": "warning"})
    unknown_sensitive = sum(e["tierRequired"] == "t2" and
                            "unrecognised_speaker" in e["signals"] for e in clean["events"])
    if unknown_sensitive:
        findings.append({"pattern": "unrecognised_sensitive_request",
                         "count": unknown_sensitive, "severity": "warning"})
    replays = sum("replayed_approval" in e["signals"] for e in clean["events"])
    if replays:
        findings.append({"pattern": "replayed_approval", "count": replays, "severity": "warning"})
    count = len(clean["events"])
    digest = hashlib.sha256(json.dumps(clean, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
    return {"schemaVersion": 1, "provider": "aws-lambda", "engine": "deterministic-v1",
            "advisoryOnly": True, "householdId": clean["householdId"], "since": clean["since"],
            "eventCount": count, "decisions": dict(sorted(decisions.items())),
            "summary": f"Reviewed {count} audit events: {len(denied)} blocked requests, "
                       f"{len(findings)} patterns for owner review.",
            "findings": findings, "inputSha256": digest}


def handler(event, context):
    # The managed Lambda runtime supplies boto3; no SDK dependencies are bundled.
    import boto3
    report = review_export(event)
    now = datetime.now(timezone.utc)
    report["generatedAt"] = now.isoformat()
    body = json.dumps(report, sort_keys=True, indent=2).encode()
    bucket = os.environ["REPORT_BUCKET"]
    key = f"reports/{now:%Y-%m-%d}/{report['inputSha256']}.json"
    boto3.client("s3").put_object(Bucket=bucket, Key=key, Body=body,
                                 ContentType="application/json", ServerSideEncryption="AES256")
    return {"report": report, "artifact": {"bucket": bucket, "key": key,
            "sha256": hashlib.sha256(body).hexdigest()}}
