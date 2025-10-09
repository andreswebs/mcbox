#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/functions.bash"

readonly REQUIRED_COMMANDS=(
    "grep"
    "head"
    "tr"
    "sed"
    "git"
    "gh"
    "jq"
)

missing_commands=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! is_cmd_available "${cmd}"; then
        missing_commands+=("${cmd}")
    fi
done

if [[ "${#missing_commands[@]}" -gt 0 ]]; then
    log "error: the following required commands are missing:"
    for missing_cmd in "${missing_commands[@]}"; do
        log "  - ${missing_cmd}"
    done
    exit 1
else
    log "All required dependencies are available."
fi
