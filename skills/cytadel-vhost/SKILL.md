---
name: cytadel-vhost
description: Add, modify, audit, or validate Cytadel Ansible website vhosts in client repositories. Use when Codex works on `website_vhosts` entries, `cytadel.website`, `cytadel.website-private`, `cytadel.website-deployinfofile`, nginx/PHP-FPM/Node/proxy/redirect vhosts, StatusCake checks, Let's Encrypt settings, vault-backed users/databases, or client repos such as carrefour, lavieclaire, senso, ansible-mutu-cytadel, and similar Cytadel Ansible layouts.
---

# Cytadel Vhost

## Objectif

Modifier les vhosts Cytadel de maniere idempotente, minimale et verifiable, sans inventer de secrets ni casser les conventions existantes du repo client.

## Workflow

1. Identifier le repo et le serveur cible
   - Lire `hosts`, `playbook.yml`, `group_vars/`, `host_vars/`.
   - Reperer le ou les fichiers qui portent `website_vhosts`, souvent `host_vars/<host>/vars.yml`.
   - Verifier que le play `website` inclut `cytadel.website`, souvent aussi `cytadel.website-private` et `cytadel.website-deployinfofile`.
   - Ne pas modifier un repo client different du cwd sans raison explicite.

2. Choisir le type de vhost
   - `wordpress` / PHP : user systeme, PHP-FPM, DB, `deploy_dir: /current/server`, souvent `capistrano: true`.
   - `node` : user systeme, pas de PHP/DB, `upstream_name`, `behind_reverse_proxy`, ports locaux, souvent PM2 hors vhost.
   - `proxy` : reverse proxy pur vers `proxy_backend`, generalement `www-data`, pas de DB/PHP.
   - `redirect` : pas de user/infofile/DB/PHP, `redirect_scheme`, `redirect_domain`, `redirect_code`, SEO include.
   - Lire `references/vhost-patterns.md` pour les blocs minimaux.

3. Respecter les conventions du repo
   - Reprendre le style YAML local : alignement, guillemets, ordre des champs, commentaires.
   - Nommer `codename` en `{client|projet}_{cms}` avec suffixe clair pour preprod/proto si le repo l'utilise.
   - Garder un seul `server_name` principal quand possible ; mettre les alias dans `server_name_redirect`.
   - Utiliser `vault_<codename>.*` pour user, groupe, uid/gid, password, DB, HTTP auth. Ne jamais ecrire de secret en clair.
   - Placer les cles SSH sous le role custom du projet, par exemple `../<client>.custom/files/ssh_keys/...pub`, si le pattern existe.

4. Gerer TLS et exposition
   - Pour domaine public pointant sur le serveur : `letsencrypt_enabled: true`.
   - Pour wildcard interne/preprod `jetpulp.work` : preferer les certs wildcard existants si c'est le pattern local.
   - Pour `server_name_redirect`, decider explicitement si `letsencrypt_redirect_enabled` est necessaire.
   - Etre prudent avec `hsts_enabled`, `hsts_include_subdomains` et `hsts_preload`; ne pas les activer par defaut sur un domaine client sans preuve.
   - Pour preprod/proto, verifier `htuser`/`htpasswd` et `http_auth_allowed_ips` si le repo les utilise.

5. Verifier les dependances de l'entree
   - Si `skip_database` absent ou false, prevoir `db_name`, `db_host`, `db_username`, `db_password`.
   - Si `skip_php_fpm` absent ou false, verifier `php_version` et `php_fpm_mode`; preferer `socket` sans `php_fpm_listen` explicite dans les repos recents.
   - Si `ignore_vhost_infofile` false, verifier que les champs necessaires au deployinfofile sont coherents.
   - Pour StatusCake, utiliser `statuscake_uptime_url`, `statuscake_uptime_find_string`, tags explicites.
   - Pour redirect, verifier `seo_include_file` et le fichier associe dans le role custom si le repo l'exige.

6. Valider localement avant de proposer une execution reelle
   - `ansible-inventory -i hosts --list` si un inventaire `hosts` existe.
   - `ansible-playbook -i hosts playbook.yml --syntax-check`.
   - Si la cible est connue : `ansible-playbook -i hosts playbook.yml --tags=website --limit <host> --check --diff`.
   - Ne pas lancer de playbook non-check contre prod sans demande explicite.
   - Si le repo a `ansible-lint`, le lancer apres modification.

## Sortie attendue

Fournir :
- fichier(s) modifies ;
- type de vhost et host cible ;
- champs sensibles attendus dans vault, sans valeurs ;
- commandes de validation lancees ;
- risques restants : DNS, certbot, secrets manquants, StatusCake, HSTS, inventaire non teste.

## References

- `references/vhost-patterns.md` : blocs YAML minimaux et checklist par type de vhost.
