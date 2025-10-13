# MCP Prompts Research

## Items Requiring Clarification

### 1. MCP Prompt Content Types and Formats

**Source**: Requirement 3.3 - "The mcbox server shall return prompt content in the format specified by the MCP specification"

### 2. MCP Prompt Argument Validation Patterns

**Source**: Requirement 3.5 - "The mcbox server shall validate prompt arguments according to MCP specification requirements"

### 3. MCP Prompt Function Interface and Return Format

**Source**: Requirement 4.8 - "Prompt functions shall accept arguments and return content according to MCP specification requirements"

### 4. MCP Prompts Capability Declaration Format

**Source**: Requirement 5.2 - "The mcbox server shall declare prompts capabilities according to MCP specification"

### 5. MCP Prompt Definition Schema Requirements

**Source**: Requirement 7.3 - "Each prompt definition shall include required fields according to MCP specification"

## Research Findings

### 1. MCP Prompt Content Types and Formats

**Supported Content Types:**

- `text`: Plain text content with `text` field (string)
- `image`: Base64-encoded image data with `data` (string) and `mimeType` (string) fields
- `audio`: Base64-encoded audio data with `data` (string) and `mimeType` (string) fields
- `resource`: Embedded resource with `resource` object containing `uri`, `name`, `title`, `mimeType` fields and optional `text`/`data` fields

**Response Structure for prompts/get:**

```json
{
  "messages": [
    {
      "role": "user" | "assistant",
      "content": {
        "type": "text" | "image" | "audio" | "resource",
        "text": "string (for text type)",
        "data": "string (base64, for image/audio)",
        "mimeType": "string (for image/audio)",
        "resource": {
          "uri": "string",
          "name": "string",
          "title": "string",
          "mimeType": "string",
          "text": "string (optional)",
          "data": "string (optional, base64)"
        }
      }
    }
  ],
  "description": "string (optional)"
}
```

### 2. MCP Prompt Argument Validation Patterns

**Required Validation:**

- All arguments marked `required: true` must be present
- Type checking against argument schema (typically strings)
- No additional/unknown arguments should be accepted
- Argument values must pass injection protection validation

**Error Handling Requirements:**

- Missing required arguments: Return specific error identifying missing argument(s)
- Invalid argument types: Return error describing type mismatch
- Unknown prompts: Return "Prompt not found: {name}" error
- Schema violations: Return structured error with validation details

**Security Requirements:**

- All prompt inputs must be validated and sanitized against injection attacks
- Follow least-privilege principles for sensitive operations

### 3. MCP Prompt Function Interface and Return Format

**Function Parameters:**
Prompt functions receive arguments as key-value object matching the prompt's argument schema:

```json
{
  "name": "prompt-name",
  "arguments": {
    "arg1": "value1",
    "arg2": "value2"
  }
}
```

**Expected Return Format:**
Functions must return structured message format:

```json
{
  "description": "string (optional)",
  "messages": [
    {
      "role": "user" | "assistant",
      "content": {
        "type": "text",
        "text": "rendered prompt content"
      }
    }
  ]
}
```

**Key Requirements:**

- Functions are templates rendered server-side with client-provided arguments
- Return value is list of chat messages with role and content
- Content minimally requires text string but supports multimodal types
- Functions should be stateless and isolated

### 4. MCP Prompts Capability Declaration Format

**Required Declaration Structure:**

```json
{
  "capabilities": {
    "prompts": {
      "listChanged": true
    }
  }
}
```

**Required Fields:**

- `prompts` (object): Required key to signal prompts support
- `listChanged` (boolean): Required field indicating whether server emits notifications when prompt list changes
  - `true`: Server will emit notifications on prompt list changes
  - `false`: Prompt list is static, no notifications sent

**Integration:**

- Must be included in server capabilities during MCP initialization
- Can be combined with other capabilities (`tools`, `resources`) in same object

### 5. MCP Prompt Definition Schema Requirements

**Required Fields:**

- `name` (string): Unique identifier for the prompt

**Optional Fields:**

- `title` (string): Human-readable name for display
- `description` (string): Human-readable purpose description
- `arguments` (array): List of prompt arguments

**Argument Schema (when arguments present):**

```json
{
  "name": "string (required)",
  "description": "string (optional)",
  "required": "boolean (optional, defaults to false)"
}
```

**Complete Schema Structure:**

```json
{
  "name": "string (required)",
  "title": "string (optional)",
  "description": "string (optional)",
  "arguments": [
    {
      "name": "string (required)",
      "description": "string (optional)",
      "required": "boolean (optional)"
    }
  ]
}
```

**Key Requirements:**

- Only `name` field is mandatory for prompt definitions
- Arguments array is optional but when present, each argument must have `name`
- Schema designed for JSON Schema compatibility and interoperability
- Structure supports extensibility while maintaining minimal requirements
