---
id: wor-efbi
status: closed
deps: [wor-ad5j]
links: []
created: 2026-03-11T03:05:30Z
type: chore
priority: 3
parent: wor-l8vn
tags: [mcp, prompts, docs]
---
# Update docs/specs/tech.md to document prompts support

Update docs/specs/tech.md to document the prompts capability implementation. Cover:

1. Prompts config files: prompts.json schema, prompts.bash function conventions.
2. Non-fatal loading behavior: prompts config failures are logged and server continues with empty prompts.
3. Conditional capability advertisement: prompts capability only in initialize response when prompts are configured.
4. Prompt name-to-function translation: same rule as tools (hyphens/dots to underscores), with configurable prefix via MCBOX_PROMPTS_FUNCTION_NAME_PREFIX (default 'prompt_').
5. Argument validation: name-based (not JSON Schema), required flag, no unknown arguments.
6. Environment variables: MCBOX_PROMPTS_CONFIG_FILE, MCBOX_PROMPTS_LIB_FILE, MCBOX_PROMPTS_FUNCTION_NAME_PREFIX, MCBOX_PROMPTS_PAGE_SIZE.
7. Pagination: same cursor-based pattern as tools/list.

## Design

Add a new section in docs/specs/tech.md adjacent to the existing tools documentation. Reference the existing tools documentation for shared patterns (pagination, name translation) to avoid duplication.

## Acceptance Criteria

docs/specs/tech.md has a new section documenting prompts support. All listed topics are covered. No factual errors relative to the implementation. Formatting consistent with existing doc sections.


## Notes

**2026-03-11T04:13:37Z**

Updated docs/specs/tech.md with a new 'Prompt Loading Mechanism' section covering: prompts.json schema, prompts.bash conventions, non-fatal loading behavior, conditional capability advertisement (prompts only advertised when ≥1 prompt configured), name-to-function translation (hyphens/dots → underscores), argument validation (name-based, required flag, no unknown args), all four MCBOX_PROMPTS_* env vars, and pagination. Also updated 'Current Capabilities', 'Configuration Files', 'Environment Configuration', 'Integration Patterns', and 'Limitations' sections to reflect prompts support. All 464 tests pass.
