# Contributing to xcode-project-format

The `xcode-project-format` source code is open source under the [Apache License 2.0](LICENSE.txt). We welcome contributions within a defined scope — please read this document before opening a pull request or issue.

## How you can help

- Reporting bugs with clear, reproducible steps
- Bug fixes for existing schema modeling, encoding/decoding, or round-trip behavior
- Improvements to `xcprojformatter`, or new small CLI tools built on the library
- Improving documentation (DocC articles, curation, README, examples)
- Adding or improving tests for existing functionality

## Commitment to quality

We maintain high standards across the project. Contributions are evaluated on:

- Technical quality and correctness
- Adherence to existing conventions and architectural patterns
- Your demonstrated understanding of the implementation and its implications
- Clarity of communication
- Maintainability

### Productivity and AI tools

You may use productivity tools, including AI-assisted coding tools, to help you work more efficiently. However, you remain fully accountable for all submitted code, issues, pull requests, and comments. Maintainers expect you to thoroughly review, understand, and validate everything you submit — and be able to explain your contributions in detail. AI-generated content must meet the same rigorous standards as human-written code.

**Important:** Low-quality pull requests and issues, including those that appear to be generated without understanding, validation, or genuine human review, will be treated as spam and moderated accordingly.

## Contribution scope

**In scope:**

- Bug fixes
- Changes to `xcprojformatter` (the CLI tool)
- Documentation improvements
- Test additions

**Not in scope for direct PRs at this time:**

- New Xcode project schema fields or types, and other API extensions. These need verification against Xcode's actual behavior/format before they can be added responsibly. Open a [Feature request](../../issues/new?template=feature_request.yml) to propose one — we may accept a PR for it once we've discussed the approach, but we're starting conservative here and expect this scope to grow over time.
- Major new features — we keep the API surface intentionally limited.

## Setting up your environment

A detailed setup guide is in [README.md](README.md#getting-started).

## Before you open a pull request

For anything beyond a straightforward bug fix, open a [Feature request](../../issues/new?template=feature_request.yml) describing what you want to build and wait for a response before writing code. This saves your time and ours.

## Submitting issues

Before opening an issue:

- Search [existing issues](../../issues) to avoid duplicates
- Use the appropriate [issue template](../../issues/new/choose)
- For security issues, follow the org-level security disclosure process. [TODO: link before public release]

## Submitting pull requests

Please review the [PR template](.github/PULL_REQUEST_TEMPLATE.md) before submitting. Small, focused pull requests are much more likely to be reviewed and merged than large ones.

### Testing

All contributions require tests.

- **Before submitting:** ensure all existing tests pass locally (`swift test`).
- **New functionality:** new features and bug fixes require corresponding automated tests.

### Commit messages

Commit messages should be clear and concise, describing what changed and why.

## Response time

Maintainer time on this project is best-effort — there is no dedicated rotation. We don't commit to a specific response-time SLA. Expect issues and pull requests to be triaged and reviewed as time allows, which may be days to a few weeks.

## Code of conduct

This project follows the [Apple Open Source Code of Conduct](https://github.com/apple/.github/blob/main/CODE_OF_CONDUCT.md). All community members are expected to adhere to these guidelines.
