#!/usr/bin/env bash
# Ethical Hacking Labs — enter the labs (hides Docker; drops you into a real Kali shell).
#   ./start.sh              choose a week from the menu
#   LAB_WEEK=04 ./start.sh  jump straight to a week
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/scripts/lab-console" "$@"
