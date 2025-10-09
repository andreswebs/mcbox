#!/usr/bin/env bats

load '../mcbox-core.bash'

load "bats-helpers/bats-support/load"
load "bats-helpers/bats-assert/load"

# Test successful cases - the function now treats ALL input as raw text

@test "mcp_create_text_content_object: creates text content object with simple string" {
    run mcp_create_text_content_object 'hello world'
    assert_success
    assert_output '{"content":[{"type":"text","text":"hello world"}]}'
}

@test "mcp_create_text_content_object: creates text content object with empty string" {
    run mcp_create_text_content_object ''
    assert_success
    assert_output '{"content":[{"type":"text","text":""}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing quotes" {
    run mcp_create_text_content_object 'hello "world"'
    assert_success
    assert_output '{"content":[{"type":"text","text":"hello \"world\""}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing newlines" {
    run mcp_create_text_content_object $'line1\nline2\nline3'
    assert_success
    assert_output '{"content":[{"type":"text","text":"line1\nline2\nline3"}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing special characters" {
    run mcp_create_text_content_object 'special chars: !@#$%^&*()_+-=[]{}|;:,.<>?'
    assert_success
    assert_output '{"content":[{"type":"text","text":"special chars: !@#$%^&*()_+-=[]{}|;:,.<>?"}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing backslashes" {
    run mcp_create_text_content_object 'path\to\file'
    assert_success
    assert_output '{"content":[{"type":"text","text":"path\\to\\file"}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing unicode" {
    run mcp_create_text_content_object 'unicode: 🌟 ∆ ∑ ∞'
    assert_success
    assert_output '{"content":[{"type":"text","text":"unicode: 🌟 ∆ ∑ ∞"}]}'
}

@test "mcp_create_text_content_object: creates text content object with string containing tabs" {
    run mcp_create_text_content_object $'column1\tcolumn2\tcolumn3'
    assert_success
    assert_output '{"content":[{"type":"text","text":"column1\tcolumn2\tcolumn3"}]}'
}

@test "mcp_create_text_content_object: creates text content object with long string" {
    local long_text='This is a very long string that contains many characters to test how the function handles longer text content. It should still work correctly regardless of the length of the input text, as long as it is properly JSON-quoted.'
    run mcp_create_text_content_object "${long_text}"
    assert_success
    expected='{"content":[{"type":"text","text":"This is a very long string that contains many characters to test how the function handles longer text content. It should still work correctly regardless of the length of the input text, as long as it is properly JSON-quoted."}]}'
    assert_output "${expected}"
}

@test "mcp_create_text_content_object: creates text content object with input containing whitespace" {
    run mcp_create_text_content_object '   '
    assert_success
    assert_output '{"content":[{"type":"text","text":""}]}'
}

@test "mcp_create_text_content_object: creates text content object with multiline string with carriage returns" {
    run mcp_create_text_content_object $'line1\r\nline2\r\nline3'
    assert_success
    assert_output '{"content":[{"type":"text","text":"line1\r\nline2\r\nline3"}]}'
}

@test "mcp_create_text_content_object: creates text content object with JSON-like string content" {
    run mcp_create_text_content_object '{"nested": "json"}'
    assert_success
    assert_output '{"content":[{"type":"text","text":"{\"nested\": \"json\"}"}]}'
}

# The function now handles any input as text, including what used to be edge cases

@test "mcp_create_text_content_object: handles number input as text" {
    run mcp_create_text_content_object '42'
    assert_success
    assert_output '{"content":[{"type":"text","text":"42"}]}'
}

@test "mcp_create_text_content_object: handles boolean true input as text" {
    run mcp_create_text_content_object 'true'
    assert_success
    assert_output '{"content":[{"type":"text","text":"true"}]}'
}

@test "mcp_create_text_content_object: handles boolean false input as text" {
    run mcp_create_text_content_object 'false'
    assert_success
    assert_output '{"content":[{"type":"text","text":"false"}]}'
}

@test "mcp_create_text_content_object: handles null input as text" {
    run mcp_create_text_content_object 'null'
    assert_success
    assert_output '{"content":[{"type":"text","text":"null"}]}'
}

@test "mcp_create_text_content_object: handles array-like input as text" {
    run mcp_create_text_content_object '["item1","item2"]'
    assert_success
    assert_output '{"content":[{"type":"text","text":"[\"item1\",\"item2\"]"}]}'
}

@test "mcp_create_text_content_object: handles object-like input as text" {
    run mcp_create_text_content_object '{"key":"value"}'
    assert_success
    assert_output '{"content":[{"type":"text","text":"{\"key\":\"value\"}"}]}'
}

@test "mcp_create_text_content_object: handles malformed JSON-like input as text" {
    run mcp_create_text_content_object '{"key":}'
    assert_success
    assert_output '{"content":[{"type":"text","text":"{\"key\":}"}]}'
}

@test "mcp_create_text_content_object: handles input with leading/trailing whitespace" {
    run mcp_create_text_content_object '  hello world  '
    assert_success
    # text_trim is applied, so leading/trailing whitespace should be removed
    assert_output '{"content":[{"type":"text","text":"hello world"}]}'
}

@test "mcp_create_text_content_object: handles shell command output format" {
    run mcp_create_text_content_object 'Command executed successfully
Exit code: 0
Output: Hello, World!'
    assert_success
    assert_output '{"content":[{"type":"text","text":"Command executed successfully\nExit code: 0\nOutput: Hello, World!"}]}'
}

@test "mcp_create_text_content_object: handles input with mixed content types" {
    run mcp_create_text_content_object 'Here is some text with numbers 123, booleans true/false, and JSON {"test": "value"}'
    assert_success
    assert_output '{"content":[{"type":"text","text":"Here is some text with numbers 123, booleans true/false, and JSON {\"test\": \"value\"}"}]}'
}
