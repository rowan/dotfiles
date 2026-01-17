---
name: pr-review
description: Apply Copilot review feedback and resolve comments.
---

You are applying Copilot's review feedback to the code.

### Step 1: Get PR details

Get the current PR number and repo info:

```bash
gh pr view --json number,url,headRefName
```

Extract the owner and repo from the URL.

### Step 2: Fetch review comments

Get all review comments on the PR:

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments
```

### Step 3: Filter for Copilot comments

Filter the comments to only include those from Copilot (author login contains "copilot").

If there are no Copilot comments, inform the user that:
- No Copilot feedback was found
- Copilot may not have reviewed yet (suggest running `/copilot-review`)
- Or Copilot had no suggestions

### Step 4: Apply each fix

For each Copilot comment that suggests a change:

1. Read the file mentioned in the comment (`path` field)
2. Understand the suggestion from the comment body
3. Use judgement to determine if the suggested change should be applied.
4. If yes, apply the fix to the correct location (use `line` or `original_line` field)
5. Track the comment ID for resolution

### Step 5: Resolve comment threads

For each comment that was addressed, resolve the thread:

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_ID"}) {
      thread { isResolved }
    }
  }
'
```

Note: To get the thread ID, you may need to query the PR's review threads first:

```bash
gh api graphql -f query='
  query {
    repository(owner: "OWNER", name: "REPO") {
      pullRequest(number: PR_NUMBER) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes {
                author { login }
                body
                path
                line
              }
            }
          }
        }
      }
    }
  }
'
```

### Step 6: Present changes

Show the user what was changed:
- List each file modified
- Summarise the fixes applied
- Note which comments were resolved, and which were skipped (and why)

**Do not commit the changes automatically.** Let the user review and commit when ready.

### Step 7: Suggest next steps

Tell the user:
- The changes have been applied but not committed
- They should review the changes with `git diff`
- When satisfied, they can commit and push
- Or run `/pr-create` to commit and update the PR
