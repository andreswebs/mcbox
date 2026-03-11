# Product Requirements Document: MCP Prompts Support for mcbox

## Introduction

This document defines the requirements for adding MCP (Model Context Protocol) prompts support to mcbox, a lightweight MCP server implementation written in Bash and jq. Currently, mcbox supports the MCP tools capability, allowing AI agents to discover and execute tools. This feature will extend mcbox to support the prompts capability, enabling AI agents to discover and request structured prompts that can provide context, templates, or guidance for specific tasks.

MCP prompts are reusable pieces of context or templates that AI agents can request to improve their understanding of specific domains, tasks, or workflows. Unlike tools which execute actions, prompts provide structured information or templates that agents can use to enhance their responses.

## Requirements

### 1. Prompt Discovery and Listing

**User Story**: As an AI agent, I want to discover available prompts from the mcbox server, so that I can understand what contextual information or templates are available.

**Acceptance Criteria**:

1. The mcbox server shall support the `prompts/list` MCP method.
2. WHEN an AI agent sends a `prompts/list` request, the mcbox server shall return a list of all available prompts.
3. The mcbox server shall include prompt metadata in the response including name, description, and arguments schema.
4. The mcbox server shall validate that all returned prompts conform to the MCP prompts specification.

### 2. Prompt Configuration Management

**User Story**: As a developer, I want to define prompts in a configuration file, so that I can manage available prompts without modifying the core server code.

**Acceptance Criteria**:

1. The mcbox server shall read prompt definitions from a JSON configuration file.
2. The mcbox server shall support an environment variable `MCBOX_PROMPTS_CONFIG_FILE` to specify the prompts configuration file location.
3. WHERE no custom prompts configuration file is specified, the mcbox server shall use `${XDG_CONFIG_HOME}/mcbox/prompts.json` as the default location.
4. WHERE the XDG_CONFIG_HOME environment variable is not set, the mcbox server shall use `~/.config/mcbox/prompts.json` as the default location.
5. The mcbox server shall validate the prompts configuration file against a JSON schema.
6. IF the prompts configuration file is invalid or unreadable, the mcbox server shall log an error and continue with zero available prompts.

### 3. Prompt Request Handling

**User Story**: As an AI agent, I want to request specific prompts with arguments, so that I can receive customized contextual information or templates.

**Acceptance Criteria**:

1. The mcbox server shall support the `prompts/get` MCP method.
2. WHEN an AI agent sends a `prompts/get` request with a prompt name and arguments, the mcbox server shall return the rendered prompt content.
3. The mcbox server shall return prompt content in the format specified by the MCP specification _(NEEDS CLARIFICATION: Research MCP spec for supported prompt content types and formats)_.
4. The mcbox server shall validate prompt arguments against the prompt's input schema.
5. The mcbox server shall validate prompt arguments according to MCP specification requirements _(NEEDS CLARIFICATION: Research MCP spec for prompt argument validation patterns)_.
6. IF invalid arguments are provided, the mcbox server shall return a JSON-RPC error response with validation details.
7. IF a requested prompt does not exist, the mcbox server shall return a JSON-RPC error response indicating the prompt was not found.

### 4. Prompt Implementation System

**User Story**: As a developer, I want to implement prompt logic in Bash functions, so that I can create dynamic prompts that generate content based on input arguments.

**Acceptance Criteria**:

1. The mcbox server shall load prompt implementations from a Bash script file.
2. The mcbox server shall support an environment variable `MCBOX_PROMPTS_LIB_FILE` to specify the prompts implementation file location.
3. WHERE no custom prompts implementation file is specified, the mcbox server shall use `${XDG_CONFIG_HOME}/mcbox/prompts.bash` as the default location.
4. WHERE the XDG_CONFIG_HOME environment variable is not set, the mcbox server shall use `~/.config/mcbox/prompts.bash` as the default location.
5. The mcbox server shall discover prompt functions using a configurable naming convention.
6. The mcbox server shall support an environment variable `MCBOX_PROMPTS_FUNCTION_NAME_PREFIX` to specify the prompt function naming prefix.
7. WHERE no custom prefix is specified, the mcbox server shall use `prompt_` as the default prefix.
8. Prompt functions shall accept arguments and return content according to MCP specification requirements _(NEEDS CLARIFICATION: Research MCP spec for prompt function interface and return format)_.
9. Prompt functions shall be stateless and isolated (no dependencies on tools or other prompts).

