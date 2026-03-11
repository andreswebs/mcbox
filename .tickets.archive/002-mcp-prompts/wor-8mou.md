---
id: wor-8mou
status: closed
deps: [wor-c34h]
links: []
created: 2026-03-11T03:04:34Z
type: feature
priority: 2
parent: wor-l8vn
tags: [mcp, prompts]
---
# Implement mcp_handle_prompts_list

Implement mcp_handle_prompts_list function in mcbox-core.bash, following the mcp_handle_tools_list pattern.

Behavior:
1. Accept id and optional params arguments.
2. Read MCBOX_PROMPTS_CONFIG from env var or fall back to loading from file via mcbox_get_prompts_config_location.
3. Validate config against PROMPTS_SCHEMA.
4. Support cursor-based pagination via MCBOX_PROMPTS_PAGE_SIZE env var (default 0 = unlimited), using the same base64-encoded offset pattern as tools/list.
5. Return { "prompts": [...] } with optional nextCursor.

Each prompt in the response includes: name (required), title (optional), description (optional), arguments (optional array).

## Design

Mirror mcp_handle_tools_list structure closely. Use MCBOX_PROMPTS_PAGE_SIZE for pagination (same base64 cursor encoding). Validate against PROMPTS_SCHEMA. The response shape is { "prompts": [...] } with optional "nextCursor" — same pagination pattern as tools/list.

## Acceptance Criteria

mcp_handle_prompts_list returns all prompts from MCBOX_PROMPTS_CONFIG in { "prompts": [...] } format. Pagination works with MCBOX_PROMPTS_PAGE_SIZE: first page includes nextCursor when more prompts exist, subsequent pages use cursor param. Invalid cursor treated as offset 0. Default (no page size set) returns all prompts without nextCursor. Empty prompts config returns { "prompts": [] }. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:23:57Z**

Implemented mcp_handle_prompts_list in mcbox-core.bash following the mcp_handle_tools_list pattern exactly. Added smoketest.prompts.json fixture with two prompts (greet, farewell). Wrote 17 tests covering: success, JSON-RPC structure, prompts content, string/null IDs, empty config, missing/invalid/malformed config files, MCBOX_PROMPTS_CONFIG env var, pagination (first page, second page, last page, no nextCursor, invalid cursor treated as offset 0), and default file path fallback. All 445 tests pass.
