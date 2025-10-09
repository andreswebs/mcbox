---
title: Error Handling and Logging
description: Explanation of error handling and logging patterns used in this project.
---

This document describes the error handling patterns, logging strategies, and error propagation mechanisms used in mcbox.

## Logging Levels and Configuration

Logging is configured via environment variables:

- `MCBOX_LOG_LEVEL`: Primary log level setting
- `OTEL_LOG_LEVEL`: OpenTelemetry-compatible log level (fallback)

The project uses OpenTelemetry-compliant logging levels:

| Level | Numeric Value | Usage                                              |
| ----- | ------------- | -------------------------------------------------- |
| TRACE | 1             | Detailed function entry/exit information           |
| DEBUG | 5             | Development debugging information                  |
| INFO  | 9             | General operational information                    |
| WARN  | 13            | Warning conditions that don't affect functionality |
| ERROR | 17            | Error conditions that affect functionality         |
| FATAL | 21            | Critical errors that prevent operation             |

The default value is `INFO`. Values are case insensitive.

## Error Handling Patterns

### Function Return Codes

All functions follow consistent return code patterns:

- `0`: Success
- `1`: Error/failure

### Error Propagation Strategy and Logging

The error handling and logging follows a layered approach with clear separation of concerns:

1. **Silent Validation Layer**: Pure utility functions return exit codes only, without logging
2. **Business Logic Layer**: Functions return exit codes and log specific operational errors
3. **Handler Layer**: Functions return exit codes and add contextual information when calling silent utilities

#### Layer 1: Pure Utility Functions (Silent)

Functions that perform basic validation or utility operations return only exit codes without logging. Examples:

- `is_valid_json` - JSON format validation
- `is_json_object` - JSON object type validation
- `json_object_has_key` - JSON object key existence validation
- `is_readable_file` - File accessibility validation
- `is_non_empty_dir` - Directory validation
- `jsonrpc_validate_id` - JSON-RPC ID format validation
- `text_trim` - String whitespace trimming

These functions are pure validators that may be called multiple times. They remain silent to avoid log noise, allowing callers to decide when to log errors.

Example silent utility function usage:

```bash
# In mcp_process_request - adds context when silent function fails
if ! is_valid_json "${input}"; then
    log_error "received invalid JSON in request"
    jsonrpc_create_error_response "${id}" -32700 "Parse error"
    return 0
fi
```

#### Layer 2: Business Logic Functions (Contextual Logging)

Functions that perform specific business operations log detailed error information. Examples:

- `jsonschema_validate_value` - JSON schema value validation
- `jsonschema_validate_schema` - JSON schema structure validation
- `json_merge_objects` - JSON object merging operations
- `json_read_file` - File reading and JSON parsing
- `jsonrpc_create_*` functions - JSON-RPC message construction
- `mcbox_load_config` - Configuration loading and validation
- `mcbox_check_dependencies` - Dependency verification

These functions perform complex operations where specific error context is valuable for debugging.

Example business logic function usage:

```bash
# In jsonschema_validate_value - logs specific validation errors
if [[ "${actual_type}" != "string" ]]; then
    log_error "expected string, got ${actual_type}"
    return 1
fi
```

#### Layer 3: Top-Level Handlers (Complete Error Context)

Functions that handle requests add contextual logging when calling silent utility functions. Examples:

- `mcp_handle_initialize` - MCP initialization protocol handling
- `mcp_handle_tool_call` - Tool execution request handling
- `mcp_handle_tools_list` - Tools listing request handling
- `mcp_process_request` - Request parsing and routing

These handlers log specific context when utility functions fail, providing operational visibility while maintaining appropriate JSON-RPC error responses.

Example top-level handler context:

```bash
# In mcp_handle_tool_call - adds operation context
if ! json_object_has_key "${params}" "name"; then
    log_error "tool call parameters missing required 'name' property"
    jsonrpc_create_error_response "${id}" -32602 "Invalid params: tool is missing the required 'name' property"
    return 0
fi
```

## JSON-RPC Error Handling

See: <https://www.jsonrpc.org/specification>

### Error Response Format

All JSON-RPC errors follow the standard format:

```json
{
    "jsonrpc": "2.0",
    "id": <request_id_or_null>,
    "error": {
        "code": <error_code>,
        "message": "<error_message>"
    }
}
```

### Standard Error Codes

| Code   | Meaning          | Usage                        |
| ------ | ---------------- | ---------------------------- |
| -32700 | Parse error      | Invalid JSON received        |
| -32600 | Invalid Request  | JSON-RPC format violation    |
| -32601 | Method not found | Unknown method called        |
| -32602 | Invalid params   | Parameter validation failed  |
| -32603 | Internal error   | Server-side processing error |

### Tool Execution Error Patterns

The Model Context Protocol distinguishes between system level failures and tool level failures. System level failures are surfaced to clients as JSON-RPC errors. Tool level failures are returned to clients as JSON-RPC success responses with the tool's error content in the response. Tool error messages are preserved and returned to the client for debugging.

**System-Level Failures** (JSON-RPC error responses):

- Configuration loading errors
- Missing tool functions
- Schema validation failures
- Infrastructure-level problems

**Tool-Level Failures** (JSON-RPC success responses with error content):

- Tool executed but returned error exit code
- Tool-specific operational failures
- Business logic errors within the tool

#### **Implementation Pattern**

```bash
# System-level failure example
if ! is_cmd_available "${tool}"; then
    log_error "tool not found: ${tool_name}"
    jsonrpc_create_error_response "${id}" -32603 "Internal error"
    return 1  # ← System failure
fi

# Tool-level failure example
if ! content=$(${tool} "${arguments}"); then
    # Tool ran but failed - return SUCCESS response with error flag
    mcp_result=$(mcp_create_text_content_object "${content}")
    mcp_result=$(json_merge_objects "${mcp_result}" '{"isError":true}')
    log_error "tool execution failed: ${content}"
    jsonrpc_create_result_response "${id}" "${mcp_result}"
    return 0  # ← Success return (tool failure is not a system failure)
fi
```

#### **When to Use Each Pattern**

**Use JSON-RPC Error Response when:**

- Configuration files cannot be loaded
- Tool function is not available/callable
- Input validation fails against schema
- Infrastructure components fail

**Use Success Response with `isError: true` when:**

- Tool function exists and is callable
- Tool executes but returns non-zero exit code
- Tool produces error output that should be returned to client

#### **Response Format Examples**

**System-Level Failure Response:**

```json
{
  "jsonrpc": "2.0",
  "id": "123",
  "error": {
    "code": -32603,
    "message": "Internal error"
  }
}
```

**Tool-Level Failure Response:**

```json
{
  "jsonrpc": "2.0",
  "id": "123",
  "result": {
    "type": "text",
    "text": "Error: file not found",
    "isError": true
  }
}
```

## Best Practices

### Function Design

1. **Early Returns**: Use early returns for error conditions
2. **Validate Inputs**: Always validate function inputs before processing
3. **Preserve Context**: Don't lose error context when propagating up the call stack

### Testing

1. **Test Error Paths**: Ensure all error conditions have test coverage
2. **Test Edge Cases**: Include tests for malformed inputs and boundary conditions
3. **Test Error Messages**: Verify error responses contain expected information
