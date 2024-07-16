# Contributing to dbx_stats

We welcome contributions to the `dbx_stats` project! Whether you're fixing bugs, adding new features, improving documentation, or suggesting ideas, your help is appreciated. Please follow the guidelines below to ensure a smooth and efficient process for everyone.

## Table of Contents

- [Getting Started](#getting-started)
- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Submitting Pull Requests](#submitting-pull-requests)
- [Style Guide](#style-guide)
- [Commit Messages](#commit-messages)
- [Code Snippets](#code-snippets)
- [License](#license)

## Getting Started

1. Fork the repository to your own GitHub account.
2. Clone your forked repository to your local machine:
    ```sh
    git clone https://github.com/dbdevmaster/dbx_stats.git
    ```
3. Create a new branch for your work:
    ```sh
    git checkout -b your-feature-branch
    ```

## Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) to understand the behavior we expect from all contributors.

## How to Contribute

### Reporting Bugs

If you find a bug in the project, please create an issue on GitHub with the following information:
- A clear and descriptive title.
- A detailed description of the bug, including steps to reproduce it.
- The expected behavior and the actual behavior.
- Any relevant screenshots or logs.
- The version of the project you are using.

### Suggesting Enhancements

If you have an idea for an enhancement or a new feature, please create an issue on GitHub with the following information:
- A clear and descriptive title.
- A detailed description of the enhancement or feature.
- Any relevant use cases or examples.

### Submitting Pull Requests

1. Ensure your code follows the [Style Guide](#style-guide).
2. Make sure your code passes all tests and linting checks.
3. Commit your changes with a clear and descriptive [commit message](#commit-messages).
4. Push your branch to your forked repository:
    ```sh
    git push origin your-feature-branch
    ```
5. Create a pull request on GitHub, explaining the changes and why they should be merged.

## Style Guide

- Use consistent indentation (4 spaces).
- Write clear and concise comments where necessary.
- Follow naming conventions for variables, functions, and procedures.
- Ensure SQL and PL/SQL code is properly formatted and readable.
- Adhere to best practices for performance and security.

## Commit Messages

- Use the present tense ("Add feature" not "Added feature").
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...").
- Limit the first line to 72 characters or less.
- Reference issues and pull requests liberally.

## Code Snippets

When adding code snippets to the documentation or comments, please ensure they are:

- Well-formatted and easy to read.
- Relevant and directly related to the context.
- Tested and functional if they are examples of how to use a feature.

### Example

```sql
-- Example of a PL/SQL procedure to gather schema statistics
PROCEDURE gather_schema_stats(p_schema_name IN VARCHAR2, p_degree IN INTEGER, p_cluster IN VARCHAR2 DEFAULT 'FALSE') IS
BEGIN
    -- Code to gather schema statistics
    DBMS_STATS.GATHER_SCHEMA_STATS(ownname => p_schema_name, degree => p_degree);
    -- Add any additional logic here
END gather_schema_stats;
/
```

## License

By contributing to `dbx_stats`, you agree that your contributions will be licensed under the [GNU General Public License](LICENSE).
