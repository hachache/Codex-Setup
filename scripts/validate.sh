#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[ -f "$ROOT_DIR/AGENTS.md" ] || die "AGENTS.md manquant"
[ -x "$ROOT_DIR/install.sh" ] || die "install.sh doit etre executable"
[ -d "$ROOT_DIR/agents" ] || die "dossier agents manquant"

agent_count=$(find "$ROOT_DIR/agents" -maxdepth 1 -type f -name '*.toml' | wc -l | tr -d ' ')
[ "$agent_count" -gt 0 ] || die "aucun agent TOML"

sh -n "$ROOT_DIR/install.sh"
sh -n "$ROOT_DIR/scripts/validate.sh"

if [ -f "$ROOT_DIR/scripts/sync-from-local.sh" ]; then
  sh -n "$ROOT_DIR/scripts/sync-from-local.sh"
fi

if [ -f "$ROOT_DIR/scripts/doctor.sh" ]; then
  sh -n "$ROOT_DIR/scripts/doctor.sh"
fi

missing=0
for file in "$ROOT_DIR"/agents/*.toml; do
  [ -f "$file" ] || continue
  base=$(basename "$file" .toml)
  name=$(sed -n 's/^name = "\(.*\)"$/\1/p' "$file" | head -n 1)
  [ -n "$name" ] || {
    printf 'missing name: %s\n' "$file" >&2
    missing=1
    continue
  }
  [ "$name" = "$base" ] || {
    printf 'name mismatch: %s declares %s\n' "$file" "$name" >&2
    missing=1
  }
  for key in description model model_reasoning_effort sandbox_mode developer_instructions; do
    if ! grep -q "^$key = " "$file"; then
      printf 'missing %s: %s\n' "$key" "$file" >&2
      missing=1
    fi
  done
done

[ "$missing" -eq 0 ] || die "schema agent invalide"

if command -v python3 >/dev/null 2>&1; then
  python3 - "$ROOT_DIR" <<'PY'
import pathlib
import sys

try:
    import tomllib
except ModuleNotFoundError:
    try:
        import tomli as tomllib
    except ModuleNotFoundError:
        print("WARN: python3 sans tomllib/tomli; validation TOML parse ignoree", file=sys.stderr)
        raise SystemExit(0)

root = pathlib.Path(sys.argv[1])
for path in sorted((root / "agents").glob("*.toml")):
    with path.open("rb") as handle:
        tomllib.load(handle)
template = root / "config" / "config.template.toml"
if template.exists():
    with template.open("rb") as handle:
        tomllib.load(handle)
print("TOML OK")
PY
else
  printf 'WARN: python3 introuvable; validation TOML parse ignoree\n' >&2
fi

if command -v rg >/dev/null 2>&1; then
  if rg -n "(sk-(proj|live|test|srv|admin|org)-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|EC|DSA)? ?PRIVATE KEY|password\\s*=\\s*['\\\"][^'\\\"]+|token\\s*=\\s*['\\\"][^'\\\"]+|api[_-]?key\\s*=\\s*['\\\"][^'\\\"]+|secret\\s*=\\s*['\\\"][^'\\\"]+)" "$ROOT_DIR" | rg -v "(your-|<[^>]+>|abc123|example|placeholder|dummy)"; then
    die "secret potentiel detecte"
  fi
fi

printf 'OK: %s agents valides\n' "$agent_count"
