# Codex Setup

[![CI](https://github.com/hachache/Codex-Setup/actions/workflows/ci.yml/badge.svg)](https://github.com/hachache/Codex-Setup/actions/workflows/ci.yml)
[![Release](https://github.com/hachache/Codex-Setup/actions/workflows/release.yml/badge.svg)](https://github.com/hachache/Codex-Setup/actions/workflows/release.yml)

Setup Mac reproductible pour transformer Codex en environnement de travail agentique: agents installables, instructions globales, skills personnels, validation locale, CI GitHub Actions et release versionnee.

L'objectif: cloner le depot, lancer un script, retrouver le meme workflow Codex proprement installe sur un autre Mac.

## Ce que ca apporte

- **Reproductibilite**: `AGENTS.md`, agents TOML et skills sont versionnes et reinstallables.
- **Securite**: aucun secret, auth, cache, session, memory ou plugin local n'est versionne.
- **Qualite**: `validate.sh`, `doctor.sh`, ShellCheck, Gitleaks, checks whitespace et installation isolee.
- **Routage intelligent**: Fast, Standard et Critical modes pour eviter de bruler du quota sur les petites taches.
- **Pipeline critique**: orchestrator, implementer, reviewer, security, performance et gatekeeper seulement quand le risque le justifie.
- **Release propre**: tag `v*`, archive `tar.gz`, checksum SHA-256 et GitHub Release automatique.

## Avant / apres

| Situation | Avant | Apres |
|---|---|---|
| Nouveau Mac | Copier des prompts, agents et fichiers a la main | `git clone`, `./install.sh`, `./scripts/doctor.sh` |
| Petites taches | Risque de lancer trop d'agents et trop de reasoning | Fast mode: direct, `medium`, validation ciblee |
| Changement standard | Validation locale dependante de la discipline | Standard mode: tests/checks adaptes + revue legere |
| Changement critique | Review manuelle et criteres implicites | Critical mode: pipeline auto-verifiant avec gate finale |
| Publication | Pas d'artefact versionne | Tag `v1.0.0` puis archive release + checksum |
| Maintenance | Drift entre Mac de reference et depot | `sync-from-local.sh`, `validate.sh`, CI obligatoire |

## Matrice d'execution

| Mode | Quand l'utiliser | Agents | Reasoning | Validation |
|---|---|---|---|---|
| Fast | README simple, copy edit, formatage, petit fix shell, changement trivial single-file | Aucun agent multiple sauf demande explicite | `medium` | Diff + commande ciblee si utile |
| Standard | Feature normale, bug non trivial, refactor modere, script ou doc operatoire | Agent principal + specialiste unique si utile | `medium` ou agent adapte | Tests, lint, build, dry-run ou validation repo |
| Critical | Securite, auth, secrets, CI/CD, prod, infra, DB, performance, gros refactor, architecture multi-fichiers | Orchestrator, implementation, review, security, perf, gatekeeper | `xhigh` si justifie | Quality gate complet, preuves et N/A explicites |

## Contenu

- instructions globales `~/.codex/AGENTS.md`;
- agents Codex `~/.codex/agents/*.toml`;
- skills personnels `~/.codex/skills/<skill>/`;
- template optionnel `~/.codex/config.toml` avec multi-agent, memories et plugins usuels;
- scripts de validation et de synchronisation.

Le depot ne versionne pas l'authentification, les logs, les sessions, les caches, les memories, les plugins installes, ni les fichiers d'etat Codex.

Docs:

- [Agents](docs/agents.md)
- [Skills](docs/skills.md)
- [Efficacite contexte et tokens](docs/context-efficiency.md)
- [Pipeline auto-verifiant](docs/quality-gate-pipeline.md)

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

La CI GitHub Actions impose aussi:

- validation du repo avec `./scripts/validate.sh`;
- syntaxe shell avec `sh -n`;
- hygiene LF/whitespace;
- `git diff --check`;
- `./install.sh --dry-run --install-config --no-skills`;
- installation isolee avec `CODEX_HOME=$(mktemp -d)/.codex`;
- `ShellCheck`;
- scan secrets `Gitleaks` sur l'arbre courant.

Les tags `v*` declenchent le workflow `Release`, qui valide le setup, cree une archive `tar.gz` versionnee et publie une release GitHub avec checksum SHA-256.

Creer la premiere release stable:

```bash
git tag v1.0.0
git push origin v1.0.0
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
