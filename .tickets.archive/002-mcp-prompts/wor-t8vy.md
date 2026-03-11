---
id: wor-t8vy
status: closed
deps: [wor-rvyq]
links: []
created: 2026-03-11T03:03:41Z
type: chore
priority: 1
parent: wor-l8vn
tags: [mcp, prompts]
---
# Add prompts config location functions

Add mcbox_get_prompts_config_location and mcbox_get_prompts_lib_location functions to mcbox-core.bash, following the existing mcbox_get_tools_config_location pattern.

mcbox_get_prompts_config_location: returns the path to prompts.json, using MCBOX_PROMPTS_CONFIG_FILE env var if set, otherwise ${config_home}/prompts.json. Uses realpath --canonicalize-missing --quiet. Logs via log_trace.

mcbox_get_prompts_lib_location: returns the path to prompts.bash, using MCBOX_PROMPTS_LIB_FILE env var if set, otherwise ${config_home}/prompts.bash. Same realpath and logging pattern.

## Design

Place adjacent to the existing mcbox_get_tools_config_location function (around line 748-770). Follow identical structure: local config_home, realpath, log_trace, echo.

## Acceptance Criteria

mcbox_get_prompts_config_location returns MCBOX_PROMPTS_CONFIG_FILE when set, otherwise ${config_home}/prompts.json. mcbox_get_prompts_lib_location returns MCBOX_PROMPTS_LIB_FILE when set, otherwise ${config_home}/prompts.bash. Both use realpath --canonicalize-missing --quiet. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:13:59Z**

Added mcbox_get_prompts_config_location and mcbox_get_prompts_lib_location functions to mcbox-core.bash after mcbox_get_tools_lib_location (line ~820). Both follow the identical pattern as the tools location functions: use env var override (MCBOX_PROMPTS_CONFIG_FILE / MCBOX_PROMPTS_LIB_FILE), fall back to config_home/prompts.json and config_home/prompts.bash respectively, use realpath --canonicalize-missing --quiet, and log via log_trace. Tests in test/mcbox_get_prompts_config_location.test.bats and test/mcbox_get_prompts_lib_location.test.bats.
