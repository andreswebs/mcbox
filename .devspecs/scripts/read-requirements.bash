#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/functions.bash"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/env.bash"


REPO_ROOT_DIR=$(get_repo_root)
SPECS_DIR=$(get_specs_parent_dir_name "${REPO_ROOT_DIR}")

REQUIREMENTS_FILE_BASE_NAME="requirements.md"
REQUIREMENTS_FILE="${SPECS_DIR}/${REQUIREMENTS_FILE_BASE_NAME}"

if ! is_readable_file "${REQUIREMENTS_FILE}"; then
    log "error: failed to access ${REQUIREMENTS_FILE}"
    exit 1
fi

cat "${REQUIREMENTS_FILE}"
