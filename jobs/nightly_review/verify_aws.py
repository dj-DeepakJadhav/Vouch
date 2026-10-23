#!/usr/bin/env python3
"""Invoke Vouch's AWS reviewer and verify the private stored report."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile

from aws_audit import review_export


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile")
    parser.add_argument("--region", default="eu-central-1")
    parser.add_argument("--input", type=Path, default=Path(__file__).with_name("sample_export.json"))
    args = parser.parse_args()
    command = [sys.executable, str(Path(__file__).with_name("main.py")), "--provider", "aws-lambda",
               "--aws-region", args.region, "--input", str(args.input)]
    if args.profile:
        command.extend(["--aws-profile", args.profile])
    result = json.loads(subprocess.check_output(command))
    report = result["report"]
    expected = review_export(json.loads(args.input.read_text()))
    assert {k: report[k] for k in expected} == expected, "Remote findings differ from expected findings"
    artifact = result["artifact"]
    with tempfile.TemporaryDirectory(prefix="vouch-verify-") as folder:
        output = Path(folder) / "report.json"
        download = ["aws", "s3api", "get-object", "--region", args.region, "--bucket", artifact["bucket"],
                    "--key", artifact["key"], str(output)]
        if args.profile:
            download.extend(["--profile", args.profile])
        subprocess.run(download, stdout=subprocess.DEVNULL, check=True)
        # Verify the downloaded object is the exact report returned by Lambda.
        body = output.read_bytes()
        assert hashlib.sha256(body).hexdigest() == artifact["sha256"], "Stored artifact hash mismatch"
        assert json.loads(body) == report, "Stored report differs from invocation response"
    print(json.dumps({"region": args.region, "function": "vouch-audit-review",
        "invocationVerified": True, "s3DownloadVerified": True, "reportSha256": artifact["sha256"],
        "inputIsIncludedSample": args.input.resolve() == Path(__file__).with_name("sample_export.json").resolve(),
        "report": report}, indent=2))


if __name__ == "__main__":
    main()
