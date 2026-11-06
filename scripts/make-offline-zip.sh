#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Build an offline student ZIP for the ethical-hacking labs.
#
#   ./scripts/make-offline-zip.sh [week|all] [out-dir]
#   ./scripts/make-offline-zip.sh 04              # week 4 only
#   ./scripts/make-offline-zip.sh all             # every week (large)
#
# The ZIP contains the repo plus images/ (one tar per image, linux/amd64 and an
# images.txt). On a VDI where GHCR is blocked, students unzip it and run
# ./start.sh; the launcher loads images/ with podman load before starting.
# Needs a running Docker or Podman with registry access to build the pack.
# ---------------------------------------------------------------------------
set -euo pipefail
cd "$(dirname "$0")/.."

find . -name "._*" -type f -delete 2>/dev/null || true

SPEC="${1:-all}"
OUTDIR="${2:-dist/offline}"
PLATFORM=linux/amd64
SLUG=ethical-hacking-docker-labs

shopt -s nullglob
COMPOSE_FILES=()
case "$SPEC" in
    all)       COMPOSE_FILES=(labs/week*/docker-compose.y*ml) ;;
    [0-9]|[0-9][0-9])
        SPEC="${SPEC#0}"
        COMPOSE_FILES=(labs/week${SPEC}/docker-compose.y*ml) ;;
    *) echo "usage: $0 [week|all] [out-dir]  (e.g. $0 4)"; exit 1 ;;
esac
[ "${#COMPOSE_FILES[@]}" -gt 0 ] || { echo "No compose file for week $SPEC."; exit 1; }

ENGINE="${CONTAINER_ENGINE:-}"
if [ -z "$ENGINE" ]; then
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then ENGINE=docker
    elif command -v podman >/dev/null 2>&1 && podman info >/dev/null 2>&1; then ENGINE=podman
    else echo "Need a running docker or podman to pull and save images."; exit 1
    fi
fi
echo "==> Engine: $ENGINE (packing $SPEC for $PLATFORM)"

IMAGES="$(
    {
        for f in "${COMPOSE_FILES[@]}"; do
            awk '/^[[:space:]]+image:/ {print $2}' "$f"
        done
        find . -name 'Dockerfile*' -not -path './dist/*' -not -path './.git/*' \
            -exec grep -hE '^FROM' {} + | awk '$2 !~ /\$/ {print $2}'
    } | tr -d '"' | sed -E 's/^\$\{[A-Za-z_][A-Za-z0-9_]*:-([^}]*)\}$/\1/' | sort -u
)"
[ -n "$IMAGES" ] || { echo "No images found for $SPEC?"; exit 1; }
echo "$IMAGES" | sed 's/^/    /'

verify_arch() {
    local arch
    arch="$("$ENGINE" image inspect "$1" --format '{{.Architecture}}')"
    if [ "$arch" != "amd64" ]; then
        "$ENGINE" image rm "$1" >/dev/null 2>&1 || true
        "$ENGINE" pull --platform "$PLATFORM" "$1" >/dev/null
        arch="$("$ENGINE" image inspect "$1" --format '{{.Architecture}}')"
    fi
    [ "$arch" = "amd64" ] || { echo "!! $1 is '$arch', not amd64. Refusing to pack."; exit 1; }
}

STAGE="$(mktemp -d /tmp/offline-zip.XXXXXX)"
trap 'rm -rf "$STAGE"' EXIT
ROOT="$STAGE/$SLUG"
mkdir -p "$ROOT/images"

echo "==> Staging the repo ..."
rsync -a --exclude .git --exclude dist --exclude images --exclude '._*' ./ "$ROOT/"

echo "==> Pulling and saving images ..."
: > "$ROOT/images/images.txt"
while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    file="$(printf '%s' "$ref" | tr '/:@' '___').tar"
    "$ENGINE" pull --platform "$PLATFORM" "$ref" >/dev/null \
        || { echo "!! pull failed: $ref"; exit 1; }
    if [ "$ENGINE" = "docker" ]; then
        "$ENGINE" save --platform "$PLATFORM" -o "$ROOT/images/$file" "$ref" \
            || { echo "!! $ref: no usable $PLATFORM content. Refusing to pack."; exit 1; }
    else
        verify_arch "$ref"
        "$ENGINE" save -o "$ROOT/images/$file" "$ref"
    fi
    printf '%s|%s\n' "$ref" "$file" >> "$ROOT/images/images.txt"
    echo "    $ref"
done <<EOF
$IMAGES
EOF
( cd "$ROOT/images" && sha256sum *.tar > manifest.sha256 )

mkdir -p "$OUTDIR"
ZIP="$(cd "$OUTDIR" && pwd)/$SLUG-offline-${SPEC}.zip"
echo "==> Writing $ZIP ..."
rm -f "$ZIP"
( cd "$STAGE" && zip -rq "$ZIP" "$SLUG" )

echo
echo "Offline zip ready: $ZIP"
du -sh "$ZIP"
echo "Students: download, unzip, then ./start.sh — images/ is loaded automatically."
