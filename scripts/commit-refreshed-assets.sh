#!/usr/bin/env bash
set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add assets

if git diff --cached --quiet; then
  echo "No asset changes to commit"
else
  git commit -m "Update merged resource pack assets"
  git pull --rebase origin main
  git push origin HEAD:main
fi
