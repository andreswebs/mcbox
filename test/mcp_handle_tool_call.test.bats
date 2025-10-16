#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

setup() {

    export MCBOX_LOG_LEVEL="trace"

    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_TMPDIR}/test-tools.json"

    cat >"${MCBOX_TOOLS_CONFIG_FILE}" <<'EOF'
{
  "tools": [
    {
      "name": "test_tool",
      "description": "Test tool",
      "inputSchema": {
        "type": "object",
        "properties": {
          "message": {
            "type": "string"
          },
          "count": {
            "type": "integer"
          }
        },
        "required": ["message"]
      }
    },
    {
      "name": "simple_tool",
      "description": "Simple tool with no parameters",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    },
    {
      "name": "complex_tool",
      "description": "Complex tool with input parameters and structured output",
      "inputSchema": {
        "type": "object",
        "properties": {
          "token": {
            "type": "string"
          }
        },
        "required": ["token"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "token": {
            "type": "string"
          }
        },
        "required": ["token"]
      }
    },
    {
      "name": "complex_tool_invalid_output",
      "description": "Complex tool that produces invalid output",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "token": {
            "type": "string"
          }
        },
        "required": ["token"]
      }
    },
    {
      "name": "failing_tool",
      "description": "Tool that fails",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    }
  ]
}
EOF

    # shellcheck disable=SC2329
    function tool_test_tool() {
        local arguments="${1}"
        local message
        message=$(echo "${arguments}" | jq --raw-output '.message')
        echo "Tool executed with message: ${message}"
    }

    # shellcheck disable=SC2329
    function tool_simple_tool() {
        echo "Simple tool executed"
    }

    # shellcheck disable=SC2329
    function tool_complex_tool() {
        local arguments="${1}"
        local token
        token=$(echo "${arguments}" | jq --raw-output '.token')
        jq --compact-output --null-input --arg token "${token}" '{"token": $token}'
    }

    # shellcheck disable=SC2329
    function tool_complex_tool_invalid_output() {
        echo '{"invalid_field":"value"}'
    }

    # shellcheck disable=SC2329
    function tool_failing_tool() {
        echo "fail!" >&2
        return 1
    }

    export -f tool_test_tool tool_simple_tool tool_complex_tool tool_complex_tool_invalid_output tool_failing_tool
}

teardown() {
    unset MCBOX_TOOLS_CONFIG_FILE
    unset -f tool_test_tool tool_simple_tool tool_complex_tool tool_complex_tool_invalid_output tool_failing_tool 2>/dev/null || true
}

@test "mcp_handle_tool_call: should handle valid tool call with required parameters" {
    local id="1"
    local params='{"name": "test_tool", "arguments": {"message": "this is a test"}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":1'
    assert_output --partial '"result":'
    assert_output --partial '"content":'
    assert_output --partial '"type":"text"'
    assert_output --partial '"text":"Tool executed with message: this is a test"'
}

@test "mcp_handle_tool_call: should handle tool call with optional parameters" {
    local id="2"
    local params='{"name": "test_tool", "arguments": {"message": "this is a test", "count": 5}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    assert_output --partial '"text":"Tool executed with message: this is a test"'
}

@test "mcp_handle_tool_call: should handle tool call with no parameters" {
    local id="3"
    local params='{"name": "simple_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    assert_output --partial '"text":"Simple tool executed"'
}

@test "mcp_handle_tool_call: should handle tool call with missing arguments field" {
    local id="4"
    local params='{"name": "simple_tool"}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
}

@test "mcp_handle_tool_call: should handle tool call with malformed tool name - special characters" {
    local id="5"
    local params='{"name": "test-tool!", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool name is malformed"'
}

@test "mcp_handle_tool_call: should handle tool call with malformed tool name - spaces" {
    local id="6"
    local params='{"name": "test tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool name is malformed"'
}

@test "mcp_handle_tool_call: should handle tool call with empty tool name" {
    local id="7"
    local params='{"name": "", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool name is malformed"'
}

@test "mcp_handle_tool_call: should fail when tools config file does not exist" {
    local id="8"
    local params='{"name": "test_tool", "arguments": {"message": "hello"}}'

    # shellcheck disable=SC2030
    export MCBOX_TOOLS_CONFIG_FILE="${BATS_TEST_TMPDIR}/nonexistent.json"

    run mcp_handle_tool_call "${id}" "${params}"
    assert_failure
    assert_output --partial '"code":-32603'
    assert_output --partial '"message":"Internal error"'
}

@test "mcp_handle_tool_call: should fail when tools config file contains invalid JSON" {
    local id="9"
    local params='{"name": "test_tool", "arguments": {"message": "hello"}}'

    # shellcheck disable=SC2031
    echo "{ invalid json }" >"${MCBOX_TOOLS_CONFIG_FILE}"

    run mcp_handle_tool_call "${id}" "${params}"
    assert_failure
    assert_output --partial '"code":-32603'
    assert_output --partial '"message":"Internal error"'
}

