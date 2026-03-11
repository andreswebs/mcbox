---
id: wor-ad5j
status: closed
deps: [wor-8mou, wor-iiti]
links: []
created: 2026-03-11T03:04:57Z
type: chore
priority: 2
parent: wor-l8vn
tags: [mcp, prompts]
---
# Add prompts/list and prompts/get routing in mcp_process_request

Add 'prompts/list' and 'prompts/get' cases to the routing case statement in mcp_process_request (mcbox-core.bash, lines 1209-1288).

prompts/list: call mcp_handle_prompts_list with id and params (same pattern as tools/list).
prompts/get: call mcp_handle_prompts_get with id and params (same pattern as tools/call).

## Design

Add two new cases in the case statement, between the existing tools/call and ping cases. Follow the exact pattern of tools/list and tools/call routing: extract id and params, pass to handler, capture result.

## Acceptance Criteria

JSON-RPC requests with method 'prompts/list' route to mcp_handle_prompts_list. Requests with method 'prompts/get' route to mcp_handle_prompts_get. Both pass id and params correctly. Unknown methods still return -32601. shfmt and shellcheck pass.


## Notes

**2026-03-11T04:06:01Z**

Added prompts/list and prompts/get routing cases to mcp_process_request in mcbox-core.bash (between tools/call and ping). Added two routing tests to test/mcp_process_request.test.bats verifying both methods are dispatched correctly and do not return -32601 (Method not found). Note: did not add MCBOX_PROMPTS_CONFIG_FILE to test setup_file to avoid breaking the existing listChanged capability test — mcbox_load_config already defaults MCBOX_PROMPTS_CONFIG to empty prompts when no file is found. All 459 tests pass.
