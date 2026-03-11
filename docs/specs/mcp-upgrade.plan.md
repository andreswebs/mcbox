# Plan: MCP Compliance Fixes

**Source:** `docs/research/mcp-version-audit.md`, findings 1–4
**Schema version:** 2025-11-25

---

## Finding 1 — Tests using stale protocol version

### Problem

Four tests in `test/mcp_process_request.test.bats` send `protocolVersion: "2025-06-18"` in the `initialize` params but assert success:

- Line 30 — `should handle valid initialize request`
- Line 107 — `should handle null id in request`
- Line 114 — `should handle numeric id in request`
- Line 121 — `should handle string id in request`

The server rejects any version that does not match `defaults/server.json`, which now advertises `2025-11-25`. These tests currently either pass against a stale fixture or are silently broken.

### Fix

Update the `protocolVersion` value in those four test inputs from `"2025-06-18"` to `"2025-11-25"`.

No changes to source code or fixtures are required.

### Files

- `test/mcp_process_request.test.bats` — lines 30, 107, 114, 121

---

## Finding 2 — No cursor-based pagination on `tools/list`

### Problem

The MCP schema's `ListToolsResult` includes an optional `nextCursor` field and `tools/list` accepts an optional `cursor` param. The server ignores `cursor` and never emits `nextCursor`, so clients that paginate will silently receive only the first (and only) page.

### Current behaviour

`mcp_handle_tools_list` (`mcbox-core.bash:967`) takes only `id` and always returns the full `tools` array.

`mcp_process_request` (`mcbox-core.bash:1236`) calls `mcp_handle_tools_list "${id}"` without passing `params`.

### Fix

**1. Pass `params` to the handler.**

In `mcp_process_request`, update the `tools/list` case to pass params:

```bash
"tools/list")
    mcp_handle_tools_list "${id}" "${params}"
    return 0
    ;;
```

**2. Add cursor logic to `mcp_handle_tools_list`.**

- Accept an optional second argument `params` (JSON object or empty string).
- Extract `cursor` from params: `jq --raw-output '.cursor // empty'`. The cursor is an opaque base64-encoded integer offset into the tools array.
- Determine page size from `MCBOX_TOOLS_PAGE_SIZE` env var; default to `0` (unlimited, preserving current behaviour).
- When page size is `0`, return all tools with no `nextCursor` (fully backward-compatible default).
- When page size is positive:
  - Decode cursor to an integer offset (default `0` if absent or empty).
  - Slice the tools array: `.[offset:offset+page_size]`.
  - If `length(remaining) > 0`, encode `offset + page_size` as base64 and include it as `nextCursor`.
  - Return `{"tools": [...], "nextCursor": "..."}` or `{"tools": [...]}`.

**Cursor encoding:** use `printf '%d' "${offset}" | base64` / `base64 --decode` to keep the cursor opaque. This avoids exposing internal array indices directly.

**3. Update `TOOLS_SCHEMA` if needed.**

The internal schema used to validate the tools config does not need to change — it validates the config file structure, not the wire response.

**4. Add tests.**

New tests in `test/mcp_handle_tools_list.test.bats`:
- Default (no `MCBOX_TOOLS_PAGE_SIZE`): returns all tools, no `nextCursor`.
- `MCBOX_TOOLS_PAGE_SIZE=1` with 2 tools: first page returns 1 tool and a `nextCursor`.
- Second page using that cursor: returns remaining tool, no `nextCursor`.
- Invalid cursor value: treated as offset `0` (lenient).

New tests in `test/mcp_process_request.test.bats`:
- `tools/list` with `cursor` param passes through correctly.

### Files

- `mcbox-core.bash` — `mcp_handle_tools_list()`, `mcp_process_request()`
- `test/mcp_handle_tools_list.test.bats` — new pagination tests
- `test/mcp_process_request.test.bats` — new cursor passthrough test

---

## Finding 3 — Tool name character restriction too strict

### Problem

