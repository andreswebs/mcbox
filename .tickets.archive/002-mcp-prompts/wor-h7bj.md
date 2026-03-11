---
id: wor-h7bj
status: closed
deps: [wor-iiti]
links: []
created: 2026-03-11T03:05:20Z
type: task
priority: 2
parent: wor-l8vn
tags: [mcp, prompts, testing]
---
# Tests for mcp_handle_prompts_get

Create test/mcp_handle_prompts_get.test.bats with comprehensive tests for mcp_handle_prompts_get, following the pattern in test/mcp_handle_tool_call.test.bats.

Test cases:
1. Successfully gets a prompt with no arguments.
2. Successfully gets a prompt with required arguments provided.
3. Successfully gets a prompt with optional arguments omitted.
4. Returns -32602 for prompt name not found.
5. Returns -32602 for missing required argument.
6. Returns -32602 for unknown argument provided.
7. Returns -32602 for invalid prompt name format (special chars).
8. Prompt name with hyphens dispatches to underscore-translated function.
9. Prompt name with dots dispatches to underscore-translated function.
10. MCBOX_PROMPTS_FUNCTION_NAME_PREFIX overrides default prefix.
11. Function returning valid messages structure is passed through.
12. Returns error when prompt function is not defined.
13. Non-string argument value returns -32602.

## Design

Use BATS_TEST_TMPDIR for temp config files and temp prompts.bash with stub functions. Set MCBOX_PROMPTS_CONFIG_FILE and MCBOX_PROMPTS_LIB_FILE env vars. Define stub prompt functions in test setup that return known JSON messages. Follow existing test/mcp_handle_tool_call.test.bats patterns.

## Acceptance Criteria

All test cases listed pass. Tests cover: happy path (no args, required args, optional args), error cases (not found, missing required, unknown arg, bad name, undefined function, non-string arg), name translation (hyphens, dots), and prefix override. File: test/mcp_handle_prompts_get.test.bats. Full test suite passes.


## Notes

**2026-03-11T04:11:27Z**

Added 2 missing test cases to test/mcp_handle_prompts_get.test.bats: (12) returns -32603 when prompt function is not defined, (13) returns -32602 for non-string argument value. The non-string argument check required a small implementation fix in mcbox-core.bash: added a type==string validation in the argument loop inside mcp_handle_prompts_get. All 12 tests pass; full suite (464 tests) passes.
