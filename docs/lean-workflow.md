# Workflow Lean Codex

Ce workflow reprend le meilleur de Ponytail sans reprendre son cout permanent:
pas de hook persistant, pas de niveaux `lite/full/ultra`, pas de mode global qui
pollue chaque tour. Le comportement par defaut reste Codex normal, mais avec un
reflexe anti-bloat systematique.

Source d'inspiration: <https://github.com/DietrichGebert/ponytail>.

## Objectif

Reduire code, dependances, latence et tokens sans baisser la qualite.

Le but n'est pas d'ecrire le code le plus court possible. Le but est d'ecrire le
plus petit changement correct, comprehensible, verifiable et maintenable.

## Ce qui est repris

- Ladder avant implementation: YAGNI, reuse local, stdlib, natif, dependance deja installee, implementation minimale.
- Review separee pour l'over-engineering.
- Audit repo entier pour trouver ce qui peut etre supprime.
- Commentaires de dette explicites pour les raccourcis volontaires.

## Ce qui est volontairement different

- Pas d'activation persistante par hook.
- Pas de niveaux supplementaires qui concurrencent `loop fast` et `loop critical`.
- Pas de benchmark marketing dans le workflow.
- Pas de simplification qui court-circuite les gates de securite, production ou infra.
- Validation repo obligatoire via `scripts/validate.sh`.

## Ladder de simplicite

Avant d'ajouter du code, lire le flux touche puis s'arreter au premier niveau qui tient:

1. **Ne pas construire**: le besoin est speculatif, non demande ou couvert par une procedure existante.
2. **Reutiliser le repo**: helper, composant, role, script, module, pattern ou config deja present.
3. **Stdlib/langage/framework**: fonction native du langage, shell standard, framework deja en place.
4. **Plateforme native**: navigateur, CSS, base de donnees, Kubernetes, Terraform, Ansible, OS.
5. **Dependance deja installee**: utiliser ce qui existe deja si l'alternative native est insuffisante.
6. **Implementation directe**: une fonction courte, un guard au bon endroit, un appel declaratif.
7. **Minimum maintenable**: seulement si les niveaux precedents ne couvrent pas le besoin.

Le ladder s'applique apres comprehension, pas avant. Un petit diff au mauvais endroit est une
regression, pas une optimisation.

## Interaction avec les modes

### Defaut Codex

Utiliser pour le travail quotidien. Le ladder est actif comme reflexe, mais sans ledger impose et sans
subagent par mot-cle.

Procedure:

1. Lire les fichiers vraiment utiles.
2. Appliquer le ladder.
3. Modifier le minimum.
4. Verifier avec les commandes adaptees au diff.
5. Repondre avec le changement, les checks et les risques residuels utiles.

### `loop fast`

Utiliser pour les petites taches a faible risque. Le ladder evite d'ajouter du code inutile, mais ne
declenche pas de review exhaustive.

Exemples:

- doc simple;
- copy edit;
- fix shell localise;
- petit changement single-file;
- suppression d'un bout de boilerplate evident.

### `loop critical`

Utiliser pour les changements a fort risque. Le ladder reste actif, mais il ne remplace jamais le
pipeline auto-verifiant.

Exemples:

- securite, auth, secrets, permissions;
- CI/CD, production, Docker, Kubernetes, Terraform, Ansible;
- migration DB, perte de donnees, rollback;
- performance, cout, scalabilite;
- gros refactor ou architecture multi-fichiers.

Dans `loop critical`, toute simplification proposee doit survivre aux etapes review, performance,
securite et quality gate.

## Skills Lean

### `$lean-review`

Utiliser sur un diff courant pour chercher uniquement l'over-engineering.

Ne pas l'utiliser comme revue correctness/security. Il complete une review normale, il ne la remplace
pas.

Sortie attendue:

```text
path:L<line>: <tag>: <what to cut>. <replacement>.
net: -<N> lines possible, -<M> deps possible.
```

Tags: `delete`, `reuse`, `stdlib`, `native`, `dependency`, `yagni`, `shrink`.

### `$lean-audit`

Utiliser pour un audit repo entier quand l'objectif est de supprimer du bloat:

- abstractions a une seule implementation;
- wrappers qui deleguent;
- dependances triviales;
- config jamais lue;
- helpers dupliques;
- code mort ou speculatif.

L'audit rapporte seulement. Il ne patch pas sans demande explicite.

### `$lean-debt`

Utiliser pour lister les raccourcis volontaires marques par `lean:` ou `ponytail:`.

Format recommande:

```text
lean: <simplification>; ceiling: <known limit>; revisit when <trigger>
```

Exemple:

```python
# lean: linear scan keeps the script dependency-free; ceiling: <1000 rows; revisit when runtime exceeds 1s
```

Un marker sans plafond ni trigger doit etre signale `no-trigger`.

## Comment choisir

| Situation | Action |
|---|---|
| Petite implementation | Mode defaut + ladder |
| Petite tache explicitement rapide | `loop fast` |
| Diff qui semble trop gros | `$lean-review` |
| Repo ou module devenu lourd | `$lean-audit` |
| Raccourcis assumes a suivre | `$lean-debt` |
| Changement prod/infra/secu | `loop critical` |
| User nomme un agent | Utiliser l'agent nomme |
| Mot-cle technique seul | Ne pas declencher d'agent |

## Regles de qualite

Toujours garder:

- validation aux trust boundaries;
- erreurs contextualisees;
- idempotence et rollback quand applicables;
- RBAC, secrets handling, permissions et audit trail;
- accessibilite frontend;
- probes et checks utiles;
- test cible pour logique non triviale;
- demande explicite utilisateur.

Supprimer ou eviter:

- abstraction sans second usage;
- nouvelle dependance pour un besoin standard;
- wrapper qui ne fait que deleguer;
- config non configurable en pratique;
- feature flag jamais active;
- duplication de helper local;
- prose ou documentation qui decrit un comportement inexistant.

## Examples

### JavaScript

Avant d'ajouter `qs`, verifier si `URLSearchParams` couvre le besoin.

Avant d'ajouter `uuid`, verifier `crypto.randomUUID()`.

Avant d'ajouter un date picker, verifier si `<input type="date">` suffit pour le produit.

### Python

Avant `click` pour une commande unique, verifier `argparse`.

Avant un cache maison, verifier `functools.lru_cache`.

Avant `pytz`, verifier `zoneinfo`.

### Infra

Avant un script shell qui manipule YAML Kubernetes, verifier si un manifest declaratif, Kustomize,
Helm existant ou `kubectl` natif couvre le besoin.

Avant un role Ansible custom, verifier si un module FQCN existant rend la tache idempotente.

Avant une logique applicative d'unicite, verifier la contrainte DB.

## Anti-patterns

- Lancer un subagent parce qu'un mot-cle apparait.
- Ajouter un mode permanent pour une heuristique qui tient en 20 lignes.
- Installer une dependance pour eviter 5 lignes simples.
- Supprimer un check parce qu'il "ajoute du code".
- Marquer `lean:` sans trigger de revisit.
- Refuser une demande explicite utilisateur au nom du minimalisme.
