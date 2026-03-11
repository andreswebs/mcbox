#!/usr/bin/env bats

load '../mcbox-core.bash'

load 'bats-helpers/bats-support/load'
load 'bats-helpers/bats-assert/load'

# PROMPT_SCHEMA tests

@test "PROMPT_SCHEMA: is valid JSON" {
    run jq --null-input "${PROMPT_SCHEMA}"
    assert_success
}

@test "PROMPT_SCHEMA: accepts minimal prompt with name only" {
    local prompt='{"name": "my-prompt"}'
    run jsonschema_validate_schema "${prompt}" "${PROMPT_SCHEMA}"
    assert_success
}

@test "PROMPT_SCHEMA: rejects prompt missing name" {
    local prompt='{"title": "No Name"}'
    run jsonschema_validate_schema "${prompt}" "${PROMPT_SCHEMA}"
    assert_failure
}

@test "PROMPT_SCHEMA: accepts prompt with all optional fields" {
    local prompt='{"name": "my-prompt", "title": "My Prompt", "description": "A test prompt", "arguments": [{"name": "arg1", "description": "first arg", "required": true}]}'
    run jsonschema_validate_schema "${prompt}" "${PROMPT_SCHEMA}"
    assert_success
}

@test "PROMPT_SCHEMA: accepts argument without optional fields" {
    local prompt='{"name": "my-prompt", "arguments": [{"name": "arg1"}]}'
    run jsonschema_validate_schema "${prompt}" "${PROMPT_SCHEMA}"
    assert_success
}

# PROMPTS_SCHEMA tests

@test "PROMPTS_SCHEMA: is valid JSON" {
    run jq --null-input "${PROMPTS_SCHEMA}"
    assert_success
}

@test "PROMPTS_SCHEMA: accepts empty prompts array" {
    local config='{"prompts": []}'
    run jsonschema_validate_schema "${config}" "${PROMPTS_SCHEMA}"
    assert_success
}

@test "PROMPTS_SCHEMA: accepts valid prompts array" {
    local config='{"prompts": [{"name": "prompt1"}, {"name": "prompt2", "description": "second"}]}'
    run jsonschema_validate_schema "${config}" "${PROMPTS_SCHEMA}"
    assert_success
}

@test "PROMPTS_SCHEMA: rejects missing prompts key" {
    local config='{}'
    run jsonschema_validate_schema "${config}" "${PROMPTS_SCHEMA}"
    assert_failure
}
