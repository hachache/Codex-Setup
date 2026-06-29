#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CODEX_HOME=${CODEX_HOME:-"$HOME/.codex"}
SOURCE_AGENTS="$CODEX_HOME/agents"
SOURCE_SKILLS="$CODEX_HOME/skills"

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[ -f "$CODEX_HOME/AGENTS.md" ] || die "$CODEX_HOME/AGENTS.md introuvable"
[ -d "$SOURCE_AGENTS" ] || die "$SOURCE_AGENTS introuvable"

mkdir -p "$ROOT_DIR/agents"
cp -p "$CODEX_HOME/AGENTS.md" "$ROOT_DIR/AGENTS.md"
find "$ROOT_DIR/agents" -maxdepth 1 -type f -name '*.toml' -delete
cp -p "$SOURCE_AGENTS"/*.toml "$ROOT_DIR/agents/"

if [ -d "$SOURCE_SKILLS" ]; then
  mkdir -p "$ROOT_DIR/skills"
  find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +
  for skill in "$SOURCE_SKILLS"/*; do
    [ -d "$skill" ] || continue
    base=$(basename "$skill")
    [ "$base" = ".system" ] && continue
    [ "$base" = "codex-primary-runtime" ] && continue
    cp -pR "$skill" "$ROOT_DIR/skills/"
  done
fi

printf 'synced: %s\n' "$CODEX_HOME/AGENTS.md"
printf 'synced agents: %s\n' "$(find "$ROOT_DIR/agents" -maxdepth 1 -type f -name '*.toml' | wc -l | tr -d ' ')"
if [ -d "$ROOT_DIR/skills" ]; then
  printf 'synced skills: %s\n' "$(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
fi
