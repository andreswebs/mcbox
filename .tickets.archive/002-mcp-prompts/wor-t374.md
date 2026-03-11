---
id: wor-t374
status: closed
deps: [wor-rvyq]
links: []
created: 2026-03-11T03:03:50Z
type: chore
priority: 1
parent: wor-l8vn
tags: [mcp, prompts]
---
# Create default prompts.json and prompts.bash files

Add defaults/prompts.json and defaults/prompts.bash alongside the existing defaults/tools.json and defaults/tools.bash.

defaults/prompts.json: { "prompts": [] } — empty prompts array, valid against PROMPTS_SCHEMA.

defaults/prompts.bash: Empty script with shebang (#!/usr/bin/env bash) and a comment explaining this file contains prompt handler functions. No functions defined since no default prompts are shipped.

## Design

Follow the structure of defaults/tools.json and defaults/tools.bash. The empty defaults ensure mcbox_config_init can copy them to the user config directory. prompts.json must validate against PROMPTS_SCHEMA.

## Acceptance Criteria

defaults/prompts.json exists and contains { "prompts": [] }. defaults/prompts.bash exists with proper shebang. Both pass shfmt/shellcheck. prompts.json is valid JSON.


## Notes

**2026-03-11T03:15:11Z**

Created defaults/prompts.json with empty prompts array ({"prompts":[]}) and defaults/prompts.bash with shebang and explanatory comment. Both files follow the same pattern as tools.json/tools.bash. All 421 tests pass.
