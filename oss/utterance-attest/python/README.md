# utterance-attest (Python)

Sign and verify short-lived, single-utterance speaker attestations for
voice agents. See the [repository README](../README.md) for the full
picture and [`../SPEC.md`](../SPEC.md) for the wire format.

## Install

```
pip install .
```

Run this from the `python/` directory of a clone. This package has not yet
been published to PyPI.

## Usage

See the [repository README](../README.md#python-usage) for a full
example.

## Development

```
python3.12 -m venv .venv   # or any Python >= 3.9
./.venv/bin/pip install -e ".[test]"
./.venv/bin/python -m pytest
```

MIT licensed — see [`../LICENSE`](../LICENSE).
