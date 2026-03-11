#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    export MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.prompts.json"
}

teardown() {
    unset MCBOX_PROMPTS_CONFIG_FILE
    unset MCBOX_PROMPTS_CONFIG
    unset MCBOX_PROMPTS_PAGE_SIZE
}

@test "mcp_handle_prompts_list: should handle valid prompts list request" {
    local id="0"

    run mcp_handle_prompts_list "${id}"
    assert_success
}

@test "mcp_handle_prompts_list: should return JSON-RPC result response with prompts array" {
    local id="0"

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"result":'
    assert_output --partial '"prompts":'
}

@test "mcp_handle_prompts_list: should return prompts with correct structure" {
    local id="0"

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"name":"greet"'
    assert_output --partial '"description":"Generate a greeting message"'
}

@test "mcp_handle_prompts_list: should handle string ID correctly" {
    local id='"test-id"'

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"id":"test-id"'
}

@test "mcp_handle_prompts_list: should handle null ID correctly" {
    local id="null"

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"id":null'
}

@test "mcp_handle_prompts_list: should handle empty prompts config" {
    local id="0"
    local empty_prompts_file="${BATS_TEST_TMPDIR}/empty.json"
    echo '{"prompts":[]}' >"${empty_prompts_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG_FILE="${empty_prompts_file}"

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"prompts":[]'
}

@test "mcp_handle_prompts_list: should fail when prompts config file does not exist" {
    local id="0"

    # shellcheck disable=SC2030
    export MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_TMPDIR}/inexistent.json"

    run mcp_handle_prompts_list "${id}"
    assert_failure
}

@test "mcp_handle_prompts_list: should fail when prompts config has invalid JSON" {
    local id="0"

    local invalid_prompts_file="${BATS_TEST_TMPDIR}/invalid.json"
    echo "{ invalid json }" >"${invalid_prompts_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG_FILE="${invalid_prompts_file}"

    run mcp_handle_prompts_list "${id}"
    assert_failure
}

@test "mcp_handle_prompts_list: should fail with malformed prompts schema" {
    local id="0"
    local malformed_prompts_file="${BATS_TEST_TMPDIR}/malformed.json"
    echo '{"not_prompts": "invalid"}' >"${malformed_prompts_file}"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG_FILE="${malformed_prompts_file}"

    run mcp_handle_prompts_list "${id}"
    assert_failure
}

@test "mcp_handle_prompts_list: should return prompt with all optional fields" {
    local id="0"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG='{"prompts":[{"name":"full","title":"Full Prompt","description":"Has all fields","arguments":[{"name":"arg","description":"An argument","required":true}]}]}'

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"name":"full"'
    assert_output --partial '"title":"Full Prompt"'
    assert_output --partial '"description":"Has all fields"'
    assert_output --partial '"arguments":'
}

@test "mcp_handle_prompts_list: should return prompt with only required name field" {
    local id="0"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG='{"prompts":[{"name":"minimal"}]}'

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"name":"minimal"'
}

@test "mcp_handle_prompts_list: should return empty prompts when cursor is beyond array length" {
    local id="0"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG='{"prompts":[{"name":"only"}]}'
    export MCBOX_PROMPTS_PAGE_SIZE=1

    local beyond_cursor
    beyond_cursor=$(printf '99' | base64)

    run mcp_handle_prompts_list "${id}" "{\"cursor\":\"${beyond_cursor}\"}"
    assert_success
    assert_output --partial '"prompts":[]'
    refute_output --partial '"nextCursor"'
}

@test "mcp_handle_prompts_list: should use MCBOX_PROMPTS_CONFIG env var when set" {
    local id="0"

    # shellcheck disable=SC2030,SC2031
    export MCBOX_PROMPTS_CONFIG='{"prompts":[{"name":"env-prompt","description":"From env"}]}'

    run mcp_handle_prompts_list "${id}"
    assert_success
    assert_output --partial '"name":"env-prompt"'
}

@test "mcp_handle_prompts_list: should return all prompts and no nextCursor when MCBOX_PROMPTS_PAGE_SIZE is unset" {
    local id="0"

    unset MCBOX_PROMPTS_PAGE_SIZE

    run mcp_handle_prompts_list "${id}" '{}'
    assert_success
    assert_output --partial '"prompts":'
    refute_output --partial '"nextCursor"'
}

@test "mcp_handle_prompts_list: should return first page and nextCursor with MCBOX_PROMPTS_PAGE_SIZE=1" {
    local id="0"

    export MCBOX_PROMPTS_PAGE_SIZE=1

    run mcp_handle_prompts_list "${id}" '{}'
    assert_success
    assert_output --partial '"nextCursor"'
}

@test "mcp_handle_prompts_list: should return only one prompt on first page with MCBOX_PROMPTS_PAGE_SIZE=1" {
    local id="0"

    export MCBOX_PROMPTS_PAGE_SIZE=1

    run mcp_handle_prompts_list "${id}" '{}'
    assert_success
    assert_output --partial '"name":"greet"'
    refute_output --partial '"name":"farewell"'
}

@test "mcp_handle_prompts_list: should return second page with different prompt when cursor provided" {
    local id="0"

    export MCBOX_PROMPTS_PAGE_SIZE=1

    local first_page
    first_page=$(MCBOX_PROMPTS_PAGE_SIZE=1 MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.prompts.json" mcp_handle_prompts_list "${id}" '{}' 2>/dev/null)
    local cursor
    cursor=$(echo "${first_page}" | jq --raw-output '.result.nextCursor')

    run mcp_handle_prompts_list "${id}" "{\"cursor\":\"${cursor}\"}"
    assert_success
    assert_output --partial '"name":"farewell"'
    refute_output --partial '"name":"greet"'
}

@test "mcp_handle_prompts_list: should return no nextCursor on last page" {
    local id="0"

    export MCBOX_PROMPTS_PAGE_SIZE=1

    local first_page
    first_page=$(MCBOX_PROMPTS_PAGE_SIZE=1 MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_DIRNAME}/fixtures/smoketest.prompts.json" mcp_handle_prompts_list "${id}" '{}' 2>/dev/null)
    local cursor
    cursor=$(echo "${first_page}" | jq --raw-output '.result.nextCursor')

    run mcp_handle_prompts_list "${id}" "{\"cursor\":\"${cursor}\"}"
    assert_success
    refute_output --partial '"nextCursor"'
}

@test "mcp_handle_prompts_list: should treat invalid cursor as offset 0" {
    local id="0"

    export MCBOX_PROMPTS_PAGE_SIZE=1

    run mcp_handle_prompts_list "${id}" '{"cursor":"not-valid-base64!!!"}'
    assert_success
    assert_output --partial '"name":"greet"'
    refute_output --partial '"name":"farewell"'
}

@test "mcp_handle_prompts_list: should use default prompts file path when MCBOX_PROMPTS_CONFIG_FILE is not set" {
    local id="0"

    export XDG_CONFIG_HOME="${BATS_TEST_TMPDIR}"
    mkdir --parents "${XDG_CONFIG_HOME}/mcbox"

    local default_prompts_file
    default_prompts_file="${XDG_CONFIG_HOME}/mcbox/prompts.json"

    # shellcheck disable=SC2031
    cat "${MCBOX_PROMPTS_CONFIG_FILE}" >"${default_prompts_file}"

    unset MCBOX_PROMPTS_CONFIG_FILE

    run mcp_handle_prompts_list "${id}"

    rm "${default_prompts_file}"

    assert_success
}
