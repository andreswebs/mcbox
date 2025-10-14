---
title: Getting Started
description: Your first steps with mcbox - install, configure, and run your own MCP server in minutes.
---

## Install

Only [Homebrew](https://brew.sh) is supported for now. More installation methods will be added soon.

To install with Homebrew:

```sh
brew tap andreswebs/tap
brew install mcbox
```

## Initialize the configuration

```bash
mcbox init-config
```

This will create the default config files at `~/.config/mcbox` if they don't already exist:

- `~/.config/mcbox/server.json`
- `~/.config/mcbox/tools.json`
- `~/.config/mcbox/tools.bash`

## Add mcbox to your agent

The **mcbox** server is now ready to be used by AI agents. You can add it to your agent configuration.

For example:

- for **Claude Desktop**:

  ```json
  {
    "mcpServers": {
      "mcbox": {
        "command": "mcbox",
        "args": []
      }
    }
  }
  ```

- for **GitHub Copilot**:

  ```json
  {
    "servers": {
      "mcbox": {
        "type": "stdio",
        "command": "mcbox",
        "args": []
      }
    }
  }
  ```

- for **other MCP clients**: use the command `mcbox`

## Next Steps

Now that you have a working **mcbox** server, you can:

- **Add more tools** - Follow our [How to Add Tools](/mcbox/guides/adding-tools) guide
- **Integrate external programs** - Create tools that call Python scripts, APIs, or databases
