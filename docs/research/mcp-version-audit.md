# MCP Version Compliance Audit

**Date:** 2026-03-11
**Schema version audited:** 2025-11-25
**Previous schema:** 2025-06-18
**Source:** `docs/refs/mcp.2025-11-25.schema.json`, `docs/refs/mcp.versions.yaml`

---

## Summary

The mcbox server achieves **core compliance** with MCP 2025-11-25 for all implemented feature areas. No breaking violations were found. Several optional features are unimplemented by design (resources, prompts, tasks, multimedia content types).

| Feature Area                  | Status           |
| ----------------------------- | ---------------- |
| Protocol version              | Compliant        |
| `initialize` request/response | Compliant        |
| `tools/list` request/response | Mostly compliant |
| `tools/call` request/response | Mostly compliant |
| JSON-RPC 2.0 layer            | Compliant        |
| Tool schema validation        | Compliant        |
| `ping`                        | Compliant        |
| Notifications                 | Minimal          |
| Resources                     | Not implemented  |
| Prompts                       | Not implemented  |
| Tasks                         | Not implemented  |
| Logging                       | Not implemented  |

---

## 1. Protocol Version

**Advertised version:** `2025-11-25` (`defaults/server.json:2`)
**Test fixture version:** `2025-11-25` (`test/fixtures/smoketest.server.json:2`)
**Status:** Compliant.

**Note:** Several tests in `test/mcp_process_request.test.bats` (lines 30, 107, 114, 121) still send `2025-06-18` as the client's requested protocol version. The server correctly rejects these with `-32602` (`mcbox-core.bash:942–947`).

---

## 2. `initialize` Request/Response

Schema type: `InitializeResult`. Required fields: `protocolVersion`, `serverInfo`, `capabilities`.

### `serverInfo`

`defaults/server.json:3–6`:

```json
{ "name": "mcbox", "version": "0.0.1" }
```

Both required fields (`name`, `version`) present. Compliant.

### `capabilities`

`defaults/server.json:7–10`:

```json
{ "tools": { "listChanged": true } }
```

`tools.listChanged` is a valid boolean per the schema's `ServerCapabilities`. Compliant.

### `instructions`

`defaults/server.json:12`: present as optional string. Compliant.

### `_meta`

Not included. Acceptable — optional.

### Handler

`mcp_handle_initialize()` (`mcbox-core.bash:914–950`):

- Validates protocol version match; rejects mismatches with `-32602`.
- Returns full server config object as result.
- Covered by 13 tests in `test/mcp_handle_initialize.test.bats`.

---

## 3. `tools/list` Request/Response

Schema type: `ListToolsResult`. Required: `tools` (array).

### Tool definition fields

Schema requires `name` and `inputSchema`. Optional: `description`, `outputSchema`, `title`, `annotations`, `icons`, `execution`, `_meta`.

`defaults/tools.json` example:

```json
{
  "name": "file_size",
  "description": "Get the size of a file in bytes",
  "inputSchema": {
    "type": "object",
    "properties": { "path": { "type": "string" } },
    "required": ["path"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "size": { "type": "number" },
      "path": { "type": "string" }
    },
    "required": ["size", "path"]
  }
}
```

`name` and `inputSchema` present. `description` and `outputSchema` present. Compliant.

### Missing optional fields

The following optional tool fields are not supported:

- `title`
- `annotations`
- `icons`
- `execution`
- `_meta` (on tool definition)

### Missing result fields

- `nextCursor` — pagination not implemented. If a server advertises many tools, clients expecting cursor-based pagination will not be supported.
- `_meta` — not included in the result.

### Handler

`mcp_handle_tools_list()` (`mcbox-core.bash:967–995`). Validates config against an internal `TOOLS_SCHEMA`. Returns `-32603` on read or schema failure. Covered by 8 tests in `test/mcp_handle_tools_list.test.bats`.

---

## 4. `tools/call` Request/Response

Schema type: `CallToolResult`. Required: `content` (array of `ContentBlock`). Optional: `isError`, `structuredContent`, `_meta`.

### `content` array

`mcp_create_text_content_object()` (`mcbox-core.bash:1004–1023`) produces:

```json
{ "type": "text", "text": "..." }
```

Matches `TextContent` schema (required: `type` const `"text"`, `text` string). Compliant.

The following `ContentBlock` variants are **not implemented**:

- `ImageContent`
- `AudioContent`
- `ResourceLink`
- `EmbeddedResource`

### `isError`

Generated as `{"isError": true}` on tool execution failure (`mcbox-core.bash:1129`). Compliant.

### `structuredContent`

Generated when `outputSchema` is defined and tool output passes validation (`mcbox-core.bash:1164`). Compliant.

### `_meta`

Not included. Acceptable — optional.

### `TextContent` optional fields

- `annotations` — not included.
- `_meta` — not included.

Both are optional.

### Tool argument validation

Arguments validated against `inputSchema` via `jsonschema_validate_schema()` (`mcbox-core.bash:1101–1107`). Returns `-32602` on mismatch. Compliant.

