#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run         Affiche les actions sans modifier le poste.
  --no-backup      N'ecrit pas de sauvegarde avant remplacement.
  --no-skills      N'installe pas les skills personnels versionnes.
  --prune-agents   Supprime de ~/.codex/agents les agents TOML absents du repo.
  --prune-skills   Supprime de ~/.codex/skills les skills absents du repo.
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

backup_path() {
  backup_src=$1
  backup_rel=$2

  [ "$BACKUP" = "1" ] || return 0
  [ -e "$backup_src" ] || return 0

  backup_dest="$BACKUP_DIR/$backup_rel"
  backup_parent=$(dirname "$backup_dest")
  run mkdir -p "$backup_parent"
  if [ -d "$backup_src" ]; then
    run cp -pR "$backup_src" "$backup_dest"
  else
    run cp -p "$backup_src" "$backup_dest"
  fi
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

install_dir() {
  dir_src=$1
  dir_dest=$2
  dir_rel=$3

  [ -d "$dir_src" ] || die "source introuvable: $dir_src"

  dir_parent=$(dirname "$dir_dest")
  run mkdir -p "$dir_parent"

  if [ -d "$dir_dest" ] && diff -qr "$dir_src" "$dir_dest" >/dev/null 2>&1; then
    info "ok: $dir_dest"
    return 0
  fi

  backup_path "$dir_dest" "$dir_rel"
  run rm -rf "$dir_dest"
  run cp -pR "$dir_src" "$dir_dest"
  info "installed: $dir_dest"
}

DRY_RUN=0
BACKUP=1
INSTALL_SKILLS=1
PRUNE_AGENTS=0
PRUNE_SKILLS=0
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
    --no-skills)
      INSTALL_SKILLS=0
      ;;
    --prune-agents)
      PRUNE_AGENTS=1
      ;;
    --prune-skills)
      PRUNE_SKILLS=1
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
TARGET_SKILLS="$CODEX_HOME/skills"
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

if [ "$INSTALL_SKILLS" = "1" ] && [ -d "$REPO_DIR/skills" ]; then
  run mkdir -p "$TARGET_SKILLS"
  for skill_src in "$REPO_DIR"/skills/*; do
    [ -d "$skill_src" ] || continue
    skill_base=$(basename "$skill_src")
    install_dir "$skill_src" "$TARGET_SKILLS/$skill_base" "skills/$skill_base"
  done
fi

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

if [ "$PRUNE_SKILLS" = "1" ] && [ -d "$TARGET_SKILLS" ]; then
  for skill_dest in "$TARGET_SKILLS"/*; do
    [ -d "$skill_dest" ] || continue
    skill_base=$(basename "$skill_dest")
    [ "$skill_base" = ".system" ] && continue
    [ "$skill_base" = "codex-primary-runtime" ] && continue
    [ -d "$REPO_DIR/skills/$skill_base" ] && continue
    backup_path "$skill_dest" "skills/$skill_base"
    run rm -rf "$skill_dest"
    info "removed unmanaged skill: $skill_dest"
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
