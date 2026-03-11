---
id: wor-rvyq
status: closed
deps: []
links: []
created: 2026-03-11T03:03:34Z
type: chore
priority: 1
parent: wor-l8vn
tags: [mcp, prompts]
---
# Define PROMPT_SCHEMA and PROMPTS_SCHEMA constants

Add readonly PROMPT_SCHEMA and PROMPTS_SCHEMA constants at the top of mcbox-core.bash, following the existing TOOL_SCHEMA/TOOLS_SCHEMA pattern.

PROMPT_SCHEMA validates a single prompt definition:
- required: name (string)
- optional: title (string), description (string), arguments (array)
- argument items: required name (string), optional description (string), optional required (boolean)

PROMPTS_SCHEMA wraps PROMPT_SCHEMA in { "type": "object", "required": ["prompts"], "properties": { "prompts": { "type": "array", "items": PROMPT_SCHEMA } } }.

These are used by subsequent tickets for config validation and list response validation.

## Design

Place immediately after the existing TOOLS_SCHEMA readonly declaration. Use the same heredoc-to-jq pattern. Arguments array items have { name: string (required), description: string (optional), required: boolean (optional) } — deliberately simpler than tools inputSchema since prompt arguments are plain strings, not JSON Schema.

## Acceptance Criteria

PROMPT_SCHEMA and PROMPTS_SCHEMA are declared as readonly variables in mcbox-core.bash. PROMPT_SCHEMA requires 'name' (string) and optionally allows 'title' (string), 'description' (string), and 'arguments' (array of objects with required 'name' string and optional 'description' string and 'required' boolean). PROMPTS_SCHEMA wraps PROMPT_SCHEMA as items of a 'prompts' array. Both constants are valid JSON. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:11:52Z**

Added readonly PROMPT_SCHEMA and PROMPTS_SCHEMA constants to mcbox-core.bash immediately after TOOLS_SCHEMA. PROMPT_SCHEMA requires 'name' (string) and optionally allows 'title', 'description', and 'arguments' (array with items having required 'name' and optional 'description'/'required'). PROMPTS_SCHEMA wraps PROMPT_SCHEMA as items of a 'prompts' array. Added shellcheck disable comment for SC2034 on PROMPTS_SCHEMA since it's unused until later tickets. Tests in test/prompt_schemas.test.bats cover JSON validity and top-level schema validation; nested array item validation is not tested because the current jsonschema_validate_schema does not recurse into array items.
