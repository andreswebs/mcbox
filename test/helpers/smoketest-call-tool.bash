#!/usr/bin/env bash
# https://github.com/wong2/mcp-cli

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG="${SCRIPT_DIR}/../fixtures/mcp-cli.config.json"

export PATH="${SCRIPT_DIR}/smoketest-server:${PATH}"

function call_tool() {
    npx --yes --package @wong2/mcp-cli@latest mcp-cli --config "${CONFIG}" call-tool "${@}"
}

call_tool "${@}"
