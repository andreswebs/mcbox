#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || return 0

TOOL_SCHEMA='
{
    "type": "object",
    "required": ["inputSchema", "name"],
    "properties": {
        "name": {
            "type": "string"
        },
        "inputSchema": {
            "type": "object",
            "required": ["type"],
            "properties": {
                "type": {
                    "const": "object",
                    "type": "string"
                },
                "properties": {
                    "type": "object",
                    "additionalProperties": {
                        "additionalProperties": true,
                        "properties": {},
                        "type": "object"
                    }
                },
                "required": {
                    "type": "array",
                    "items": {
                    "type": "string"
                }
            }
        }
    },
        "outputSchema": {
            "type": "object",
            "required": ["type"],
            "properties": {
                "type": {
                    "const": "object",
                    "type": "string"
                },
                "properties": {
                    "type": "object",
                    "additionalProperties": {
                        "additionalProperties": true,
                        "properties": {},
                        "type": "object"
                    }
                },
                "required": {
                    "type": "array",
                    "items": {
                        "type": "string"
                    }
                }
            }
        }
    }
}
'

TOOLS_SCHEMA='
{
    "type": "object",
    "required": ["tools"],
    "properties": {
        "tools": {
            "type": "array",
            "items": '${TOOL_SCHEMA}'
        }
    }
}
'

function echo_stderr() {
    echo "${*}" >&2
}

function log_level_to_num() {
    local -r level="${1}"
    # See: https://opentelemetry.io/docs/specs/otel/logs/data-model/#field-severitynumber
    case "${level}" in
    "trace") echo 1 ;;
    "debug") echo 5 ;;
    "info") echo 9 ;;
    "warn") echo 13 ;;
    "error") echo 17 ;;
    "fatal") echo 21 ;;
    *) echo 9 ;; # unknown -> info
    esac
}

function log() {
    local OTEL_LOG_LEVEL="${OTEL_LOG_LEVEL:-info}"
    local MCBOX_LOG_LEVEL="${MCBOX_LOG_LEVEL:-${OTEL_LOG_LEVEL}}"
    MCBOX_LOG_LEVEL=$(printf '%s' "${MCBOX_LOG_LEVEL}" | tr '[:upper:]' '[:lower:]')

    local -r LOG_SEVERITY_NUMBER=$(log_level_to_num "${MCBOX_LOG_LEVEL}")

    local -r level="${1}"
    local -r message="${2}"
    local -r timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local -r script_loc="${0##*/}"
    local -r function="${FUNCNAME[2]}"

    local l
    l=$(printf '%s' "${level}" | tr '[:upper:]' '[:lower:]')
    local s_num
    s_num=$(log_level_to_num "${l}")

    if ((s_num >= LOG_SEVERITY_NUMBER)); then
        echo_stderr "[${timestamp}] [${l}] [${script_loc}] [${function}] ${message}"
    fi
}

function log_trace() {
    local -r message="${1}"
    log "TRACE" "${message}"
}

function log_debug() {
    local -r message="${1}"
    log "DEBUG" "${message}"
}

function log_info() {
    local -r message="${1}"
    log "INFO" "${message}"
}

function log_warn {
    local -r message="${1}"
    log "WARN" "${message}"
}

function log_error {
    local -r message="${1}"
    log "ERROR" "${message}"
}

function log_fatal {
    local -r message="${1}"
    log "FATAL" "${message}"
}

function is_cmd_available() {
    local cmd="${1}"
    command -v "${cmd}" &>/dev/null
}

function mcbox_check_dependencies() {
    if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
        log_fatal "bash version 4.3 or higher is required"
        return 1
    fi

    local deps=(
        "cat"
        "grep"
        "ls"
        "printf"
        "tr"
        "jq"
    )

    missing_commands=()

    for cmd in "${deps[@]}"; do
        if ! is_cmd_available "${cmd}"; then
            missing_commands+=("${cmd}")
        fi
    done

    if [[ "${#missing_commands[@]}" -gt 0 ]]; then
        log_fatal "the following required commands are missing:"
        for missing_cmd in "${missing_commands[@]}"; do
            echo_stderr "  - ${missing_cmd}"
        done
        return 1
    fi

    return 0
}

function is_non_empty_dir() {
    [ -d "${1}" ] && [ -r "${1}" ] && [ -n "$(ls -A "${1}" 2>/dev/null)" ]
}

