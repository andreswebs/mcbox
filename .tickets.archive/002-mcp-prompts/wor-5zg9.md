---
id: wor-5zg9
status: closed
deps: [wor-8mou]
links: []
created: 2026-03-11T03:05:09Z
type: task
priority: 2
parent: wor-l8vn
tags: [mcp, prompts, testing]
---
# Tests for mcp_handle_prompts_list

Create test/mcp_handle_prompts_list.test.bats with comprehensive tests for mcp_handle_prompts_list, following the pattern in test/mcp_handle_tools_list.test.bats.

Test cases:
1. Returns empty prompts array when config has no prompts.
2. Returns all prompts when no pagination configured.
3. Returns prompt with all optional fields (title, description, arguments).
4. Returns prompt with only required name field.
5. Pagination: MCBOX_PROMPTS_PAGE_SIZE=1 with 2 prompts returns first prompt and nextCursor.
6. Pagination: using nextCursor returns second page without nextCursor.
7. Pagination: invalid cursor treated as offset 0.
8. Pagination: cursor beyond array length returns empty prompts.
9. Falls back to config file when MCBOX_PROMPTS_CONFIG not set.
10. Invalid config (not matching PROMPTS_SCHEMA) returns error.

## Design

Use BATS_TEST_TMPDIR for temp config files. Set MCBOX_PROMPTS_CONFIG_FILE env var to point to temp files. Load mcbox-core.bash via load directive. Use bats-assert helpers (assert_success, assert_failure, assert_output). Follow existing test/mcp_handle_tools_list.test.bats structure closely.

## Acceptance Criteria

All test cases listed pass. Tests cover: empty config, full config, minimal config, pagination (page size, cursor, invalid cursor, overflow), file fallback, and invalid config. File: test/mcp_handle_prompts_list.test.bats. Full test suite passes.


## Notes

**2026-03-11T04:08:53Z**

test/mcp_handle_prompts_list.test.bats already existed with 17 tests covering the core behaviors. Added 3 more tests to fully satisfy acceptance criteria: prompt with all optional fields (including title), prompt with only required name field, and cursor beyond array length returns empty prompts. All 20 tests pass and full validation passes (462 tests total).
