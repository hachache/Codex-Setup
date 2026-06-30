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
[ -f "$ROOT_DIR/docs/quality-gate-pipeline.md" ] || die "documentation pipeline auto-verifiant manquante"
[ -f "$ROOT_DIR/agents/engineering-pipeline-orchestrator.toml" ] || die "agent engineering-pipeline-orchestrator manquant"
[ -f "$ROOT_DIR/agents/implementation-engineer.toml" ] || die "agent implementation-engineer manquant"
[ -f "$ROOT_DIR/agents/quality-gatekeeper.toml" ] || die "agent quality-gatekeeper manquant"

grep -q '^## Pipeline auto-verifiant$' "$ROOT_DIR/AGENTS.md" || die "section pipeline auto-verifiant manquante dans AGENTS.md"
grep -q 'quality-gatekeeper' "$ROOT_DIR/docs/agents.md" || die "documentation des agents de pipeline manquante"
grep -q 'gate_report' "$ROOT_DIR/docs/quality-gate-pipeline.md" || die "schema gate_report manquant dans la documentation"
grep -q 'Implementation: utiliser `@implementation-engineer` comme owner du `gate_report`' "$ROOT_DIR/AGENTS.md" || die "implementation-engineer doit etre owner du gate_report dans AGENTS.md"
grep -q 'writer: `@implementation-engineer` as accountable owner' "$ROOT_DIR/agents/workflow-orchestrator.toml" || die "workflow-orchestrator doit garder implementation-engineer comme writer owner"
grep -q 'Select `@implementation-engineer` as the accountable writer stage owner' "$ROOT_DIR/agents/engineering-pipeline-orchestrator.toml" || die "engineering-pipeline-orchestrator doit garder implementation-engineer comme writer owner"
grep -q 'Use this agent as the accountable implementation owner' "$ROOT_DIR/agents/implementation-engineer.toml" || die "implementation-engineer doit etre accountable owner"

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
  effort=$(sed -n 's/^model_reasoning_effort = "\(.*\)"$/\1/p' "$file" | head -n 1)
  case "$effort" in
    medium|xhigh)
      ;;
    high)
      printf 'invalid effort, use xhigh instead of high: %s\n' "$file" >&2
      missing=1
      ;;
    *)
      printf 'unknown model_reasoning_effort %s: %s\n' "$effort" "$file" >&2
      missing=1
      ;;
  esac
  if ! grep -q '^Technical depth:$' "$file"; then
    printf 'missing Technical depth block: %s\n' "$file" >&2
    missing=1
  fi
  if ! grep -q '^Development loop:$' "$file"; then
    printf 'missing Development loop block: %s\n' "$file" >&2
    missing=1
  fi
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
        print("ERROR: python3 doit fournir tomllib ou tomli pour valider les agents", file=sys.stderr)
        raise SystemExit(1)

root = pathlib.Path(sys.argv[1])
required = {
    "name",
    "description",
    "model",
    "model_reasoning_effort",
    "sandbox_mode",
    "developer_instructions",
}
pipeline_agents = {
    "workflow-orchestrator",
    "engineering-pipeline-orchestrator",
    "implementation-engineer",
    "code-reviewer",
    "reviewer",
    "performance-engineer",
    "security-auditor",
    "quality-gatekeeper",
}
gate_fields = {
    "agent",
    "status",
    "scope",
    "evidence",
    "commands_run",
    "blocking_findings",
    "residual_risks",
    "rerun_required",
}
for path in sorted((root / "agents").glob("*.toml")):
    with path.open("rb") as handle:
        data = tomllib.load(handle)
    missing = sorted(required - data.keys())
    if missing:
        raise SystemExit(f"{path}: champs manquants: {', '.join(missing)}")
    if data["name"] != path.stem:
        raise SystemExit(f"{path}: name ne correspond pas au nom du fichier")
    if data["model_reasoning_effort"] not in {"medium", "xhigh"}:
        raise SystemExit(f"{path}: model_reasoning_effort invalide: {data['model_reasoning_effort']}")
    instructions = data["developer_instructions"]
    for section in ("Technical depth:", "Development loop:"):
        if section not in instructions:
            raise SystemExit(f"{path}: section manquante dans developer_instructions: {section}")
    technical = instructions.split("Technical depth:", 1)[1].split("Development loop:", 1)[0]
    loop = instructions.split("Development loop:", 1)[1]
    if technical.count("\n- ") < 3:
        raise SystemExit(f"{path}: section Technical depth trop faible")
    if "3 unsuccessful correction cycles" not in loop:
        raise SystemExit(f"{path}: boucle de developpement non bornee")
    if data["name"] in pipeline_agents:
        return_block = instructions.rsplit("Return:", 1)[-1]
        if "gate_report" not in return_block:
            raise SystemExit(f"{path}: gate_report absent du bloc Return")
        missing_gate_fields = sorted(field for field in gate_fields if field not in return_block)
        if missing_gate_fields:
            raise SystemExit(
                f"{path}: champs gate_report manquants dans Return: {', '.join(missing_gate_fields)}"
            )
template = root / "config" / "config.template.toml"
if template.exists():
    with template.open("rb") as handle:
        tomllib.load(handle)
print("TOML OK")
PY
else
  die "python3 introuvable: validation TOML obligatoire"
fi

if command -v rg >/dev/null 2>&1; then
  if rg -n "(sk-(proj|live|test|srv|admin|org)-[A-Za-z0-9_-]{16,}|sk-[A-Za-z0-9_-]{32,}|AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|EC|DSA)? ?PRIVATE KEY|password\\s*=\\s*['\\\"][^'\\\"]+|token\\s*=\\s*['\\\"][^'\\\"]+|api[_-]?key\\s*=\\s*['\\\"][^'\\\"]+|secret\\s*=\\s*['\\\"][^'\\\"]+)" "$ROOT_DIR" | rg -v "(your-|<[^>]+>|abc123|example|placeholder|dummy)"; then
    die "secret potentiel detecte"
  fi
fi

printf 'OK: %s agents valides\n' "$agent_count"
