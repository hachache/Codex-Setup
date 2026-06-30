# Agents inclus

Le dossier `agents/` contient les agents globaux installes dans `~/.codex/agents`.

## Conventions

Chaque agent est un fichier TOML:

```toml
name = "agent-name"
description = "Use when ..."
model = "gpt-5.5"
model_reasoning_effort = "xhigh"
sandbox_mode = "workspace-write"
developer_instructions = """
...
"""
```

Champs obligatoires:

- `name`
- `description`
- `model`
- `model_reasoning_effort`
- `sandbox_mode`
- `developer_instructions`

## Effort de raisonnement

Valeurs autorisees pour les agents:

- `medium`
- `xhigh`

La valeur `xhigh` est l'equivalent technique du mode "very high" dans ce setup. Ne pas utiliser `high`: les agents qui etaient en `high` doivent rester en `xhigh`.

Politique locale:

- agents standards: `medium`;
- agents avances ou critiques: `xhigh`;
- `high` interdit pour eviter un palier intermediaire quand le besoin est explicitement "very high".

## Blocs obligatoires

Chaque agent doit contenir:

- `Technical depth:` avec les controles techniques adaptes a sa famille;
- `Development loop:` avec la boucle inspecter, planifier, implementer, verifier, corriger.

La boucle est bornee: arret quand la reussite est prouvee, quand un vrai blocage est atteint, ou apres 3 cycles de correction infructueux.

Ce pattern suit les pratiques publiques Claude Code: explorer/planifier avant implementation, prouver avec des sorties de commandes ou captures, et utiliser des hooks/subagents pour verifier quand c'est pertinent.

References publiques:

- [Codex config reference](https://developers.openai.com/codex/config-reference)
- [Claude Code common workflows](https://docs.anthropic.com/en/docs/claude-code/common-workflows)
- [Claude Code hooks guide](https://docs.anthropic.com/en/docs/claude-code/hooks-guide)
- [Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices)

Le nom du fichier doit correspondre a `name`:

```text
agents/python-pro.toml -> name = "python-pro"
```

## Agents alias

Certains agents existent pour compatibilite avec les habitudes de routage:

- `shell-specialist`
- `docker-specialist`
- `terraform-specialist`
- `aws-specialist`
- `python-specialist`
- `vite-specialist`
- `tailwind-specialist`
- `design-specialist`

Ils evitent que `AGENTS.md` reference un agent absent sur un nouveau Mac.

## Agents de pipeline

Le workflow auto-verifiant repose sur ces agents dedies:

- `engineering-pipeline-orchestrator`: definit le pipeline, les agents requis, les validations et les N/A acceptables.
- `implementation-engineer`: owner de l'etape d'implementation et du `gate_report` writer; les specialistes stack peuvent rester en support.
- `quality-gatekeeper`: gate finale qui retourne `PASS` ou `BLOCKED` avant toute reponse finale de completion.

Les autres etapes s'appuient sur les agents existants:

- critique: `code-reviewer` ou `reviewer`;
- performance: `performance-engineer`;
- securite: `security-auditor`.

Procedure detaillee: [Pipeline auto-verifiant](quality-gate-pipeline.md).

Chaque agent implique dans le pipeline doit produire un `gate_report` avec:

- `agent`;
- `status`: `pass`, `fail`, `blocked` ou `not_applicable`;
- `scope`;
- `evidence`;
- `commands_run`;
- `blocking_findings`;
- `residual_risks`;
- `rerun_required`.

## Validation

```bash
./scripts/validate.sh
```

La validation controle:

- syntaxe shell des scripts;
- presence des champs TOML obligatoires;
- coherence `filename == name`;
- parsing TOML obligatoire via `tomllib` ou `tomli`;
- presence et contenu minimal des blocs `Technical depth:` et `Development loop:`;
- presence des agents et de la documentation du pipeline auto-verifiant;
- scan basique de secrets si `rg` est disponible.
