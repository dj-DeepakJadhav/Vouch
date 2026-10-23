#!/usr/bin/env bash
# Creates config/passwords.yaml from config/passwords.example.yaml, replacing
# every CHANGE_ME with a fresh random value. Never overwrites an existing file.
set -euo pipefail
cd "$(dirname "$0")/.."

target=config/passwords.yaml
template=config/passwords.example.yaml

if [[ -e "$target" ]]; then
  echo "$target already exists; leaving it untouched."
  exit 0
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
while IFS= read -r line || [[ -n "$line" ]]; do
  while [[ "$line" == *CHANGE_ME* ]]; do
    value="$(openssl rand -hex 24)"
    line="${line/CHANGE_ME/$value}"
  done
  printf '%s\n' "$line" >> "$tmp"
done < "$template"

umask 077
cp "$tmp" "$target"
chmod 600 "$target"
echo "Created $target with random local secrets."
echo "Nebius: nebiusApiKey is still a placeholder. Put your Nebius Token Factory"
echo "key there to enable plain-language rule compilation; without it the Rules"
echo "tab's Preview shows an error and everything else works."