### Handler

`mcp_handle_tool_call()` (`mcbox-core.bash:1025–1172`):

- Tool name validated against `[a-zA-Z0-9_]+` pattern (`mcbox-core.bash:1073`).
- Tool looked up in config; returns `-32602` if not found.
- Arguments validated against `inputSchema`.
- Tool executed as `${prefix}${name}` Bash function.
- Output validated against `outputSchema` when present.
- Covered by 27 tests in `test/mcp_handle_tool_call.test.bats`.

---

## 5. JSON-RPC 2.0 Layer

All error codes used are from the standard JSON-RPC 2.0 set:

| Code     | Meaning          | Locations                                                                             |
| -------- | ---------------- | ------------------------------------------------------------------------------------- |
| `-32700` | Parse error      | `mcbox-core.bash:1058, 1188`                                                          |
| `-32600` | Invalid Request  | `mcbox-core.bash:1197, 1206, 1213`                                                    |
| `-32601` | Method not found | `mcbox-core.bash:1249`                                                                |
| `-32602` | Invalid params   | `mcbox-core.bash:945, 1065, 1076, 1083, 1105`                                         |
| `-32603` | Internal error   | `mcbox-core.bash:930, 981, 990, 1043, 1052, 1093, 1125, 1131, 1142, 1148, 1160, 1166` |

Request validation (`mcbox-core.bash:1192–1215`):

- Checks `jsonrpc == "2.0"`.
- Validates `id` via `jsonrpc_validate_id()` (`mcbox-core.bash:474–516`): accepts string, positive integer, null; rejects negative integers, fractions, booleans, arrays, objects.

Response structure:

- Success: `jsonrpc_create_result_response()` (`mcbox-core.bash:686–712`).
- Error: `jsonrpc_create_error_response()` (`mcbox-core.bash:617–645`).

Both match the JSON-RPC 2.0 envelope schema. Compliant.

---

## 6. Notifications

Handler: `mcp_handle_notification()` (`mcbox-core.bash:952–965`).

Supported:

- `notifications/initialized` — returns success (no response sent, as required for notifications).

Unsupported:

- `notifications/cancelled`
- `notifications/progress`
- `tools/list_changed` (server-to-client; not applicable here)
- `resources/list_changed`
- `prompts/list_changed`

Receiving unknown notifications returns a non-zero exit code internally, but no response is sent to the client (correct per the JSON-RPC spec — notifications must not produce a response). Compliant for `notifications/initialized`; all others silently rejected.

---

## 7. Unimplemented Methods

The following MCP methods exist in the schema but are not handled (returning `-32601` Method not found):

**Resources**

- `resources/list`
- `resources/read`
- `resources/subscribe`
- `resources/unsubscribe`
- `resources/templates/list`

**Prompts**

- `prompts/list`
- `prompts/get`

**Tasks** (new in 2025-11-25)

- `tasks/list`
- `tasks/get`
- `tasks/cancel`
- `tasks/payloads/get`

**Completion**

- `completion/complete`

**Logging**

- `logging/setLevel`

None of these are required for a tools-only server. The absence of resources and prompts does not violate the spec if they are not advertised in `capabilities` — and they are not (`defaults/server.json` only advertises `tools`).

---

## 8. Changes Between 2025-06-18 and 2025-11-25

The following features were added in 2025-11-25 and are absent from the implementation:

- **Tasks** (`tasks/*`) — async long-running operation tracking.
- **`AudioContent`** content block type.
- **URL mode elicitation** — client-side out-of-band interaction.
- **`execution` field on tools** — hints about tool execution behaviour.
- **`icons` field on tools** — visual icons for servers and tools.
- **`title` field on tools** — human-readable display name distinct from `name`.
- **Sampling with tools** — server-side agent loops via `createMessage`.
- **Extensions framework** — optional capability extensions.
- **Client credentials flow** in authorization.

None of these are implemented. Most are optional extensions; none are required for a compliant tools server.

---

## 9. Findings Requiring Attention

These are not spec violations but are worth reviewing:

1. **Test inputs using old protocol version.** `test/mcp_process_request.test.bats` lines 30, 107, 114, 121 send `"2025-06-18"` as the client's `protocolVersion`. The server correctly rejects them, but the tests may be asserting the wrong error scenario if the intent is to test valid requests.

2. **No pagination on `tools/list`.** The schema defines `nextCursor` / `cursor` for paginating large tool lists. If the server is ever extended with many tools, clients relying on pagination will not be supported without implementation changes.

3. **Tool name character restriction.** The server restricts tool names to `[a-zA-Z0-9_]+` (`mcbox-core.bash:1073`). The MCP schema does not impose this restriction beyond using a JSON string. This is a stricter local constraint, not a violation, but may reject valid tool names that include hyphens or dots.

4. **`listChanged: true` advertised but not enforced.** The server advertises `tools.listChanged: true` in capabilities, implying it will send `tools/list_changed` notifications when the tool list changes. No such notification is ever sent. This is a capability claim that is not backed by behaviour.
