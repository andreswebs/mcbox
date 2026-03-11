#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

function echo_stderr() {
    echo "${*}" >&2
}

function step() {
    echo_stderr ""
    echo_stderr "==> ${1}"
}

step "shfmt (format check)"
"${REPO_ROOT}/test/shfmt.bash"

step "shellcheck (lint)"
"${REPO_ROOT}/test/shellcheck.bash"

step "bats (tests)"
"${REPO_ROOT}/test/test.bash"

echo_stderr ""
echo_stderr "All checks passed."