### 5. Server Capability Declaration

**User Story**: As an AI agent, I want to know if the mcbox server supports prompts during initialization, so that I can determine which MCP capabilities are available.

**Acceptance Criteria**:

1. WHEN prompts are configured and available, the mcbox server shall include prompts capability in the server capabilities during MCP initialization.
2. The mcbox server shall declare prompts capabilities according to MCP specification _(NEEDS CLARIFICATION: Research MCP spec for prompts capability declaration format and options)_.
3. WHERE no prompts are configured or available, the mcbox server shall not include prompts capability in the server capabilities.

### 6. Error Handling and Validation

**User Story**: As a developer, I want comprehensive error handling for prompt operations, so that I can diagnose and fix issues with prompt configurations and implementations.

**Acceptance Criteria**:

1. The mcbox server shall validate all prompt request parameters against JSON schemas.
2. IF a prompt function returns invalid content, the mcbox server shall return a JSON-RPC error response.
3. IF a prompt function execution fails, the mcbox server shall return a JSON-RPC error response with execution details.
4. The mcbox server shall log all prompt-related errors to stderr for debugging purposes.
5. The mcbox server shall continue operating normally even if individual prompt operations fail.
6. The mcbox server shall provide immediate failure reporting without retry mechanisms for failed prompt operations.

### 7. Configuration Schema Validation

**User Story**: As a developer, I want the prompts configuration to be validated against a schema, so that I can catch configuration errors early and ensure reliable operation.

**Acceptance Criteria**:

1. The mcbox server shall define a JSON schema for prompt configurations.
2. The mcbox server shall validate the prompts configuration file against this schema on startup.
3. Each prompt definition shall include required fields according to MCP specification _(NEEDS CLARIFICATION: Research MCP spec for required prompt definition fields and schema format)_.
4. The prompt configuration schema shall follow MCP specification requirements for prompt definitions.
5. IF the prompts configuration fails schema validation, the mcbox server shall log detailed validation errors.

### 8. Integration with Existing Architecture

**User Story**: As a developer, I want prompts support to integrate seamlessly with the existing mcbox architecture, so that the implementation is consistent and maintainable.

**Acceptance Criteria**:

1. The prompts implementation shall follow the same architectural patterns as the existing tools implementation.
2. The prompts implementation shall use the existing JSON-RPC and logging infrastructure.
3. The prompts implementation shall use the existing configuration loading and validation patterns.
4. The prompts implementation shall not break existing tools functionality.
5. The prompts implementation shall support the same error handling patterns as tools.

### 9. Default Prompts Configuration

**User Story**: As a user, I want default prompts configuration files to be provided, so that I can understand the expected format and have working examples.

**Acceptance Criteria**:

1. The mcbox distribution shall include a default `prompts.json` configuration file with example prompts.
2. The mcbox distribution shall include a default `prompts.bash` implementation file with example prompt functions.
3. The default configuration shall demonstrate common prompt patterns and best practices.
4. The default implementations shall serve as documentation for developers creating custom prompts.

### 10. Backward Compatibility

**User Story**: As an existing mcbox user, I want the prompts feature to not break my current setup, so that I can upgrade mcbox without disruption.

**Acceptance Criteria**:

1. The mcbox server shall continue to function normally for users who do not configure prompts.
2. WHERE prompts configuration files do not exist, the mcbox server shall operate with zero available prompts without errors.
3. The existing tools functionality shall remain unchanged and unaffected by prompts implementation.
4. The MCP initialization process shall remain backward compatible with existing AI agent integrations.

## Success Criteria

- AI agents can successfully discover and request prompts from mcbox servers
- Developers can easily create and configure custom prompts using Bash functions
- The prompts feature integrates seamlessly with existing mcbox functionality
- The implementation follows mcbox's principles of simplicity and minimal dependencies
- The feature is well-documented with working examples and clear configuration patterns

## Out of Scope

- Dynamic prompt discovery (prompts added/removed without server restart)
- Advanced prompt templating engines beyond simple Bash string manipulation
- Prompt caching or performance optimization features
- GUI or web-based prompt management interfaces
- Integration with external prompt repositories or marketplaces
- Real-time prompt synchronization across multiple mcbox instances
- Retry mechanisms for failed prompt operations
- Prompt dependencies on tools or other prompts
