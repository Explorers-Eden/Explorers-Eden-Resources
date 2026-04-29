#!/usr/bin/env bash
set -euo pipefail

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

git add server.properties

if git diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

git commit -m "Update server.properties resource pack link"
git pull --rebase origin main
git push origin HEAD:main
