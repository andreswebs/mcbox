---
title: Adding Tools
description: Step-by-step guide to adding custom tools to mcbox, including examples with tools written in other languages.
---

This guide shows you how to add custom tools to your **mcbox** instance. You'll learn to create tool definitions, implement the logic, and integrate tools written in any programming language.

## Prerequisites

Before adding tools, ensure you have:

- A working **mcbox** installation
- Configuration files located at `~/.config/mcbox` (`tools.json` and `tools.bash`)
- Basic familiarity with JSON and Bash scripting

Follow the [Getting Started](/guides/getting-started) guide to setup **mcbox** with default configuration files if you haven't installed it yet.

## Adding a Simple Bash Tool

### Step 1: Define the Tool in `tools.json`

Add a new tool definition to your `tools.json` file:

```json
{
  "tools": [
    {
      "name": "file_size",
      "description": "Get the size of a file in bytes",
      "inputSchema": {
        "type": "object",
        "properties": {
          "path": {
            "type": "string",
            "description": "Path to the file"
          }
        },
        "required": ["path"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "size": {
            "type": "number",
            "description": "File size in bytes"
          },
          "path": {
            "type": "string",
            "description": "Original file path"
          }
        },
        "required": ["size", "path"]
      }
    }
  ]
}
```

### Step 2: Implement the Tool Function

Add the corresponding function to your `tools.bash` file:

```bash
function tool_file_size() {
    local arguments="${1}"
    local file_path
    file_path=$(echo "${arguments}" | jq --raw-output '.path')

    if ! is_readable_file "${file_path}"; then # notice you can use functions from mcbox-core.bash
        log_error "file not accessible"
        return 1
    fi

    local size
    if ! size=$(wc -c < "${file_path}" 2>/dev/null); then
        log_error "failed to get file size"
        return 1
    fi

    jq --compact-output \
        --null-input \
        --arg path "${file_path}" \
        --argjson size "${size}" \
        '{"path": $path, "size": $size}'
}

export -f tool_file_size
```

## Adding a Tool Written in Another Language

This example shows how to integrate a Go program as an **mcbox** tool.

### Step 1: Create the Go Program

First, create a simple Go program that processes JSON input:

```go
// file-hash.go
package main

import (
    "crypto/sha256"
    "encoding/json"
    "fmt"
    "io"
    "os"
)

type Input struct {
    Path      string `json:"path"`
    Algorithm string `json:"algorithm"`
}

type Output struct {
    Path      string `json:"path"`
    Hash      string `json:"hash"`
    Algorithm string `json:"algorithm"`
}

func main() {
    if len(os.Args) != 2 {
        fmt.Fprintf(os.Stderr, "Usage: %s <json-input>\n", os.Args[0])
        os.Exit(1)
    }

    var input Input
    if err := json.Unmarshal([]byte(os.Args[1]), &input); err != nil {
        fmt.Fprintf(os.Stderr, "Invalid JSON input: %v\n", err)
        os.Exit(1)
    }

    // Default to SHA256 if no algorithm specified
    if input.Algorithm == "" {
        input.Algorithm = "sha256"
    }

    // Open and hash the file
    file, err := os.Open(input.Path)
    if err != nil {
        fmt.Fprintf(os.Stderr, "Cannot open file: %v\n", err)
        os.Exit(1)
    }
    defer file.Close()

    hasher := sha256.New()
    if _, err := io.Copy(hasher, file); err != nil {
        fmt.Fprintf(os.Stderr, "Cannot read file: %v\n", err)
        os.Exit(1)
    }

    output := Output{
        Path:      input.Path,
        Hash:      fmt.Sprintf("%x", hasher.Sum(nil)),
        Algorithm: input.Algorithm,
    }

    result, _ := json.Marshal(output)
    fmt.Print(string(result))
}
```

### Step 2: Build the Go Program

Compile your Go program to create an executable:

```bash
go build -o file-hash file-hash.go
```

Place the executable in a location accessible to your **mcbox** server (e.g., same directory or in your PATH).

### Step 3: Define the Tool in tools.json

Add the tool definition to your `tools.json`:

