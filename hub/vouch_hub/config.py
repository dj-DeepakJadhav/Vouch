import json
import os
from pathlib import Path

from . import HUB_ROOT

DATA_DIR = Path(os.environ.get("VOUCH_HUB_DATA", HUB_ROOT / "data"))
CONFIG_PATH = DATA_DIR / "config.json"
DEFAULTS = {"serverUrl": "http://localhost:8080", "mcpUrl": "http://localhost:8082/mcp",
            "threshold": 0.60,
            # Anti-spoof signal only: can only lower trust, never raise it.
            # At most caps the attested tier at T1.
            "spoofScorer": "null",
            "spoofMediumThreshold": 0.4,
            "spoofHighThreshold": 0.75,
            "spoofCapTierAtT1": False}


def load() -> dict:
    cfg = dict(DEFAULTS)
    if CONFIG_PATH.exists():
        cfg.update(json.loads(CONFIG_PATH.read_text()))
    return cfg


def save(cfg: dict) -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    CONFIG_PATH.write_text(json.dumps(cfg, indent=2))
    os.chmod(CONFIG_PATH, 0o600)  # holds the MCP bearer token
