---
id: wor-c34h
status: closed
deps: [wor-t8vy, wor-t374]
links: []
created: 2026-03-11T03:04:03Z
type: feature
priority: 1
parent: wor-l8vn
tags: [mcp, prompts]
---
# Update mcbox_load_config to load prompts config non-fatally

Extend mcbox_load_config (mcbox-core.bash, lines 809-844) to load prompts.json and prompts.bash using the new location functions. Unlike tools loading which is fatal on failure, prompts loading must be NON-FATAL per spec requirement 2.6: if prompts.json or prompts.bash is missing or invalid, log an error and continue with zero available prompts.

Behavior:
1. Call mcbox_get_prompts_config_location to get prompts.json path.
2. If file exists and is valid JSON matching PROMPTS_SCHEMA, export MCBOX_PROMPTS_CONFIG.
3. If file missing or invalid: log_error, set MCBOX_PROMPTS_CONFIG to '{"prompts":[]}', continue.
4. Call mcbox_get_prompts_lib_location to get prompts.bash path.
5. If file exists, source it. If source fails or file missing: log_error, continue.
6. Export MCBOX_PROMPTS_CONFIG (either loaded or empty fallback).

## Design

Add prompts loading after the existing tools loading block. Use a conditional pattern rather than the fatal log_fatal used for tools. The empty fallback ensures downstream code can always read MCBOX_PROMPTS_CONFIG without null checks. Validate against PROMPTS_SCHEMA using the same jsonschema_validate_schema function used for tools.

## Acceptance Criteria

When prompts.json exists and is valid: MCBOX_PROMPTS_CONFIG contains its contents and prompts.bash is sourced. When prompts.json is missing: log_error is called, MCBOX_PROMPTS_CONFIG is set to '{"prompts":[]}', server continues running. When prompts.json is invalid JSON: same graceful fallback. When prompts.bash is missing: log_error, server continues. When prompts.bash fails to source: log_error, server continues. Existing tools loading behavior unchanged. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:18:40Z**

Added prompts loading block to mcbox_load_config in mcbox-core.bash (after tools loading). Uses non-fatal pattern: if prompts.json is missing, invalid JSON, or fails schema validation against PROMPTS_SCHEMA, logs error and falls back to {"prompts":[]}. If prompts.bash is missing or returns non-zero when sourced, logs error and continues. Added 7 unit tests in test/mcbox_load_config.test.bats. All 428 tests pass.
