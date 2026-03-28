#!/usr/bin/env bash
# Fetch the CFLint standalone JAR (required by the vscode-cflint extension).
# Usage: from repo root: bash tools/cflint/download.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
JAR="$DIR/CFLint-1.5.0-all.jar"
echo "Downloading CFLint to $JAR ..."
curl -fsSL -o "$JAR" \
  'https://repo1.maven.org/maven2/com/github/cflint/CFLint/1.5.0/CFLint-1.5.0-all.jar'
echo "Done. Set cflint.jarPath in .vscode/settings.json to this path (see DEV_NOTES.md)."
