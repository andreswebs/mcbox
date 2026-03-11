---
id: wor-syps
status: closed
deps: []
links: []
created: 2026-03-11T00:54:29Z
type: feature
priority: 2
tags: [mcp, pagination, tools]
---
# Implement cursor-based pagination for tools/list

The MCP schema's ListToolsResult includes an optional nextCursor field and tools/list accepts an optional cursor param. The server currently ignores cursor and never emits nextCursor, so clients that paginate silently receive only one page.

mcp_handle_tools_list (mcbox-core.bash:967) takes only id and always returns the full tools array. mcp_process_request (mcbox-core.bash:1236) calls it without passing params.

Fix:
1. In mcp_process_request, pass params to mcp_handle_tools_list.
2. In mcp_handle_tools_list, accept optional params argument and extract cursor value.
3. Read page size from MCBOX_TOOLS_PAGE_SIZE env var (default 0 = unlimited, preserving current behaviour).
4. When page size > 0: decode cursor (base64-encoded integer offset, default 0), slice the tools array, and include nextCursor in the response if more tools remain.
5. Cursor encoding: printf '%d' "${offset}" | base64 to keep it opaque.

## Acceptance Criteria

Default behaviour (no MCBOX_TOOLS_PAGE_SIZE set) unchanged: all tools returned, no nextCursor. With MCBOX_TOOLS_PAGE_SIZE=1 and 2 tools: first page returns 1 tool and nextCursor; second page returns remaining tool with no nextCursor. Invalid cursor treated as offset 0. New tests in test/mcp_handle_tools_list.test.bats cover all cases. test/mcp_process_request.test.bats has a test for cursor param passthrough. Full test suite passes.


## Notes

**2026-03-11T01:37:40Z**

Implemented cursor-based pagination for tools/list. Changes: (1) mcp_handle_tools_list now accepts optional params arg and reads MCBOX_TOOLS_PAGE_SIZE env var (default 0 = unlimited); when page_size>0, decodes base64 cursor to integer offset, slices tools array with jq, and appends nextCursor if more tools remain. (2) mcp_process_request now passes params to mcp_handle_tools_list. Cursor encoding: printf '%d' offset | base64. Invalid cursors (non-base64 or non-integer decoded value) treated as offset 0. 6 new tests in mcp_handle_tools_list.test.bats + 1 new test in mcp_process_request.test.bats. Full test suite (408 tests) passes.
