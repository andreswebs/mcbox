#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if ! command -v "shellcheck" &>/dev/null; then
    echo "shellcheck not installed" >&2
    exit 1
fi

# see: https://www.shellcheck.net/wiki/SC2038
find "${SCRIPT_DIR}/.." -type f -name '*.bash' ! -path '*/bats*/*' -print0 | xargs shellcheck
