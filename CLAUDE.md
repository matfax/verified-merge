# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitHub Action called "Verified Auto-Merge" that triggers on `auto_merge_enabled` events to enhance the auto-merge workflow with intelligent commit message generation and co-signing.

## Architecture

### Core Action Flow (`action.yml`)
The action follows an enhanced workflow:
1. **Validate Auto-Merge Event**: Extracts auto-merge properties (commit_title, commit_message, merge_method)
2. **Wait for All Checks**: Uses `poseidon/wait-for-status-checks@v0.6.0` with configurable timeout (default 15min)
3. **Early Exit for Failed Checks**: Exits gracefully with code 0 if any checks fail
4. **Handle Merge Method Logic**: Routes processing based on merge method:
   - `merge`: No action needed (graceful exit)
   - `rebase`: Co-signs unsigned commits (simple case only - 1 commit)
   - `squash`: Generates AI commit message with co-author preservation
5. **Checkout Repository**: Fetches full git history for analysis
6. **Analyze Commits & Extract Co-Authors**: Identifies unsigned commits and collects existing co-authors
7. **Load Repository Configuration**: Reads `.github/commit-instructions.md` from consuming repo, falls back to `default-commit-instructions.md`
8. **Generate Commit Message**: Uses Claude Code Action or falls back to auto_merge properties
9. **Process Git Operations**: Performs `git reset --soft` operations based on merge method
10. **Create Signed Commit**: Uses `iarekylew00t/verified-bot-commit@v1` with preserved co-authors

### Configuration System
- **Primary**: `.github/commit-instructions.md` in consuming repository
- **Fallback**: `default-commit-instructions.md` in action repository
- **Status tracking**: `has-config` values: `true`, `fallback`, or `false`

### Input Prioritization Logic
The action prioritizes input sources in this order:
1. User instructions in PR comments (highest)
2. Auto-merge properties (commit_title, commit_message)
3. PR title and description
4. Individual commit messages (lowest)

## Key Files

### `action.yml`
Main GitHub Action definition with composite steps. Key considerations:
- Uses `${{ github.action_path }}` to reference files in action repo
- Outputs use bracket notation for hyphenated names: `steps.step-id.outputs['output-name']`
- Uses actual `anthropics/claude-code-action` for commit message generation
- Supports dual authentication: API key OR OAuth token
- Implements real git operations with `git reset --soft` and co-author preservation

### `default-commit-instructions.md`
Comprehensive fallback instructions for commit message generation, including:
- Input prioritization strategy with decision tree
- Conventional commit format guidelines
- Real-world examples for different scenarios
- Special handling for user feedback and bot approvals

### `README.md`
User-facing documentation explaining the auto-merge enhancement workflow, setup requirements, and troubleshooting.

## Important Technical Details

### GitHub Actions Specifics
- Event trigger: `pull_request` with `types: [auto_merge_enabled]`
- Required permissions: `contents: write`, `pull-requests: read`, `issues: read`, `checks: read`
- Uses `poseidon/wait-for-status-checks@v0.6.0` for check waiting
- Uses `iarekylew00t/verified-bot-commit@v1` for signed commits
- Uses `anthropics/claude-code-action` for AI commit generation
- Supports API key and OAuth token authentication for Claude integration
- Outputs with hyphens must be referenced with bracket notation

### Action Input Parameters
- `anthropic-api-key`: Anthropic API key for Claude Code Action (optional)
- `claude-code-oauth-token`: Claude Code OAuth token for Claude Code Action (optional, alternative to API key)
- `enable-claude-generation`: Toggle Claude generation vs auto_merge fallback (default: true)
- `check-timeout-seconds`: Configurable wait time in seconds (default: 900/15min)
- `conventional-commit-types`: Allowed commit types (comma-separated)

### Exit Strategies
The action has multiple graceful exit points:
- Wrong event type
- Checks timeout or fail
- Merge method is 'merge' (no action needed)
- Complex rebase scenarios (multiple unsigned commits)
- Missing authentication for Claude generation (falls back to auto_merge properties)

## Development Notes

### Authentication Methods
The action supports two Claude authentication approaches:
1. **API Key**: Uses `anthropic-api-key` input (ANTHROPIC_API_KEY secret)
2. **OAuth Token**: Uses `claude-code-oauth-token` input (CLAUDE_CODE_OAUTH_TOKEN secret)

### Implementation Details
- **Rebase**: Only handles simple case (1 unsigned commit), uses `git reset --soft HEAD~1` + `verified-bot-commit`
- **Squash**: Uses `git reset --soft origin/base` + collects all co-authors + Claude/fallback message
- **Co-author preservation**: Extracts existing co-authors from git log and adds `github-actions[bot]` as additional co-author
- **Git operations**: Uses real `git reset --soft` commands to prepare commits for signing

### Current Limitations
- Rebase only supports single unsigned commit scenarios (exits gracefully for complex cases)
- Requires either API key OR OAuth token for Claude generation
- Claude generation is optional - falls back to auto_merge properties when disabled or auth missing
- Depends on external actions (wait-for-status-checks, claude-code-action, verified-bot-commit)

### When Making Changes
- Test action logic with different merge methods (merge/rebase/squash)
- Verify output variable naming (hyphens vs underscores) - use bracket notation
- Ensure configuration file loading works for both primary and fallback scenarios
- Test both authentication methods (API key and OAuth token)
- Validate co-author extraction from git log output (grep "Co-authored-by:")
- Ensure graceful exits return code 0, actual errors return non-zero
- Test Claude generation vs auto_merge fallback scenarios
- Verify git operations work correctly with different commit histories