# Codex Rules

Ce repo ne fournit pas de `default.rules` global par defaut.

Raison:
- les rules locales peuvent autoriser des commandes destructrices;
- elles dependent fortement du poste, des repos et du niveau de confiance;
- elles peuvent contenir des chemins personnels.

Si une rule doit etre partagee, ajouter un fichier explicite dans ce dossier et documenter:
- la commande autorisee;
- le risque;
- le contexte d'usage;
- la procedure de rollback.
