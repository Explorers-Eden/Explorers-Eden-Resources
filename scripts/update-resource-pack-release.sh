#!/usr/bin/env bash
set -euo pipefail

REPO="${1:?GitHub repository argument is required}"
TAG="${RELEASE_TAG}"
TITLE="${RELEASE_TITLE}"
FILE="${PACK_ZIP_NAME}"

if gh release view "$TAG" >/dev/null 2>&1; then
  echo "Release exists, updating asset"
else
  gh release create "$TAG" \
    --title "$TITLE" \
    --notes "Automated release for the latest resource pack."
fi

gh release upload "$TAG" "$FILE" --clobber

URL="https://github.com/${REPO}/releases/download/${TAG}/${FILE}"

echo "resource_pack_url=$URL" >> "$GITHUB_OUTPUT"
echo "Release asset URL: $URL"
