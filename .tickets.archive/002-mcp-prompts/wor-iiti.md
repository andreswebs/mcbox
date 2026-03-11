---
id: wor-iiti
status: closed
deps: [wor-c34h]
links: []
created: 2026-03-11T03:04:49Z
type: feature
priority: 2
parent: wor-l8vn
tags: [mcp, prompts]
---
# Implement mcp_handle_prompts_get

Implement mcp_handle_prompts_get function in mcbox-core.bash, following the mcp_handle_tool_call pattern but adapted for prompts.

Behavior:
1. Accept id and params arguments. Extract params.name and params.arguments.
2. Validate prompt name format (same regex as tools: ^[a-zA-Z0-9_.-]+$).
3. Look up prompt by name in MCBOX_PROMPTS_CONFIG. Return -32602 if not found.
4. Validate arguments:
   a. Check all required arguments (where required: true) are present in params.arguments. Return -32602 if missing.
   b. Check no unknown arguments are provided (not defined in prompt.arguments). Return -32602 if unknown.
   c. All argument values are strings (not objects/arrays).
5. Translate prompt name to function name: prefix (MCBOX_PROMPTS_FUNCTION_NAME_PREFIX, default 'prompt_') + name with dots/hyphens translated to underscores.
6. Call the function with the arguments JSON object.
7. Function must return a JSON object with optional 'description' (string) and required 'messages' array. Each message has 'role' (user|assistant) and 'content' object with 'type' and 'text'.
8. Return the function's response as the prompts/get result.

## Design

Follow mcp_handle_tool_call structure: name validation, config lookup, argument validation, name-to-function translation (tr '.-' '__'), function execution, output validation. Key differences: argument validation checks name presence and required flag instead of JSON Schema; function prefix defaults to 'prompt_' via MCBOX_PROMPTS_FUNCTION_NAME_PREFIX; output must contain 'messages' array with role+content objects.

## Acceptance Criteria

Prompt lookup by name works. Missing prompt returns -32602 with 'prompt not found' message. Required argument missing returns -32602 with descriptive message. Unknown argument returns -32602. Non-string argument value returns -32602. Name-to-function translation works (hyphens and dots become underscores). MCBOX_PROMPTS_FUNCTION_NAME_PREFIX overrides default 'prompt_' prefix. Function is called with arguments JSON and its response returned. Invalid prompt name format returns -32602. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:27:55Z**

Implemented mcp_handle_prompts_get in mcbox-core.bash following the mcp_handle_tool_call pattern. Handles: config loading with fallback, schema validation, name format validation, prompt lookup, required/unknown argument validation, name-to-function translation (hyphens and dots to underscores), MCBOX_PROMPTS_FUNCTION_NAME_PREFIX override, and function execution. Added test/mcp_handle_prompts_get.test.bats with 10 tests covering all acceptance criteria. All 455 tests pass.
