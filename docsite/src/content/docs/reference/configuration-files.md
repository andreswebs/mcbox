---
title: Configuration Files
description: Complete reference for mcbox configuration files that enable pluggable tool customization.
---

**mcbox** uses three configuration files to define server metadata, tool specifications, and tool implementations. These files enable you to create customized local instances of **mcbox** by plugging in new tools on demand.

## Overview

The three configuration files work together to create a complete MCP server instance:

| File          | Purpose                                | Format      |
| ------------- | -------------------------------------- | ----------- |
| `server.json` | Server metadata and MCP capabilities   | JSON        |
| `tools.json`  | Tool definitions and JSON schemas      | JSON        |
| `tools.bash`  | Tool implementations as Bash functions | Bash script |

## server.json

Server configuration file containing MCP protocol metadata and capability declarations.

### Schema

```txt
{
  "protocolVersion": "2025-06-18",
  "serverInfo": {
    "name": string,
    "version": string
  },
  "capabilities": {
    "tools": {
      "listChanged": boolean
    }
  },
  "instructions": string
}
```

### Fields

#### `protocolVersion`

**Type:** `string`
**Required:** Yes
**Description:** MCP protocol version supported by the server.
**Default:** `"2025-06-18"`

#### `serverInfo`

**Type:** `object`
**Required:** Yes
**Description:** Server identification metadata.

##### `serverInfo.name`

**Type:** `string`
**Required:** Yes
**Description:** Unique identifier for the server instance.

##### `serverInfo.version`

**Type:** `string`
**Required:** Yes
**Description:** Version of the server instance.

#### `capabilities`

**Type:** `object`
**Required:** Yes
**Description:** MCP capabilities supported by the server.

##### `capabilities.tools`

**Type:** `object`
**Required:** Yes
**Description:** Tool-related capabilities.

##### `capabilities.tools.listChanged`

**Type:** `boolean`
**Required:** Yes
**Description:** Whether the server supports tool list change notifications.
**Default:** `true`

#### `instructions`

**Type:** `string`
**Required:** No
**Description:** Human-readable description of the server's purpose and capabilities.

### Example

```json
{
  "protocolVersion": "2025-06-18",
  "serverInfo": {
    "name": "nodejs-toolbox",
    "version": "1.0.0"
  },
  "capabilities": {
    "tools": {
      "listChanged": true
    }
  },
  "instructions": "Custom mcbox instance with development tools for Node.js projects."
}
```

## tools.json

Tool configuration file containing tool definitions, descriptions, and JSON schemas for input/output validation.

### Schema

```txt
{
  "tools": [
    {
      "name": string,
      "description": string,
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      },
      "outputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    }
  ]
}
```

### Fields

#### `tools`

**Type:** `array`
**Required:** Yes
**Description:** Array of tool definitions.

#### `tools[].name`

**Type:** `string`
**Required:** Yes
**Description:** Unique tool identifier. Must match the function name in `tools.bash` (without the configured prefix).

#### `tools[].description`

**Type:** `string`
**Required:** Yes
**Description:** Human-readable description of the tool's purpose and functionality.

#### `tools[].inputSchema`

**Type:** `object`
**Required:** Yes
**Description:** JSON Schema defining the structure and validation rules for tool input parameters.

##### `tools[].inputSchema.type`

**Type:** `string`
**Required:** Yes
**Value:** `"object"`
**Description:** Input must be a JSON object.

##### `tools[].inputSchema.properties`

**Type:** `object`
**Required:** No
**Description:** Object defining input parameter schemas.

##### `tools[].inputSchema.required`

**Type:** `array`
**Required:** No
**Description:** Array of required parameter names.

#### `tools[].outputSchema`

**Type:** `object`
**Required:** No
**Description:** JSON Schema defining the structure and validation rules for tool output. If omitted, output validation is skipped.

### Example

```json
{
  "tools": [
    {
      "name": "file_read",
      "description": "Read the contents of a file",
      "inputSchema": {
        "type": "object",
        "properties": {
          "path": {
            "type": "string",
            "description": "Path to the file to read"
          },
          "encoding": {
            "type": "string",
            "enum": ["utf-8", "ascii", "base64"],
            "default": "utf-8"
          }
        },
        "required": ["path"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "content": {
            "type": "string"
          },
          "size": {
            "type": "number"
          }
        },
        "required": ["content"]
      }
    },
    {
      "name": "system_info",
      "description": "Get basic system information",
      "inputSchema": {
        "type": "object",
        "properties": {},
        "required": []
      }
    }
  ]
}
```

