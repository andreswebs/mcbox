#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/functions.bash"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/env.bash"

function generate_instructions_filename() {
  local filename="${1}"
  if [[ "${filename}" == *.md ]]; then
    echo "${filename%.md}.instructions.md"
  fi
}

REPO_ROOT_DIR=$(get_repo_root)
DEVSPECS_MEMORY_DIR="${REPO_ROOT_DIR}/${DEVSPECS_MEMORY_RELATIVE_DIR:-.devspecs/memory}"
GITHUB_INSTRUCTIONS_DIR="${REPO_ROOT_DIR}/.github/instructions"

if [ ! -d "${DEVSPECS_MEMORY_DIR}" ]; then
    log "error: ${DEVSPECS_MEMORY_DIR} does not exist."
    exit 1
fi

if is_non_empty_dir "${DEVSPECS_MEMORY_DIR}"; then
    for SRC_FILE in "${DEVSPECS_MEMORY_DIR}"/*; do
        SRC_BASE_NAME=$(basename "${SRC_FILE}")
        DEST_BASE_NAME=$(generate_instructions_filename "${SRC_BASE_NAME}")
        DEST_FILE="${GITHUB_INSTRUCTIONS_DIR}/${DEST_BASE_NAME}"
        create_relative_symlink "${SRC_FILE}" "${DEST_FILE}"
    done
fi
