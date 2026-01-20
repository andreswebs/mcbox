#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    export MCBOX_SERVER_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.server.json"
}

teardown() {
    unset MCBOX_SERVER_CONFIG_FILE
}

@test "mcp_handle_initialize: should handle valid initialize request with matching protocol version" {
    local id="0"
    local params='{"protocolVersion": "2025-11-25"}'

    run mcp_handle_initialize "${id}" "${params}"
    assert_success
}

@test "mcp_handle_initialize: should fail with protocol version mismatch" {
    local id="0"
    local params='{"protocolVersion": "2024-11-05"}'

    run mcp_handle_initialize "${id}" "${params}"
    assert_failure
}

@test "mcp_handle_initialize: should fail when server config file does not exist" {
    local id="0"
    local params='{"protocolVersion": "2025-11-25"}'

    # shellcheck disable=SC2030
    export MCBOX_SERVER_CONFIG_FILE="${BATS_TEST_TMPDIR}/inexistent.json"

    run mcp_handle_initialize "${id}" "${params}"
    assert_failure
}

@test "mcp_handle_initialize: should fail when server config file contains invalid JSON" {
    local id="0"
    local params='{"protocolVersion": "2025-11-25"}'

    local invalid_config_file="${BATS_TEST_TMPDIR}/invalid.json"
    echo "{ invalid json }" >"${invalid_config_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_SERVER_CONFIG_FILE="${invalid_config_file}"

    run mcp_handle_initialize "${id}" "${params}"
    assert_failure
}

@test "mcp_handle_initialize: should handle string ID correctly" {
    local id='"test-id"'
    local params='{"protocolVersion": "2025-11-25"}'

    run mcp_handle_initialize "${id}" "${params}"
    assert_success
    assert_output --partial '"id":"test-id"'
}

@test "mcp_handle_initialize: should handle null ID correctly" {
    local id="null"
    local params='{"protocolVersion": "2025-11-25"}'

    run mcp_handle_initialize "${id}" "${params}"
    assert_success
    assert_output --partial '"id":null'
}

@test "mcp_handle_initialize: should fail when params is missing protocolVersion" {
    local id="0"
    local params='{}'

    run mcp_handle_initialize "${id}" "${params}"
    assert_failure
}

@test "mcp_handle_initialize: should fail when params is invalid JSON" {
    local id="0"
    local params='{ invalid }'

    run mcp_handle_initialize "${id}" "${params}"
    assert_failure
}

@test "mcp_handle_initialize: should use default config file path when MCBOX_SERVER_CONFIG_FILE is not set" {
    local id="0"
    local params='{"protocolVersion": "2025-11-25"}'

    # Create config in default location (XDG_CONFIG_HOME)
    export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}"
    mkdir -p "${XDG_CONFIG_HOME}/mcbox"

    local default_config_file
    default_config_file="${XDG_CONFIG_HOME}/mcbox/server.json"

    # shellcheck disable=SC2031
    cat "${MCBOX_SERVER_CONFIG_FILE}" >"${default_config_file}"

    unset MCBOX_SERVER_CONFIG_FILE

    run mcp_handle_initialize "${id}" "${params}"

    rm "${default_config_file}"

    assert_success
}
