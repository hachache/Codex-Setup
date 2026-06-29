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
- Debug runtime, logs, erreurs: `@debugger` ou `@error-detective`
- UI bugs: `@ui-fixer`
- UI/UX design: `@ui-designer` ou `@design-specialist`
- Data, SQL, PostgreSQL: `@data-engineer`, `@data-analyst`, `@sql-pro` ou `@postgres-pro`
- LLM, prompts, systemes agents: `@prompt-engineer`, `@llm-architect` ou `@ai-engineer`
- Documentation: `@technical-writer`, `@documentation-engineer` ou `@readme-generator`
- Planning projet/produit: `@project-manager` ou `@product-manager`

## Regle finale

Use subagents.
