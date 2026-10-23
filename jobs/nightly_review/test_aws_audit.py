import json
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock, patch

import pytest

from aws_audit import handler, review_export, sanitise_export


def sample():
    return json.loads(Path(__file__).with_name("sample_export.json").read_text())


def test_detects_repeated_denials_and_unrecognised_sensitive_requests():
    report = review_export(sample())
    assert report["eventCount"] == 4
    assert report["decisions"] == {"allowed": 2, "denied": 2}
    assert report["advisoryOnly"] is True
    assert {f["pattern"]: f["count"] for f in report["findings"]} == {
        "repeated_denial": 2, "unrecognised_sensitive_request": 2}


def test_strips_private_fields_before_upload_and_is_idempotent():
    export = sample()
    export.update(token="secret-bearer", ownerName="Private Name")
    export["events"][0].update(utterance="Private message", audio="biometrics",
                                reason="Private Name said Private message")
    clean = sanitise_export(export)
    assert clean == sanitise_export(clean)
    assert "Private" not in json.dumps(clean)
    assert "secret-bearer" not in json.dumps(clean)
    assert "biometrics" not in json.dumps(clean)
    assert "reason" not in clean["events"][0]


def test_replay_is_a_reported_signal_not_an_approval():
    export = sample()
    export["events"][0].update(decision="denied", reason="replayed requestState for already-used approval 7")
    report = review_export(export)
    assert any(f["pattern"] == "replayed_approval" for f in report["findings"])
    assert report["advisoryOnly"] is True


@pytest.mark.parametrize("change", [
    {"householdId": True}, {"householdId": -1}, {"events": [{}] * 1001},
    {"events": [{"action": "../../outside"}]},
    {"events": [{"action": "ok", "signals": [{}]}]},
    {"events": [{"action": "ok", "decision": {}}]},
    {"since": "invalid"},
])
def test_rejects_malformed_or_oversized_exports(change):
    export = sample()
    export.update(change)
    with pytest.raises(ValueError):
        sanitise_export(export)


def test_quiet_window_does_not_invent_findings():
    export = sample()
    export["events"] = []
    assert review_export(export)["findings"] == []


def test_handler_writes_only_the_report_with_encryption_and_scoped_prefix():
    s3 = Mock()
    with patch.dict("sys.modules", {"boto3": SimpleNamespace(client=lambda service: s3)}), \
         patch.dict("os.environ", {"REPORT_BUCKET": "test-reports"}):
        result = handler(sample(), None)
    args = s3.put_object.call_args.kwargs
    assert args["Bucket"] == "test-reports"
    assert args["Key"].startswith("reports/")
    assert args["ServerSideEncryption"] == "AES256"
    stored = json.loads(args["Body"])
    assert stored == result["report"]
    assert "events" not in stored
    assert "speaker not recognised" not in args["Body"].decode()


def test_storage_error_is_not_reported_as_success():
    s3 = Mock()
    s3.put_object.side_effect = RuntimeError("storage unavailable")
    with patch.dict("sys.modules", {"boto3": SimpleNamespace(client=lambda service: s3)}), \
         patch.dict("os.environ", {"REPORT_BUCKET": "test-reports"}), \
         pytest.raises(RuntimeError):
        handler(sample(), None)