```json
{
  "tools": [
    {
      "name": "file_hash",
      "description": "Calculate SHA256 hash of a file using an external Go program",
      "inputSchema": {
        "type": "object",
        "properties": {
          "path": {
            "type": "string",
            "description": "Path to the file to hash"
          },
          "algorithm": {
            "type": "string",
            "description": "Hash algorithm (currently only sha256)",
            "enum": ["sha256"],
            "default": "sha256"
          }
        },
        "required": ["path"]
      },
      "outputSchema": {
        "type": "object",
        "properties": {
          "path": {
            "type": "string",
            "description": "Original file path"
          },
          "hash": {
            "type": "string",
            "description": "Hexadecimal hash value"
          },
          "algorithm": {
            "type": "string",
            "description": "Hash algorithm used"
          }
        },
        "required": ["path", "hash", "algorithm"]
      }
    }
  ]
}
```

### Step 4: Create the Bash Wrapper Function

Add a wrapper function to your `tools.bash` that calls the Go program:

```bash
function tool_file_hash() {
    local arguments="${1}"
    local script_dir result

    # Get the directory where this script is located
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Call the Go program with JSON arguments
    if result=$("${script_dir}/file-hash" "${arguments}" 2>&1); then
        # Program succeeded, return the result
        echo "${result}"
        return 0
    else
        # Program failed, log error and return failure
        log_error "${result}"
        return 1
    fi
}

# Export the function
export -f tool_file_hash
```

## Advanced Integration Patterns

### Python Script Integration

For Python tools, create a similar wrapper pattern:

```bash
function tool_python_example() {
    local arguments="${1}"
    local script_dir python_result

    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if python_result=$(python3 "${script_dir}/my-tool.py" "${arguments}" 2>&1); then
        echo "${python_result}"
        return 0
    else
        echo "Python tool error: ${python_result}" >&2
        return 1
    fi
}
```

### Network Service Integration

For tools that call web APIs or network services:

```bash
function tool_api_call() {
    local arguments="${1}"
    local endpoint data response

    endpoint=$(echo "${arguments}" | jq --raw-output '.endpoint')
    data=$(echo "${arguments}" | jq --compact-output '.data')

    if response=$(curl --silent --fail \
                      --header "Content-Type: application/json" \
                      --data "${data}" \
                      "${endpoint}"); then
        echo "${response}"
        return 0
    else
        echo "API call failed: ${response}" >&2
        return 1
    fi
}
```

### Database Integration

For tools that query databases:

```bash
function tool_db_query() {
    local arguments="${1}"
    local query result

    query=$(echo "${arguments}" | jq --raw-output '.query')

    if result=$(sqlite3 -json "${DB_PATH}" "${query}" 2>&1); then
        echo "${result}"
        return 0
    else
        echo "Database query failed: ${result}" >&2
        return 1
    fi
}
```

## Best Practices

### Input Validation

Use jq to validate and extract input parameters safely:

```bash
function tool_safe_example() {
    local arguments="${1}"
    local param

    # Extract with default value
    param=$(echo "${arguments}" | jq --raw-output '.param // "default"')

    # Validate parameter format
    if [[ ! "${param}" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid parameter format" >&2
        return 1
    fi
}
```

### Testing Tools

Test your tools independently before integrating:

```bash
# Test the tool function directly
source tools.bash
tool_file_size '{"path": "/tmp/test.txt"}'
```

## Troubleshooting

### Tool Not Found

If your tool isn't recognized:

1. Check that the function name matches `tool_${name}` pattern
2. Verify the function is exported with `export -f`
3. Ensure `tools.json` contains the correct tool definition
4. Restart the **mcbox** server after changes

### JSON Schema Validation Errors

If input/output validation fails:

1. Verify your JSON schemas match the actual data structure passed to the tool
2. Test JSON generation with `jq` independently
3. Check that all required fields are present
4. Ensure data types match schema definitions

### External Program Failures

For tools calling external programs:

1. Verify the external program is executable and in the correct path
2. Test the external program independently with sample input
3. Check error output from the external program
4. Ensure proper error handling in your wrapper function

This guide provides the foundation for adding any type of tool to **mcbox**, whether implemented in Bash or any other programming language. The key is creating proper JSON schemas and reliable wrapper functions that handle errors gracefully.
