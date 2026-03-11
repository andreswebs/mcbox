---
title: Adding Prompts
description: Step-by-step guide to adding custom prompts to mcbox, including prompt definitions, handler functions, and argument validation.
---

This guide shows you how to add custom prompts to your **mcbox** instance. Prompts let you expose reusable prompt templates through the MCP protocol, enabling clients to request structured messages with dynamic arguments.

## Prerequisites

Before adding prompts, ensure you have:

- A working **mcbox** installation
- Configuration files located at `~/.config/mcbox` (`prompts.json` and `prompts.bash`)
- Basic familiarity with JSON and Bash scripting

Follow the [Getting Started](/mcbox/guides/getting-started) guide to setup **mcbox** with default configuration files if you haven't installed it yet.

## Adding a Simple Prompt

### Step 1: Define the Prompt in `prompts.json`

Add a new prompt definition to your `prompts.json` file:

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
        }
    ]
}
```

### Step 2: Implement the Prompt Function

Add the corresponding function to your `prompts.bash` file:

```bash
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

export -f prompt_greet
```

The function receives a JSON object with the prompt arguments and must return a valid MCP prompt result containing a `messages` array.

## Adding a Prompt Without Arguments

Not all prompts require arguments. Here's a prompt that returns a static message:

```json
{
    "prompts": [
        {
            "name": "code-review",
            "description": "Start a code review session"
        }
    ]
}
```

```bash
function prompt_code_review() {
    echo '{"messages":[{"role":"user","content":{"type":"text","text":"Please review the following code for quality, correctness, and potential improvements."}}]}'
}

export -f prompt_code_review
```

Notice that hyphens in the prompt name (`code-review`) are translated to underscores in the function name (`prompt_code_review`). The same applies to dots.

## Prompt Definition Fields

Each prompt object in `prompts.json` supports these fields:

| Field         | Type   | Required | Description                         |
| ------------- | ------ | -------- | ----------------------------------- |
| `name`        | string | Yes      | Unique prompt identifier            |
| `title`       | string | No       | Human-readable display title        |
| `description` | string | No       | Description of the prompt's purpose |
| `arguments`   | array  | No       | List of argument definitions        |

Each argument object supports:

| Field         | Type    | Required | Description                           |
| ------------- | ------- | -------- | ------------------------------------- |
| `name`        | string  | Yes      | Argument name                         |
| `description` | string  | No       | Description of the argument           |
| `required`    | boolean | No       | Whether the argument must be provided |

## Function Naming Convention

Prompt functions must follow the naming pattern:

```
${MCBOX_PROMPTS_FUNCTION_NAME_PREFIX}${prompt_name}
```

Where:

- `MCBOX_PROMPTS_FUNCTION_NAME_PREFIX` defaults to `prompt_` (configurable via environment variable)
- `prompt_name` matches the `name` field from `prompts.json`, with hyphens (`-`) and dots (`.`) replaced by underscores (`_`)

**Examples:**

| Prompt Name   | Function Name        |
| ------------- | -------------------- |
| `greet`       | `prompt_greet`       |
| `code-review` | `prompt_code_review` |
| `read.file`   | `prompt_read_file`   |

## Function Return Value

Prompt functions must output a JSON object to stdout with a `messages` array containing MCP message objects:

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

An optional `description` field can be included at the top level:

```json
{
    "description": "A greeting for the user",
    "messages": [
        {
            "role": "user",
            "content": {
                "type": "text",
                "text": "Hello!"
            }
        }
    ]
}
```

## Advanced Example: Multi-Argument Prompt

Here's a more complete example with multiple arguments, including optional ones:

```json
{
    "prompts": [
        {
            "name": "explain-code",
            "title": "Explain Code",
            "description": "Explain a piece of code in a given programming language at a specified detail level",
            "arguments": [
                {
                    "name": "code",
                    "description": "The code snippet to explain",
                    "required": true
                },
                {
                    "name": "language",
                    "description": "Programming language of the code",
                    "required": false
                },
                {
                    "name": "detail",
                    "description": "Level of detail: brief, normal, or thorough",
                    "required": false
                }
            ]
        }
    ]
}
```

```bash
function prompt_explain_code() {
    local arguments="${1}"
    local code language detail

    code=$(echo "${arguments}" | jq --raw-output '.code')
    language=$(echo "${arguments}" | jq --raw-output '.language // "unknown"')
    detail=$(echo "${arguments}" | jq --raw-output '.detail // "normal"')

    jq --compact-output --null-input \
        --arg code "${code}" \
        --arg language "${language}" \
        --arg detail "${detail}" '{
        "description": ("Explain " + $language + " code (" + $detail + " detail)"),
        "messages": [
            {
                "role": "user",
                "content": {
                    "type": "text",
                    "text": ("Explain the following " + $language + " code at a " + $detail + " level of detail:\n\n" + $code)
                }
            }
        ]
    }'
}

export -f prompt_explain_code
```

## Capability Advertisement

The `prompts` capability is only advertised to clients when at least one prompt is configured in `prompts.json`. If no prompts are defined, clients will not see the capability and will not send `prompts/list` or `prompts/get` requests.

## Pagination

By default, all prompts are returned in a single `prompts/list` response. To enable pagination, set the `MCBOX_PROMPTS_PAGE_SIZE` environment variable to a positive integer:

```bash
export MCBOX_PROMPTS_PAGE_SIZE="10"
```

This uses the same cursor-based pagination pattern as `tools/list`.

## Troubleshooting

### Prompt Not Found

If your prompt isn't recognized:

1. Check that the function name matches the `prompt_${name}` pattern (with hyphens/dots converted to underscores)
2. Verify the function is exported with `export -f`
3. Ensure `prompts.json` contains the correct prompt definition
4. Restart the **mcbox** server after changes

### Missing Required Arguments

If you get "missing required argument" errors:

1. Verify the client is providing all arguments marked as `required: true`
2. Check that argument names in the request match exactly what's defined in `prompts.json`

### Server Starts Without Prompts

If prompts aren't loading on startup, check:

1. `prompts.json` exists and is readable at the expected location
2. The file contains valid JSON that matches the expected schema
3. Check server logs for validation errors (set `MCBOX_LOG_LEVEL=debug`)

Prompt loading is non-fatal — if the configuration is missing or invalid, the server continues with zero prompts and logs the error.
