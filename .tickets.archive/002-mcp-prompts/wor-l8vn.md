---
id: wor-l8vn
status: closed
deps: []
links: []
created: 2026-03-11T03:03:23Z
type: epic
priority: 1
tags: [mcp, prompts]
---
# Implement MCP prompts capability

Add MCP Prompts support to mcbox. This includes prompts/list and prompts/get methods, prompt schema validation, non-fatal config loading, conditional capability advertisement, default config files, and full test coverage. Prompts use simple name+required argument validation (not JSON Schema like tools), and config loading failures are non-fatal (server continues with zero prompts).

## Acceptance Criteria

All 12 sub-tickets completed and closed. prompts/list and prompts/get work end-to-end. Full test suite passes. Documentation updated.


## Notes

**2026-03-11T04:14:44Z**

All 12 sub-tickets were already closed. Ran validate.bash to confirm all 464 tests pass and formatting/lint checks are clean. Epic closed as all acceptance criteria are met: prompts/list and prompts/get work end-to-end, full test suite passes.
