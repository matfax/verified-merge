# Verified Auto-Merge Action

**Automatically generate conventional commit messages and co-sign commits with GitHub auto-merge**

Perfect for teams using squash merges who want consistent, AI-generated conventional commit messages without manual intervention.

![GitHub release](https://img.shields.io/github/v/release/matfax/verified-merge)
![GitHub](https://img.shields.io/github/license/matfax/verified-merge)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/matfax/verified-merge/ci.yml)

## Quick Start

```yaml
# .github/workflows/auto-merge-enhance.yml
name: Auto-Merge Enhancement
on:
  pull_request:
    types: [auto_merge_enabled]

jobs:
  enhance-auto-merge:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
      issues: read
      checks: read
      id-token: write
    steps:
      - uses: matfax/verified-merge@main
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

## What It Does

1. **Waits for all CI checks** to pass after auto-merge is enabled
2. **Generates intelligent commit messages** using Claude AI (or falls back to auto-merge settings)  
3. **Preserves co-authors** from all commits being squashed/rebased
4. **Creates signed commits** with github-actions[bot] as co-author
5. **Exits gracefully** if checks fail or unsupported scenarios occur

**Supported merge methods:** Squash (generates new message), Rebase (co-signs single commits), Merge (no action needed)

## How It Works

### Workflow Overview

1. **Event Trigger**: Action runs when `auto_merge_enabled` event is fired
2. **Check Waiting**: Waits for all CI/CD checks to complete (with configurable timeout)
3. **Exit Strategy**: If checks fail or timeout, exits gracefully with code 0
4. **Merge Method Processing**:
   - **`merge`**: No action needed, exits gracefully
   - **`rebase`**: Co-signs any unsigned commits
   - **`squash`**: Generates intelligent commit message using Claude

### Merge Method Behaviors

| Merge Method | Action Taken | Description |
|--------------|--------------|-------------|
| `merge` | None | Exits gracefully - merge commits don't need processing |
| `rebase` | Co-sign (simple case) | Co-signs the latest unsigned commit if only 1 commit exists |
| `squash` | Generate & squash | Uses Claude or auto-merge properties to create commit message |

## Setup

### 1. Add the Workflow

Create `.github/workflows/auto-merge-enhance.yml` in your repository:

```yaml
name: Auto-Merge Enhancement
on:
  pull_request:
    types: [auto_merge_enabled]

jobs:
  enhance-auto-merge:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: read
      issues: read
      checks: read
      id-token: write # Required for Claude Code Action
    steps:
      - uses: matfax/verified-merge@main
        with:
          anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
```

### 2. Add Anthropic API Key

1. Get an [Anthropic API key](https://console.anthropic.com/) (requires credits)
2. Add it as repository secret: `ANTHROPIC_API_KEY`

> **Alternative:** Claude Pro/Max users can use OAuth tokens instead. See [Advanced Configuration](#advanced-configuration) below.

### 3. Configure Branch Protection Rules

To ensure the action works properly with GitHub's auto-merge feature, you need to set up branch protection rules:

1. **Enable Required Signed Commits**:
   - Go to your repository's Settings → Branches
   - Add or edit a branch protection rule for your main branch
   - Check ✅ **"Require signed commits"**

2. **Deploy and Test First**:
   - Create a test PR and enable auto-merge to trigger the action once
   - This creates the initial "Auto-Merge Helper" status check

3. **Enable Required Status Checks**:
   - Return to the same branch protection rule
   - Check ✅ **"Require status checks to pass before merging"**
   - In the status checks list, select **"Auto-Merge Helper"**
   - Optionally check "Require branches to be up to date before merging"

> **Important**: The status check "Auto-Merge Helper" only appears after the action runs at least once. Deploy the workflow first, then configure the branch protection rule.

### Advanced Configuration

```yaml
- name: Verified Auto-Merge
  uses: matfax/verified-merge@main
  with:
    # Choose ONE authentication method:
    anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
    # claude-code-oauth-token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}  # Alternative to API key
    enable-claude-generation: true
    check-timeout-seconds: 1200
    conventional-commit-types: 'feat,fix,docs,style,refactor,test,chore,ci,perf,build'
    ignore-workflows: 'Auto-Merge'  # Ignore the calling workflow to prevent self-referential failures
```

## Configuration

### Repository-Specific Instructions

Create a `.github/commit-instructions.md` file in your repository to provide custom instructions for commit message generation:

```markdown
# Commit Instructions for MyProject

## Style Guidelines
- Use present tense ("add feature" not "added feature")
- Include ticket numbers when applicable: `feat: add user login (PROJ-123)`
- For breaking changes, include `BREAKING CHANGE:` in the footer

## Project-Specific Types
- `api`: API changes
- `ui`: User interface changes
- `db`: Database schema changes

## Examples
- `feat(auth): implement OAuth2 integration (AUTH-456)`
- `fix(api): resolve timeout in user endpoint (BUG-789)`
- `docs: update deployment guide`
```


<!--- BEGIN_ACTION_DOCS --->
## Usage

```yaml
- name: Auto-Merge Enhanced Commit Processor
  uses: ${{ github.repository }}@${{ github.ref }}
  with:
    # Anthropic API key for Claude Code Action
    anthropic-api-key: 'your-value-here'
    # Maximum time to wait for all checks to complete (in seconds)
    check-timeout-seconds: 900
    # Claude Code OAuth token for Claude Code Action
    claude-code-oauth-token: 'your-value-here'
    # Allowed conventional commit types (comma-separated)
    conventional-commit-types: feat,fix,docs,style,refactor,test,chore,ci,perf,build
    # Enable Claude-powered commit message generation (fallback to auto_merge properties if false)
    enable-claude-generation: true
    # GitHub token for API access
    github-token: ${{ github.token }}
    # Workflow names to ignore when waiting for checks (comma-separated) - typically the workflow calling this action to prevent self-referential failures
    ignore-workflows: Auto-Merge,Auto-merge,Automerge,auto-merge,automerge,Verified-Merge,Verified-merge,verified-merge,verifiedmerge
```

## Example Workflow

```yaml
name: Auto-Merge

on:
  pull_request:
    types: [auto_merge_enabled]

permissions:
  contents: write      # Required for creating commits
  pull-requests: read  # Required for reading PR details
  issues: read         # Required for reading issue comments
  statuses: write      # Required for publishing the final status
  checks: read         # Required for checking status checks
  id-token: write      # Required for Claude OIDC

jobs:
  automerge-helper:
    name: Auto-Merge Helper
    environment: claude
    runs-on: ubuntu-latest
    steps:
      - name: Enhanced Auto-Merge Processing
        uses: matfax/verified-merge@main
        with:
          # Anthropic API key authentication (choose one)
          # anthropic-api-key: ${{ secrets.ANTHROPIC_API_KEY }}
          claude-code-oauth-token: ${{ secrets.CLAUDE_CODE_OAUTH_TOKEN }}
          
          # Optional: Enable/disable Claude generation (default: true)
          enable-claude-generation: true
          
          # Optional: Timeout for waiting for status checks in seconds (default: 900 = 15 minutes)
          check-timeout-seconds: 900

```

## Inputs

### anthropic-api-key

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-none-lightgrey?style=flat-square)

Anthropic API key for Claude Code Action

### check-timeout-seconds

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-900-blue?style=flat-square)

Maximum time to wait for all checks to complete (in seconds)

### claude-code-oauth-token

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-none-lightgrey?style=flat-square)

Claude Code OAuth token for Claude Code Action

### conventional-commit-types

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-feat,fix,docs,style,refactor,test,chore,ci,perf,build-blue?style=flat-square)

Allowed conventional commit types (comma-separated)

### enable-claude-generation

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-true-blue?style=flat-square)

Enable Claude-powered commit message generation (fallback to auto\_merge properties if false)

### github-token

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-${{_github.token_}}-blue?style=flat-square)

GitHub token for API access

### ignore-workflows

![Required](https://img.shields.io/badge/Required-no-inactive?style=flat-square)
![Default](https://img.shields.io/badge/Default-Auto--Merge,Auto--merge,Automerge,auto--merge,automerge,Verified--Merge,Verified--merge,verified--merge,verifiedmerge-blue?style=flat-square)

Workflow names to ignore when waiting for checks (comma-separated) - typically the workflow calling this action to prevent self-referential failures

## Outputs

### action_taken

![Output](https://img.shields.io/badge/Output-action__taken-green?style=flat-square)

Action taken (none, graceful-exit, co-signed, squash-generated)

### checks_status

![Output](https://img.shields.io/badge/Output-checks__status-green?style=flat-square)

Status of all checks (passed, failed, timeout)

### commit_sha

![Output](https://img.shields.io/badge/Output-commit__sha-green?style=flat-square)

SHA of the final commit (if modified)

### failure_status

![Output](https://img.shields.io/badge/Output-failure__status-green?style=flat-square)

Indicates if any step failed (success, failure)

### merge_method

![Output](https://img.shields.io/badge/Output-merge__method-green?style=flat-square)

The merge method used (merge, rebase, squash)

### status_description

![Output](https://img.shields.io/badge/Output-status__description-green?style=flat-square)

Descriptive status message indicating what action was taken

<!--- END_ACTION_DOCS --->

## Examples

### Squash Merge with AI-Generated Message

**Scenario**: PR with multiple commits using squash merge

```
PR Title: "Add user authentication system"
PR Body: "Implements OAuth2 with Google provider, includes tests and documentation"

Original commits:
- "wip: start auth"
- "fix login bug" 
- "add tests"
- "update readme"

Generated: "feat(auth): implement OAuth2 authentication with Google provider

- Add OAuth2 integration with Google
- Include comprehensive test coverage
- Update documentation with setup instructions"
```

### Rebase with Co-Signing (Simple Case)

**Scenario**: PR with 1 unsigned commit using rebase merge

```
Original commit (unsigned):
- "feat: add payment processing"
  Co-authored-by: John Doe <john@example.com>

Action: Co-signs commit with github-actions[bot] as additional co-author
Result: Same commit message with all co-authors preserved + bot signature
```

**Complex Case**: Multiple commits - exits gracefully (not supported)

### Merge - No Action

**Scenario**: PR using merge method

```
Action: Exits gracefully with action_taken=none
Reason: Merge commits don't require processing
```

## Troubleshooting

### Action Not Triggering

**Check Event Configuration**:
```yaml
on:
  pull_request:
    types: [auto_merge_enabled]  # Must be exactly this
```

**Verify Auto-Merge is Enabled**:
- Go to PR page
- Click "Enable auto-merge" button
- Select merge method
- Action should trigger immediately

### Checks Timeout

**Issue**: Action times out waiting for checks
**Solutions**:
- Increase `check-timeout-seconds` parameter
- Ensure all required checks are configured correctly
- Check that CI/CD workflows complete successfully

### Claude API Errors

**Issue**: Commit message generation fails
**Solutions**:
- Verify `ANTHROPIC_API_KEY` is valid and has credits
- Check API rate limits
- Review action logs for specific error messages
- Set `enable-claude-generation: false` to use auto-merge fallback

### Missing Configuration File

**Issue**: No repository-specific instructions found
**Solution**: The action uses fallback instructions automatically. To customize:
1. Create `.github/commit-instructions.md` in your repository
2. Add your project-specific guidelines
3. Action will automatically detect and use them

### Rebase Limitations

**Issue**: "Exiting gracefully - rebase with multiple commits not supported"
**Solution**: This is expected behavior. The action only handles simple rebase cases (1 unsigned commit). For complex rebases, it exits gracefully to avoid complications.

### Permission Errors

**Issue**: Cannot create commits or access PR data
**Solutions**:
- Ensure workflow has `contents: write` permission
- Verify `checks: read` permission for status checking
- Check that `GITHUB_TOKEN` has sufficient scope

## Dependencies

This composite action uses the following GitHub Actions:
- [`poseidon/wait-for-status-checks`](https://github.com/poseidon/wait-for-status-checks) - Wait for all PR checks
- [`anthropics/claude-code-action`](https://github.com/anthropics/claude-code-action) - Claude AI integration
- [`iarekylew00t/verified-bot-commit`](https://github.com/iarekylew00t/verified-bot-commit) - Create signed commits
- [`actions/checkout`](https://github.com/actions/checkout) - Repository checkout
- [`guibranco/github-status-action-v2`](https://github.com/guibranco/github-status-action-v2) - Set commit status checks
