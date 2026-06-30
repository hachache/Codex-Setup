# Codex Setup

[![CI](https://github.com/hachache/Codex-Setup/actions/workflows/ci.yml/badge.svg)](https://github.com/hachache/Codex-Setup/actions/workflows/ci.yml)
[![Release](https://github.com/hachache/Codex-Setup/actions/workflows/release.yml/badge.svg)](https://github.com/hachache/Codex-Setup/actions/workflows/release.yml)

Setup Mac reproductible pour transformer Codex en environnement de travail agentique: agents installables, instructions globales, skills personnels, validation locale, CI GitHub Actions et release versionnee.

L'objectif: cloner le depot, lancer un script, retrouver le meme workflow Codex proprement installe sur un autre Mac.

## Ce que ca apporte

- **Reproductibilite**: `AGENTS.md`, agents TOML et skills sont versionnes et reinstallables.
- **Securite**: aucun secret, auth, cache, session, memory ou plugin local n'est versionne.
- **Qualite**: `validate.sh`, `doctor.sh`, ShellCheck, Gitleaks, checks whitespace et installation isolee.
- **Defaut leger**: sans instruction de boucle, Codex garde son comportement normal.
- **Lean par defaut**: YAGNI, reuse local, stdlib, natif plateforme et minimum correct avant tout ajout.
- **Boucles invocables**: seulement `loop fast` et `loop critical`, avec budgets de retry bornes.
- **Pipeline critique**: orchestrator, implementer, reviewer, security, performance et gatekeeper seulement en `loop critical`.
- **Reviews anti-bloat**: skills `lean-review`, `lean-audit` et `lean-debt` pour couper le superflu sans melanger avec la revue correctness/security.
- **Release propre**: tag `v*`, archive `tar.gz`, checksum SHA-256 et GitHub Release automatique.

## Avant / apres

| Situation | Avant | Apres |
|---|---|---|
| Nouveau Mac | Copier des prompts, agents et fichiers a la main | `git clone`, `./install.sh`, `./scripts/doctor.sh` |
| Petites taches | Risque de lancer trop d'agents et trop de reasoning | `loop fast`: direct, `medium`, validation ciblee |
| Changement standard | Validation locale dependante de la discipline | Defaut Codex: workflow normal + verification adaptee |
| Changement critique | Review manuelle et criteres implicites | `loop critical`: pipeline auto-verifiant avec gate finale |
| Over-engineering | Prompts ad hoc ou dependances ajoutees trop vite | Ladder Lean + skills explicites de review/audit |
| Publication | Pas d'artefact versionne | Tag `v1.0.0` puis archive release + checksum |
| Maintenance | Drift entre Mac de reference et depot | `sync-from-local.sh`, `validate.sh`, CI obligatoire |

## Matrice d'execution

| Mode | Quand l'utiliser | Agents | Reasoning | Validation |
|---|---|---|---|---|
| Defaut Codex | Aucune boucle nommee par l'utilisateur | Agent principal direct, subagent seulement si explicitement justifie | Le plus petit effort suffisant | Verification adaptee au diff et au risque |
| `loop fast` | README simple, copy edit, formatage, petit fix shell, changement trivial single-file | Aucun agent multiple sauf demande explicite | `medium` | Diff + commande ciblee si utile |
| `loop critical` | Securite, auth, secrets, CI/CD, prod, infra, DB, performance, gros refactor, architecture multi-fichiers | Orchestrator, implementation, review, security, perf, gatekeeper | `xhigh` si justifie | Quality gate complet, preuves et N/A explicites |

Les agents specialises ne sont pas declenches par mot-cle seul. Ils entrent en jeu si l'utilisateur
les nomme, si `loop critical` les requiert, ou si le risque technique justifie clairement un
specialiste.

## Methode de travail

Le workflow vise a faire mieux qu'un mode minimaliste permanent: il garde Codex rapide par defaut,
mais conserve les gates fortes quand le risque l'exige.

### Pourquoi mieux que Ponytail pour ce setup

| Point | Ponytail | Ce setup |
|---|---|---|
| Activation | Mode/plugin persistant avec hooks possibles | Reflexe Lean dans `AGENTS.md`, sans etat runtime |
| Intensite | Niveaux `lite/full/ultra` | Seulement `default`, `loop fast`, `loop critical` |
| Cout tokens | Instructions injectees selon l'adapter | Ladder compact par defaut, skills charges seulement si utiles |
| Subagents | Hors scope principal | Reserves aux demandes explicites ou a `loop critical` |
| Securite/infra | Garde-fous generaux | Pipeline critique dedie avec review, security, performance, gatekeeper |
| Dette de raccourcis | `ponytail:` comments | `lean:` avec plafond + trigger, auditable par `$lean-debt` |
| Reproductibilite | Plugin externe | Repo installable, valide par `validate.sh`, `doctor.sh`, CI |

L'idee gardee: ecrire moins, reutiliser plus, refuser le bloat. L'idee ajoutee: ne jamais laisser
le minimalisme court-circuiter les modes de risque, les validations ou la preuve.

### 1. Par defaut: Codex normal + ladder Lean

Sans mot-cle de boucle, Codex travaille normalement:

1. lire les fichiers utiles;
2. comprendre le flux touche;
3. appliquer le ladder Lean;
4. modifier le minimum correct;
5. verifier avec les commandes adaptees au diff;
6. repondre avec les changements, les checks et les risques residuels utiles.

Le ladder Lean:

```text
1. Est-ce necessaire maintenant ?
2. Est-ce deja dans le repo ?
3. Est-ce deja dans la stdlib, le langage, le framework ou le shell ?
4. Est-ce deja dans la plateforme native ?
5. Est-ce couvert par une dependance deja installee ?
6. Est-ce faisable directement et court ?
7. Sinon: ecrire le minimum maintenable qui marche.
```

Le ladder ne remplace pas la comprehension. Un petit diff au mauvais endroit reste un bug.

### 2. Pour aller vite: `loop fast`

Utiliser explicitement `loop fast` pour les taches faibles risques:

```text
loop fast corrige cette phrase dans le README
loop fast simplifie ce petit script shell
```

Regles:

- pas de pipeline complet;
- pas d'agents multiples sauf demande explicite;
- 1 passe, 0 a 1 correction;
- verification ciblee.

### 3. Pour les changements critiques: `loop critical`

Utiliser `loop critical` pour les changements qui peuvent casser production, infra, donnees,
securite ou cout:

```text
loop critical modifie ce role Ansible et prouve le dry-run
loop critical corrige cette config Kubernetes avec probes et RBAC
```

Regles:

- pipeline auto-verifiant complet;
- orchestrator, implementation, review, performance, security, gatekeeper;
- evidence ledger;
- jusqu'a 3 cycles de correction justifies;
- gate finale obligatoire.

### 4. Pour couper le superflu: skills Lean

Les skills Lean sont explicites. Ils ne s'activent pas par simple mot-cle technique.

```text
$lean-review
```

Review le diff courant uniquement pour l'over-engineering: code mort, abstraction speculative,
dependance inutile, stdlib/native ignoree, simplification evidente. Ne remplace pas une revue
correctness/security.

```text
$lean-audit
```

Audit repo entier pour trouver ce qui peut etre supprime ou remplace. Utile apres une phase de build,
avant refactor, ou quand un projet commence a accumuler des wrappers et configs.

```text
$lean-debt
```

Liste les commentaires `lean:` ou `ponytail:` qui marquent des raccourcis volontaires.

Convention:

```text
lean: <simplification>; ceiling: <known limit>; revisit when <trigger>
```

Un `lean:` sans plafond ni trigger est considere fragile.

### 5. Quand accepter plus de code

Ne jamais simplifier au detriment de:

- securite, auth, secrets, permissions;
- validation aux trust boundaries;
- idempotence, rollback, donnees et migrations;
- accessibilite;
- observabilite utile;
- tests ou checks qui prouvent une logique non triviale;
- demande explicite utilisateur.

Une dependance ou abstraction est acceptable si elle remplace beaucoup de code fragile, couvre un
edge case obligatoire, est deja standard dans le repo, ou devient necessaire apres preuve.

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
- [Workflow Lean Codex](docs/lean-workflow.md)
- [Alternatives natives et stdlib](docs/native-platform-alternatives.md)
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
