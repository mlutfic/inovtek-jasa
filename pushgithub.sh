#!/usr/bin/env bash
set -euo pipefail

REMOTE_NAME="${REMOTE_NAME:-origin}"
REMOTE_URL="${REMOTE_URL:-git@github.com:mlutfic/inovtek-jasa.git}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
COMMIT_MESSAGE="${*:-Update project $(date '+%Y-%m-%d %H:%M:%S')}"

ensure_gitignore_entry() {
  local entry="$1"

  if [ ! -f .gitignore ]; then
    printf '%s\n' "$entry" > .gitignore
    return
  fi

  if ! grep -Fxq "$entry" .gitignore; then
    printf '%s\n' "$entry" >> .gitignore
  fi
}

ensure_git_repo() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    return
  fi

  if [ -d .git ]; then
    if find .git -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
      echo "Direktori .git ada tetapi tidak valid. Rapikan dulu sebelum push."
      exit 1
    fi

    rmdir .git
  fi

  git init
}

ensure_git_identity() {
  if ! git config --get user.name >/dev/null 2>&1; then
    echo "Git user.name belum disetel. Jalankan: git config --global user.name \"Nama Anda\""
    exit 1
  fi

  if ! git config --get user.email >/dev/null 2>&1; then
    echo "Git user.email belum disetel. Jalankan: git config --global user.email \"email@anda.com\""
    exit 1
  fi
}

ensure_remote() {
  if git remote get-url "$REMOTE_NAME" >/dev/null 2>&1; then
    git remote set-url "$REMOTE_NAME" "$REMOTE_URL"
  else
    git remote add "$REMOTE_NAME" "$REMOTE_URL"
  fi
}

main() {
  ensure_gitignore_entry ".agents/"
  ensure_gitignore_entry ".codex/"
  ensure_gitignore_entry ".DS_Store"
  ensure_gitignore_entry "Thumbs.db"

  ensure_git_repo
  ensure_git_identity

  git branch -M "$DEFAULT_BRANCH"
  ensure_remote

  git add .

  if git diff --cached --quiet; then
    echo "Tidak ada perubahan baru untuk di-commit."
  else
    git commit -m "$COMMIT_MESSAGE"
  fi

  git push -u "$REMOTE_NAME" "$DEFAULT_BRANCH"
}

main "$@"
