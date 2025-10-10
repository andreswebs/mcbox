---
title: Development
description: How to set up a development environment for contributing to mcbox.
---

This guide shows you how to set up a development environment for mcbox and get ready to make contributions.

Check the [Contributing](https://github.com/andreswebs/mcbox?tab=contributing-ov-file) guidelines to understand how we assess contributions.

Check the [Security Policy](https://github.com/andreswebs/mcbox?tab=security-ov-file) for details on how to report security issues.

## Prerequisites

Before you begin, ensure you have:

- **Git** - For version control and repository management
- **GPG** - For commit signing (required for contributions)
- **GitHub account** - With GPG key configured for verified commits
- **Unix-like environment** - macOS, Linux, or WSL on Windows

## Step 1: Install Development Dependencies

Look up how to install these tools using your preferred package manager tool, depending on your OS.

### Core Dependencies

- `bash`
- `jq`

### Development Tools

- `shellcheck`
- `shfmt`

### Node.js

Install Node.js (LTS version) for end-to-end testing. Example:

```bash
# Install Node.js using fnm (recommended)
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.bashrc  # or ~/.zshrc
fnm install --lts
fnm use lts-latest
```

### Set Up EditorConfig

Install the EditorConfig extension for your IDE to automatically apply the project's formatting rules:

- **VS Code**: Install the "EditorConfig for VS Code" extension
- **Vim**: Install the `editorconfig-vim` plugin
- **Emacs**: Install the `editorconfig-emacs` package
- **Other editors**: Check [editorconfig.org](https://editorconfig.org/) for your editor

### Verify Installation

Check that all tools are properly installed:

```bash
bash --version
jq --version
shellcheck --version
shfmt --version
node --version
npm --version
```

## Step 2: Fork and Clone the Repository

1. **Fork the repository** on GitHub by visiting [github.com/andreswebs/mcbox](https://github.com/andreswebs/mcbox) and clicking "Fork"

2. **Clone your fork:**

   ```bash
   git clone https://github.com/YOUR-USERNAME/mcbox.git
   cd mcbox
   ```

3. **Add the upstream remote:**

   ```bash
   git remote add upstream https://github.com/andreswebs/mcbox.git
   ```

4. **Initialize git submodules** (for the testing framework):

   ```bash
   git submodule update --init --recursive
   ```

## Step 3: Set Up Your Development Environment

### Configure Git

Set up your Git configuration for signed commits:

```bash
# Configure your identity (use --global if you want this to be your global configuration)
git config --local user.name "Your Name"
git config --local user.email "your.email@example.com"

# Enable GPG signing (replace with your GPG key ID)
git config --local user.signingkey YOUR_GPG_KEY_ID
```

## Step 4: Verify Your Setup

### Run the Test Suite

Execute all tests to ensure everything works:

```bash
# Run all unit tests
./test/test.bash

# Run a specific test file
./test/bats/bin/bats ./test/mcp_handle_tool_call.test.bats

# Run end-to-end tests
./test/bats/bin/bats ./test/e2e.test.bats
```

All tests should pass.

### Run Code Quality Checks

Verify code formatting and linting:

```bash
# Check shell script quality
find . -type f -name '*.bash' ! -path '*/bats*/*' | xargs shellcheck

# Check formatting (shows differences)
shfmt --indent 4 --diff ./*.bash
shfmt --indent 4 --diff ./test/*.bats
```

No output means everything is properly formatted. If there are formatting issues, fix them:

```bash
# Auto-format shell scripts
shfmt --indent 4 --write ./*.bash
shfmt --indent 4 --write ./test/*.bats
```

### Test the Smoke Test Server

To run the development smoke test server:

```bash
./test/helpers/smoketest-server/mcbox.bash
```

Test it with the MCP Inspector:

```bash
npx @modelcontextprotocol/inspector ./test/helpers/smoketest-server/mcbox.bash
```

## Step 5: Make Your Changes

### Development Workflow

1. **Make your changes** to the appropriate files:

   - `mcbox-core.bash` - Core library functions
   - `mcbox-server.bash` - Reference server implementation
   - `test/*.test.bats` - Unit tests
   - `defaults/` - Default configuration files

2. **Add tests** for new functionality:

   ```bash
   # Create test file for new function
   cp test/template.test.bats test/your_function_name.test.bats
   # Edit the test file to test your function
   ```

3. **Run tests frequently:**

   ```bash
   ./test/test.bash
   ```

4. **Check code quality:**
   ```bash
   shellcheck your-modified-files.bash
   shfmt --indent 4 --diff your-modified-files.bash
   ```

### Testing Guidelines

- **Write tests first** when adding new functions
- **Test both success and failure cases**
- **Use descriptive test names** that explain what's being tested
- **Test files should be named** `function_name.test.bats`
- **Use test fixtures** in `test/fixtures/` for reusable test data

### Code Style Guidelines

Follow the project's shell scripting conventions:

- **Use 4-space indentation** for bash scripts
- **Always use double brackets** for conditionals: `[[ condition ]]`
- **Quote variables** properly: `"${VARIABLE}"`
- **Use strict mode** for scripts: `set -o errexit -o nounset -o pipefail`
- **Add function documentation** for complex functions
- **Follow the `.editorconfig`** rules

## Step 6: Prepare Your Contribution

### Commit Your Changes

Create a single, well-formatted commit:

```bash
# Stage your changes
git add .

# Signed commit with a descriptive message
git commit --gpg-sign --signoff --message "feat: add new prompt handler function

- Add input validation for prompt requests
- Include comprehensive test coverage
- Update documentation for new functionality

Closes #123"
```

### Commit Message Format

Follow the conventional commit format:

<https://www.conventionalcommits.org/en/v1.0.0/#specification>

```txt
type(scope): short description

Longer description explaining what changed and why.

Closes #issue-number
```

**Type examples:**

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `test:` - Test additions or modifications
- `refactor:` - Code refactoring
- `style:` - Code style changes

Other types are allowed, such as `build`, `ci`, `chore`, when it makes sense.

### Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
# Visit: https://github.com/YOUR-USERNAME/mcbox/compare
```

## Step 7: Maintain Your Development Environment

### Keep Your Fork Updated

Regularly sync with the upstream repository:

```bash
# Fetch upstream changes
git fetch upstream

# Update your main branch
git checkout main
git merge upstream/main

# Rebase your feature branch (if needed)
git checkout feature/your-feature-name
git rebase main
```

### Update Dependencies

Periodically update your development tools:

```bash
# Update Node.js
fnm install --lts
fnm use lts-latest

# Update packages (macOS)
brew update && brew upgrade
```

## Common Development Tasks

### Manual Testing

```bash
# Source the library for interactive testing
source mcbox-core.bash

# Test functions directly
is_valid_json '{"valid":"json"}'
```

## Getting Help

- **GitHub Discussions**: For questions and proposals
- **GitHub Issues**: For bug reports and feature requests
- **Contributing Guide**: See `CONTRIBUTING.md` for detailed contribution requirements
- **Code of Conduct**: See `CODE_OF_CONDUCT.md` for community guidelines

Your development environment is now ready for contributing to **mcbox**!
