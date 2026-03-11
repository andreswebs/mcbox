#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

MCP_SCHEMA_DIR="${MCP_SCHEMA_DIR:-${REPO_ROOT}/docs/refs}"

GITHUB_API_BASE="https://api.github.com/repos/modelcontextprotocol/modelcontextprotocol"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/modelcontextprotocol/modelcontextprotocol/main"

function echo_stderr() {
    echo "${*}" >&2
}

function check_deps() {
    local missing=()
    for cmd in curl jq; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            missing+=("${cmd}")
        fi
    done
    if ((${#missing[@]} > 0)); then
        echo_stderr "missing required commands: ${missing[*]}"
        return 1
    fi
}

function fetch_latest_version() {
    local response
    response=$(
        curl \
            --silent \
            --fail \
            --show-error \
            --location \
            --header "Accept: application/vnd.github+json" \
            "${GITHUB_API_BASE}/contents/schema"
    )

    # Version dirs follow the YYYY-MM-DD pattern; pick the lexicographically largest
    printf '%s' "${response}" \
        | jq --raw-output '.[] | select(.type == "dir") | .name | select(test("^[0-9]{4}-[0-9]{2}-[0-9]{2}$"))' \
        | sort \
        | tail --lines=1
}

function fetch_schema() {
    local version="${1}"
    local output_file="${2}"
    local url="${GITHUB_RAW_BASE}/schema/${version}/schema.json"

    echo_stderr "fetching schema version ${version} from ${url}"
    curl --silent --fail --show-error --location \
        --output "${output_file}" \
        "${url}"
}

function main() {
    check_deps

    echo_stderr "querying latest MCP schema version..."
    local version
    version=$(fetch_latest_version)

    if [[ -z "${version}" ]]; then
        echo_stderr "could not determine latest schema version"
        return 1
    fi

    echo_stderr "latest version: ${version}"

    local output_file="${MCP_SCHEMA_DIR}/mcp.${version}.schema.json"

    if [[ ! -d "${MCP_SCHEMA_DIR}" ]]; then
        echo_stderr "output directory does not exist: ${MCP_SCHEMA_DIR}"
        return 1
    fi

    fetch_schema "${version}" "${output_file}"
    echo_stderr "schema written to ${output_file}"
}

main
