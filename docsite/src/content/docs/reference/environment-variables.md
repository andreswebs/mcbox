---
title: Environment Variables
description: Complete reference for all environment variables used by mcbox for configuration and runtime behavior.
---

mcbox uses environment variables to configure file locations and runtime behavior. All variables are optional and have sensible defaults that follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

## XDG Base Directory Variables

mcbox respects the XDG Base Directory Specification for determining default configuration and data locations.

### `XDG_CONFIG_HOME`

**Default:** `$HOME/.config`

Base directory for user-specific configuration files. mcbox uses this to locate configuration files when specific `MCBOX_*` variables are not set.

**Example usage:**

```bash
export XDG_CONFIG_HOME="/custom/config"
# mcbox will look for configs in /custom/config/mcbox/
```

### `XDG_DATA_HOME`

**Default:** `$HOME/.local/share`

Base directory for user-specific data files. mcbox uses this to locate the core library file when `MCBOX_CORE_LIB_FILE` is not set.

**Example usage:**

```bash
export XDG_DATA_HOME="/custom/data"
# mcbox will look for core library at /custom/data/mcbox/mcbox-core.bash
```

## mcbox Configuration Variables

### `MCBOX_DATA_HOME`

**Default:** `$XDG_DATA_HOME/mcbox`

Absolute path to the mcbox data directory. This directory contains data files such as the core library and version information. Setting this variable overrides the XDG-based default.

**Example usage:**

```bash
export MCBOX_DATA_HOME="/custom/data/mcbox"
# mcbox will use /custom/data/mcbox instead of ~/.local/share/mcbox
```

### `MCBOX_CONFIG_HOME`

**Default:** `$XDG_CONFIG_HOME/mcbox`

Absolute path to the mcbox configuration directory. This directory contains configuration files such as server.json, tools.json, and tools.bash. Setting this variable overrides the XDG-based default.

**Example usage:**

```bash
export MCBOX_CONFIG_HOME="/custom/config/mcbox"
# mcbox will use /custom/config/mcbox instead of ~/.config/mcbox
```

### `MCBOX_SERVER_CONFIG_FILE`

**Default:** `$MCBOX_CONFIG_HOME/server.json` (which defaults to `$XDG_CONFIG_HOME/mcbox/server.json`)

Absolute path to the server configuration file containing MCP server metadata and capabilities.

**Example usage:**

```bash
export MCBOX_SERVER_CONFIG_FILE="/path/to/custom/server.json"
```

### `MCBOX_TOOLS_CONFIG_FILE`

**Default:** `$MCBOX_CONFIG_HOME/tools.json` (which defaults to `$XDG_CONFIG_HOME/mcbox/tools.json`)

Absolute path to the tools configuration file containing tool definitions and JSON schemas.

**Example usage:**

```bash
export MCBOX_TOOLS_CONFIG_FILE="/path/to/custom/tools.json"
```

### `MCBOX_TOOLS_LIB_FILE`

**Default:** `$MCBOX_CONFIG_HOME/tools.bash` (which defaults to `$XDG_CONFIG_HOME/mcbox/tools.bash`)

Absolute path to the tools implementation file containing Bash functions that implement the tools.

**Example usage:**

```bash
export MCBOX_TOOLS_LIB_FILE="/path/to/custom/tools.bash"
```

### `MCBOX_CORE_LIB_FILE`

**Default:** `$MCBOX_DATA_HOME/mcbox-core.bash` (which defaults to `$XDG_DATA_HOME/mcbox/mcbox-core.bash`)

Absolute path to the mcbox core library file. The reference server implementation will prefer a local `mcbox-core.bash` file in the same directory if available.

**Example usage:**

```bash
export MCBOX_CORE_LIB_FILE="/path/to/custom/mcbox-core.bash"
```

### `MCBOX_TOOLS_FUNCTION_NAME_PREFIX`

**Default:** `tool_`

Prefix used for tool function names in the tools library file. Tool functions must follow the naming convention `${prefix}${tool_name}`.

**Example usage:**

```bash
export MCBOX_TOOLS_FUNCTION_NAME_PREFIX="custom_tool_"
# Tools would be named: custom_tool_example, custom_tool_another, etc.
```

## Logging Configuration Variables

These variables control mcbox's logging behavior and follow OpenTelemetry standards.

### `MCBOX_LOG_LEVEL`

**Default:** Uses `OTEL_LOG_LEVEL` if set, otherwise `info`

Primary log level setting for mcbox. Takes precedence over `OTEL_LOG_LEVEL` when both are set. Controls which log messages are displayed based on severity.

**Valid values:**

- `trace` - Most verbose, shows all logging including function entry/exit
- `debug` - Development debugging information
- `info` - General operational information (default)
- `warn` - Warning conditions that don't affect functionality
- `error` - Error conditions that affect functionality
- `fatal` - Critical errors that prevent operation

Values are case-insensitive.

**Example usage:**

```bash
export MCBOX_LOG_LEVEL="debug"
# Enable debug-level logging
```

### `OTEL_LOG_LEVEL`

**Default:** `info`