function is_readable_file() {
    local file_path="${1}"

    local resolved_path
    if ! resolved_path=$(realpath -q "${file_path}" 2>/dev/null); then
        return 1
    fi
    [ -f "${resolved_path}" ] && [ -r "${resolved_path}" ]
}

# shellcheck disable=SC2120
function text_trim() {
    local input

    if [ "${#}" -gt 0 ]; then
        input="${*}"
    else
        input=$(cat)
    fi

    # Remove leading whitespace characters
    input="${input#"${input%%[![:space:]]*}"}"
    # Remove trailing whitespace characters
    input="${input%"${input##*[![:space:]]}"}"

    printf '%s' "${input}"
}

function is_valid_json() {
    local input="${1}"

    if [ -z "${input}" ]; then
        return 1
    fi

    if echo "${input}" | grep --quiet '\bNaN\b\|\bInfinity\b\|\b-Infinity\b'; then
        return 1
    fi

    if ! echo "${input}" | jq empty >/dev/null 2>&1; then
        return 1
    fi

    # Check if there are multiple JSON values (should be invalid)
    # Count the number of top-level JSON values
    local value_count
    if ! value_count=$(echo "${input}" | jq --slurp '. | length' 2>/dev/null); then
        return 1
    fi

    # If we can't parse it as an array or there's more than one value, it's invalid
    if [ "${value_count}" != "1" ]; then
        return 1
    fi

    return 0
}

function is_json_object() {
    local input="${1}"

    if [ -z "${input}" ]; then
        return 1
    fi

    if ! echo "${input}" | jq --exit-status 'type == "object"' >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

function json_object_has_key() {
    local input="${1}"
    local expect_key="${2}"

    if ! is_json_object "${input}"; then
        return 1
    fi

    if ! echo "${input}" | jq --exit-status --arg key "${expect_key}" 'has($key)' >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

function jsonschema_validate_value() {
    local value="${1}"
    local schema="${2}"

    if ! is_json_object "${schema}"; then
        log_error "invalid schema format: the passed schema is not a valid JSON object"
        return 1
    fi

    if ! json_object_has_key "${schema}" "type"; then
        log_error "the schema is missing the 'type' property"
        return 1
    fi

    local schema_type
    schema_type=$(echo "${schema}" | jq --raw-output '.type')

    if [[ -z "${schema_type}" ]]; then
        log_error "the schema is missing the 'type' property"
        return 1
    fi

    local actual_type
    actual_type=$(echo "${value}" | jq --raw-output 'type')

    case "${schema_type}" in
    "string")
        if [[ "${actual_type}" != "string" ]]; then
            log_error "expected string, got ${actual_type}"
            return 1
        fi
        ;;
    "number")
        if [[ "${actual_type}" != "number" ]]; then
            log_error "expected number, got ${actual_type}"
            return 1
        fi
        ;;
    "integer")
        # In JSON, integers are numbers, but we need to check if it's a whole number
        if [[ "${actual_type}" != "number" ]]; then
            log_error "expected integer, got ${actual_type}"
            return 1
        fi
        # Check if the number is actually an integer (no decimal part)
        if ! echo "${value}" | jq --exit-status '. == (. | floor)' >/dev/null 2>&1; then
            log_error "expected integer, got non-integer number"
            return 1
        fi
        ;;
    "boolean")
        if [[ "${actual_type}" != "boolean" ]]; then
            log_error "expected boolean, got ${actual_type}"
            return 1
        fi
        ;;
    "array")
        if [[ "${actual_type}" != "array" ]]; then
            log_error "expected array, got ${actual_type}"
            return 1
        fi
        ;;
    "object")
        if [[ "${actual_type}" != "object" ]]; then
            log_error "expected object, got ${actual_type}"
            return 1
        fi
        ;;
    *)
        log_error "unsupported schema type: ${schema_type}"
        return 1
        ;;
    esac

    return 0
}

