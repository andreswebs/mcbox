---
id: wor-wrjj
status: closed
deps: [wor-c34h]
links: []
created: 2026-03-11T03:04:23Z
type: feature
priority: 2
parent: wor-l8vn
tags: [mcp, prompts]
---
# Add dynamic prompts capability to mcp_handle_initialize

Update mcp_handle_initialize (mcbox-core.bash, lines 914-950) to conditionally include prompts capability in the server config response. Currently it returns MCBOX_SERVER_CONFIG verbatim. Per spec requirements 5.1 and 5.3, prompts capability should only be advertised when prompts are actually configured.

The static server.json should NOT contain prompts capability. Instead, mcp_handle_initialize should dynamically inject it:
1. Read MCBOX_PROMPTS_CONFIG.
2. If it contains a non-empty prompts array, add { "prompts": { "listChanged": false } } to the capabilities object in the response.
3. If prompts array is empty or MCBOX_PROMPTS_CONFIG is the fallback, do not advertise prompts capability.

Note: listChanged is false, consistent with the approach taken for tools (see closed ticket wor-pzzy which removed listChanged:true from tools).

## Design

Use jq to conditionally merge prompts capability into the server config. Check if MCBOX_PROMPTS_CONFIG has .prompts | length > 0. If so, pipe MCBOX_SERVER_CONFIG through jq to add .capabilities.prompts = {"listChanged": false}. Otherwise return MCBOX_SERVER_CONFIG as-is.

## Acceptance Criteria

When prompts are configured (non-empty prompts array): initialize response includes { "capabilities": { "tools": {}, "prompts": { "listChanged": false } } }. When no prompts configured: initialize response has only { "capabilities": { "tools": {} } } (unchanged). server.json remains unchanged (no static prompts capability). shfmt and shellcheck pass.


## Notes

**2026-03-11T04:00:50Z**

Implemented dynamic prompts capability in mcp_handle_initialize. After getting server_config, checks MCBOX_PROMPTS_CONFIG: if it has a non-empty prompts array, injects capabilities.prompts={listChanged:false} into the response via jq. Two new tests added to test/mcp_handle_initialize.test.bats covering non-empty and empty prompts configs. teardown() updated to unset MCBOX_PROMPTS_CONFIG. All 457 tests pass.
