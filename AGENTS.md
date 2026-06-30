# Standards Codex

## Langue

- Repondre uniquement en francais, sauf code, noms d'API ou messages techniques imposes.
- Ecrire les messages de commit en anglais avec Conventional Commits.
- Respecter la langue du projet pour la documentation versionnee.

## Comportement

- Etre concis, direct et technique.
- Ne pas ajouter d'introduction, de conclusion ou de remplissage.
- Lire les fichiers existants avant modification.
- Respecter les patterns du repo.
- Prioriser la correction, l'idempotence et la securite.
- Ne jamais hardcoder de secret.
- Ne jamais revert des changements non faits par toi sans demande explicite.

## Code

- Produire du code propre, maintenable et pret production.
- Gerer les cas limites utiles.
- Eviter le code mort, les placeholders et les commentaires inutiles.
- Preferer les noms explicites, les fonctions courtes et les retours anticipes.
- Donner des erreurs contextualisees, jamais silencieuses.

## Infra / DevOps

- Ansible: taches idempotentes, modules FQCN, handlers pour les redemarrages, secrets via Vault ou secret manager.
- Terraform: ressources explicites, variables claires, pas de comportement implicite.
- Kubernetes: manifests declaratifs, ressources, probes, RBAC et secrets explicites.
- Docker: images minimales, builds reproductibles, pas de secret dans l'image.
- Linux/macOS: commandes standards, portables et verifiables.

## Git

- Utiliser Conventional Commits.
- Un commit = un changement logique.
- Format: `type(scope): subject`.
- Sujet court, explicite, en anglais, imperatif si possible.

## Recherche et modification

- Utiliser `rg` ou `rg --files` en priorite.
- Utiliser `apply_patch` pour les edits manuels.
- Verifier apres modification avec les commandes adaptees.

## Boucle de developpement automatique

Pour toute tache de code, debug, documentation, infra ou maintenance:

1. Identifier l'objectif, le perimetre, les contraintes et les criteres de succes.
2. Lire les sources pertinentes avant modification.
3. Planifier le plus petit changement correct.
4. Implementer.
5. Executer les tests, linters, builds, plans, dry-runs ou verifications exactes.
6. Analyser les echecs par cause racine.
7. Corriger et repeter jusqu'a preuve concrete de reussite.

Arreter la boucle quand la reussite est prouvee, quand un vrai blocage existe, ou apres 3 cycles de correction infructueux. Ne jamais boucler indefiniment.

## Pipeline auto-verifiant

Pour toute modification non triviale de code, scripts, documentation operatoire, agents, infra ou maintenance, appliquer automatiquement ce pipeline:

1. `@engineering-pipeline-orchestrator`: definir le perimetre, les criteres de succes, les agents, les validations et les N/A acceptables.
2. Implementation: utiliser `@implementation-engineer` comme owner du `gate_report`; il peut s'appuyer sur l'agent le plus specifique au stack.
3. Critique: utiliser `@code-reviewer` ou `@reviewer`.
4. Performance: utiliser `@performance-engineer` si un impact runtime, build, base de donnees, UI, reseau, scalabilite ou cout est plausible; sinon noter `N/A` avec raison concrete.
5. Securite: utiliser `@security-auditor` pour tout changement code, infra, auth, donnees, dependances, reseau, permissions, secrets ou CI/CD; sinon noter `N/A` avec raison concrete.
6. Gate finale: utiliser `@quality-gatekeeper`.

Chaque agent du pipeline doit produire un `gate_report`: `agent`, `status` (`pass`, `fail`, `blocked`, `not_applicable`), `scope`, `evidence`, `commands_run`, `blocking_findings`, `residual_risks`, `rerun_required`.

Ne pas envoyer de reponse finale affirmant que le travail est termine tant que `@quality-gatekeeper` n'a pas retourne `PASS` ou qu'un blocage reel n'est pas explique.

La gate finale bloque si une validation attendue manque, si une commande echoue sans cause racine, si une critique critical/high reste ouverte, si les impacts performance/securite ne sont pas prouves ou justifies, si la preuve ne couvre pas les fichiers touches, ou si le diff change apres une revue sans relancer les etapes impactees.

## Routage subagents

- Quand une demande correspond clairement a un agent installe dans `~/.codex/agents`, utiliser cet agent automatiquement.
- Si plusieurs agents correspondent, choisir le plus specifique et le mentionner brievement.
- Si aucun agent ne correspond clairement, traiter directement.
- Si l'utilisateur nomme un agent avec `@agent-name`, utiliser cet agent.
- Ne pas demander quel agent utiliser sauf ambiguite risquee.

## Routage par defaut

- Shell, Bash, Zsh, POSIX: `@shell-specialist`
- Python, FastAPI, pytest, packaging, typing: `@python-pro` ou `@python-specialist`
- React, composants, hooks, accessibilite frontend: `@react-specialist`
- Next.js: `@nextjs-developer`
- TypeScript: `@typescript-pro`
- JavaScript: `@javascript-pro`
- Node.js: `@node-specialist`
- Vite: `@vite-specialist`
- Tailwind CSS: `@tailwind-specialist`
- Docker ou Compose: `@docker-expert` ou `@docker-specialist`
- Terraform: `@terraform-engineer` ou `@terraform-specialist`
- Terragrunt: `@terragrunt-expert`
- AWS: `@aws-specialist`
- Kubernetes: `@kubernetes-specialist`
- Ansible, playbooks, roles, inventories, Vault, Molecule: `@ansible-specialist`
- Securite, SAST, secrets, OWASP: `@security-auditor`
- Code review: `@code-reviewer` ou `@reviewer`
- Pipeline auto-verifiant: `@engineering-pipeline-orchestrator`, `@implementation-engineer`, `@quality-gatekeeper`
- Debug runtime, logs, erreurs: `@debugger` ou `@error-detective`
- UI bugs: `@ui-fixer`
- UI/UX design: `@ui-designer` ou `@design-specialist`
- Data, SQL, PostgreSQL: `@data-engineer`, `@data-analyst`, `@sql-pro` ou `@postgres-pro`
- LLM, prompts, systemes agents: `@prompt-engineer`, `@llm-architect` ou `@ai-engineer`
- Documentation: `@technical-writer`, `@documentation-engineer` ou `@readme-generator`
- Planning projet/produit: `@project-manager` ou `@product-manager`

## Regle finale

Use subagents.
