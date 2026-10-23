import json
from pathlib import Path

import pytest

VECTORS_DIR = Path(__file__).resolve().parents[2] / "vectors"


def load_vector(name: str):
    with open(VECTORS_DIR / name, "r", encoding="utf-8") as f:
        return json.load(f)


@pytest.fixture(scope="session")
def normalise_vectors():
    return load_vector("normalise.json")["cases"]


@pytest.fixture(scope="session")
def matching_vectors():
    return load_vector("matching.json")["cases"]


@pytest.fixture(scope="session")
def signed_payload_vector():
    return load_vector("signed_payload.json")