The server validates tool names with `^[a-zA-Z0-9_]+$` (`mcbox-core.bash:1073`), rejecting names containing hyphens or dots. The MCP schema imposes no such restriction — `Tool.name` is a plain string. Clients may send tool names like `read-file` or `fs.list` and receive a misleading `Invalid params: tool name is malformed` error.

### Root cause

Tool names are used directly as Bash function name suffixes: `tool_${tool_name}`. Bash function names cannot contain hyphens or dots, so the restriction is real but should be handled transparently rather than exposed as a user-facing error.

### Fix

**Allow hyphens and dots in tool names; translate to underscores when resolving the function name.**

1. Relax the validation regex to `^[a-zA-Z0-9_./-]+$` (allow `-` and `.`; keep the guard against empty strings and shell-special characters).

   Actually, to remain safe for use in Bash function names via translation: only allow `[a-zA-Z0-9_.-]`:

   ```bash
   if ! [[ "${tool_name}" =~ ^[a-zA-Z0-9_.\\-]+$ ]]; then
   ```

2. Before constructing the function name, translate `-` and `.` to `_`:

   ```bash
   local function_name
   function_name=$(printf '%s' "${tool_name}" | tr '.-' '__')
   # then call: ${MCBOX_TOOL_FN_PREFIX}${function_name}
   ```

3. Document the mapping in `defaults/tools.bash` and in `docs/specs/tech.md`.

**Scope of the change:** only `mcp_handle_tool_call()` (`mcbox-core.bash:1073–1077`) and the function-name construction that follows it.

### Tests to update/add

- `test/mcp_handle_tool_call.test.bats`:
  - Existing tests for `special characters` (line ~319) and `spaces` (line ~320) should still fail (they contain characters outside `[a-zA-Z0-9_.-]`).
  - Add new passing tests: tool name `echo-token` maps to function `tool_echo_token`.
  - Add new passing tests: tool name `fs.list` maps to function `tool_fs_list`.

### Files

- `mcbox-core.bash` — `mcp_handle_tool_call()` (~line 1073)
- `test/mcp_handle_tool_call.test.bats` — update existing + add new tests
- `docs/specs/tech.md` — document the name-to-function translation rule

---

## Finding 4 — `listChanged: true` advertised but never emitted

### Problem

`defaults/server.json` advertises `capabilities.tools.listChanged: true`. Per the MCP spec this signals that the server will send `notifications/tools/list_changed` when the tool list changes. The server never sends this notification. The capability claim is false.

### Options considered

| Option | Description | Complexity |
|---|---|---|
| A | Remove the `listChanged` key from `defaults/server.json` | Trivial |
| B | Implement file-watch + notification emission | High; requires background process or polling loop incompatible with the current synchronous stdio model |

Option B is out of scope for a synchronous stdio server with no background event loop. Option A is the correct fix.

### Fix

Remove `listChanged: true` from `defaults/server.json`. The `tools` capabilities object becomes `{}` (or the key can be omitted entirely, as `listChanged` defaults to `false`/absent).

```json
"capabilities": {
  "tools": {}
}
```

Update the test fixture `test/fixtures/smoketest.server.json` the same way if it also advertises `listChanged: true`.

### Tests to update

- `test/mcp_handle_initialize.test.bats` — any test asserting `listChanged: true` in the response should be updated to expect `{}` or the key's absence.
- `test/mcp_handle_tools_list.test.bats` — no changes needed (unrelated to the response body).

### Files

- `defaults/server.json` — remove `listChanged: true`
- `test/fixtures/smoketest.server.json` — remove `listChanged: true` if present
- `test/mcp_handle_initialize.test.bats` — update assertions if any reference `listChanged`

---

## Execution order

The findings are independent and can be worked in any order. Suggested sequence based on risk and size:

1. **Finding 1** — two-minute test-only change, zero risk.
2. **Finding 4** — single-line config change plus fixture/test updates, low risk.
3. **Finding 3** — localised change to one function + regex, medium risk.
4. **Finding 2** — largest change; new handler logic, new tests, env var configuration.
