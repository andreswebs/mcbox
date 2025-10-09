## Description

<!--- Describe your changes in detail -->

## Checklist

<!---
  Linting: make sure all shellcheck issues are addressed when you run:
  ```sh
  find . -type f -name '*.bash'  ! -path '*/bats*/*' | xargs shellcheck
  ```

  Formatting: make sure all shfmt issues are addressed when you run:
  ```sh
  shfmt --indent 4 --diff ./*.bash
  shfmt --indent 4 --diff ./test/*.bats
  ```

  To fix formatting you can run:
  ```sh
  shfmt --indent 4 --write ./*.bash
  shfmt --indent 4 --write ./test/*.bats
  ```

  Make sure all new and existing test pass. To run all tests:
  ```sh
  ./test/test.bash
  ```
 -->

- [ ] I have performed a self-review of my code
- [ ] All new code follows the style guidelines of this project
- [ ] All new code has been linted with `shellcheck` and formated with `shfmt`
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing tests pass locally with my changes

<!--- For bug fixes and new features, this project only accepts pull requests related to open issues -->
<!--- If suggesting a new feature or change, please discuss it in an issue first -->
<!--- If fixing a bug, there should be an issue describing it with steps to reproduce -->

<!--- Please link to the issue here: -->Issue: #<!-- Issue number here -->
