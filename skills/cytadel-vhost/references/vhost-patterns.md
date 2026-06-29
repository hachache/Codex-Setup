# Cytadel vhost patterns

## WordPress / PHP

Use for a PHP application with isolated system user, PHP-FPM pool, database, optional StatusCake.

```yaml
  - name: <client> <env> website - wordpress
    codename: '<client>_wp'
    adv_client_id: '<9XXXXXXX>'
    adv_presta_id: '<JPYYYY/MM/NNN>'
    octopus_env: '<PROD|PREPROD>'
    octopus_skip_configure: true

    state: 'present'
    enabled: true
    cms: 'wordpress'
    filename: '<domain>.conf'

    owner: "{{ vault_<codename>.owner }}"
    group: "{{ vault_<codename>.group }}"
    uid: "{{ vault_<codename>.uid }}"
    gid: "{{ vault_<codename>.gid }}"
    password: "{{ vault_<codename>.password }}"
    authorized_keys:
      - '../<client>.custom/files/ssh_keys/<key>.pub'
    homedir: '/srv/www/vhosts/<codename>'
    deploy_dir: '/current/server'
    capistrano: true
    shell: '/bin/bash'

    php_fpm_mode: 'socket'
    php_version: '8.2'

    db_name: '<codename>'
    db_host: 'localhost'
    db_username: "{{ vault_<codename>.db_username }}"
    db_password: "{{ vault_<codename>.db_password }}"

    listen:
      - '80'
    listen_tls:
      - '443 ssl http2'
    tls_only: true
    letsencrypt_enabled: true
    server_name: '<domain>'
    server_name_redirect: '<www-or-alt-domain>'

    http_security_headers:
      - name: 'X-Content-Type-Options'
        value: 'nosniff'
      - name: 'X-XSS-Protection'
        value: '1; mode=block'
    header_x_frame_options: 'SAMEORIGIN'
    hsts_enabled: false

    statuscake_username: "{{ vault_statuscake_username }}"
    statuscake_api_key: "{{ vault_statuscake_api_key }}"
    statuscake_uptime_state: 'present'
    statuscake_uptime_url: 'https://<domain>/'
    statuscake_uptime_find_string: '/html>'
    statuscake_uptime_test_tags: 'ansible_declared, nginx, php8.2, php-fpm, <domain>, wordpress, <client>'
```

Vault keys expected:

```yaml
vault_<codename>:
  owner: <login>
  group: <group>
  uid: <uid>
  gid: <gid>
  password: <hashed-password>
  db_username: <db-user>
  db_password: <db-password>
```

## Node reverse proxy

Use for Node/Vue storefront style apps where nginx proxies to a local upstream.

```yaml
  - name: '<codename> - <PROD|PREPROD>'
    codename: '<codename>'
    state: 'present'
    enabled: true
    cms: 'node'
    filename: '<codename>.conf'

    owner: "{{ vault_<codename>.owner }}"
    group: "{{ vault_<codename>.group }}"
    uid: "{{ vault_<codename>.uid }}"
    gid: "{{ vault_<codename>.gid }}"
    password: "{{ vault_<codename>.password }}"
    authorized_keys:
      - '../<client>.custom/files/ssh_keys/<key>.pub'
    homedir: '/srv/www/vhosts/<codename>'
    deploy_dir: '/current'
    deploy_webdir: '/static'
    capistrano: false
    shell: '/bin/bash'

    skip_php_fpm: true
    skip_database: true

    proxy_pass_scheme: 'http://'
    upstream_name: 'localhost:<port>'
    listen:
      - '8080'
    behind_reverse_proxy: true
    letsencrypt_enabled: true
    letsencrypt_redirect_enabled: true
    server_name: '<domain>'
    server_name_redirect: '<www-or-alt-domain>'

    log_access_static: 'off'
    log_access_media: 'off'
    header_x_frame_options: 'SAMEORIGIN'
    hsts_enabled: false
```

For preprod, usually add HTTP auth:

```yaml
    http_auth_satisfy: 'any'
    http_auth_allowed_ips:
      - '127.0.0.1/32'
    htuser: "{{ vault_<codename>.htuser }}"
    htpasswd: "{{ vault_<codename>.htpasswd }}"
```

## Proxy only

Use when nginx only fronts an external/internal backend.

```yaml
  - name: <client> proxy <env>
    codename: '<client>_proxy'
    state: 'present'
    enabled: true
    cms: 'proxy'
    proxy_backend: 'https://<backend>:<port>'
    filename: '<domain>.conf'

    owner: 'www-data'
    group: 'www-data'
    uid: '33'
    gid: '33'
    homedir: '/srv/www/vhosts/<codename>'
    deploy_dir: ''

    listen:
      - '80'
    listen_tls:
      - '443 ssl http2'
    tls_only: true
    tls_cert: 'WILDCARD.jetpulp.work.LIVE-bundle.crt'
    tls_key: 'WILDCARD.jetpulp.work.LIVE.key'
    letsencrypt_enabled: false
    letsencrypt_redirect_enabled: false
    server_name: '<domain>'
```

## Redirect only

Use for legacy domains or SEO migrations.

```yaml
  - name: ancien <domain> website redirect
    codename: '<short>_legacy_redir'
    state: 'present'
    enabled: true
    cms: 'redirect'
    filename: 'yy-<short>-redir.conf'

    ignore_vhost_user_management: true
    ignore_vhost_infofile: true
    homedir: '/var/www/html'
    deploy_dir: ''
    capistrano: false
    skip_php_fpm: true
    skip_database: true

    listen:
      - '80'
    listen_tls:
      - '443 ssl http2'
    tls_only: true
    letsencrypt_enabled: true
    letsencrypt_redirect_enabled: true
    server_name: '<legacy-domain>'
    server_name_redirect: '<legacy-aliases>'

    redirect_scheme: 'https'
    redirect_domain: '<target-domain-or-path>'
    redirect_code: '301'
    seo_include_file: '../<client>.custom/files/nginx_include_seo/<short>-redirection-nginx.conf'
```

## Validation checklist

- YAML parses and matches local alignment style.
- `codename`, `filename`, `server_name`, `homedir`, DB name, and vault prefix are consistent.
- No secret value is hardcoded.
- Redirect vhosts have `skip_php_fpm: true`, `skip_database: true`, and ignore user/infofile unless explicitly needed.
- PHP vhosts either use socket mode or a manually unique TCP port.
- Public domains using Let's Encrypt already resolve to the target server before real execution.
- HSTS is not enabled blindly.
- StatusCake URL matches the externally reachable canonical URL.
- Run syntax/check commands before real playbook execution.