OpenTelemetry-compatible log level setting. Used as a fallback when `MCBOX_LOG_LEVEL` is not set. Follows the [OpenTelemetry logging specification](https://opentelemetry.io/docs/specs/otel/logs/data-model/#field-severitynumber).

**Valid values:** Same as `MCBOX_LOG_LEVEL`

**Example usage:**

```bash
export OTEL_LOG_LEVEL="warn"
# Set logging to warnings and above using OpenTelemetry standard
```

### Log Level Priority

The logging system uses this priority order:

1. `MCBOX_LOG_LEVEL` (highest priority)
2. `OTEL_LOG_LEVEL` (fallback)
3. `info` (default)

**Example priority resolution:**

```bash
# Case 1: MCBOX_LOG_LEVEL takes precedence
export OTEL_LOG_LEVEL="debug"
export MCBOX_LOG_LEVEL="error"
# Result: error level logging

# Case 2: OTEL_LOG_LEVEL used as fallback
export OTEL_LOG_LEVEL="debug"
# MCBOX_LOG_LEVEL not set
# Result: debug level logging

# Case 3: Default when neither is set
# Result: info level logging
```

## Runtime Variables

These variables are set automatically by mcbox during execution and should not be modified directly.

### `MCBOX_SERVER_CONFIG`

Contains the parsed JSON content of the server configuration file. Set automatically by `mcbox_load_config()`.

### `MCBOX_TOOLS_CONFIG`

Contains the parsed JSON content of the tools configuration file. Set automatically by `mcbox_load_config()`.

## Default File Locations

When using default settings, mcbox expects files in these locations:

| File Type     | Default Location                                                                      |
| ------------- | ------------------------------------------------------------------------------------- |
| Server Config | `$MCBOX_CONFIG_HOME/server.json` (typically `~/.config/mcbox/server.json`)            |
| Tools Config  | `$MCBOX_CONFIG_HOME/tools.json` (typically `~/.config/mcbox/tools.json`)              |
| Tools Library | `$MCBOX_CONFIG_HOME/tools.bash` (typically `~/.config/mcbox/tools.bash`)              |
| Core Library  | `$MCBOX_DATA_HOME/mcbox-core.bash` (typically `~/.local/share/mcbox/mcbox-core.bash`) |

## Environment Variables Summary

### Configuration Variables

| Variable                           | Default                            | Purpose                       |
| ---------------------------------- | ---------------------------------- | ----------------------------- |
| `MCBOX_DATA_HOME`                  | `$XDG_DATA_HOME/mcbox`             | mcbox data directory          |
| `MCBOX_CONFIG_HOME`                | `$XDG_CONFIG_HOME/mcbox`           | mcbox configuration directory |
| `MCBOX_SERVER_CONFIG_FILE`         | `$MCBOX_CONFIG_HOME/server.json`   | Server configuration file     |
| `MCBOX_TOOLS_CONFIG_FILE`          | `$MCBOX_CONFIG_HOME/tools.json`    | Tools configuration file      |
| `MCBOX_TOOLS_LIB_FILE`             | `$MCBOX_CONFIG_HOME/tools.bash`    | Tools implementation file     |
| `MCBOX_CORE_LIB_FILE`              | `$MCBOX_DATA_HOME/mcbox-core.bash` | Core library file             |
| `MCBOX_TOOLS_FUNCTION_NAME_PREFIX` | `tool_`                            | Tool function naming prefix   |

### Logging Variables

| Variable          | Default         | Purpose                   |
| ----------------- | --------------- | ------------------------- |
| `MCBOX_LOG_LEVEL` | _uses fallback_ | Primary log level setting |
| `OTEL_LOG_LEVEL`  | `info`          | OpenTelemetry log level   |

### XDG Base Directory Variables

| Variable          | Default              | Purpose                         |
| ----------------- | -------------------- | ------------------------------- |
| `XDG_CONFIG_HOME` | `$HOME/.config`      | Base directory for config files |
| `XDG_DATA_HOME`   | `$HOME/.local/share` | Base directory for data files   |

## Configuration Examples

### Basic Setup

```bash
# Use default XDG locations
mkdir -p ~/.config/mcbox ~/.local/share/mcbox
# Place your configuration files in ~/.config/mcbox/
# Place mcbox-core.bash in ~/.local/share/mcbox/
```

### Custom Configuration Directory

```bash
export XDG_CONFIG_HOME="/opt/mcbox-config"
mkdir -p /opt/mcbox-config/mcbox
# mcbox will look for configs in /opt/mcbox-config/mcbox/
```

### Custom mcbox Directories

```bash
# Set custom directories directly without changing XDG paths
export MCBOX_DATA_HOME="/opt/mcbox/data"
export MCBOX_CONFIG_HOME="/opt/mcbox/config"
mkdir -p /opt/mcbox/data /opt/mcbox/config
# mcbox will use /opt/mcbox/data for data files and /opt/mcbox/config for config files
```

### Fully Custom Paths

```bash
export MCBOX_SERVER_CONFIG_FILE="/etc/mcbox/server.json"
export MCBOX_TOOLS_CONFIG_FILE="/etc/mcbox/tools.json"
export MCBOX_TOOLS_LIB_FILE="/usr/local/lib/mcbox/tools.bash"
export MCBOX_CORE_LIB_FILE="/usr/local/lib/mcbox/mcbox-core.bash"
```

### Development Setup

```bash
# For development, you might want everything in a project directory
PROJECT_DIR="/path/to/mcbox-project"
export MCBOX_SERVER_CONFIG_FILE="${PROJECT_DIR}/config/server.json"
export MCBOX_TOOLS_CONFIG_FILE="${PROJECT_DIR}/config/tools.json"
export MCBOX_TOOLS_LIB_FILE="${PROJECT_DIR}/tools.bash"
export MCBOX_CORE_LIB_FILE="${PROJECT_DIR}/mcbox-core.bash"
```

### Logging Configuration Examples

```bash
# Enable debug logging for development
export MCBOX_LOG_LEVEL="debug"

# Use OpenTelemetry standard environment variable
export OTEL_LOG_LEVEL="trace"

# Production logging (errors and above only)
export MCBOX_LOG_LEVEL="error"

# Quiet operation (fatal errors only)
export MCBOX_LOG_LEVEL="fatal"
```
