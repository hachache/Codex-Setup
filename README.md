# Codex Setup

Setup reproductible pour installer le workflow Codex de reference sur un Mac:

- instructions globales `~/.codex/AGENTS.md`;
- agents Codex `~/.codex/agents/*.toml`;
- skills personnels `~/.codex/skills/<skill>/`;
- template optionnel `~/.codex/config.toml` avec multi-agent, memories et plugins usuels;
- scripts de validation et de synchronisation.

Le depot ne versionne pas l'authentification, les logs, les sessions, les caches, les memories, les plugins installes, ni les fichiers d'etat Codex.

Docs:

- [Agents](docs/agents.md)
- [Skills](docs/skills.md)

## Installation rapide

```bash
git clone git@github.com:hachache/Codex-Setup.git
cd Codex-Setup
./install.sh
```

Installer aussi le template de config si `~/.codex/config.toml` n'existe pas:

```bash
./install.sh --install-config
```

Forcer le remplacement du `config.toml` existant:

```bash
./install.sh --install-config --force-config
```

## Options

```text
--dry-run         Affiche les actions sans modifier le poste.
--no-backup      N'ecrit pas de sauvegarde avant remplacement.
--no-skills      N'installe pas les skills personnels versionnes.
--prune-agents   Supprime de ~/.codex/agents les agents TOML absents du repo.
--prune-skills   Supprime de ~/.codex/skills les skills absents du repo.
--install-config Installe config/config.template.toml si config.toml est absent.
--force-config   Remplace config.toml par le template apres sauvegarde.
--help           Affiche l'aide.
```

Variable utile:

```bash
CODEX_HOME="$HOME/.codex" ./install.sh
```

## Ce que le script installe

| Source repo | Destination |
|---|---|
| `AGENTS.md` | `~/.codex/AGENTS.md` |
| `agents/*.toml` | `~/.codex/agents/*.toml` |
| `skills/<skill>/` | `~/.codex/skills/<skill>/` |
| `config/config.template.toml` | `~/.codex/config.toml` avec `--install-config` |

Les fichiers existants remplaces sont sauvegardes dans:

```text
~/.codex/backups/Codex-Setup-<timestamp>/
```

## Verification

```bash
./scripts/validate.sh
./install.sh --dry-run
./scripts/doctor.sh
find ~/.codex/agents -maxdepth 1 -type f -name '*.toml' | wc -l
codex --version
```

## Mise a jour depuis le Mac de reference

Depuis ce repo:

```bash
./scripts/sync-from-local.sh
./scripts/validate.sh
git status --short
git diff --check
git add AGENTS.md agents config scripts docs rules README.md .gitignore install.sh
git commit -m "feat(setup): update codex workflow"
git push origin main
```

`sync-from-local.sh` copie uniquement:

- `~/.codex/AGENTS.md`;
- `~/.codex/agents/*.toml`;
- les skills personnels de `~/.codex/skills/`, hors `.system` et `codex-primary-runtime`.

Verifier un poste deja installe:

```bash
./scripts/doctor.sh
```

Il ne copie jamais:

- `~/.codex/auth.json`;
- `~/.codex/config.toml`;
- `~/.codex/*.sqlite*`;
- `~/.codex/memories`;
- `~/.codex/cache`;
- `~/.codex/plugins`;
- `~/.codex/sessions`;
- `~/.codex/attachments`.
- `~/.codex/skills/.system`;
- `~/.codex/skills/codex-primary-runtime`.

## Premier poste Mac

Pre-requis:

- macOS;
- Git;
- Codex installe et authentifie;
- acces SSH au depot si clone via `git@github.com:hachache/Codex-Setup.git`.

Le script ne gere pas l'authentification Codex. Chaque utilisateur doit se connecter avec son propre compte.

Le template `config/config.template.toml` evite les chemins personnels, les projets trustes et les MCP locaux. Il active seulement les options et plugins generiques du workflow.

## Rollback

Restaurer une sauvegarde:

```bash
cp -R ~/.codex/backups/Codex-Setup-<timestamp>/AGENTS.md ~/.codex/AGENTS.md
cp -R ~/.codex/backups/Codex-Setup-<timestamp>/agents/. ~/.codex/agents/
```

Pour `config.toml`, restaurer uniquement si le backup en contient un:

```bash
cp ~/.codex/backups/Codex-Setup-<timestamp>/config.toml ~/.codex/config.toml
```
