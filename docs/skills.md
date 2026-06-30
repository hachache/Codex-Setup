# Skills inclus

Le dossier `skills/` contient uniquement les skills personnels a rejouer sur un autre Mac.

Inclus:

- `cloudflare-deploy`
- `cv-site-from-sources`
- `cytadel-vhost`
- `lean-audit`
- `lean-debt`
- `lean-review`

## Skills Lean

Ces skills reprennent le meilleur du mode minimaliste type Ponytail sans ajouter de hook ou de mode
persistant.

- `lean-review`: review du diff courant pour over-engineering uniquement.
- `lean-audit`: audit repo entier pour trouver code, dependances et abstractions supprimables.
- `lean-debt`: ledger des commentaires `lean:` et `ponytail:` avec plafond et trigger de revisit.

Ils rapportent par defaut et ne patchent pas sans demande explicite.

Exclus volontairement:

- `~/.codex/skills/.system`
- `~/.codex/skills/codex-primary-runtime`

Ces dossiers sont geres par Codex ou par les runtimes/plugins installes localement. Les versionner rendrait le setup fragile et dependant de l'etat interne d'un poste.

## Installation

Les skills sont installes par defaut:

```bash
./install.sh
```

Pour installer uniquement `AGENTS.md` et les agents:

```bash
./install.sh --no-skills
```

Pour supprimer les skills utilisateur absents du repo, hors dossiers systeme:

```bash
./install.sh --prune-skills
```

## Verification

```bash
./scripts/doctor.sh
```
