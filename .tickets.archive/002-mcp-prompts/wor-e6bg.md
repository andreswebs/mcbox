---
id: wor-e6bg
status: closed
deps: [wor-t8vy, wor-t374]
links: []
created: 2026-03-11T03:04:11Z
type: chore
priority: 1
parent: wor-l8vn
tags: [mcp, prompts]
---
# Update mcbox_config_init to include prompts files

Update the config_files array in mcbox_config_init (mcbox-core.bash, lines 857-912) to include prompts.json and prompts.bash. Currently: ("server.json" "tools.json" "tools.bash"). After: ("server.json" "tools.json" "tools.bash" "prompts.json" "prompts.bash").

This ensures that when mcbox_config_init copies defaults to the user config directory, the prompt default files are included.

## Design

Simple addition to the config_files array. The defaults/prompts.json and defaults/prompts.bash files must exist (created in ticket 3) for the copy to succeed.

## Acceptance Criteria

config_files array in mcbox_config_init includes 'prompts.json' and 'prompts.bash'. Running mcbox_config_init copies defaults/prompts.json and defaults/prompts.bash to the config directory. shfmt and shellcheck pass.


## Notes

**2026-03-11T03:20:33Z**

Added 'prompts.json' and 'prompts.bash' to config_files array in mcbox_config_init (mcbox-core.bash:977). Updated cli.test.bats to assert these files are created/overwritten by init-config. defaults/prompts.json and defaults/prompts.bash already existed.
