#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/functions.bash"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/env.bash"

SPEC_INFO=$(get_spec_info || exit 1)

REPO_ROOT_DIR=$(echo "${SPEC_INFO}" | jq --raw-output '.repo_root')
TASKS_DIR=$(echo "${SPEC_INFO}" | jq --raw-output '.tasks_dir')
TASKS_FILE=$(echo "${SPEC_INFO}" | jq --raw-output '.tasks_file')
TASKS_TEMPLATE_FILE="${REPO_ROOT_DIR}/${DEVSPECS_TASKS_TEMPLATE_RELATIVE_FILE_NAME:-.devspecs/templates/tasks.template.md}"

mkdir -p "${TASKS_DIR}"

if [ -f "${TASKS_TEMPLATE_FILE}" ] && [ -r "${TASKS_TEMPLATE_FILE}"  ]; then
    cp "${TASKS_TEMPLATE_FILE}" "${TASKS_FILE}"
else
    log "warning: template not found at ${TASKS_TEMPLATE_FILE}"
    touch "${TASKS_FILE}"
fi

# Print info for LLM
echo "${SPEC_INFO}" | jq --monochrome-output
