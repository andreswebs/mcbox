---
title: Library and Server
description: Understanding the separation between mcbox-core.bash library and mcbox-server.bash reference implementation.
---

**mcbox** is designed around a clear architectural separation between **library** and **server implementation**. This design enables users to either configure and run the provided reference server or build completely custom MCP servers using the core functionality.

## `mcbox-core.bash` (Library)

The **core library** contains all the fundamental MCP protocol functions and utilities needed to build an MCP server in Bash. It provides:

- **MCP Protocol Handling** - Complete JSON-RPC and MCP message processing
- **Configuration Management** - Functions to load and validate server and tool configurations
- **Tool Execution Engine** - Framework for discovering, validating, and executing tool functions
- **JSON Processing** - Utilities for JSON schema validation and manipulation
- **Error Handling and Logging** - Standardized error responses and logging

The library is **purely functional** - it defines capabilities but doesn't run anything by itself. You can source it in any Bash script to gain MCP server functionality.

## `mcbox-server.bash` (Reference Implementation)

The **reference server** is a complete, working MCP server that uses the core library. It provides:

- **Signal Handling** - Graceful shutdown on SIGINT/SIGTERM, configuration reload on SIGHUP
- **Configuration Loading** - Automatic discovery and loading of configuration files
- **Server Loop** - The main `mcp_server` event loop that processes incoming requests
- **Default Behavior** - Sensible defaults for a typical MCP server deployment

This is what most users will run directly, but it's also a **template** for building custom servers.
