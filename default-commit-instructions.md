# Default Commit Instructions
# These instructions are only used for generating commit messages for user-generated code changes. They do not apply to automated commits or non-code changes unless explicitly specified by the user.

## Input Prioritization

When generating commit messages, prioritize input sources in this order:

### 1. **Highest Priority: User Instructions in Comments**
- Look for explicit user instructions in PR comments
- Check for approval of bot-suggested commit messages (e.g., "looks good", "approved", "use this")
- User feedback overrides all other inputs
- Examples:
  ```
  "Please use: feat(auth): implement OAuth integration"
  "The bot's suggestion is perfect, go with that"
  "Change it to fix(api): resolve timeout issues instead"
  ```

### 2. **High Priority: Auto-Merge Properties**
- Use `auto_merge.commit_title` and `auto_merge.commit_message` if explicitly set by user
- These represent the user's intended commit message for the squash
- Only use if they follow conventional commit format or can be adapted to it

### 3. **Medium Priority: PR Title and Description**
- PR title often reflects the overall intent of the changes
- PR description provides context about what was implemented/fixed
- Use these to understand the scope and nature of changes
- Adapt PR title to conventional format if it's not already

### 4. **Lower Priority: Individual Commit Messages**
- Analyze all commits being squashed for context
- Look for patterns in commit types (mostly fixes, features, etc.)
- Use commit details to understand the technical implementation
- Summarize the overall change rather than listing individual commits

## Decision Logic

Follow this decision tree:

1. **Check for user comment instructions** → Use exactly as specified
2. **Check for bot approval in comments** → Use the approved bot suggestion
3. **Check auto-merge title/message** → Adapt to conventional format if good
4. **Analyze PR title + description** → Create conventional message from PR context
5. **Fallback to commit analysis** → Summarize squashed commits into single conventional message

## Context Integration

When no explicit user instructions exist, integrate all available context:

- **Technical scope**: What systems/components were modified (from commits)
- **User intent**: What problem was solved or feature added (from PR title/description)  
- **Change type**: Bug fix, new feature, refactoring, etc. (from commit patterns)
- **Breaking changes**: Any API changes or backwards incompatibility (from PR/commits)

## Conventional Commit Format

Generate commit messages following the conventional commit specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

Use these types based on the nature of changes:

- **feat**: New features or functionality (code changes only)
- **fix**: Bug fixes (code changes only)
- **docs**: Documentation only changes
- **style**: Code style changes (formatting, missing semicolons, etc)
- **refactor**: Code changes that neither fix bugs nor add features (code changes only)
- **test**: Adding missing tests or correcting existing tests (code changes only)
- **chore**: Changes to build process, auxiliary tools, libraries
- **ci**: Changes to CI configuration files and scripts
- **perf**: Performance improvements (code changes only)
- **build**: Changes that affect the build system or external dependencies

**Important Clarifications:**

- Only use `fix`, `refactor`, `perf`, `test`, and `feat` for changes that modify code logic or behavior. Do **not** use these types for pure `style`, `docs`, `build`, or `ci` changes.
- For pure style, documentation, build system, or CI changes, use only the corresponding types: `style`, `docs`, `build`, or `ci`.
- Do not include assistant names (like Claude or GPT) in commit messages since these instructions are only used for user-generated changes.

## Scope Guidelines

When applicable, include a scope in parentheses:
- Component names: `feat(auth): add user login validation`
- File/module names: `fix(parser): handle edge case in JSON parsing`
- Feature areas: `docs(api): update authentication examples`

## Description Guidelines

- Use imperative mood: "add feature" not "added feature"
- Start with lowercase letter
- No period at the end
- Be concise but descriptive
- Limit to 50 characters when possible

## Body Guidelines

Include a body when:
- The change is complex and needs explanation
- Breaking changes are introduced
- Multiple related changes are being made

## Examples

### Simple Changes
```
feat: add user profile validation
fix: resolve memory leak in data processor
docs: update installation instructions
```

### With Scope
```
feat(auth): implement OAuth2 integration
fix(api): handle timeout errors gracefully
test(utils): add comprehensive string helper tests
```

### With Body
```
feat: implement advanced search functionality

Add full-text search with filters for date range, categories,
and user preferences. Includes indexing optimization and
query performance improvements.

Closes #123
```

