---
id: wor-pzzy
status: open
deps: []
links: []
created: 2026-03-11T00:54:05Z
type: chore
priority: 1
tags: [mcp, config, tests]
---
# Remove false listChanged capability from server config

defaults/server.json advertises capabilities.tools.listChanged: true, which per the MCP spec signals the server will emit notifications/tools/list_changed when the tool list changes. The server never sends this notification. Implementing file-watching is out of scope for a synchronous stdio server, so the fix is to drop the false claim.

## Acceptance Criteria

defaults/server.json no longer contains listChanged: true. test/fixtures/smoketest.server.json updated the same way if it contained the key. Any test asserting listChanged: true in the initialize response updated to expect the key absent. Full test suite passes.

