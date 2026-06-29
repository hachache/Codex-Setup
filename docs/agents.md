# Agents inclus

Le dossier `agents/` contient les agents globaux installes dans `~/.codex/agents`.

## Conventions

Chaque agent est un fichier TOML:

```toml
name = "agent-name"
description = "Use when ..."
model = "gpt-5.5"
model_reasoning_effort = "high"
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

## Validation

```bash
./scripts/validate.sh
```

La validation controle:

- syntaxe shell des scripts;
- presence des champs TOML obligatoires;
- coherence `filename == name`;
- parsing TOML si `python3` fournit `tomllib`;
- scan basique de secrets si `rg` est disponible.