## tools.bash

Tool implementation file containing Bash functions that execute the actual tool logic.

### Function Naming Convention

Tool functions must follow the naming pattern:

```sh
${MCBOX_TOOLS_FUNCTION_NAME_PREFIX}${tool_name}
```

Where:

- `MCBOX_TOOLS_FUNCTION_NAME_PREFIX` defaults to `tool_` (configurable via environment variable)
- `tool_name` matches the `name` field from `tools.json`

### Function Signature

```bash
function tool_example() {
    local arguments="${1}"
    # Tool implementation
    echo "${result_json}"
}
```

#### Parameters

- `arguments`: JSON string containing tool input parameters as defined in `inputSchema`

#### Return Value

- **Success**: Tool should result to stdout and return exit code 0
- **Failure**: Tool should return non-zero exit code, optionally echoing error message to stdout

### Input Processing

Use `jq` to extract parameters from the input JSON:

```bash
function tool_example() {
    local arguments="${1}"
    local path encoding

    path=$(echo "${arguments}" | jq --raw-output '.path')
    encoding=$(echo "${arguments}" | jq --raw-output '.encoding // "utf-8"')

    # Tool logic here
}
```

### Output Generation

Return results as JSON using `jq`:

```bash
function tool_file_read() {
    local arguments="${1}"
    local path content size

    path=$(echo "${arguments}" | jq --raw-output '.path')

    if [[ ! -f "${path}" ]]; then
        return 1
    fi

    content=$(cat "${path}")
    size=$(wc -c < "${path}")

    jq --compact-output --null-input \
        --arg content "${content}" \
        --argjson size "${size}" \
        '{"content": $content, "size": $size}'
}
```

### Function Export

All tool functions must be exported for discovery by **mcbox**:

```bash
export -f tool_file_read tool_system_info
```

### Complete Example

```bash
#!/usr/bin/env bash

function tool_file_read() {
    local arguments="${1}"
    local path encoding content size

    path=$(echo "${arguments}" | jq --raw-output '.path')
    encoding=$(echo "${arguments}" | jq --raw-output '.encoding // "utf-8"')

    if [[ ! -f "${path}" ]]; then
        echo "File not found: ${path}" >&2
        return 1
    fi

    content=$(cat "${path}")
    size=$(wc -c < "${path}")

    jq --compact-output --null-input \
        --arg content "${content}" \
        --argjson size "${size}" \
        '{"content": $content, "size": $size}'
}

function tool_system_info() {
    local arguments="${1}"
    local os kernel uptime

    os=$(uname -s)
    kernel=$(uname -r)
    uptime=$(uptime -p 2>/dev/null || uptime)

    jq --compact-output --null-input \
        --arg os "${os}" \
        --arg kernel "${kernel}" \
        --arg uptime "${uptime}" \
        '{"os": $os, "kernel": $kernel, "uptime": $uptime}'
}

export -f tool_file_read tool_system_info
```

## Plugin Development Workflow

Creating custom **mcbox** instances with new tools:

1. **Define Tools** - Add tool definitions to `tools.json` with proper schemas
2. **Implement Functions** - Write corresponding Bash functions in `tools.bash`
3. **Configure Server** - Update `server.json` with appropriate metadata
4. **Test Tools** - Verify functionality using MCP Inspector or integration tests
5. **Deploy** - Place configuration files in appropriate locations

### Best Practices

- **Validate Input**: Always validate input parameters using the provided JSON schemas
- **Handle Errors**: Return appropriate exit codes and error messages
- **Use jq**: Leverage `jq` for JSON processing and output generation
- **Export Functions**: Remember to export all tool functions
- **Test Thoroughly**: Verify tools work correctly with various input scenarios
- **Document Tools**: Provide clear, helpful descriptions in `tools.json`

### Schema Validation

**mcbox** automatically validates:

- Tool input against `inputSchema` before function execution
- Tool output against `outputSchema` (if defined) after function execution
- JSON structure and required fields compliance

Invalid input or output will result in MCP error responses without executing the tool function.
