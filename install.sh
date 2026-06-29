#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run         Affiche les actions sans modifier le poste.
  --no-backup      N'ecrit pas de sauvegarde avant remplacement.
  --prune-agents   Supprime de ~/.codex/agents les agents TOML absents du repo.
  --install-config Installe config/config.template.toml si config.toml est absent.
  --force-config   Remplace config.toml par le template apres sauvegarde.
  --help           Affiche cette aide.

Variables:
  CODEX_HOME       Repertoire Codex cible. Defaut: $HOME/.codex
EOF
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

run() {
  if [ "$DRY_RUN" = "1" ]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

backup_file() {
  backup_src=$1
  backup_rel=$2

  [ "$BACKUP" = "1" ] || return 0
  [ -e "$backup_src" ] || return 0

  backup_path="$BACKUP_DIR/$backup_rel"
  backup_parent=$(dirname "$backup_path")
  run mkdir -p "$backup_parent"
  run cp -p "$backup_src" "$backup_path"
}

install_file() {
  src=$1
  dest=$2
  rel=$3

  [ -f "$src" ] || die "source introuvable: $src"

  dest_parent=$(dirname "$dest")
  run mkdir -p "$dest_parent"

  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    info "ok: $dest"
    return 0
  fi

  backup_file "$dest" "$rel"
  run install -m 0644 "$src" "$dest"
  info "installed: $dest"
}

DRY_RUN=0
BACKUP=1
PRUNE_AGENTS=0
INSTALL_CONFIG=0
FORCE_CONFIG=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --no-backup)
      BACKUP=0
      ;;
    --prune-agents)
      PRUNE_AGENTS=1
      ;;
    --install-config)
      INSTALL_CONFIG=1
      ;;
    --force-config)
      INSTALL_CONFIG=1
      FORCE_CONFIG=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      die "option inconnue: $1"
      ;;
  esac
  shift
done

[ -n "${HOME:-}" ] || die "HOME est vide"

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
CODEX_HOME=${CODEX_HOME:-"$HOME/.codex"}
TARGET_AGENTS="$CODEX_HOME/agents"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BACKUP_DIR="$CODEX_HOME/backups/Codex-Setup-$TIMESTAMP"

[ -f "$REPO_DIR/AGENTS.md" ] || die "AGENTS.md introuvable dans $REPO_DIR"
[ -d "$REPO_DIR/agents" ] || die "dossier agents introuvable dans $REPO_DIR"

agent_count=$(find "$REPO_DIR/agents" -maxdepth 1 -type f -name '*.toml' | wc -l | tr -d ' ')
[ "$agent_count" -gt 0 ] || die "aucun agent TOML trouve dans $REPO_DIR/agents"

info "Codex home: $CODEX_HOME"
info "Agents repo: $agent_count"

run mkdir -p "$CODEX_HOME" "$TARGET_AGENTS"

install_file "$REPO_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.md" "AGENTS.md"

for src in "$REPO_DIR"/agents/*.toml; do
  [ -f "$src" ] || continue
  base=$(basename "$src")
  install_file "$src" "$TARGET_AGENTS/$base" "agents/$base"
done

if [ "$PRUNE_AGENTS" = "1" ]; then
  for dest in "$TARGET_AGENTS"/*.toml; do
    [ -f "$dest" ] || continue
    base=$(basename "$dest")
    [ -f "$REPO_DIR/agents/$base" ] && continue
    backup_file "$dest" "agents/$base"
    run rm -f "$dest"
    info "removed unmanaged agent: $dest"
  done
fi

if [ "$INSTALL_CONFIG" = "1" ]; then
  config_src="$REPO_DIR/config/config.template.toml"
  config_dest="$CODEX_HOME/config.toml"
  [ -f "$config_src" ] || die "template config introuvable: $config_src"

  if [ -f "$config_dest" ] && [ "$FORCE_CONFIG" != "1" ]; then
    info "skip: $config_dest existe deja (utiliser --force-config pour remplacer)"
  else
    install_file "$config_src" "$config_dest" "config.toml"
  fi
fi

if [ -d "$BACKUP_DIR" ]; then
  info "backup: $BACKUP_DIR"
fi

info "done"
