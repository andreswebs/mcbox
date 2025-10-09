---
applyTo: "**/*"
---

# Technology Brief: mcbox

## Core Technologies

### Runtime Environment

- **Bash**: Primary implementation language and runtime environment
- **jq**: JSON processing and manipulation tool for MCP protocol handling
- **Minimal Dependencies**: Only Bash and jq required for end-user deployment

### Protocol Implementation

- **Model Context Protocol (MCP)**: JSON-based protocol for AI agent communication
- **JSON-RPC**: Underlying RPC protocol for MCP message handling
- **stdio Transport**: Exclusive transport method for process communication
- **Protocol Version**: 2025-06-18 (as specified in default server configuration)

## Architecture

### Library Design

- **mcbox-core.bash**: Core library providing MCP server functions
- **mcbox-server.bash**: Reference implementation demonstrating library usage
- **Modular Architecture**: Developers can source core library to build custom MCP servers
- **Plugin System**: Tools loaded as Bash functions with configurable naming conventions

### Configuration System

- **JSON Configuration**: Server and tools configuration via JSON files
- **XDG Base Directory Specification**: Default file locations follow XDG standards
- **Environment Variable Override**: All configuration paths configurable via `MCBOX_*` environment variables
  - `MCBOX_SERVER_CONFIG_FILE`: Server configuration location
  - `MCBOX_TOOLS_CONFIG_FILE`: Tools configuration location
  - `MCBOX_TOOLS_LIB_FILE`: Tools implementation script location
  - `MCBOX_TOOLS_FUNCTION_NAME_PREFIX`: Tool function naming prefix (default: `tool_`)
  - `MCBOX_CORE_LIB_FILE`: Core library location

### Tool Loading Mechanism

- **Convention-Based Naming**: Tools implemented as Bash functions with `tool_*` prefix (configurable)
- **Dynamic Loading**: Tools sourced from `tools.bash` script at runtime
- **JSON Schema Validation**: Input and output validation for tool parameters and results
- **Function Export**: Tools must be exported for discoverability

## Development Tools

### Testing Framework

- **BATS (Bash Automated Testing System)**: Testing framework aligned with Bash-first approach
- **Comprehensive Test Suite**: Unit tests for all core functions and integration scenarios
- **Fixture-Based Testing**: Test data and configurations in `test/fixtures/` directory

### Code Quality Tools

- **shellcheck**: Static analysis for shell script quality and best practices
- **shfmt**: Code formatting with 4-space indentation standard
- **Strict Mode**: Error handling with `set -o errexit`, `set -o nounset`, `set -o pipefail`

### CI/CD and Release Management

- **GitHub Actions**: Continuous integration and deployment workflows
- **SLSA Level 3 Attestations**: Supply chain security and provenance tracking
- **Homebrew Distribution**: Primary installation method via custom Homebrew tap
- **Future Nix Support**: Planned package management integration

### Documentation

- **Astro Framework**: Documentation site generation and hosting
- **TypeScript Configuration**: Enhanced development experience for documentation site

## Security Model

### Trust Assumptions

- **Trusted Local Environment**: Designed for developer-controlled local environments
- **User Privilege Level**: Executes with same privileges as user running the server
- **No Sandboxing**: Tools run with full user permissions
- **Developer Responsibility**: Security depends on trusted AI agents and vetted tools

### Input Validation

- **JSON Schema Validation**: Comprehensive input/output validation for reliability
- **Parameter Sanitization**: Tool name validation with alphanumeric and underscore constraints
- **Error Handling**: Robust error handling for malformed requests and protocol violations

## Performance Characteristics

### Design Constraints

- **Single-Threaded**: No concurrency or parallel processing support
- **Sequential Execution**: Tools executed one at a time
- **Limited Memory Management**: Basic memory handling capabilities
- **No Streaming**: Synchronous request-response pattern only

### Target Use Cases

- **Local Development**: Single-user development environments
- **AI Agent Integration**: Local AI agents requiring tool execution
- **Low Throughput**: Not designed for high-performance or production workloads
- **Interactive Use**: Human-in-the-loop development scenarios

## MCP Protocol Implementation

### Current Capabilities

- **Tools**: Complete tool definition, listing, and execution support
- **Server Initialization**: MCP handshake and capability negotiation
- **Error Handling**: JSON-RPC error responses with detailed error information
- **Schema Validation**: Input/output schema validation for tool parameters

### Planned Features

- **Prompts**: Planned support for MCP prompt capabilities
- **Resources**: Planned support for MCP resource management
- **Sampling**: Planned support for MCP sampling capabilities

## File System Organization

### Default Installation Paths

- **Data Directory**: `${XDG_DATA_HOME}/mcbox` (typically `~/.local/share/mcbox`)
- **Configuration Directory**: `${XDG_CONFIG_HOME}/mcbox` (typically `~/.config/mcbox`)
- **Binary Installation**: `~/.local/bin/mcbox` (symlink to server script)

### Configuration Files

- **server.json**: Server metadata and capabilities configuration
- **tools.json**: Tool definitions and schemas
- **tools.bash**: Tool implementations as Bash functions

## Integration Patterns

### Library Usage

```bash
# Source the core library
source "${MCBOX_CORE_LIB_FILE}"

# Implement custom server logic
# Custom initialization, tool loading, etc.
```

### Tool Implementation

```bash
# Tool function following naming convention
function tool_example() {
    local arguments="${1}"
    # Tool implementation
    echo "${result_json}"
}

# Export for discoverability
export -f tool_example
```

### Environment Configuration

```bash
# Override default configuration paths
export MCBOX_SERVER_CONFIG_FILE="/custom/path/server.json"
export MCBOX_TOOLS_CONFIG_FILE="/custom/path/tools.json"
export MCBOX_TOOLS_LIB_FILE="/custom/path/tools.bash"
export MCBOX_TOOLS_FUNCTION_NAME_PREFIX="custom_tool_"
```

## Technical Constraints

### Limitations

- **Transport**: stdio only, no network or other transport methods
- **Concurrency**: No parallel tool execution
- **Memory**: Limited memory management capabilities
- **Streaming**: No streaming response support
- **Protocol**: Tools capability only (currently)

### Acceptable Trade-offs

These limitations are intentional design decisions that align with the target use case of local AI agent development environments, prioritizing simplicity and minimal overhead over performance and scalability.
