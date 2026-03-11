---
title: Configuration Files
description: Complete reference for mcbox configuration files that enable pluggable tool and prompt customization.
---

**mcbox** uses configuration files to define server metadata, tool specifications, tool implementations, prompt definitions, and prompt implementations. These files enable you to create customized local instances of **mcbox** by plugging in new tools and prompts on demand.

## Overview

The configuration files work together to create a complete MCP server instance:

| File           | Purpose                                  | Format      |
| -------------- | ---------------------------------------- | ----------- |
| `server.json`  | Server metadata and MCP capabilities     | JSON        |
| `tools.json`   | Tool definitions and JSON schemas        | JSON        |
| `tools.bash`   | Tool implementations as Bash functions   | Bash script |
| `prompts.json` | Prompt definitions and arguments         | JSON        |
| `prompts.bash` | Prompt implementations as Bash functions | Bash script |

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

## prompts.json

Prompt configuration file containing prompt definitions, descriptions, and argument specifications.

### Schema

```txt
{
  "prompts": [
    {
      "name": string,
      "title": string,
      "description": string,
      "arguments": [
        {
          "name": string,
          "description": string,
          "required": boolean
        }
      ]
    }
  ]
}
```

### Fields

#### `prompts`

**Type:** `array`
**Required:** Yes
**Description:** Array of prompt definitions.

#### `prompts[].name`

**Type:** `string`
**Required:** Yes
**Description:** Unique prompt identifier. Must match the function name in `prompts.bash` (without the configured prefix, with hyphens and dots converted to underscores).

#### `prompts[].title`

**Type:** `string`
**Required:** No
**Description:** Human-readable display title for the prompt.

#### `prompts[].description`

**Type:** `string`
**Required:** No
**Description:** Human-readable description of the prompt's purpose and functionality.

#### `prompts[].arguments`

**Type:** `array`
**Required:** No
**Description:** Array of argument definitions for the prompt.

#### `prompts[].arguments[].name`

**Type:** `string`
**Required:** Yes
**Description:** Argument name. Must be provided exactly as-is in the `prompts/get` request.

#### `prompts[].arguments[].description`

**Type:** `string`
**Required:** No
**Description:** Human-readable description of the argument.

#### `prompts[].arguments[].required`

**Type:** `boolean`
**Required:** No
**Description:** Whether this argument is required. If `true`, the argument must be present in the `prompts/get` request or the server returns an error.

### Example

```json
{
    "prompts": [
        {
            "name": "greet",
            "description": "Generate a greeting message",
            "arguments": [
                {
                    "name": "name",
                    "description": "The name to greet",
                    "required": true
                }
            ]
        },
        {
            "name": "code-review",
            "title": "Code Review",
            "description": "Start a code review session"
        }
    ]
}
```

## prompts.bash

Prompt implementation file containing Bash functions that generate prompt messages.

### Function Naming Convention

Prompt functions must follow the naming pattern:

```sh
${MCBOX_PROMPTS_FUNCTION_NAME_PREFIX}${prompt_name}
```

Where:

- `MCBOX_PROMPTS_FUNCTION_NAME_PREFIX` defaults to `prompt_` (configurable via environment variable)
- `prompt_name` matches the `name` field from `prompts.json`, with hyphens (`-`) and dots (`.`) replaced by underscores (`_`)

### Function Signature

```bash
function prompt_example() {
    local arguments="${1}"
    # Prompt implementation
    echo "${result_json}"
}
```

#### Parameters

- `arguments`: JSON object containing the prompt arguments as key-value string pairs

#### Return Value

- **Success**: Output a JSON object with a `messages` array to stdout and return exit code 0
- **Failure**: Return non-zero exit code, optionally echoing error message to stdout

### Output Format

Prompt functions must return a JSON object containing a `messages` array with MCP message objects:

```json
{
    "messages": [
        {
            "role": "user",
            "content": {
                "type": "text",
                "text": "Your prompt text here"
            }
        }
    ]
}
```

### Complete Example

```bash
#!/usr/bin/env bash

function prompt_greet() {
    local arguments="${1}"
    local name
    name=$(echo "${arguments}" | jq --raw-output '.name')

    jq --compact-output --null-input --arg name "${name}" '{
        "messages": [
            {
                "role": "user",
                "content": {
                    "type": "text",
                    "text": ("Hello " + $name + "! How can I help you today?")
                }
            }
        ]
    }'
}

function prompt_code_review() {
    echo '{"messages":[{"role":"user","content":{"type":"text","text":"Please review the following code for quality, correctness, and potential improvements."}}]}'
}

export -f prompt_greet prompt_code_review
```

## Plugin Development Workflow

Creating custom **mcbox** instances with new tools and prompts:

1. **Define Tools** - Add tool definitions to `tools.json` with proper schemas
2. **Define Prompts** - Add prompt definitions to `prompts.json` with argument specifications
3. **Implement Functions** - Write corresponding Bash functions in `tools.bash` and `prompts.bash`
4. **Configure Server** - Update `server.json` with appropriate metadata
5. **Test** - Verify functionality using MCP Inspector or integration tests
6. **Deploy** - Place configuration files in appropriate locations

### Best Practices

- **Validate Input**: Always validate input parameters using the provided JSON schemas
- **Handle Errors**: Return appropriate exit codes and error messages
- **Use jq**: Leverage `jq` for JSON processing and output generation
- **Export Functions**: Remember to export all tool and prompt functions
- **Test Thoroughly**: Verify tools and prompts work correctly with various input scenarios
- **Document**: Provide clear, helpful descriptions in `tools.json` and `prompts.json`

### Schema Validation

**mcbox** automatically validates:

- Tool input against `inputSchema` before function execution
- Tool output against `outputSchema` (if defined) after function execution
- Prompt definitions against the built-in prompt schema at startup
- Prompt arguments (required/unknown) before function execution
- JSON structure and required fields compliance

Invalid input or output will result in MCP error responses without executing the function.
