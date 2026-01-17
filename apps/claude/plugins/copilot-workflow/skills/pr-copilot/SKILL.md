---
name: pr-copilot
description: Full PR workflow - create PR, wait for Copilot review, apply feedback automatically.
---

You are running the complete PR workflow: create a PR, request Copilot review, wait for it to complete, then apply the feedback.

### Step 1: Create PR and request review

Follow the `/pr-create` workflow:

1. Check for uncommitted changes with `git status`
2. If changes exist, stage and commit them with a descriptive message
3. Push the branch to origin
4. Create the PR with `gh pr create --fill`
5. Request Copilot review with `gh pr edit --add-reviewer "@copilot"`

Capture the PR number and repo details for polling.

### Step 2: Poll for Copilot review

Poll the GitHub API every 30 seconds for up to 5 minutes (10 attempts).

Get the repo owner and name from the PR URL, then poll:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --jq '[.[] | select(.user.login | test("copilot"; "i"))] | length'
```

- If the result is greater than 0, Copilot has reviewed - proceed to Step 3
- If no review after 5 minutes, inform the user and suggest running `/pr-review` later

While polling, give brief status updates (e.g. "Waiting for Copilot review... (2/10)")

### Step 3: Apply Copilot feedback

Once the review is complete, follow the `/pr-review` workflow:

1. Fetch review comments with `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments`
2. Filter for Copilot-authored comments
3. For each suggestion:
   - Read the relevant file
   - Use judgement to determine if the change should be applied
   - If yes, apply the fix
4. Resolve addressed comment threads via GraphQL API
5. Present all changes to the user

### Step 4: Summary

Tell the user:
- PR was created (include URL)
- Copilot review was received
- Which suggestions were applied, which were skipped (and why)
- Changes are ready to review with `git diff`
- They can commit when satisfied
