#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/functions.bash"

# shellcheck disable=SC1091
source "${SCRIPT_DIR}/env.bash"

DESCRIPTION="${1}"
if [ -z "${DESCRIPTION}" ]; then
    log "Usage: ${0} <description>"
    exit 1
fi

REPO_ROOT_DIR=$(get_repo_root)
SPECS_DIR=$(get_specs_parent_dir_name "${REPO_ROOT_DIR}")

mkdir -p "${SPECS_DIR}"

SPECS_HIGHEST_PREFIX=$(find_highest_number_dir_prefix "${SPECS_DIR}")
SPEC_NUMBER_PREFIX=$(generate_next_spec_number "${SPECS_HIGHEST_PREFIX}")
SPEC_NAME_SUFFIX=$(generate_spec_name_suffix "${DESCRIPTION}")
SPEC_NAME="${SPEC_NUMBER_PREFIX}-${SPEC_NAME_SUFFIX}"
SPEC_DIR="${SPECS_DIR}/${SPEC_NAME}"
SPEC_FILE="${SPEC_DIR}/spec.md"
SPEC_TEMPLATE_FILE="${REPO_ROOT_DIR}/${DEVSPECS_SPEC_TEMPLATE_RELATIVE_FILE_NAME:-.devspecs/templates/spec.template.md}"

git checkout -b "${SPEC_NAME}"
mkdir -p "${SPEC_DIR}"

if [ -f "${SPEC_TEMPLATE_FILE}" ] && [ -r "${SPEC_TEMPLATE_FILE}" ]; then
    cp "${SPEC_TEMPLATE_FILE}" "${SPEC_FILE}"
else
    log "warning: template not found at ${SPEC_TEMPLATE_FILE}"
    touch "${SPEC_FILE}"
fi

SPEC_INFO='{
    "spec_number": "'${SPEC_NUMBER_PREFIX}'",
    "spec_name": "'${SPEC_NAME}'",
    "spec_file": "'${SPEC_FILE}'"
}'

# Print info for LLM
echo "${SPEC_INFO}" | tr -d '\n' | tr -d ' ' | jq --monochrome-output
