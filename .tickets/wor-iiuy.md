---
id: wor-iiuy
status: open
deps: []
links: []
created: 2026-03-11T00:53:59Z
type: chore
priority: 1
tags: [mcp, tests]
---
# Fix stale protocol version in mcp_process_request tests

Four tests in test/mcp_process_request.test.bats send protocolVersion "2025-06-18" in initialize params but assert success. The server now advertises 2025-11-25 and rejects mismatches, so these tests are broken or relying on stale fixtures.

## Acceptance Criteria

All four test inputs updated from "2025-06-18" to "2025-11-25": lines 30, 107, 114, 121 of test/mcp_process_request.test.bats. Full test suite passes.

