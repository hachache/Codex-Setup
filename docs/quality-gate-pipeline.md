# Pipeline auto-verifiant

Ce workflow transforme les agents Codex en pipeline de revue automatique pour les taches a fort
risque. Il est reserve a `loop critical`.

## Objectif

Le resultat attendu n'est pas seulement une reponse utile. Le resultat attendu est une reponse autorisee par une gate finale apres preuves:

1. un agent implemente;
2. un agent critique;
3. un agent verifie la performance;
4. un agent verifie la securite;
5. un agent bloque la reponse finale tant que les criteres ne sont pas satisfaits.

## Agents

| Etape | Agent |
|---|---|
| Orchestration | `@engineering-pipeline-orchestrator` |
| Implementation | `@implementation-engineer`, avec specialiste stack en support si utile |
| Critique | `@code-reviewer` ou `@reviewer` |
| Performance | `@performance-engineer` |
| Securite | `@security-auditor` |
| Gate finale | `@quality-gatekeeper` |

## Declenchement

Par defaut, Codex ne lance pas ce pipeline. Il s'active seulement quand l'utilisateur demande
`loop critical`, `critical loop` ou `boucle critical`, ou quand une `loop fast` demandee serait trop
faible pour une tache critique.

### Mode par defaut

Utiliser le comportement Codex normal: inspecter ce qui est utile, implementer, verifier avec les
commandes adaptees, puis repondre. Pas de `gate_report` impose.

### Loop fast

Utiliser pour les petites taches a faible risque: formatage, README simple, copy edit, correction de
texte, petit script, fix shell localise ou changement trivial dans un seul fichier.

- reasoning `medium`;
- pas de pipeline complet;
- pas d'agents multiples sauf demande explicite;
- validation minimale ciblee;
- jamais `xhigh` pour formatage, docs simples, copy edits, petits fixes shell ou changements triviaux single-file.

### Loop critical

Utiliser ce pipeline uniquement pour les changements a fort risque qui modifient ou analysent:

- code applicatif;
- scripts et tooling;
- agents, prompts, instructions ou workflows;
- infrastructure, CI/CD, Docker, Kubernetes, Terraform, Ansible;
- documentation operatoire ou procedures mainteneur critiques;
- dependances, configuration, permissions, auth, secrets, donnees ou exposition reseau.

Le pipeline complet ne doit pas tourner en mode par defaut ou en `loop fast`.

## Contrat d'execution

1. `@engineering-pipeline-orchestrator` definit le perimetre, les criteres de succes, les agents requis, les validations et les N/A autorises.
2. `@implementation-engineer` lit les fichiers existants, applique ou coordonne le plus petit changement correct, puis produit le bundle de preuves et le `gate_report` writer.
3. `@code-reviewer` ou `@reviewer` critique le diff: exactitude, regressions, maintenabilite, tests manquants.
4. `@performance-engineer` mesure, borne ou declare N/A pour le risque performance.
5. `@security-auditor` inspecte surface d'attaque, secrets, permissions, dependencies, exposition, entrees utilisateur et trust boundaries.
6. `@quality-gatekeeper` retourne `PASS` ou `BLOCKED`.

Un correctif apres critique, performance ou securite relance les etapes impactees. La boucle s'arrete quand la gate passe, quand un vrai blocage est prouve, ou apres 3 cycles de correction infructueux.

Toute modification du diff apres une revue invalide les etapes downstream. Relancer au minimum critique, performance, securite et gate finale sur le nouveau diff.

## Bundle de preuves

Chaque handoff doit contenir:

- objectif et perimetre;
- fichiers modifies;
- comportement attendu;
- commandes executees et statut;
- resultats de tests, linters, builds, plans, dry-runs, scans ou screenshots;
- conclusions de revue;
- risques residuels;
- rollback ou recovery quand la production, les donnees, l'infra ou le deploiement sont touches;
- validations non lancees avec raison.

## gate_report

Chaque agent du pipeline doit retourner un `gate_report`:

```text
gate_report:
  agent: <agent-name>
  status: pass | fail | blocked | not_applicable
  scope: <files, chemins, feature ou diff analyse>
  evidence:
    - <preuve verifiee>
  commands_run:
    - <commande et resultat, ou none avec raison>
  blocking_findings:
    - <finding bloquant ou none>
  residual_risks:
    - <risque accepte ou none>
  rerun_required: true | false
```

Statuts:

- `pass`: criteres satisfaits pour le scope.
- `fail`: finding bloquant ou regression prouvee/plausible.
- `blocked`: preuve impossible ou environnement insuffisant.
- `not_applicable`: etape non applicable, avec raison basee sur les fichiers touches.

## Criteres de blocage

`@quality-gatekeeper` doit retourner `BLOCKED` si au moins un point est vrai:

- critique correctness/security/performance encore ouverte en severite critical/high;
- commande de validation echouee ou non expliquee;
- test, linter, build, plan, scan ou dry-run attendu absent;
- changement de secrets, auth, permissions, dependances, data, reseau, CI/CD ou infra non revu;
- impact performance plausible non mesure, non borne et non justifie en N/A;
- impact securite plausible non revu et non justifie en N/A;
- preuve trop vague pour autoriser une reponse finale.
- un `gate_report` est absent, en `fail`, en `blocked`, ou en `not_applicable` non justifie.

Seuil performance par defaut: `@performance-engineer` bloque une regression mesuree ou plausible au-dela de `+10%` sur latence, memoire, bundle, temps de build, cout tokens ou appels externes, sauf politique projet differente ou waiver humain explicite.

## Format gate

`@quality-gatekeeper` retourne:

```text
Decision: PASS | BLOCKED
Evidence checked:
- ...
Gate reports:
- ...
Blockers:
- ...
Accepted residual risks:
- ...
Required next action: Final answer allowed | ...
```

## Validation de ce repo

Avant commit:

```bash
./scripts/validate.sh
git diff --check
./install.sh --dry-run
./scripts/doctor.sh
```

Pour verifier une installation isolee:

```bash
tmp_home=$(mktemp -d)
CODEX_HOME="$tmp_home/.codex" ./install.sh --install-config
CODEX_HOME="$tmp_home/.codex" ./scripts/doctor.sh
```
