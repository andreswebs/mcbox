#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

WRITE="${WRITE:-false}"

if ! command -v "shfmt" &>/dev/null; then
    echo "shfmt not installed" >&2
    exit 1
fi

function sh_format_check() {
    shfmt --indent 4 --diff "${@}"
}

function sh_format() {
    shfmt --indent 4 --write "${@}"
}

check_list=(
    "${SCRIPT_DIR}"/../*.bash
    "${SCRIPT_DIR}"/*.bash
    "${SCRIPT_DIR}"/*.bats
    "${SCRIPT_DIR}"/helpers/*.bash
)

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [ "${WRITE}" != "true" ]; then
        sh_format_check "${check_list[@]}"
    else
        sh_format "${check_list[@]}"
    fi
fi
