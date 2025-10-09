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
SPEC_DIR=$(echo "${SPEC_INFO}" | jq --raw-output '.spec_dir')
PLAN_FILE=$(echo "${SPEC_INFO}" | jq --raw-output '.plan_file')
PLAN_TEMPLATE_FILE="${REPO_ROOT_DIR}/${DEVSPECS_PLAN_TEMPLATE_RELATIVE_FILE_NAME:-.devspecs/templates/plan.template.md}"

mkdir -p "${SPEC_DIR}"

if [ -f "${PLAN_TEMPLATE_FILE}" ] && [ -r "${PLAN_TEMPLATE_FILE}"  ]; then
    cp "${PLAN_TEMPLATE_FILE}" "${PLAN_FILE}"
else
    log "warning: template not found at ${PLAN_TEMPLATE_FILE}"
    touch "${PLAN_FILE}"
fi

# Print info for LLM
echo "${SPEC_INFO}" | jq --monochrome-output
