#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CODEX_HOME=${CODEX_HOME:-"$HOME/.codex"}
TARGET_AGENTS="$CODEX_HOME/agents"

status=0

check() {
  label=$1
  shift
  if "$@"; then
    printf 'OK: %s\n' "$label"
  else
    printf 'FAIL: %s\n' "$label" >&2
    status=1
  fi
}

check "Codex home existe" test -d "$CODEX_HOME"
check "AGENTS.md installe" test -f "$CODEX_HOME/AGENTS.md"
check "dossier agents installe" test -d "$TARGET_AGENTS"

if command -v codex >/dev/null 2>&1; then
  printf 'OK: codex CLI: %s\n' "$(codex --version 2>/dev/null || printf unknown)"
elif [ -x /Applications/Codex.app/Contents/Resources/codex ]; then
  printf 'OK: codex app CLI: %s\n' "$(/Applications/Codex.app/Contents/Resources/codex --version 2>/dev/null || printf unknown)"
else
  printf 'WARN: codex CLI introuvable dans PATH et app standard absente\n' >&2
fi

if [ -f "$CODEX_HOME/AGENTS.md" ]; then
  check "AGENTS.md aligne" cmp -s "$ROOT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md"
fi

repo_count=$(find "$ROOT_DIR/agents" -maxdepth 1 -type f -name '*.toml' | wc -l | tr -d ' ')
installed_count=0
if [ -d "$TARGET_AGENTS" ]; then
  installed_count=$(find "$TARGET_AGENTS" -maxdepth 1 -type f -name '*.toml' | wc -l | tr -d ' ')
fi

printf 'INFO: agents repo=%s installed=%s\n' "$repo_count" "$installed_count"

missing=0
different=0
for src in "$ROOT_DIR"/agents/*.toml; do
  [ -f "$src" ] || continue
  base=$(basename "$src")
  dest="$TARGET_AGENTS/$base"
  if [ ! -f "$dest" ]; then
    printf 'MISSING: %s\n' "$base" >&2
    missing=$((missing + 1))
    continue
  fi
  if ! cmp -s "$src" "$dest"; then
    printf 'DIFF: %s\n' "$base" >&2
    different=$((different + 1))
  fi
done

if [ "$missing" -eq 0 ] && [ "$different" -eq 0 ]; then
  printf 'OK: agents alignes\n'
else
  printf 'FAIL: agents missing=%s different=%s\n' "$missing" "$different" >&2
  status=1
fi

exit "$status"
