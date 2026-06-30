# Efficacite contexte et tokens

Cette policy reduit le cout, la latence et le bruit sans baisser le niveau de qualite attendu. Elle
complete le mode par defaut Codex avec deux boucles explicites: `loop fast` et `loop critical`.

## Principe

Toujours choisir le plus petit workflow qui donne assez de confiance pour le risque reel du changement.

Ne pas escalader par mot-cle seul. Escalader quand la tache touche une surface sensible, un
comportement difficile a verifier, un impact production, une migration, la securite, la performance,
l'infra ou une architecture multi-fichiers.

Sans invocation de boucle, rester en comportement Codex normal: lire ce qui est utile, appliquer le
ladder Lean, modifier, verifier de facon adaptee, puis repondre.

## Matrice

Defaut Codex:
- Scope: toute tache sans boucle explicitement nommee.
- Contexte: fichiers utiles au changement.
- Agents: aucun subagent par defaut, sauf demande explicite ou besoin specialiste justifie.
- Lean: YAGNI, reuse local, stdlib, natif plateforme, dependance existante, minimum correct.
- Validation: commandes adaptees au diff et au risque.

`loop fast`:
- Scope: petites edits, formatage, docs simples, commentaires, renommage, boilerplate, petit bug fix.
- Contexte: bloc pertinent.
- Agents: aucun agent multiple sauf demande explicite.
- Validation: diff et commande ciblee.

`loop critical`:
- Scope: securite, auth, secrets, infra, DB migration, performance, CI/CD, architecture large.
- Contexte: contexte borne au risque.
- Agents: pipeline auto-verifiant.
- Validation: gate complet et preuves.

## Regles de contexte

- Lire les sources pertinentes avant modification.
- Avant de lire un nouveau fichier, demander: "cette information est-elle requise pour finir correctement ?"
- Preferer les fichiers, fonctions et blocs pertinents au chargement large du repo.
- Ne pas relire un fichier deja compris sauf s'il a change, si une information manque ou si la confiance est basse.
- Ne pas rechercher plusieurs fois la meme chose. Si le fichier pertinent est identifie, le lire directement.
- Eviter lockfiles, code genere, assets minifies, vendor, `node_modules` et artefacts de build sauf necessite explicite.
- Preferer logs, stack traces, code, markdown et sorties terminal aux screenshots quand le texte suffit.

## Regles de travail

- Appliquer le ladder Lean avant d'ajouter code, dependance ou abstraction.
- Grouper implementation, verification, revue legere et correction quand c'est coherent.
- Eviter les arrets intermediaires inutiles sur les taches simples.
- Finir, verifier, puis expliquer.
- Compresser mentalement le contexte obsolete: garder l'objectif courant, les contraintes, les
  decisions d'architecture et le travail restant.
- Arreter quand les exigences sont satisfaites, les validations adaptees passent et la confiance est suffisante.

## Boucles explicites

Les boucles ne s'activent que si l'utilisateur les nomme, ou si une fast loop demandee est
manifestement insuffisante pour une tache critique.

Boucle canonique de `loop critical`:

```text
inspecter -> implementer -> verifier -> reviewer -> corriger -> gate
```

| Boucle | Budget | Gate | Ledger |
|---|---|---|---|
| `loop fast` | 1 passe, 0 a 1 correction | verification ciblee | non requis |
| `loop critical` | jusqu'a 3 cycles de correction | pipeline auto-verifiant complet | obligatoire |

## Invocation dans le chat

L'utilisateur peut forcer une boucle en disant:

- `loop fast`, `Fast loop` ou `boucle fast`;
- `loop critical`, `Critical loop` ou `boucle critical`.

Regles:

- Si la boucle demandee est suffisante pour le risque, l'utiliser explicitement.
- Si `loop fast` est trop faible pour le risque, utiliser `loop critical` et expliquer brievement la raison.
- Si `loop critical` est invoquee, appliquer le pipeline auto-verifiant complet.
- Si aucune boucle n'est nommee, rester en comportement Codex normal.

## Retry policy

Chaque retry doit etre justifie par une cause concrete:

- test casse;
- linter ou format;
- comportement incorrect;
- manque de preuve;
- risque securite ou performance;
- ambiguite utilisateur.

Interdit:

```text
test failed -> patch au hasard -> retry
```

Requis:

```text
test failed -> cause racine -> patch cible -> retry
```

Ne jamais relancer une validation echouee sans avoir change la cause pertinente.

Arreter la boucle quand la reussite est prouvee, quand un vrai blocage existe, ou quand le budget de
retry est epuise. Ne jamais boucler indefiniment.

## Evidence ledger

`loop fast` n'a pas besoin d'un ledger si le diff et le check cible suffisent.

`loop critical` garde un ledger court:

```text
changed:
checks:
failures:
fixes:
residual_risks:
```

## Reasoning

Utiliser le plus petit effort de raisonnement suffisant:

- Defaut Codex: effort normal, sans escalation automatique.
- `loop fast`: `medium`;
- `loop critical`: `xhigh` quand le risque le justifie.

Ne jamais utiliser `xhigh` pour formatage, docs simples, copy edits, petits fixes shell ou changements
triviaux single-file.
