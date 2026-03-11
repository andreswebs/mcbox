#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {
    export MCBOX_PROMPTS_CONFIG_FILE="${BATS_TEST_TMPDIR}/test-prompts.json"

    cat >"${MCBOX_PROMPTS_CONFIG_FILE}" <<'EOF'
{
  "prompts": [
    {
      "name": "greet",
      "description": "Generate a greeting message",
      "arguments": [
        {
          "name": "name",
          "description": "The name to greet",
          "required": true
        },
        {
          "name": "style",
          "description": "Greeting style",
          "required": false
        }
      ]
    },
    {
      "name": "no-args",
      "description": "Prompt with no arguments"
    },
    {
      "name": "read.file",
      "description": "Prompt with dot-separated name",
      "arguments": []
    }
  ]
}
EOF

    # shellcheck disable=SC2329
    function prompt_greet() {
        local arguments="${1}"
        local name
        name=$(echo "${arguments}" | jq --raw-output '.name')
        echo '{"messages":[{"role":"user","content":{"type":"text","text":"Hello '"${name}"'"}}]}'
    }

    # shellcheck disable=SC2329
    function prompt_no_args() {
        echo '{"messages":[{"role":"user","content":{"type":"text","text":"No args prompt"}}]}'
    }

    # shellcheck disable=SC2329
    function prompt_read_file() {
        echo '{"messages":[{"role":"user","content":{"type":"text","text":"read.file prompt"}}]}'
    }

    export -f prompt_greet prompt_no_args prompt_read_file
}

teardown() {
    unset MCBOX_PROMPTS_CONFIG_FILE
    unset MCBOX_PROMPTS_CONFIG
    unset MCBOX_PROMPTS_FUNCTION_NAME_PREFIX
    unset -f prompt_greet prompt_no_args prompt_read_file 2>/dev/null || true
}

@test "mcp_handle_prompts_get: should handle valid prompts/get request" {
    local id="1"
    local params='{"name":"greet","arguments":{"name":"World"}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":1'
    assert_output --partial '"result":'
    assert_output --partial '"messages":'
}

@test "mcp_handle_prompts_get: should return -32602 when name is missing from params" {
    local id="2"
    local params='{}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32602'
}

@test "mcp_handle_prompts_get: should return -32602 for invalid prompt name format" {
    local id="3"
    local params='{"name":"bad name!","arguments":{}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'malformed'
}

@test "mcp_handle_prompts_get: should return -32602 when prompt is not found" {
    local id="4"
    local params='{"name":"nonexistent","arguments":{}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'not found'
}

@test "mcp_handle_prompts_get: should return -32602 when required argument is missing" {
    local id="5"
    local params='{"name":"greet","arguments":{}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'name'
}

@test "mcp_handle_prompts_get: should return -32602 for unknown argument" {
    local id="6"
    local params='{"name":"greet","arguments":{"name":"World","unknown":"extra"}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'unknown'
}

@test "mcp_handle_prompts_get: should call function with arguments and return messages" {
    local id="7"
    local params='{"name":"greet","arguments":{"name":"Alice"}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    assert_output --partial '"messages":'
    assert_output --partial 'Hello Alice'
}

@test "mcp_handle_prompts_get: should translate hyphens and dots in name to underscores for function" {
    local id="8"
    local params='{"name":"read.file","arguments":{}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"messages":'
    assert_output --partial 'read.file prompt'
}

@test "mcp_handle_prompts_get: should handle prompt with no arguments defined" {
    local id="9"
    local params='{"name":"no-args","arguments":{}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"messages":'
}

@test "mcp_handle_prompts_get: should use MCBOX_PROMPTS_FUNCTION_NAME_PREFIX override" {
    export MCBOX_PROMPTS_FUNCTION_NAME_PREFIX="custom_prompt_"

    # shellcheck disable=SC2329
    function custom_prompt_greet() {
        local arguments="${1}"
        local name
        name=$(echo "${arguments}" | jq --raw-output '.name')
        echo '{"messages":[{"role":"user","content":{"type":"text","text":"Custom '"${name}"'"}}]}'
    }
    export -f custom_prompt_greet

    local id="10"
    local params='{"name":"greet","arguments":{"name":"Bob"}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial 'Custom Bob'

    unset -f custom_prompt_greet
}

@test "mcp_handle_prompts_get: should return -32603 when prompt function is not defined" {
    local id="11"
    local params='{"name":"greet","arguments":{"name":"World"}}'

    unset -f prompt_greet

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_failure
    assert_output --partial '"code":-32603'
}

@test "mcp_handle_prompts_get: should return -32602 when arguments is not an object" {
    local id="12"
    local params='{"name":"no-args","arguments":"not-an-object"}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'arguments must be a JSON object'
}

@test "mcp_handle_prompts_get: should return -32602 when arguments is an array" {
    local id="13"
    local params='{"name":"no-args","arguments":["a","b"]}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial 'arguments must be a JSON object'
}

@test "mcp_handle_prompts_get: should return -32602 for non-string argument value" {
    local id="14"
    local params='{"name":"greet","arguments":{"name":42}}'

    run mcp_handle_prompts_get "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
}
