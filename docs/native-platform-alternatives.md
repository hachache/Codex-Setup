# Alternatives natives et stdlib

Verifier ces alternatives avant d'ajouter une dependance, une abstraction ou un wrapper. La liste est
un aide-memoire, pas une interdiction: une dependance est acceptable quand l'alternative native ne
couvre pas les contraintes reelles du projet.

## JavaScript et navigateur

| Besoin | Alternative native |
|---|---|
| Parser une query string | `new URLSearchParams(location.search)` |
| Cloner des donnees serialisables | `structuredClone(value)` |
| UUID v4 | `crypto.randomUUID()` |
| Format nombre/devise | `Intl.NumberFormat` |
| Format date | `Intl.DateTimeFormat` |
| Temps relatif | `Intl.RelativeTimeFormat` |
| Pluriels | `Intl.PluralRules` |
| Copier dans le presse-papiers | `navigator.clipboard.writeText()` |
| Annuler un fetch | `AbortController` ou `AbortSignal.timeout()` |
| Observer intersection | `IntersectionObserver` |
| Observer resize | `ResizeObserver` |
| Observer DOM | `MutationObserver` |
| Event bus simple | `EventTarget` + `CustomEvent` |
| Stockage simple | `localStorage` avec serialization explicite |

## HTML et CSS

| Besoin | Alternative native |
|---|---|
| Date picker simple | `<input type="date">` |
| Time picker simple | `<input type="time">` |
| Color picker simple | `<input type="color">` |
| Slider | `<input type="range">` |
| Modal simple | `<dialog>` + `showModal()` |
| Accordion/FAQ | `<details><summary>` |
| Progression | `<progress>` |
| Gauge | `<meter>` |
| Suggestions input | `<datalist>` |
| Header sticky | `position: sticky` |
| Layout responsive | CSS grid/flex + `minmax()` |
| Taille fluide | `clamp()` |
| Responsive composant | Container queries |
| Theme | CSS custom properties |
| Motion safe | `prefers-reduced-motion` |
| Dark mode | `prefers-color-scheme` |
| Carousel simple | CSS scroll snap |

## Node.js

| Besoin | Alternative native |
|---|---|
| `mkdirp` | `fs.mkdirSync(path, { recursive: true })` |
| `rimraf` | `fs.rmSync(path, { recursive: true, force: true })` |
| Lire JSON | `JSON.parse(fs.readFileSync(path, "utf8"))` |
| Ecrire JSON | `fs.writeFileSync(path, JSON.stringify(data, null, 2))` |
| UUID | `crypto.randomUUID()` |
| Path portable | `path.normalize`, `path.posix`, `path.win32` |
| Unicite tableau | `[...new Set(values)]` |
| Flatten tableau | `array.flat(depth)` |
| Existence fichier | `fs.existsSync` ou `fs.stat` |

## Python

| Besoin | Alternative stdlib |
|---|---|
| Data object simple | `dataclasses.dataclass` |
| CLI simple | `argparse` |
| Paths | `pathlib.Path` |
| Timezone | `zoneinfo.ZoneInfo` |
| Date ISO | `datetime.fromisoformat()` |
| Cache memoization | `functools.lru_cache` |
| Iteration avancee | `itertools` |
| Enum | `enum.Enum` |
| JSON | `json` |
| CSV | `csv` |
| Pretty print debug | `pprint` |
| Temporary files | `tempfile` |
| Archives | `zipfile`, `tarfile` |
| HTTP simple ponctuel | `urllib.request`; garder `requests` pour clients reels |

## Shell et macOS/Linux

| Besoin | Alternative standard |
|---|---|
| Chercher fichiers | `find`, ou `rg --files` si disponible |
| Chercher texte | `rg`, sinon `grep` |
| Copier en preservant metadata | `cp -p`, `cp -pR` |
| Installer fichier mode fixe | `install -m 0644 source dest` |
| Creer dossier idempotent | `mkdir -p` |
| Fichier temporaire | `mktemp`, `mktemp -d` |
| Remplacer texte simple | `sed`, `perl -0pi` pour multi-ligne mecanique |
| Verifier script shell | `sh -n`, ShellCheck si disponible |

## Base de donnees

| Besoin | Alternative DB |
|---|---|
| Unicite | `UNIQUE` |
| Plage de valeurs | `CHECK` |
| Integrite relationnelle | `FOREIGN KEY` |
| Upsert | `ON CONFLICT` / equivalent moteur |
| Pagination | `LIMIT` / `OFFSET` ou keyset pagination |
| Dedup | `SELECT DISTINCT` |
| Totaux/rangs | Window functions |
| JSON query | `jsonb` Postgres, JSON functions SQLite/MySQL |
| Search simple | Full-text natif du moteur si suffisant |
| Timestamp creation | `DEFAULT now()` / equivalent |

## Infra et DevOps

| Besoin | Alternative native |
|---|---|
| Kubernetes config declarative | Manifest, Kustomize ou Helm existant avant script custom |
| Verification readiness | Probes Kubernetes avant sleep/retry maison |
| Permissions | RBAC declaratif avant logique ad hoc |
| Secret runtime | Secret manager/Kubernetes Secret/Vault, jamais hardcode |
| Ansible idempotence | Module FQCN existant avant `shell`/`command` |
| Ansible restart | Handler avant restart inline |
| Terraform composition | Module existant et variables explicites avant wrapper custom |
| Docker build | Multi-stage/minimal base avant script post-build |
| CI validation | Job existant ou reusable workflow avant nouveau script |

## Quand accepter une dependance

Une dependance est justifiee si au moins un point est vrai:

- l'alternative native ne couvre pas un edge case necessaire;
- la compatibilite navigateur/runtime du projet l'impose;
- le projet utilise deja la dependance et elle evite une implementation fragile;
- la dependance remplace beaucoup de code metier risque;
- elle apporte maintenance, securite ou performance mesurable.

Dans ce cas, documenter pourquoi l'alternative native ne suffit pas dans la PR, le commit ou un
commentaire proche de la decision.
