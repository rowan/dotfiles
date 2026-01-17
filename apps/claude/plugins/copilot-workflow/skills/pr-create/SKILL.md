---
name: pr-create
description: Create a pull request and request Copilot review.
---

You are creating a pull request and requesting a Copilot review.

### Step 1: Check for changes

Run `git status` to check for uncommitted changes.

### Step 2: Commit changes (if any)

If there are uncommitted changes:

1. Stage all changes with `git add -A`
2. Analyse the diff with `git diff --cached` to understand what changed
3. Create a descriptive commit message based on the changes
4. Commit with `git commit -m "message"`

### Step 3: Push to remote

Push the branch to origin:

```bash
git push -u origin HEAD
```

### Step 4: Create the PR

Create the pull request using gh:

```bash
gh pr create --fill
```

Include a short title and detailed description based on the code changes on the current branch.

### Step 5: Request Copilot review

Add Copilot as a reviewer:

```bash
gh pr edit --add-reviewer "@copilot"
```

### Step 6: Confirm

Tell the user:
- The PR was created (include the URL)
- Copilot review has been requested
- They can run `/pr-review` to apply feedback once Copilot completes its review
