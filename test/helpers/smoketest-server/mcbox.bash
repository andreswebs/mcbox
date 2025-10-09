#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

FIXTURES_DIR="${SCRIPT_DIR}/../../fixtures"

MCBOX_SERVER_CONFIG_FILE="${FIXTURES_DIR}/smoketest.server.json"
MCBOX_TOOLS_CONFIG_FILE="${FIXTURES_DIR}/smoketest.tools.json"
MCBOX_TOOLS_LIB_FILE="${FIXTURES_DIR}/smoketest.tools.bash"

MCBOX_CORE_LIB_FILE="${SCRIPT_DIR}/../../../mcbox-core.bash"
MCBOX_SERVER="${SCRIPT_DIR}/../../../mcbox-server.bash"

export MCBOX_SERVER_CONFIG_FILE
export MCBOX_TOOLS_CONFIG_FILE
export MCBOX_TOOLS_LIB_FILE
export MCBOX_CORE_LIB_FILE

${MCBOX_SERVER}
