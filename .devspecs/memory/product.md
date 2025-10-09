---
applyTo: "**/*"
---

# Product Brief: mcbox

## Why

mcbox exists to provide a simple MCP (Model Context Protocol) server implementation to run local tools using only Bash. It offers a low-overhead, pluggable framework for running tools for AI agents, simplifying the process and reducing complexity.

- Simplifies the process of running a local MCP server.
- Reduces overhead by using only Bash and `jq`.
- Provides a lightweight solution for developers working with AI agents.

## Core Functional Requirements

1. **MCP Implementation**:

   - Must be implemented using only Bash and `jq`.

2. **Transport**:

   - Supports **stdio transport** exclusively (no other transport methods will be supported).

3. **Configuration**:

   - Reads a **server configuration file** from the local file system in JSON format.
   - Reads a **tools configuration file** from the local file system in JSON format.
   - Reads a **tools script file** from the local file system in Bash.

4. **Library and Default Implementation**:
   - Designed as a **Bash library** with functions to implement the MCP server.
   - Includes a **default implementation** capable of running tools as plugins.

## Goals

- To enable running a local MCP server with minimal overhead.

## User Experience Goals

- To be **simple and intuitive**.
- Users should only need to source a **single Bash file** as a library to use it to build their own MCP server.
- Users should be able to run a **single Bash script** to start the server. The script sources the library.

## Target Audience

- **Developers** who are working with **AI agents** and need a lightweight, local MCP server solution.

## Success Criteria

- **Ease of use**: The product should be simple to set up and use, requiring minimal effort from developers.

## Unique Value Proposition

- A **minimalistic MCP server** implemented entirely in **Bash**, offering simplicity and low overhead.

## Project Scope

- **Exclusions**:
  - No support for **concurrency** or **parallel processing**.
  - **Limited memory management** capabilities.
  - No support for **streaming responses**.
  - Not designed for **high throughput** use cases.
  - No MCP transports other than `stdio`.

These limitations are acceptable for the intended use case of AI assistants and local tool execution.

## Key Deliverables

1. **mcbox-core.bash**:

   - A Bash file containing all the server functions.
   - Can be sourced to create MCP servers in Bash.

2. **mcbox.bash**:
   - A reference implementation of a pluggable MCP server.
   - Built using `mcbox-core.bash`.
