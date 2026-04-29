#!/usr/bin/env bash
set -euo pipefail

if [ -z "${REPO_TOKEN:-}" ]; then
  echo "REPO_TOKEN secret is missing"
  exit 1
fi

echo "Removing existing local assets folder before syncing"
rm -rf assets
mkdir -p assets

WORKDIR="$(mktemp -d)"

repos=(
  "Explorers-Eden/Nice-Actions"
  "Explorers-Eden/Katters_Structures"
  "Explorers-Eden/Enchantments-Encore"
  "Explorers-Eden/Fabled-Roots"
  "Explorers-Eden/Warping-Wonders"
  "Explorers-Eden/Nice-Mob-Variants"
  "Explorers-Eden/Nice-Keep-Inventory"
  "Explorers-Eden/Nice-Mob-Manager"
  "Explorers-Eden/Nice-Things"
  "Explorers-Eden/A-Realm-Recrafted"
  "Explorers-Eden/Nice-Name-Tags"
  "Explorers-Eden/Nice-Admin-Tools"
)

for repo in "${repos[@]}"; do
  name="${repo##*/}"
  target="$WORKDIR/$name"

  echo "Checking $repo"
  git clone --depth 1 "https://x-access-token:${REPO_TOKEN}@github.com/${repo}.git" "$target"

  if [ -d "$target/assets" ]; then
    echo "Copying assets from $repo"
    rsync -a "$target/assets/" "assets/"
  else
    echo "Skipping $repo because it has no assets folder"
  fi
done

echo "Final assets folder contents:"
find assets -maxdepth 2 -type d | sort
