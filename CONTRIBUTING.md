# Contributing Guide to mcbox

The **mcbox** project happily accepts contributions for bug fixes and new features. This document outlines the process we use to validate contributions.

## Issues and discussions

Bug reports, support requests and feature requests occur through GitHub issues. If you would like to file an issue, view existing issues or comment on an issue, please engage with issues at <https://github.com/andreswebs/mcbox/issues>.

General questions and proposals occur through GitHub discussions. You can create new discussions, view existing ones and comment on them at <https://github.com/andreswebs/mcbox/discussions>.

## Pull Requests

All changes to the source code and documentation are made through [GitHub pull requests](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests).

You can find the existing pull requests at <https://github.com/andreswebs/mcbox/pulls>.

For bug fixes and new features, this project only accepts pull requests related to open issues. If you'd like propose a bug fix or a new feature, please file an issue first at <https://github.com/andreswebs/mcbox/issues>. The issue can detail the change and you will get feedback from the maintainers prior to starting to make the change.

For changes to documentation, you can open a new pull request directly without first opening an issue.

To submit a pull request, fork this repository, push the changes to your fork, then open a pull request from your fork against the `main` branch of this repository. Make sure you follow the **Commits** guidelines below.

Each pull request must consist of a single commit.

## Commits

We require all git commits to be properly formatted and signed. There are 4 requirements, which will be further explained below:

- Commits must be cryptographically signed with GPG and verified by GitHub
- Committers must agree and sign-off on the Developer Certificate of Origin (DCO)
- Commit messages must be formatted according to our repo's conventions
- Every pull request must consist of a SINGLE commit

### GPG Signing

For additional security, we require that you sign your commits with [GPG](https://www.gnupg.org/) using a properly configured key for [GitHub commit verification](https://docs.github.com/en/authentication/managing-commit-signature-verification). GPG signing provides cryptographic proof that commits came from you.

Your commits must meet the following requisites for GitHub verified commits:

- The committer must have a GPG public/private key pair.
- The committer's public key must be uploaded to their GitHub account.
- One of the email addresses in the GPG public key must match a verified email address used by the committer in GitHub. To keep this address private, use the automatically generated private commit email address GitHub provides in your profile.
- The committer's email address must match the verified email address from the GPG key.

#### Setting up GPG signing (only needed once)

Do this if you haven't already added a GPG key to your GitHub account:

0. Ensure you have `gpg` installed in your environment.

1. **Generate a GPG key** (if you don't have one):

   ```sh
   gpg --full-generate-key
   ```

   Choose the defaults ("ECC (sign and encrypt)", "Curve 25519"), and set an appropriate expiration date and your identifying information.

2. **List your GPG keys** to find the key ID:

   ```sh
   gpg --list-secret-keys --keyid-format=long
   ```

   Look for the key ID after `sec ed25519/` (e.g., `3AA5C34371567BD2`).

3. **Configure Git to use your GPG key on your local repository**:

   ```sh
   git config --local user.signingkey $YOUR_KEY_ID
   ```

4. **Add your GPG public key to GitHub**:

   - Export your public key:

     ```sh
     gpg --armor --export $YOUR_KEY_ID
     ```

   - Copy the output and [add it to your GitHub account](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account) at `Settings -> SSH` and `GPG keys -> New GPG key`.

#### Signing commits

With GPG signing enabled locally or globally on your git configuration, all commits will be signed automatically. You can also sign individual commits:

```sh
git commit --gpg-sign --signoff
# or:
# git commit -S -s
```

The `-S` (`--gpg-sign`) flag signs the commit with GPG, and `-s` (`--signoff`) adds the DCO sign-off.

#### Verifying GPG signatures

You can verify that your commits are properly signed:

```sh
git log --show-signature
```

Signed commits will show "Good signature" in the output and display a "Verified" badge on GitHub.

### Developer Certificate of Origin

The **mcbox** project uses a [Developers Certificate of Origin (DCO)](https://developercertificate.org/) to sign-off that you have the right to contribute the code being contributed. Please read full text of the DCO here and make sure you agree: [DCO](DCO.txt).

To state that you agree, every commit needs to have a sign-off line added to it with a message like:

```txt
Signed-off-by: Joe Smith <joe.smith@example.com>
```

By adding the sign-off line you agree to the DCO above.

Git makes doing this fairly straightforward. First, add your name to your git configuration on your local repository.

```sh
git config --local user.name 'Joe Smith'
git config --local user.email 'joe.smith@example.com'
```

We kindly request that you use your citizen's name. Make sure the information matches what you had configured previously in your GPG key.

If you set your `user.name` and `user.email` in your git configuration, you can sign your commit automatically with `git commit -S -s`.

Signed commits in the git log will look something like:

```txt
Author: Joe Smith <joe.smith@example.com>
Date:   Thu Feb 2 11:41:15 2018 -0800

    Update README

    Signed-off-by: Joe Smith <joe.smith@example.com>
```

Notice how the `Author` and `Signed-off-by` lines match. If they do not match the PR will be rejected by the automated DCO check.

If more than one person contributed to a commit than there can be more than one `Signed-off-by` line where each line is a signoff from a different person who contributed to the commit.

### Commit message format

When creating a commit, use the command:

```sh
git commit  --gpg-sign --signoff
```

This will open an interactive editor where you can write a multi-line message. Add the subject line as the first line, then a single blank line, then write the body of the message.

The commit subject line must follow the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification.

For example, this is a good subject line:

```txt
feat: add support for MCP prompts
```

When writing the commit message:

- Separate the subject from body with a blank line
- Limit the subject line to 50 characters
- Do not end the subject line with a period
- Use the imperative mode in the subject line
- Wrap the body at 72 characters
- Use the body to explain what and why vs. how

Here's an example message:

```txt
fix: add a short summary in imperative mode

More detailed explanatory text, if necessary.  Wrap it to about 72
characters or so.  In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body.  The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Write your commit message in the imperative: "Fix bug" and not
"fixed bug" or "fixes bug."  This convention matches up with
commit messages generated by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, followed by a
  single space, with blank lines in between, but conventions vary here

```

### Preparing a single commit

If you have multiple commits in your feature branch, you'll need to squash them into a single commit before submitting your pull request. Use interactive rebase to combine your commits into a single one:

1. **Start an interactive rebase** on your feature branch:

   Here, `<n>` is the number of commits you have added:

   ```txt
   git rebase --gpg-sign --signoff --interactive HEAD~<n>
   ```

   For example, if you've added 5 commits, do:

   ```sh
   git rebase --gpg-sign --signoff --interactive HEAD~5
   ```

2. **In the editor that opens**, you'll see a list of your commits. Change `pick` to `squash` (or `s`) for all commits except the first one:

   ```txt
   pick abc1234 Your first commit message
   squash def5678 Second commit message
   squash ghi9012 Third commit message
   ```

3. **Save and close** the editor. Git will then open another editor for you to write the final commit message.

4. **Write a single, clear commit message** following the Conventional Commits format, then save and close.

5. **Force push** your rebased branch:

   ```sh
   git push --force-with-lease origin your-branch-name
   ```

## AI Usage

AI-generated contributions are welcome as long as they follow the development standards defined in the project and are fully reviewed by the committer before submitted for human review. Please make sure you fully understand the AI-generated code before committing it.
