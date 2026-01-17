---
name: copilot-review
description: Request a Copilot review on an existing pull request.
---

You are requesting a Copilot review on an existing PR.

### Step 1: Get current PR

Check if we're on a branch with an open PR:

```bash
gh pr view --json number,url,state
```

If no PR exists, inform the user they need to create one first (suggest using `/pr-create`).

### Step 2: Request Copilot review

Add Copilot as a reviewer:

```bash
gh pr edit --add-reviewer "@copilot"
```

### Step 3: Confirm

Tell the user:
- Copilot review has been requested on PR #[number]
- They can run `/pr-review` to apply feedback once Copilot completes its review
- Copilot typically takes a few minutes to review
