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

La valeur `xhigh` est l'equivalent technique du mode "very high" dans ce setup. Ne pas utiliser
`high`: les agents qui etaient en `high` doivent rester en `xhigh`.

Politique locale:

- agents standards: `medium`;
- agents avances ou critiques: `xhigh`;
- `high` interdit pour eviter un palier intermediaire quand le besoin est explicitement "very high".

Politique d'execution:

- Par defaut, Codex traite directement sans boucle nommee.
- `loop fast` utilise `medium` et traite directement les petites taches a faible risque.
- `loop critical` active les agents de pipeline et les agents `xhigh` quand le risque le justifie.
- Les agents specialises ne se declenchent pas par mot-cle seul. Ils sont utilises si l'utilisateur
  les nomme, si `loop critical` les requiert, ou si le risque technique justifie clairement un
  specialiste.
- Les skills Lean (`lean-review`, `lean-audit`, `lean-debt`) sont des outils de simplification
  explicites; ils ne changent pas le routage automatique des agents.
- Ne jamais utiliser `xhigh` pour formatage, docs simples, copy edits, petits fixes shell ou changements triviaux single-file.
- Preferer le workflow le moins cher qui donne assez de confiance.

## Instructions d'agent

Chaque agent doit rester centre sur son domaine:

- mission claire;
- conditions d'utilisation;
- working mode court;
- controles qualite propres au stack;
- format de retour utile au parent agent.

Ne pas injecter de boucle generique dans tous les agents. Les boucles sont centralisees dans
`AGENTS.md`:

- `loop fast`: boucle courte, directe, sans pipeline;
- `loop critical`: pipeline auto-verifiant complet.

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

Le workflow auto-verifiant est reserve a `loop critical`. Il repose sur ces agents dedies:

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
- absence d'effort `high`, au profit de `medium` ou `xhigh`;
- presence des agents et de la documentation du pipeline auto-verifiant;
- scan basique de secrets si `rg` est disponible.