function jsonschema_validate_schema() {
    local input="${1}"
    local schema="${2}"

    if ! is_json_object "${input}"; then
        log_error "invalid input format: the passed input is not a valid JSON object"
        return 1
    fi

    if ! is_json_object "${schema}"; then
        log_error "invalid schema format: the passed schema is not a valid JSON object"
        return 1
    fi

    local required_props
    required_props=$(echo "${schema}" | jq --raw-output '.required[]? // empty')

    if [ -n "${required_props}" ]; then
        while IFS= read -r required; do
            if [ -n "${required}" ]; then
                if ! json_object_has_key "${input}" "${required}"; then
                    log_error "missing required argument: '${required}'"
                    return 1
                fi
            fi
        done <<<"${required_props}"
    fi

    local properties
    properties=$(echo "${schema}" | jq '.properties // {}')

    local arg_names
    arg_names=$(echo "${input}" | jq --raw-output 'keys[]')

    while IFS= read -r arg_name; do
        if [ -n "${arg_name}" ]; then
            local prop_schema
            prop_schema=$(echo "${properties}" | jq --arg key "${arg_name}" '.[$key] // null')

            if [ "${prop_schema}" == "null" ]; then
                log_error "unknown argument: '${arg_name}'"
                return 1
            fi

            local arg_value
            arg_value=$(echo "${input}" | jq --arg key "${arg_name}" '.[$key]')

            if ! jsonschema_validate_value "${arg_value}" "${prop_schema}"; then
                log_error "invalid argument: '${arg_name}'"
                return 1
            fi
        fi
    done <<<"${arg_names}"

    return 0
}

function json_merge_objects() {
    if [ "${#}" -eq 0 ]; then
        log_error "at least one argument is required"
        return 1
    fi

    local jsons=()

    for arg in "${@}"; do
        if ! echo "${arg}" | jq --exit-status 'type == "object"' >/dev/null 2>&1; then
            log_error "invalid JSON object: ${arg}"
            return 1
        fi
        jsons+=("${arg}")
    done

    printf '%s\n' "${jsons[@]}" | jq --compact-output --monochrome-output --slurp 'add'
}

function json_read_file() {
    local file_path="${1}"

    if [ "${#}" -eq 0 ]; then
        log_error "file path argument is required"
        return 1
    fi

    if ! is_readable_file "${file_path}"; then
        log_error "${file_path} is not accessible"
        return 1
    fi

    # Check if file is empty
    if [ ! -s "${file_path}" ]; then
        log_error "${file_path} is empty"
        return 1
    fi

    if ! jq --compact-output --monochrome-output '.' "${file_path}" 2>/dev/null; then
        log_error "${file_path} contains invalid JSON"
        return 1
    fi
}

function jsonrpc_validate_id() {
    local id="${1}"

    if [ "${#}" -eq 0 ]; then
        return 0
    fi

    if [ "${id}" = "null" ]; then
        return 0
    fi

    # reject negative integer first (before JSON validation)
    if [[ "${id}" =~ ^-[0-9]+$ ]]; then
        return 1
    fi

    # JSON-formatted string
    if echo "${id}" | jq --exit-status 'type == "string"' >/dev/null 2>&1; then
        return 0
    fi

    # JSON-formatted number (integer only)
    if echo "${id}" | jq --exit-status 'type == "number" and . == floor' >/dev/null 2>&1; then
        return 0
    fi

    # plain integer (positive or zero)
    if [[ "${id}" =~ ^[0-9]+$ ]]; then
        return 0
    fi

    # reject strings that look like JSON literals (true, false, fractional numbers)
    if [[ "${id}" == "true" ]] || [[ "${id}" == "false" ]] || [[ "${id}" =~ ^-?[0-9]+\.[0-9]+$ ]]; then
        return 1
    fi

    # accept other plain strings that are simple identifiers
    if [[ "${id}" =~ ^[a-zA-Z0-9]+([_-][a-zA-Z0-9]+)*$ ]]; then
        return 0
    fi

    return 1
}

function jsonrpc_init_json() {
    local id="${1}"
    local init_obj='{"jsonrpc":"2.0"}'

    if [ -n "${id}" ]; then
        if ! jsonrpc_validate_id "${id}"; then
            log_error "invalid id: ${id}"
            return 1
        fi

        local id_obj

        if [ "${id}" = "null" ]; then
            id_obj='{"id":null}'
        elif echo "${id}" | jq --exit-status 'type == "number"' >/dev/null 2>&1; then
            # Already JSON-formatted number
            id_obj='{"id":'${id}'}'
        elif echo "${id}" | jq --exit-status 'type == "string"' >/dev/null 2>&1; then
            # Already JSON-formatted string
            id_obj='{"id":'${id}'}'
        elif [[ "${id}" =~ ^-?[0-9]+$ ]]; then
            # Plain number (integer)
            id_obj='{"id":'${id}'}'
        else
            # Plain string - needs JSON encoding
            id_obj='{"id":'$(printf '%s' "${id}" | jq --raw-input .)'}'
        fi
        if ! init_obj=$(json_merge_objects "${init_obj}" "${id_obj}"); then
            return 1
        fi
    fi

    echo "${init_obj}"
}

