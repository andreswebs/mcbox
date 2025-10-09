#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.tools.json"
}

teardown() {
    unset MCBOX_TOOLS_CONFIG_FILE
}

@test "mcp_handle_tools_list: should handle valid tools list request" {
    local id="0"

    run mcp_handle_tools_list "${id}"
    assert_success
}

@test "mcp_handle_tools_list: should fail when tools config file does not exist" {
    local id="0"

    # shellcheck disable=SC2030
    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_TMPDIR}/inexistent.json"

    run mcp_handle_tools_list "${id}"
    assert_failure
}

@test "mcp_handle_tools_list: should fail when tools config file contains invalid JSON" {
    local id="0"

    local invalid_tools_file="${BATS_TEST_TMPDIR}/invalid.json"
    echo "{ invalid json }" >"${invalid_tools_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_TOOLS_CONFIG_FILE="${invalid_tools_file}"

    run mcp_handle_tools_list "${id}"
    assert_failure
}

@test "mcp_handle_tools_list: should handle string ID correctly" {
    local id='"test-id"'

    run mcp_handle_tools_list "${id}"
    assert_success
    assert_output --partial '"id":"test-id"'
}

@test "mcp_handle_tools_list: should handle null ID correctly" {
    local id="null"

    run mcp_handle_tools_list "${id}"
    assert_success
    assert_output --partial '"id":null'
}

@test "mcp_handle_tools_list: should use default tools file path when MCBOX_TOOLS_CONFIG_FILE is not set" {
    local id="0"

    # Create tools config in current directory (default location)
    # Create config in default location (XDG_CONFIG_HOME)
    export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}"
    mkdir -p "${XDG_CONFIG_HOME}/mcbox"

    local default_tools_file
    default_tools_file="${XDG_CONFIG_HOME}/mcbox/tools.json"

    # shellcheck disable=SC2031
    cat "${MCBOX_TOOLS_CONFIG_FILE}" >"${default_tools_file}"

    unset MCBOX_TOOLS_CONFIG_FILE

    run mcp_handle_tools_list "${id}"

    rm "${default_tools_file}"

    assert_success
}

@test "mcp_handle_tools_list: should return JSON-RPC result response with tools array" {
    local id="0"

    run mcp_handle_tools_list "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"result":'
    assert_output --partial '"tools":'
}

@test "mcp_handle_tools_list: should return tools with correct structure" {
    local id="0"

    run mcp_handle_tools_list "${id}"
    assert_success
    assert_output --partial '"name":"smoketest"'
    assert_output --partial '"description":"Confirm that simple tool calling works"'
    assert_output --partial '"inputSchema":'
}

@test "mcp_handle_tools_list: should handle empty tools file" {
    local id="0"
    local empty_tools_file="${BATS_TEST_TMPDIR}/empty.json"
    echo '{"tools":[]}' >"${empty_tools_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_TOOLS_CONFIG_FILE="${empty_tools_file}"

    run mcp_handle_tools_list "${id}"
    assert_success
    assert_output --partial '"tools":[]'
}

@test "mcp_handle_tools_list: should fail with malformed tools schema" {
    local id="0"
    local malformed_tools_file="${BATS_TEST_TMPDIR}/malformed.json"
    echo '{"not_tools": "invalid"}' >"${malformed_tools_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_TOOLS_CONFIG_FILE="${malformed_tools_file}"

    run mcp_handle_tools_list "${id}"
    assert_failure
}
