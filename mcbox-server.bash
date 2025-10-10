#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -o errexit -o nounset -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
MCBOX_DATA_HOME="${MCBOX_DATA_HOME:-${XDG_DATA_HOME}/mcbox}"
MCBOX_CORE_LIB_FILE="${MCBOX_CORE_LIB_FILE:-${MCBOX_DATA_HOME}/mcbox-core.bash}"

if [ -f "${SCRIPT_DIR}/mcbox-core.bash" ] && [ -r "${SCRIPT_DIR}/mcbox-core.bash" ]; then
    MCBOX_CORE_LIB_FILE="${SCRIPT_DIR}/mcbox-core.bash"
fi

# shellcheck disable=SC1090
source "${MCBOX_CORE_LIB_FILE}"

function shutdown() {
    local server_tag
    server_tag=$(mcbox_get_server_tag)
    server_tag=": ${server_tag}"

    echo_stderr
    log_info "MCP Server${server_tag}: shutting down"

    exit 0
}

function reload() {
    local server_tag
    server_tag=$(mcbox_get_server_tag)
    server_tag=": ${server_tag}"

    echo_stderr
    log_info "MCP Server${server_tag}: reloading configuration"

    if ! mcbox_load_config; then
        log_error "MCP Server${server_tag}: failed to reload configuration"
    fi
}

trap shutdown SIGINT SIGTERM
trap reload SIGHUP SIGUSR1

function usage() {
    echo_stderr "mcbox - A pluggable MCP server in Bash and jq"
    echo_stderr
    echo_stderr "Usage:"
    echo_stderr "  mcbox"
    echo_stderr "  mcbox init-config [--overwrite | -w]"
    echo_stderr "  mcbox --help | -h"
    echo_stderr "  mcbox --version | -v"
    echo_stderr
    echo_stderr "Commands:"
    echo_stderr "  init-config"
    echo_stderr "    Initialize configuration files"
    echo_stderr
    echo_stderr "Options:"
    echo_stderr "  --help, -h"
    echo_stderr "    Show this help"
    echo_stderr
    echo_stderr "  --version, -v"
    echo_stderr "    Show version information"
    echo_stderr
    echo_stderr "  --overwrite, -w"
    echo_stderr "    Overwrite existing configuration files (use with init-config)"
    echo_stderr
}

function parse_arguments() {
    action="root"

    while [ "${#}" -gt 0 ]; do
        key="${1}"
        case "${key}" in
        --version | -v)
            mcbox_version
            exit 0
            ;;

        --help | -h)
            usage
            exit 0
            ;;

        init-config)
            action="init-config"
            shift
            break
            ;;

        *)
            break
            ;;
        esac
    done

    while [ "${#}" -gt 0 ]; do
        key="${1}"
        case "${key}" in
        --overwrite | -w)
            if [ "${action}" == "init-config" ]; then
                action="init-config-overwrite"
            fi
            break
            ;;
        -?*)
            echo_stderr "$(basename "${0}"): invalid option: ${key}"
            exit 1
            ;;

        *)
            echo_stderr "$(basename "${0}"): invalid argument: ${key}"
            exit 1
            ;;

        esac
    done
}

function run() {
    local action
    parse_arguments "${@}"
    case "${action}" in
    "init-config") mcbox_config_init ;;
    "init-config-overwrite") mcbox_config_init "overwrite" ;;
    "root") mcp_server ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run "${@}"
fi
