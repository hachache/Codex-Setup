#!/bin/sh
set -eu

ROOT_DIR=$(unset CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_grep() {
  pattern=$1
  file=$2
  message=$3

  grep -q "$pattern" "$file" || die "$message"
}

require_contains() {
  pattern=$1
  file=$2
  message=$3

  grep -F -q "$pattern" "$file" || die "$message"
}

[ -f "$ROOT_DIR/AGENTS.md" ] || die "AGENTS.md manquant"
[ -x "$ROOT_DIR/install.sh" ] || die "install.sh doit etre executable"
[ -d "$ROOT_DIR/agents" ] || die "dossier agents manquant"
[ -f "$ROOT_DIR/docs/quality-gate-pipeline.md" ] || die "documentation pipeline auto-verifiant manquante"
[ -f "$ROOT_DIR/docs/context-efficiency.md" ] || die "documentation efficacite contexte/tokens manquante"
[ -f "$ROOT_DIR/agents/engineering-pipeline-orchestrator.toml" ] ||
  die "agent engineering-pipeline-orchestrator manquant"
[ -f "$ROOT_DIR/agents/implementation-engineer.toml" ] || die "agent implementation-engineer manquant"
[ -f "$ROOT_DIR/agents/quality-gatekeeper.toml" ] || die "agent quality-gatekeeper manquant"

require_grep '^## Pipeline auto-verifiant$' "$ROOT_DIR/AGENTS.md" \
  "section pipeline auto-verifiant manquante dans AGENTS.md"
require_grep "^## Mode par defaut$" "$ROOT_DIR/AGENTS.md" \
  "section mode par defaut manquante dans AGENTS.md"
require_grep '^## Efficacite contexte et tokens$' "$ROOT_DIR/AGENTS.md" \
  "section efficacite contexte/tokens manquante dans AGENTS.md"
require_grep '^## Loop fast$' "$ROOT_DIR/AGENTS.md" "loop fast manquante dans AGENTS.md"
require_grep '^## Loop critical$' "$ROOT_DIR/AGENTS.md" "loop critical manquante dans AGENTS.md"
require_contains 'Traiter le contexte comme un budget limite.' "$ROOT_DIR/AGENTS.md" \
  "budget contexte manquant dans AGENTS.md"
require_contains 'La validation doit suivre le risque:' "$ROOT_DIR/AGENTS.md" \
  "validation par risque manquante dans AGENTS.md"
require_contains "Si l'utilisateur ne nomme pas \`loop fast\`, \`fast loop\`, \`boucle fast\`, \`loop critical\`," \
  "$ROOT_DIR/AGENTS.md" "mode par defaut Codex manquant dans AGENTS.md"
require_contains 'Escalader la verification par risque reel, sans activer `loop critical` implicitement.' \
  "$ROOT_DIR/AGENTS.md" "loop critical implicite interdite dans AGENTS.md"
require_contains 'Chaque retry doit etre justifie par une cause concrete' "$ROOT_DIR/AGENTS.md" \
  "retry par cause concrete manquant dans AGENTS.md"
require_contains 'Ne jamais utiliser ' "$ROOT_DIR/AGENTS.md" \
  "interdiction xhigh faible risque manquante dans AGENTS.md"
require_contains 'triviaux single-file.' "$ROOT_DIR/AGENTS.md" \
  "interdiction xhigh faible risque incomplete dans AGENTS.md"
require_contains 'Uniquement en `loop critical`, appliquer automatiquement ce pipeline.' \
  "$ROOT_DIR/AGENTS.md" "pipeline complet doit etre limite a loop critical dans AGENTS.md"
require_contains '[Efficacite contexte et tokens](docs/context-efficiency.md)' "$ROOT_DIR/README.md" \
  "README doit referencer la documentation efficacite contexte/tokens"
require_grep 'quality-gatekeeper' "$ROOT_DIR/docs/agents.md" \
  "documentation des agents de pipeline manquante"
require_grep 'gate_report' "$ROOT_DIR/docs/quality-gate-pipeline.md" \
  "schema gate_report manquant dans la documentation"
require_contains 'Toujours choisir le plus petit workflow qui donne assez de confiance' \
  "$ROOT_DIR/docs/context-efficiency.md" "principe efficacite manquant dans la documentation"
require_contains '## Invocation dans le chat' "$ROOT_DIR/docs/context-efficiency.md" \
  "invocation chat manquante dans la documentation"
require_contains '`loop fast`' "$ROOT_DIR/docs/context-efficiency.md" \
  "loop fast manquante dans la documentation"
require_contains '`loop critical`' "$ROOT_DIR/docs/context-efficiency.md" \
  "loop critical manquante dans la documentation"
require_contains 'Ne jamais relancer une validation echouee sans avoir change la cause pertinente.' \
  "$ROOT_DIR/docs/context-efficiency.md" "no blind retry manquant dans la documentation"
require_contains 'residual_risks:' "$ROOT_DIR/docs/context-efficiency.md" \
  "evidence ledger manquant dans la documentation"
require_grep '^### Loop fast$' "$ROOT_DIR/docs/quality-gate-pipeline.md" \
  "loop fast manquante dans la documentation pipeline"
require_grep '^### Loop critical$' "$ROOT_DIR/docs/quality-gate-pipeline.md" \
  "loop critical manquante dans la documentation pipeline"
require_contains 'Le workflow auto-verifiant est reserve a `loop critical`.' "$ROOT_DIR/docs/agents.md" \
  "documentation agents doit limiter le pipeline a loop critical"
require_contains "Implementation: utiliser \`@implementation-engineer\` comme owner du \`gate_report\`" \
  "$ROOT_DIR/AGENTS.md" "implementation-engineer doit etre owner du gate_report dans AGENTS.md"
require_contains "writer: \`@implementation-engineer\` as accountable owner" \
  "$ROOT_DIR/agents/workflow-orchestrator.toml" \
  "workflow-orchestrator doit garder implementation-engineer comme writer owner"
require_contains "Select \`@implementation-engineer\` as the accountable writer stage owner" \
  "$ROOT_DIR/agents/engineering-pipeline-orchestrator.toml" \
  "engineering-pipeline-orchestrator doit garder implementation-engineer comme writer owner"
require_contains "Use this agent as the accountable implementation owner" \
  "$ROOT_DIR/agents/implementation-engineer.toml" "implementation-engineer doit etre accountable owner"

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
  if grep -q '^Technical depth:$' "$file"; then
    printf 'obsolete Technical depth block: %s\n' "$file" >&2
    missing=1
  fi
  if grep -q '^Development loop:$' "$file"; then
    printf 'obsolete Development loop block: %s\n' "$file" >&2
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
    for obsolete in ("Technical depth:", "Development loop:"):
        if obsolete in instructions:
            raise SystemExit(f"{path}: section obsolete dans developer_instructions: {obsolete}")
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
  secret_pattern='(sk-(proj|live|test|srv|admin|org)-[A-Za-z0-9_-]{16,}'
  secret_pattern="${secret_pattern}|sk-[A-Za-z0-9_-]{32,}"
  secret_pattern="${secret_pattern}|AKIA[0-9A-Z]{16}"
  secret_pattern="${secret_pattern}|BEGIN (RSA|OPENSSH|EC|DSA)? ?PRIVATE KEY"
  secret_pattern="${secret_pattern}|password\\s*=\\s*['\\\"][^'\\\"]+"
  secret_pattern="${secret_pattern}|token\\s*=\\s*['\\\"][^'\\\"]+"
  secret_pattern="${secret_pattern}|api[_-]?key\\s*=\\s*['\\\"][^'\\\"]+"
  secret_pattern="${secret_pattern}|secret\\s*=\\s*['\\\"][^'\\\"]+)"
  allow_pattern='(your-|<[^>]+>|abc123|example|placeholder|dummy)'

  if rg -n "$secret_pattern" "$ROOT_DIR" | rg -v "$allow_pattern"; then
    die "secret potentiel detecte"
  fi
fi

printf 'OK: %s agents valides\n' "$agent_count"