### Breaking Changes
```
feat!: update API response format

BREAKING CHANGE: The API now returns data in a nested object
structure instead of a flat array. Update client code to
access data via response.data.items.
```

## Prioritization Examples

### Example 1: User Comment Override
- **PR Title**: "Update authentication system"
- **User Comment**: "Please use: feat(auth): implement multi-factor authentication support"
- **Result**: Use exactly as specified by user

### Example 2: Bot Approval
- **Bot Suggestion**: "fix(api): resolve timeout handling in payment processor" 
- **User Comment**: "Perfect, use that commit message"
- **Result**: Use the bot's suggestion

### Example 3: Auto-Merge Properties
- **PR Title**: "Fix bugs and add tests"
- **Auto-merge title**: "feat: enhance payment processing with better error handling"
- **Result**: Adapt auto-merge title to conventional format

### Example 4: PR Context Priority
- **PR Title**: "Add user dashboard functionality"
- **PR Description**: "Implements new user dashboard with profile management, settings, and activity history"
- **Commits**: Various small commits like "fix typo", "add component", "update tests"
- **Result**: `feat(dashboard): implement user profile management and activity tracking`

### Example 5: Commit Analysis Fallback
- **PR Title**: "Updates"
- **PR Description**: Empty
- **Commits**: "fix login bug", "update user model", "add validation"
- **Result**: `fix(auth): resolve login validation and user model issues`

## Special Considerations

- If multiple commits are being squashed, summarize the overall change
- Consider the PR title and description as context
- Look for keywords in PR comments that indicate the nature of changes
- Prioritize clarity and usefulness for future developers
- When in doubt, prefer `feat` for new code functionality and `fix` for code corrections. For non-code changes, use the appropriate type (`docs`, `style`, `build`, `ci`, etc.)
- Bot suggestions should be preserved when explicitly approved by users
- User instructions always take precedence over automated analysis

## Conventional Commits Specification:

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

1. Commits MUST be prefixed with a type, which consists of a noun, `feat`, `fix`, etc., followed
  by the OPTIONAL scope, OPTIONAL `!`, and REQUIRED terminal colon and space.
2. The type `feat` MUST be used when a commit adds a new feature to your application or library.
3. The type `fix` MUST be used when a commit represents a bug fix for your application.
4. A scope MAY be provided after a type. A scope MUST consist of a noun describing a
  section of the codebase surrounded by parenthesis, e.g., `fix(parser):`
5. A description MUST immediately follow the colon and space after the type/scope prefix.
The description is a short summary of the code changes, e.g., _fix: array parsing issue when multiple spaces were contained in string_.
6. A longer commit body MAY be provided after the short description, providing additional contextual information about the code changes. The body MUST begin one blank line after the description.
7. A commit body is free-form and MAY consist of any number of newline separated paragraphs.
8. One or more footers MAY be provided one blank line after the body. Each footer MUST consist of
 a word token, followed by either a `:<space>` or `<space>#` separator, followed by a string value (this is inspired by the
  [git trailer convention](https://git-scm.com/docs/git-interpret-trailers)).
9. A footer's token MUST use `-` in place of whitespace characters, e.g., `Acked-by` (this helps differentiate
  the footer section from a multi-paragraph body). An exception is made for `BREAKING CHANGE`, which MAY also be used as a token.
10. A footer's value MAY contain spaces and newlines, and parsing MUST terminate when the next valid footer
  token/separator pair is observed.
11. Breaking changes MUST be indicated in the type/scope prefix of a commit, or as an entry in the
  footer.
12. If included as a footer, a breaking change MUST consist of the uppercase text BREAKING CHANGE, followed by a colon, space, and description, e.g.,
_BREAKING CHANGE: environment variables now take precedence over config files_.
13. If included in the type/scope prefix, breaking changes MUST be indicated by a
  `!` immediately before the `:`. If `!` is used, `BREAKING CHANGE:` MAY be omitted from the footer section,
  and the commit description SHALL be used to describe the breaking change.
14. Types other than `feat` and `fix` MAY be used in your commit messages, e.g., _docs: update ref docs._
15. The units of information that make up Conventional Commits MUST NOT be treated as case sensitive by implementors, with the exception of BREAKING CHANGE which MUST be uppercase.
16. BREAKING-CHANGE MUST be synonymous with BREAKING CHANGE, when used as a token in a footer.