@test "mcp_handle_tool_call: should handle tool call when tool is not found in config" {
    local id="10"
    local params='{"name": "nonexistent_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool not found"'
}

@test "mcp_handle_tool_call: should handle tool call when required argument is missing" {
    local id="11"
    local params='{"name": "test_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool arguments do not match inputSchema"'
}

@test "mcp_handle_tool_call: should handle tool call when argument type is wrong" {
    local id="12"
    local params='{"name": "test_tool", "arguments": {"message": 123}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool arguments do not match inputSchema"'
}

@test "mcp_handle_tool_call: should fail when tool function does not exist" {
    local id="13"
    local params='{"name": "test_tool", "arguments": {"message": "hello"}}'

    # Unset the tool function
    unset -f tool_test_tool

    run mcp_handle_tool_call "${id}" "${params}"
    assert_failure
    assert_output --partial '"code":-32603'
    assert_output --partial '"message":"Internal error"'
}

@test "mcp_handle_tool_call: should handle tool call when tool function returns error" {
    local id="14"
    local params='{"name": "failing_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"isError":true'
}

@test "mcp_handle_tool_call: should handle string ID correctly" {
    local id='"string-id"'
    local params='{"name": "simple_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"id":"string-id"'
}

@test "mcp_handle_tool_call: should handle null ID correctly" {
    local id="null"
    local params='{"name": "simple_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"id":null'
}

@test "mcp_handle_tool_call: should handle integer ID correctly" {
    local id="42"
    local params='{"name": "simple_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"id":42'
}

@test "mcp_handle_tool_call: should handle tool call with special characters in output" {
    local id="15"
    local params='{"name": "test_tool", "arguments": {"message": "hello \"world\" with \n newlines"}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    # Should properly escape special characters in JSON
    assert_output --partial '"text":"Tool executed with message: hello \"world\" with \n newlines"'
}

@test "mcp_handle_tool_call: should handle tool call with invalid JSON params" {
    local id="16"
    local params='invalid json'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32700'
    assert_output --partial '"message":"Parse error"'
}

@test "mcp_handle_tool_call: should handle tool call when params missing 'name' field" {
    local id="17"
    local params='{"arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
}

@test "mcp_handle_tool_call: should handle unknown arguments gracefully" {
    local id="18"
    local params='{"name": "simple_tool", "arguments": {"unknown_param": "value"}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool arguments do not match inputSchema"'
}

@test "mcp_handle_tool_call: should handle complex tool with valid structured output" {
    local id="19"
    local params='{"name": "complex_tool", "arguments": {"token": "test-token-123"}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"jsonrpc":"2.0"'
    assert_output --partial '"id":19'
    assert_output --partial '"result":'
    assert_output --partial '"content":'
    assert_output --partial '"type":"text"'
    assert_output --partial '"text":"{\"token\":\"test-token-123\"}"'
    assert_output --partial '"structuredContent":{"token":"test-token-123"}'
}

@test "mcp_handle_tool_call: should handle complex tool with missing required argument" {
    local id="20"
    local params='{"name": "complex_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool arguments do not match inputSchema"'
}

@test "mcp_handle_tool_call: should handle complex tool with invalid argument type" {
    local id="21"
    local params='{"name": "complex_tool", "arguments": {"token": 12345}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32602'
    assert_output --partial '"message":"Invalid params: tool arguments do not match inputSchema"'
}

@test "mcp_handle_tool_call: should fail when tool output does not match outputSchema" {
    local id="22"
    local params='{"name": "complex_tool_invalid_output", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"error":'
    assert_output --partial '"code":-32603'
    assert_output --partial '"message":"Internal error: tool output does not match outputSchema"'
}

@test "mcp_handle_tool_call: should handle complex tool with special characters in token" {
    local id="23"
    local params='{"name": "complex_tool", "arguments": {"token": "test-token-with-\"quotes\"-and-\\backslashes"}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    assert_output --partial '"structuredContent":'
    assert_output --partial '"token":"test-token-with-\"quotes\"-and-\\backslashes"'
}

@test "mcp_handle_tool_call: should handle complex tool with empty token" {
    local id="24"
    local params='{"name": "complex_tool", "arguments": {"token": ""}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '"result":'
    assert_output --partial '"structuredContent":{"token":""}'
}

@test "mcp_handle_tool_call: logs tool output with log_debug" {
    local id="25"
    local params='{"name": "failing_tool", "arguments": {}}'

    run mcp_handle_tool_call "${id}" "${params}"
    assert_success
    assert_output --partial '[mcp_handle_tool_call] fail!'
}
