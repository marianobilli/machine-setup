# Branch Protection Setup Guide

This guide explains how to configure branch protection rules to require CI checks before merging pull requests.

## Overview

Branch protection rules ensure that:
- All CI checks pass before merging
- Code is reviewed before merging
- The main branch remains stable
- No direct pushes to protected branches

## Setup Instructions

### 1. Navigate to Branch Protection Settings

1. Go to your GitHub repository
2. Click **Settings** (top right)
3. Click **Branches** (left sidebar)
4. Under "Branch protection rules", click **Add rule** or **Add branch protection rule**

### 2. Configure Branch Protection Rule

#### Branch Name Pattern
```
main
```
Or use a pattern to protect multiple branches:
```
main
master
develop
```

#### Protect Matching Branches

Check the following options:

##### ✅ Require a pull request before merging
- **Required approvals**: 1 (or more, depending on team size)
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners (if you have CODEOWNERS file)

##### ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date before merging

**Required status checks** (add these):
```
All Checks Passed
```

This is the summary job from `.github/workflows/ci.yml` that depends on:
- ShellCheck Linting
- Test on Ubuntu
- Test on macOS
- Validate Configuration Files
- Documentation Check

**Alternative**: If you want more granular control, require each individual check:
```
ShellCheck Linting
Test on Ubuntu
Test on macOS
Validate Configuration Files
Documentation Check
```

##### ✅ Require conversation resolution before merging
- Ensures all review comments are addressed

##### ✅ Do not allow bypassing the above settings
- Enforces rules for everyone, including administrators

#### Optional but Recommended

- ✅ Require linear history (prevents merge commits, enforces rebase/squash)
- ✅ Require deployments to succeed before merging (if you have deployment workflows)
- ✅ Lock branch (prevents all pushes - use only for archived branches)

### 3. Save Changes

Click **Create** or **Save changes** at the bottom of the page.

## Visual Guide

### Required Status Checks Configuration

When adding required status checks, you should see:

```
┌─────────────────────────────────────────┐
│ Status checks that are required:        │
│                                         │
│ ☑ All Checks Passed                    │
│                                         │
│ This check must pass before merging    │
└─────────────────────────────────────────┘
```

### How It Works

1. **Developer creates PR** → Pushes changes to feature branch
2. **CI triggers automatically** → Runs all tests on Ubuntu and macOS
3. **Status checks appear** → GitHub shows check status on PR
4. **All checks must pass** → Green checkmarks required
5. **Review required** → At least 1 approval needed
6. **Merge enabled** → Only after all requirements met

## Testing Branch Protection

After setup, try to merge a PR without passing checks:

```bash
# Create a test branch
git checkout -b test-branch-protection

# Make a change that will fail tests
echo "syntax error" >> setup.sh

# Commit and push
git add setup.sh
git commit -m "test: intentional syntax error"
git push origin test-branch-protection
```

Create a PR from this branch. You should see:
- ❌ CI checks fail
- 🔒 Merge button is disabled
- Message: "Required status checks must pass before merging"

## Viewing Status Checks on PRs

On any pull request, you'll see a section like:

```
All checks have passed
  5 successful checks

  ✅ ShellCheck Linting
  ✅ Test on Ubuntu
  ✅ Test on macOS
  ✅ Validate Configuration Files
  ✅ Documentation Check
  ✅ All Checks Passed
```

## CI Workflow Features

Our CI workflow (`.github/workflows/ci.yml`) includes:

### Automatic Triggering
- Runs on every push to `main`, `master`, `develop`
- Runs on PR open, update, or reopen
- Cancels in-progress runs when new commits are pushed

### Comprehensive Testing
- **ShellCheck**: Lints all shell scripts for errors
- **Ubuntu Tests**: 51 automated tests
- **macOS Tests**: 51 automated tests
- **Config Validation**: Verifies all configuration files
- **Documentation**: Checks required documentation exists

### Summary Job
- `all-checks-pass` job depends on all other jobs
- Only passes if ALL tests pass
- Provides clear status summary
- This is the job you require in branch protection

## Troubleshooting

### Status check not appearing?

1. Ensure the workflow has run at least once on the base branch
2. Check that the job name matches exactly: `All Checks Passed`
3. Verify the workflow file is in `.github/workflows/ci.yml`

### Can't find status check to require?

Status checks only appear in the list after they've run at least once. To populate the list:

1. Create a test PR
2. Let the CI workflow run
3. Go back to branch protection settings
4. The status checks should now be available in the dropdown

### Checks not running on PR?

1. Verify the workflow triggers include `pull_request`
2. Check that the PR target branch matches the trigger branches
3. Look at Actions tab for any errors

## Best Practices

1. **Start strict**: Enable all protections from the start
2. **Require reviews**: At least 1 approval for production
3. **Keep checks fast**: Optimize CI to run quickly (<10 minutes)
4. **Clear communication**: Use PR template to guide contributors
5. **Update regularly**: Keep required checks in sync with your CI

## Related Files

- `.github/workflows/ci.yml` - CI/CD pipeline configuration
- `.github/pull_request_template.md` - PR template
- `tests/test_setup.sh` - Test suite (51 tests)

## Support

If you encounter issues with branch protection or CI:

1. Check GitHub Actions logs in the **Actions** tab
2. Review the test output for specific failures
3. Run tests locally: `./tests/test_setup.sh`
4. Check branch protection settings match this guide

---

**Remember**: Branch protection is your safety net. Keep it enabled and enforced! 🛡️