function jsonrpc_create_error_object() {
    local error_code="${1}"
    local error_message="${2}"
    local error_data="${3:-}"

    if [ "${#}" -lt 2 ]; then
        log_error "requires two arguments"
        return 1
    fi

    if ! [[ "${error_code}" =~ ^-?[0-9]+$ ]]; then
        log_error "the error code must be an integer"
        return 1
    fi

    local error_contents
    if [ "${#}" -ge 3 ] && [ -n "${error_data}" ]; then
        # Data parameter was provided and is not empty
        # Try to parse the data as JSON first
        local parsed_data
        if parsed_data=$(echo "${error_data}" | jq -c . 2>/dev/null); then
            # Data is valid JSON, use it as-is
            if ! error_contents=$(
                jq \
                    --null-input --compact-output --monochrome-output \
                    --arg code "${error_code}" \
                    --arg message "${error_message}" \
                    --argjson data "${parsed_data}" \
                    '{"code": ($code | tonumber), "message": $message, "data": $data}'
            ); then
                return 1
            fi
        else
            # Data is not valid JSON, treat it as a string
            if ! error_contents=$(
                jq \
                    --null-input --compact-output --monochrome-output \
                    --arg code "${error_code}" \
                    --arg message "${error_message}" \
                    --arg data "${error_data}" \
                    '{"code": ($code | tonumber), "message": $message, "data": $data}'
            ); then
                return 1
            fi
        fi
    else
        # No data parameter provided or empty, create error object without data
        if ! error_contents=$(
            jq \
                --null-input --compact-output --monochrome-output \
                --arg code "${error_code}" \
                --arg message "${error_message}" \
                '{"code": ($code | tonumber), "message": $message}'
        ); then
            return 1
        fi
    fi

    local error_obj
    error_obj='{"error":'${error_contents}'}'

    echo "${error_obj}"
}

function jsonrpc_create_error_response() {
    local id="${1}"
    local error_code="${2}"
    local error_message="${3}"
    local error_data="${4:-}"
    log_debug "id: ${id}, error_code: ${error_code}, error_message: ${error_message}"

    if [ "${#}" -lt 3 ]; then
        log_error "requires at least three arguments"
        return 1
    fi

    local init_obj
    if ! init_obj=$(jsonrpc_init_json "${id}"); then
        return 1
    fi

    local error_obj
    if ! error_obj=$(jsonrpc_create_error_object "${error_code}" "${error_message}" "${error_data}"); then
        return 1
    fi

    local error_response
    if ! error_response=$(json_merge_objects "${init_obj}" "${error_obj}"); then
        return 1
    fi

    echo "${error_response}"
}

