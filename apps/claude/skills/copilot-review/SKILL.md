---
name: copilot-review
description: Apply Copilot review feedback and resolve comments.
---

You are reviewing and applying GitHub Copilot's code review feedback. Your job is to:
1. Fetch Copilot's review comments
2. Evaluate each suggestion critically
3. Apply changes that make sense, skip those that don't
4. Resolve the comment threads for applied changes

## Step 1: Get PR details

Get the current PR number and repo info:

```bash
gh pr view --json number,url,headRefName
```

Extract the owner and repo from the URL (e.g. `https://github.com/owner/repo/pull/123`).

## Step 2: Fetch Copilot review comments

Use GraphQL to get review threads with full context:

```bash
gh api graphql -f query='
  query {
    repository(owner: "OWNER", name: "REPO") {
      pullRequest(number: PR_NUMBER) {
        reviewThreads(first: 100) {
          nodes {
            id
            isResolved
            path
            line
            comments(first: 10) {
              nodes {
                author { login }
                body
                createdAt
              }
            }
          }
        }
      }
    }
  }
'
```

Filter for threads where the first comment author login contains "copilot" (case-insensitive).

If there are no Copilot comments:
- Tell the user no Copilot feedback was found
- Copilot may not have reviewed yet, or had no suggestions

## Step 3: Parse Copilot's comment format

Copilot comments typically follow this structure:

```
In path/to/file.rb:

> @@ -21,6 +21,8 @@ def method_name
>    existing_line
>    another_line
+    new_suggested_line

[Explanation of the issue and reasoning]

Suggested change
-    old_code_line
+    new_code_line
```

For each comment, extract:
- **File path**: from the "In path/to/file:" line or the thread's `path` field
- **Line number**: from the thread's `line` field
- **Explanation**: the prose explaining the issue
- **Suggested change**: the diff block after "Suggested change" showing `-` (remove) and `+` (add) lines

## Step 4: Evaluate each suggestion

**Do not blindly apply all suggestions.** For each one:

1. **Read the relevant file** to understand the full context
2. **Understand Copilot's reasoning** - what problem is it trying to solve?
3. **Evaluate critically**:
   - Does this suggestion actually improve the code?
   - Is the reasoning sound given the full context?
   - Are there side effects Copilot might have missed?
   - Does it align with the codebase's patterns and conventions?

**Apply the change if:**
- The reasoning is sound
- The fix is correct
- It improves code quality, performance, or correctness

**Skip the change if:**
- The reasoning is flawed or based on incomplete context
- The suggested code has bugs or issues
- It conflicts with project conventions
- The "problem" isn't actually a problem in this context

## Step 5: Apply approved changes

For each suggestion you decide to apply:

1. Read the file at the specified path
2. Locate the code matching the `-` lines in the suggested change
3. Replace it with the `+` lines
4. Keep track of which thread IDs were addressed

## Step 6: Resolve applied comment threads

For each comment thread where you applied the fix, resolve it:

```bash
gh api graphql -f query='
  mutation {
    resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
      thread { isResolved }
    }
  }
'
```

Use the thread `id` from the GraphQL query in Step 2.

## Step 7: Report to the user

Present a clear summary:

**Applied changes:**
- List each file modified
- Briefly describe what was changed and why

**Skipped suggestions:**
- List each suggestion that was not applied
- Explain why (e.g. "Suggestion assumed X but the code actually does Y")

**Next steps:**
- Changes have been applied but not committed
- User should review with `git diff`
- When satisfied, commit and push

**Do not commit automatically.** Let the user review first.
