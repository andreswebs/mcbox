[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/andreswebs/mcbox/badge)](https://scorecard.dev/viewer/?uri=github.com/andreswebs/mcbox)

# $\_mcbox

**mcbox** is a pluggable MCP (Model Context Protocol) server written in [Bash](<https://en.wikipedia.org/wiki/Bash_(Unix_shell)>) and [jq](https://jqlang.org/), fully tested using [Bats](https://bats-core.readthedocs.io/en/stable/), [shellcheck](https://www.shellcheck.net/) and [shfmt](https://github.com/mvdan/sh). It aims to be lightweight, portable, and just **good enough** for AI agents that use local tool execution through `stdio` transport.

The project has a few non-goals:

- No concurrency/parallel processing
- No support for high throughput
- No streaming responses
- No MCP transports other than `stdio`

Aside from that, it's a great way to provide your own tools for local AI agents, and write those tools in any programming language you like.

Check out the [documentation](https://andreswebs.github.io/mcbox/guides/getting-started/) to get started.

## Support

Feel free to open a [GitHub issue](https://github.com/andreswebs/mcbox/issues) to ask for help, file a bug report, or request a new feature.

## Development

Check out the [Contributing](CONTRIBUTING.md) guide and the [Development](https://andreswebs.github.io/mcbox/guides/development) documentation for how to get started with development.

### Prerequisites

You'll need `bash` and `jq` installed to run the MCP server. Both can be installed using your preferred package manager (e.g. [Homebrew](https://brew.sh/)).

```sh
brew install bash
brew install jq
```

For development, you'll also need to install:

- [Node.js](https://nodejs.org/en) (LTS version) and the NPM CLI (which already comes with Node); we recommend using [fnm](https://github.com/Schniz/fnm), the "Fast Node Manager", to install Node's current LTS version. Follow the instructions in [`fnm`'s GitHub repo](https://github.com/Schniz/fnm) to install it.
- [shellcheck](https://www.shellcheck.net/): follow the instructions to install using your [preferred package manager](https://github.com/koalaman/shellcheck#user-content-installing)
- [shfmt](https://github.com/mvdan/sh): use your preferred package manager (see options listed in its [GitHub README](https://github.com/mvdan/sh))

We recommend using [EditorConfig](https://editorconfig.org/) for automated code formatting. Install the EditorConfig extension for your favorite IDE.

### Code formatting and linting

To run the `shfmt` format and `shellcheck` linting checks, use:

```sh
./test/shfmt.bash
./test/shellcheck.bash
```

To fix formatting you can run:

```sh
WRITE=true ./test/shfmt.bash
```

### Tests

Test files in this project are located under the [test/](test/) directory, and named with a `.test.bats` extension, by convention.

The Bats testing framework and helpers are included in this repo as [git submodules](.gitmodules) under the [test/](test/) directory.

Unit test files are named as `<function_name>.test.bats`.

To run all tests:

```sh
./test/test.bash
```

To run a specific test file:

```txt
./test/bats/bin/bats <function_name>.test.bats
```

The `npx` command from Node's NPM is used for end-to-end testing. You must have Node.js (LTS) installed to run the E2E tests.

#### Running the smoke test server

A pre-configured "smoke test" server can be run with:

```sh
./test/helpers/smoketest-server/mcbox.bash
```

The [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) tool can be used to visually inspect the smoke test server, with:

```sh
npx @modelcontextprotocol/inspector ./test/helpers/smoketest-server/mcbox.bash
```

The smoke test server is used in end-to-end tests:

```sh
./test/bats/bin/bats ./test/e2e.test.bats
```

## Built with

- [bash](https://www.gnu.org/software/bash/manual/bash.html)
- [jq](https://jqlang.org/manual)
- [Bats](https://bats-core.readthedocs.io/en/stable/)
- [shellcheck](https://www.shellcheck.net/)
- [shfmt](https://github.com/mvdan/sh)
- [mcp-cli](https://github.com/wong2/mcp-cli)
- [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector)

## Acknowledgements

Thanks to [@flimzy](https://github.com/flimzy) for initial discussions about this project, when it was still being written in Go.

Inspiration for rewriting it in Bash came after reading these two blog posts:

Muthukumaran Navaneethakrishnan, "Why I Built an MCP Server Sdk in Shell (Yes, Bash)":

- <https://medium.com/@muthuishere/why-i-built-an-mcp-server-sdk-in-shell-yes-bash-6f2192072279> (2025-05-29)
- <https://github.com/muthuishere/mcp-server-bash-sdk>

Anton Umnikov, "Minimalistic MCP Server in bash script":

- <https://dev.to/antonum/minimalistic-mcp-server-in-bash-script-10k5> (2025-05-31)
- <https://github.com/antonum/mcp-server-bash>

## Authors

**Andre Silva** - [@andreswebs](https://github.com/andreswebs)

## License

This project is licensed under the [GPL-3.0-or-later](LICENSE).