function jsonrpc_create_result_object() {
    local result="${1}"

    if [ "${#}" -lt 1 ]; then
        log_error "requires an argument"
        return 1
    fi

    local result_contents

    if is_valid_json "${result}"; then
        result_contents="${result}"
    elif [ -n "${result}" ]; then
        # Check if input looks like a JSON structure but is malformed
        # This includes: objects, arrays, quoted strings, or multiple JSON values
        if [[ "${result}" =~ ^\{ ]] || [[ "${result}" =~ ^\[ ]] || [[ "${result}" =~ ^\" ]] || [[ "${result}" =~ \"[[:space:]]+\" ]]; then
            if ! echo "${result}" | jq empty >/dev/null 2>&1; then
                log_error "malformed JSON: ${result}"
                return 1
            fi
        fi

        # Treat as plain string
        if ! result_contents=$(printf '%s' "${result}" | jq --raw-input --slurp --compact-output .); then
            return 1
        fi
    else
        log_error "result cannot be empty"
        return 1
    fi

    local result_obj
    if ! result_obj=$(printf '%s' "${result_contents}" | jq --compact-output '{result: .}'); then
        return 1
    fi

    echo "${result_obj}"
}

function jsonrpc_create_result_response() {
    local id="${1}"
    local result="${2}"

    if [ "${#}" -lt 2 ]; then
        log_error "requires two arguments"
        return 1
    fi

    log_debug "id: ${id}"
    log_debug "result: ${result}"

    local init_obj
    if ! init_obj=$(jsonrpc_init_json "${id}"); then
        return 1
    fi

    local result_obj
    if ! result_obj=$(jsonrpc_create_result_object "${result}"); then
        return 1
    fi

    local result_response
    if ! result_response=$(json_merge_objects "${init_obj}" "${result_obj}"); then
        return 1
    fi

    echo "${result_response}"
}

function mcbox_get_data_home() {
    local default_data_home="${XDG_DATA_HOME:-${HOME}/.local/share}"
    local data_home="${MCBOX_DATA_HOME:-${default_data_home}/mcbox}"
    log_debug "MCBOX_DATA_HOME: ${data_home}"
    echo "${data_home}"
}

function mcbox_get_config_home() {
    local default_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
    local config_home="${MCBOX_CONFIG_HOME:-${default_config_home}/mcbox}"
    log_debug "MCBOX_CONFIG_HOME: ${config_home}"
    echo "${config_home}"
}

function mcbox_get_server_config_location() {
    local config_home
    config_home=$(mcbox_get_config_home)
    local server_config_file="${MCBOX_SERVER_CONFIG_FILE:-${config_home}/server.json}"
    log_debug "MCBOX_SERVER_CONFIG_FILE: ${server_config_file}"
    echo "${server_config_file}"
}

function mcbox_get_tools_config_location() {
    local config_home
    config_home=$(mcbox_get_config_home)
    local tools_config_file="${MCBOX_TOOLS_CONFIG_FILE:-${config_home}/tools.json}"
    log_debug "MCBOX_TOOLS_CONFIG_FILE: ${tools_config_file}"
    echo "${tools_config_file}"
}

function mcbox_get_tools_lib_location() {
    local config_home
    config_home=$(mcbox_get_config_home)
    local tools_lib_file="${MCBOX_TOOLS_LIB_FILE:-${config_home}/tools.bash}"
    log_debug "MCBOX_TOOLS_LIB_FILE: ${tools_lib_file}"
    echo "${tools_lib_file}"
}

function mcbox_get_version_location() {
    local data_home
    data_home=$(mcbox_get_data_home)
    local version_file="${data_home}/version.json"
    log_debug "MCBOX_VERSION_FILE: ${version_file}"
    echo "${version_file}"
}

function mcbox_version() {
    local version="mcbox UNKNOWN Commit: UNKNOWN BuildDate: UNKNOWN"

    local version_file
    version_file=$(mcbox_get_version_location)
    if is_readable_file "${version_file}"; then
        local version_json
        if version_json=$(json_read_file "${version_file}"); then
            local semver commit build_date

            semver=$(echo "${version_json}" | jq --raw-output '.Version // "UNKNOWN"')
            commit=$(echo "${version_json}" | jq --raw-output '.Commit // "UNKNOWN"')
            build_date=$(echo "${version_json}" | jq --raw-output '.BuildDate // "UNKNOWN"')

            version="mcbox ${semver#v} Commit: ${commit} BuildDate: ${build_date}"
        else
            log_warn "failed to read version file: ${version_file}"
        fi
    else
        log_warn "failed to read version file: ${version_file}"
    fi

    echo "${version}"
}

function mcbox_load_config() {
    local server_config_file
    server_config_file=$(mcbox_get_server_config_location)

    local server_config
    if ! server_config=$(json_read_file "${server_config_file}"); then
        log_fatal "failed to load ${server_config_file}"
        return 1
    fi

    local tools_config_file
    tools_config_file=$(mcbox_get_tools_config_location)

    local tools_config
    if ! tools_config=$(json_read_file "${tools_config_file}"); then
        log_fatal "failed to load ${tools_config_file}"
        return 1
    fi

    local tools_lib_file
    tools_lib_file=$(mcbox_get_tools_lib_location)

    if ! is_readable_file "${tools_lib_file}"; then
        log_fatal "tools library file not accessible: ${tools_lib_file}"
        return 1
    fi

    export MCBOX_SERVER_CONFIG="${server_config}"
    export MCBOX_TOOLS_CONFIG="${tools_config}"

    # shellcheck disable=SC1090
    if ! source "${tools_lib_file}"; then
        log_fatal "failed to source tools library: ${tools_lib_file}"
        return 1
    fi
}

function mcbox_get_server_tag() {
    if [ -n "${MCBOX_SERVER_CONFIG}" ]; then
        local server_info server_name server_version server_tag
        server_info="$(echo "${MCBOX_SERVER_CONFIG}" | jq --compact-output --monochrome-output '.serverInfo')"
        server_name="$(echo "${server_info}" | jq --raw-output '.name')"
        server_version="$(echo "${server_info}" | jq --raw-output '.version')"
        server_tag="${server_name} ${server_version}"
    fi
    echo "${server_tag}"
}

function mcbox_config_init() {
    local input="${1:-}"

    local overwrite="false"

    if [ -n "${input}" ] && [ "${input}" == "overwrite" ]; then
        overwrite="true"
    fi

    local data_home
    data_home=$(mcbox_get_data_home)
    local defaults_dir="${data_home}/defaults"

    local config_home
    config_home=$(mcbox_get_config_home)

    local config_files=("server.json" "tools.json" "tools.bash")

    if ! [ -d "${defaults_dir}" ]; then
        echo_stderr "config defaults directory does not exist: ${defaults_dir}"
        return 1
    fi

    for file in "${config_files[@]}"; do
        local default_file="${defaults_dir}/${file}"
        if ! is_readable_file "${default_file}"; then
            echo_stderr "required default file is not accessible: ${default_file}"
            return 1
        fi
    done

    if [ ! -d "${config_home}" ]; then
        if ! mkdir -p "${config_home}"; then
            echo_stderr "failed to create config directory: ${config_home}"
            return 1
        fi
    fi

    for file in "${config_files[@]}"; do
        local default_file="${defaults_dir}/${file}"
        local config_file="${config_home}/${file}"

        if [ -f "${config_file}" ] && [ "${overwrite}" != "true" ]; then
            echo_stderr "config file already exists, skipping: ${config_file}"
            continue
        fi

        if ! cp "${default_file}" "${config_file}"; then
            echo_stderr "failed to copy ${default_file} to ${config_file}"
            return 1
        fi
    done

    echo_stderr "configuration initialized at ${config_home}"
    return 0
}

function mcp_handle_initialize() {
    local id="${1}"
    local params="${2}"

    local server_config
    server_config="${MCBOX_SERVER_CONFIG}"

    log_debug "MCBOX_SERVER_CONFIG: ${server_config}"

    if [ -z "${server_config}" ] || ! is_valid_json "${server_config}"; then
        log_error "server config is not valid; using default"
        local server_config_file
        server_config_file=$(mcbox_get_server_config_location)

        if ! server_config=$(json_read_file "${server_config_file}"); then
            log_fatal "failed to read server configuration file: ${server_config_file}"
            jsonrpc_create_error_response "${id}" -32603 "Internal error"
            return 1
        fi

        log_debug "MCBOX_SERVER_CONFIG: ${server_config}"
    fi

    local server_protocol_version client_protocol_version

    server_protocol_version=$(echo "${server_config}" | jq --raw-output '.protocolVersion')
    client_protocol_version=$(echo "${params}" | jq --raw-output '.protocolVersion')

    if [ "${server_protocol_version}" != "${client_protocol_version}" ]; then
        local error_msg="Invalid params: protocol version mismatch"
        log_error "${error_msg}: server=${server_protocol_version}, client=${client_protocol_version}"
        jsonrpc_create_error_response "${id}" -32602 "${error_msg}" '{"server_protocol_version":"'"${server_protocol_version}"'","client_protocol_version":"'"${client_protocol_version}"'"}'
        return 1
    fi

    jsonrpc_create_result_response "${id}" "${server_config}"
}

function mcp_handle_notification() {
    local method="${1}"
    log_debug "${method}"

    case "${method}" in
    "notifications/initialized")
        log_info "initialized"
        return 0
        ;;
    ## Add other notification types here
    ## "notifications/TODO")
    ## return 0
    *)
        return 1 # Not a notification
        ;;
    esac
}

function mcp_handle_tools_list() {
    local id="${1}"

    local tools_config
    tools_config="${MCBOX_TOOLS_CONFIG}"
    log_debug "MCBOX_TOOLS_CONFIG: ${tools_config}"

    if [ -z "${tools_config}" ] || ! is_valid_json "${tools_config}"; then
        log_error "tools config is not valid; using default"
        local tools_config_file
        tools_config_file=$(mcbox_get_tools_config_location)

        if ! tools_config=$(json_read_file "${tools_config_file}"); then
            log_fatal "failed to read tools configuration file: ${tools_config_file}"
            jsonrpc_create_error_response "${id}" -32603 "Internal error"
            return 1
        fi

        log_debug "MCBOX_TOOLS_CONFIG: ${tools_config}"
    fi

    if ! jsonschema_validate_schema "${tools_config}" "${TOOLS_SCHEMA}"; then
        log_fatal "tools config failed schema validation"
        jsonrpc_create_error_response "${id}" -32603 "Internal error"
        return 1
    fi

    jsonrpc_create_result_response "${id}" "${tools_config}"
}

function mcp_handle_ping() {
    local id="${1}"
    log_info "ping id: ${1}"

    jsonrpc_create_result_response "${id}" "{}"
}

function mcp_create_text_content_object() {
    local content="${1}"
    log_debug "${content}"

    local stringified_content
    stringified_content=$(echo "${content}" | text_trim | jq --raw-input --slurp '.')

    local content_object
    content_object='
    {
        "content": [
            {
                "type": "text",
                "text": '${stringified_content}'
            }
        ]
    }'

    echo "${content_object}" | jq --compact-output --monochrome-output '.'
}

function mcp_handle_tool_call() {
    local id="${1}"
    local params="${2}"

    local tools_config
    tools_config="${MCBOX_TOOLS_CONFIG}"

    log_debug "MCBOX_TOOLS_CONFIG: ${tools_config}"
    log_debug "id: ${id}"
    log_debug "tool call parameters: ${params}"

    if [ -z "${tools_config}" ] || ! is_valid_json "${tools_config}"; then
        log_error "tools config is not valid; using default"
        local tools_config_file
        tools_config_file=$(mcbox_get_tools_config_location)

        if ! tools_config=$(json_read_file "${tools_config_file}"); then
            log_fatal "failed to read tools configuration file: ${tools_config_file}"
            jsonrpc_create_error_response "${id}" -32603 "Internal error"
            return 1
        fi

        log_debug "MCBOX_TOOLS_CONFIG: ${tools_config}"
    fi

    if ! jsonschema_validate_schema "${tools_config}" "${TOOLS_SCHEMA}"; then
        log_fatal "failed to validate tools config"
        jsonrpc_create_error_response "${id}" -32603 "Internal error"
        return 1
    fi

    if ! is_valid_json "${params}"; then
        log_error "tool call parameters are not valid JSON"
        jsonrpc_create_error_response "${id}" -32700 "Parse error"
        return 0
    fi

    if ! json_object_has_key "${params}" "name"; then
        local error_message="tool call parameters missing required 'name' property"
        log_error "${error_message}"
        jsonrpc_create_error_response "${id}" -32602 "Invalid params: ${error_message}"
        return 0
    fi

    local tool_name
    tool_name=$(echo "${params}" | jq --raw-output '.name')

    if ! [[ "${tool_name}" =~ ^[a-zA-Z0-9_]+$ ]]; then
        local error_message="tool name is malformed"
        log_error "${error_message}: ${tool_name}"
        jsonrpc_create_error_response "${id}" -32602 "Invalid params: ${error_message}"
        return 0
    fi

    if ! echo "${tools_config}" | jq --exit-status --arg name "${tool_name}" '.tools | any(.name == $name)' >/dev/null 2>&1; then
        local error_message="tool not found"
        log_error "${error_message}: ${tool_name}"
        jsonrpc_create_error_response "${id}" -32602 "Invalid params: ${error_message}"
        return 0
    fi

    local input_schema
    input_schema=$(echo "${tools_config}" | jq --arg tool_name "${tool_name}" '.tools[] | select(.name == $tool_name) | .inputSchema // null')

    if [ "${input_schema}" == "null" ]; then
        log_fatal "input schema is not defined for tool: ${tool_name}"
        jsonrpc_create_error_response "${id}" -32603 "Internal error"
        return 1
    fi

    local arguments
    arguments=$(echo "${params}" | jq '.arguments // {}')

    if ! jsonschema_validate_schema "${arguments}" "${input_schema}"; then
        local error_message="tool arguments do not match inputSchema"
        log_debug "tool arguments: ${arguments}"
        log_debug "tool input schema: ${input_schema}"
        log_error "${error_message}"
        jsonrpc_create_error_response "${id}" -32602 "Invalid params: ${error_message}"
        return 0
    fi

    local tool_name_prefix tool content mcp_result

    tool_name_prefix="${MCBOX_TOOLS_FUNCTION_NAME_PREFIX:-tool_}"
    tool="${tool_name_prefix}${tool_name}"

    if is_cmd_available "${tool}"; then
        if ! content=$(${tool} "${arguments}"); then
            local error_message="tool execution failed"
            if [ -n "${content}" ] && [ "${content}" != "null" ]; then
                error_message="${error_message}: ${content}"
            fi

            if ! mcp_result=$(mcp_create_text_content_object "${content}"); then
                log_fatal "${error_message}"
                jsonrpc_create_error_response "${id}" -32603 "Internal error"
                return 1
            fi

            if ! mcp_result=$(json_merge_objects "${mcp_result}" '{"isError":true}'); then
                log_fatal "${error_message}"
                jsonrpc_create_error_response "${id}" -32603 "Internal error"
                return 1
            fi

            log_error "${error_message}"
            jsonrpc_create_result_response "${id}" "${mcp_result}"
            return 0
        fi
        log_debug "tool result: ${content}"
    else
        log_fatal "tool not available: ${tool_name}"
        jsonrpc_create_error_response "${id}" -32603 "Internal error"
        return 1
    fi

    if ! mcp_result=$(mcp_create_text_content_object "${content}"); then
        log_fatal "failed to format content"
        jsonrpc_create_error_response "${id}" -32603 "Internal error"
        return 1
    fi

    local output_schema
    output_schema=$(echo "${tools_config}" | jq --arg tool_name "${tool_name}" '.tools[] | select(.name == $tool_name) | .outputSchema // null')

    if [ "${output_schema}" != "null" ]; then
        log_debug "tool output schema: ${output_schema}"

        if ! jsonschema_validate_schema "${content}" "${output_schema}"; then
            local error_message="tool output does not match outputSchema"
            log_error "${error_message}"
            jsonrpc_create_error_response "${id}" -32603 "Internal error: ${error_message}"
            return 0
        fi

        if ! mcp_result=$(json_merge_objects "${mcp_result}" '{"structuredContent":'"${content}"'}'); then
            log_fatal "failed to format content"
            jsonrpc_create_error_response "${id}" -32603 "Internal error"
            return 1
        fi
    fi

    jsonrpc_create_result_response "${id}" "${mcp_result}"
}

function mcp_process_request() {
    local input="${1}"
    local id="null" # Default value for malformed requests

    # Ignore empty messages
    if [ -z "${input}" ]; then
        log_debug "empty request received"
        return 0
    fi

    log_debug "${input}"

    if ! is_valid_json "${input}"; then
        log_error "received invalid JSON in request"
        jsonrpc_create_error_response "${id}" -32700 "Parse error"
        return 0
    fi

    local jsonrpc
    jsonrpc=$(echo "${input}" | jq --raw-output '.jsonrpc')

    if [ "${jsonrpc}" != "2.0" ]; then
        log_error "not a valid JSON RPC 2.0 request"
        jsonrpc_create_error_response "${id}" -32600 "Invalid request"
        return 0
    fi

    # Extract id after validating JSON
    id=$(echo "${input}" | jq --compact-output --monochrome-output '.id // null')

    if ! jsonrpc_validate_id "${id}"; then
        local error_message="invalid id"
        log_debug "${error_message}: ${id}"
        jsonrpc_create_error_response "${id}" -32600 "Invalid request: ${error_message}"
        return 0
    fi

    if ! json_object_has_key "${input}" "method"; then
        local error_message="missing required 'method' property"
        log_error "request ${error_message}"
        jsonrpc_create_error_response "${id}" -32600 "Invalid request: ${error_message}"
        return 0
    fi

    local method
    method=$(echo "${input}" | jq --raw-output '.method')

    log_debug "MCP method: ${method}"

    if mcp_handle_notification "${method}"; then
        return 0
    fi

    local params result

    params=$(echo "${input}" | jq --compact-output --monochrome-output '.params')

    case "${method}" in
    "initialize")
        mcp_handle_initialize "${id}" "${params}"
        return 0
        ;;
    "tools/list")
        mcp_handle_tools_list "${id}"
        return 0
        ;;
    "tools/call")
        mcp_handle_tool_call "${id}" "${params}"
        return 0
        ;;
    "ping")
        mcp_handle_ping "${id}"
        return 0
        ;;
    *)
        log_error "method not found: ${method}"
        jsonrpc_create_error_response "${id}" -32601 "Method not found: ${method}"
        return 0
        ;;
    esac
}

function mcp_server() {
    if ! mcbox_check_dependencies; then
        return 1
    fi

    if ! mcbox_load_config; then
        return 1
    fi

    local server_tag
    server_tag=$(mcbox_get_server_tag)
    server_tag=": ${server_tag}"

    log_info "MCP Server${server_tag}: started"

    while IFS= read -r request; do
        mcp_process_request "${request}"
    done
}
