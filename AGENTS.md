# CLAUDE.md

## Project overview

**mcbox** is a pluggable MCP (Model Context Protocol) server written in Bash and jq. It uses stdio transport only. The core library is `mcbox-core.bash` (sourced, not executed directly) and the server entry point is `mcbox-server.bash`.

## Key files

- `mcbox-core.bash` — core library with all MCP/JSON-RPC/JSON Schema functions (sourced via `source`)
- `mcbox-server.bash` — server entry point (executed directly)
- `defaults/` — default config files: `server.json`, `tools.json`, `tools.bash`
- `test/` — all tests (Bats unit tests + e2e tests)
- `docsite/` — Astro-based documentation site
- `docs/specs/product.md` — product requirements and feature specifications
- `docs/specs/tech.md` — technical architecture and design decisions

## Shell scripting conventions

- Shebang: `#!/usr/bin/env bash`
- Extension: `.bash` for all Bash scripts
- Indent: 4 spaces for `.bash`/`.sh` files, 2 spaces for everything else (see `.editorconfig`)
- Strict mode for directly-executed scripts: `set -o errexit -o nounset -o pipefail`
- Always quote variable references with braces: `"${VAR}"` (not `$VAR`, `${VAR}`, or `"$VAR"`)
- Use long-form flags when available (e.g. `--recursive` not `-r`)
- Do not add unnecessary comments — only explain _why_, not _what_
- stdout is reserved for function return values; use stderr for logs/errors
- Use the `log` function family for logging (not raw `echo >&2`)

## Validation

Run all checks (formatting, lint, tests) in one step:

```sh
./scripts/validate.bash
```

## Formatting and linting

```sh
./test/shfmt.bash          # check formatting
./test/shellcheck.bash     # lint
```

```sh
WRITE=true ./test/shfmt.bash  # fix formatting
```

Tools: `shfmt` (indent 4) and `shellcheck`.

## Testing

Framework: [Bats](https://bats-core.readthedocs.io/) with helpers (`bats-assert`, `bats-support`, `bats-file`), included as git submodules under `test/`.

```sh
./test/test.bash                                    # run all tests
./test/bats/bin/bats test/<function_name>.test.bats  # run a specific test
./test/bats/bin/bats test/e2e.test.bats             # run e2e tests
```

- Unit test files: `test/<function_name>.test.bats`
- E2E tests: `test/e2e.test.bats` (requires Node.js for `npx`)
- Smoke test server: `./test/helpers/smoketest-server/mcbox.bash`
- Use Bats temp dirs (`BATS_FILE_TMPDIR`, `BATS_TEST_TMPDIR`, `BATS_SUITE_TMPDIR`) for filesystem ops in tests

## Commits and PRs

- Follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages
- Commits must be GPG-signed and DCO signed-off (`git commit -S -s`)
- Each PR must be a single squashed commit
- See `CONTRIBUTING.md` for full details

## CI/CD

GitHub Actions workflows in `.github/workflows/`:

- `pull-request.yaml` — PR checks
- `build.yaml` / `build.dispatch.yaml` — build pipeline
- `test.dispatch.yaml` — test pipeline
- `docs.yaml` — documentation site deployment
- `scorecard.yml` — OpenSSF Scorecard

## Dependencies

Runtime: `bash`, `jq`
Development: `shellcheck`, `shfmt`, Node.js (LTS, for e2e tests via `npx`)
