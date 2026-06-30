# Efficacite contexte et tokens

Cette policy reduit le cout, la latence et le bruit sans baisser le niveau de qualite attendu. Elle complete les modes Fast, Standard et Critical.

## Principe

Toujours choisir le plus petit workflow qui donne assez de confiance pour le risque reel du changement.

Ne pas escalader par mot-cle seul. Escalader quand la tache touche une surface sensible, un comportement difficile a verifier, un impact production, une migration, la securite, la performance, l'infra ou une architecture multi-fichiers.

## Matrice

| Mode | Scope typique | Contexte | Agents | Validation |
|---|---|---|---|---|
| Fast | petites edits, formatage, docs simples, commentaires, renommage, boilerplate, petit bug fix, single-file | fichier ou bloc pertinent seulement | aucun agent multiple sauf demande explicite | diff + commande ciblee si utile |
| Standard | feature normale, refactor modere, multi-file coherent, tests, API work, tooling | fichiers lies au flux modifie | agent principal + specialiste unique si utile | tests, lint, build, dry-run ou validation repo adaptee |
| Critical | securite, auth, secrets, infra, Docker, Kubernetes, Terraform, Ansible, DB migration, perf, CI/CD, architecture large | contexte complet mais borne au risque | pipeline auto-verifiant | gate complet avec preuves et N/A explicites |

## Regles de contexte

- Lire les sources pertinentes avant modification.
- Avant de lire un nouveau fichier, demander: "cette information est-elle requise pour finir correctement ?"
- Preferer les fichiers, fonctions et blocs pertinents au chargement large du repo.
- Ne pas relire un fichier deja compris sauf s'il a change, si une information manque ou si la confiance est basse.
- Ne pas rechercher plusieurs fois la meme chose. Si le fichier pertinent est identifie, le lire directement.
- Eviter lockfiles, code genere, assets minifies, vendor, `node_modules` et artefacts de build sauf necessite explicite.
- Preferer logs, stack traces, code, markdown et sorties terminal aux screenshots quand le texte suffit.

## Regles de travail

- Grouper implementation, verification, revue legere et correction quand c'est coherent.
- Eviter les arrets intermediaires inutiles sur les taches simples.
- Finir, verifier, puis expliquer.
- Compresser mentalement le contexte obsolete: garder l'objectif courant, les contraintes, les decisions d'architecture et le travail restant.
- Arreter quand les exigences sont satisfaites, les validations adaptees passent et la confiance est suffisante.

## Boucles

Boucle par defaut:

1. implementation;
2. review;
3. correction;
4. final review.

Maximum par defaut: 2 cycles de correction.

Le Critical mode peut aller jusqu'au plafond de 3 cycles de correction quand un bloqueur concret le justifie. Ne jamais boucler indefiniment.

## Reasoning

Utiliser le plus petit effort de raisonnement suffisant:

- Fast: `medium`;
- Standard: `medium` ou effort de l'agent specialiste choisi;
- Critical: `xhigh` quand le risque le justifie.

Ne jamais utiliser `xhigh` pour formatage, docs simples, copy edits, petits fixes shell ou changements triviaux single-file.
