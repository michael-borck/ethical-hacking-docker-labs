#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# No-sudo compose bootstrap for Podman-only machines (e.g. a lab VDI).
#
#   bash scripts/setup-user.sh
#
# Installs a current podman-compose into YOUR home directory, or a standalone
# Docker Compose v2 binary if python3-venv is unavailable. Nothing system-wide,
# no root, no Docker. Afterwards open a new terminal and run ./start.sh.
# ---------------------------------------------------------------------------
set -euo pipefail

BIN="$HOME/.local/bin"
VENV="$HOME/.local/podman-compose"

echo "==> Checking Podman ..."
command -v podman >/dev/null 2>&1 || { echo "Podman is not installed — ask lab staff."; exit 1; }
podman info >/dev/null 2>&1 || { echo "Podman is installed but not answering (try: podman info)."; exit 1; }

mkdir -p "$BIN"

compose_ok() { "$1" version >/dev/null 2>&1; }

# Already good?
for candidate in "$BIN/podman-compose" "$(command -v podman-compose 2>/dev/null || true)" \
                 "$BIN/docker-compose" "$(command -v docker-compose 2>/dev/null || true)"; do
    [ -n "$candidate" ] && [ -x "$candidate" ] && compose_ok "$candidate" && {
        echo "==> $candidate already works — nothing to do."
        exit 0
    }
done

installed=""
rm -rf "$VENV"
if python3 -m venv "$VENV" >/dev/null 2>&1; then
    echo "==> Installing a current podman-compose (user-local) ..."
    "$VENV/bin/pip" install -q --upgrade pip
    "$VENV/bin/pip" install -q podman-compose
    ln -sfn "$VENV/bin/podman-compose" "$BIN/podman-compose"
    installed="$BIN/podman-compose"
else
    rm -rf "$VENV"
    echo "==> python3-venv unavailable; using the standalone Compose v2 binary ..."
    URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$BIN/docker-compose" "$URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$BIN/docker-compose" "$URL"
    else
        echo "Need curl or wget to download the fallback. Ask lab staff."; exit 1
    fi
    chmod +x "$BIN/docker-compose"
    installed="$BIN/docker-compose"
fi

case ":$PATH:" in
    *":$BIN:"*) : ;;
    *)  printf '\n# podman labs: user-local compose\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.bashrc"
        export PATH="$BIN:$PATH" ;;
esac

echo "==> Verifying ..."
compose_ok "$installed" || { echo "Something went wrong: $installed does not run."; exit 1; }
"$installed" version 2>/dev/null || true

if [ "${RUN_BY_CONSOLE:-0}" = "1" ]; then
    echo "One-time setup complete."
else
    cat <<'EOF'

Ready. Open a NEW terminal, then from the lab folder:

    ./start.sh

The launcher finds this compose automatically — you type nothing else.
EOF
fi
