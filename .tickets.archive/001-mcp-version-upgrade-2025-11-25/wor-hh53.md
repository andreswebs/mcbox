---
id: wor-hh53
status: closed
deps: []
links: []
created: 2026-03-11T00:54:16Z
type: feature
priority: 2
tags: [mcp, validation, tools]
---
# Relax tool name validation to allow hyphens and dots

The server validates tool names with ^[a-zA-Z0-9_]+$ (mcbox-core.bash:1073), rejecting names with hyphens or dots. The MCP schema imposes no such restriction. Tool names like read-file or fs.list receive a misleading 'Invalid params: tool name is malformed' error.

Root cause: tool names are used as Bash function name suffixes (tool_${tool_name}), and Bash function names cannot contain hyphens or dots. The restriction is real but should be handled transparently.

Fix:
1. Relax the validation regex to ^[a-zA-Z0-9_.-]+$
2. Before constructing the Bash function name, translate - and . to _:
   function_name=$(printf '%s' "${tool_name}" | tr '.-' '__')
3. Document the name-to-function mapping in docs/specs/tech.md

## Acceptance Criteria

Tool names containing hyphens (e.g. read-file) and dots (e.g. fs.list) are accepted and dispatched to the corresponding underscore-translated function. Names with other special characters (spaces, slashes, etc.) are still rejected with -32602. New passing tests added for hyphen and dot names. Existing rejection tests still pass. docs/specs/tech.md documents the translation rule. Full test suite passes.


## Notes

**2026-03-11T01:32:15Z**

Relaxed tool name validation regex from ^[a-zA-Z0-9_]+$ to ^[a-zA-Z0-9_.-]+$ in mcbox-core.bash:1073. Added name-to-function translation using tr '.-' '__' before constructing the Bash function name (mcbox-core.bash:1112). Tool names like read-file now dispatch to tool_read_file and fs.list dispatches to tool_fs_list. Added 2 new tests in test/mcp_handle_tool_call.test.bats covering hyphen and dot name acceptance. Existing rejection tests for spaces, slashes and other special chars (e.g. test-tool\!) still pass. Documented the name-to-function mapping rule in docs/specs/tech.md. All 401 tests pass.
