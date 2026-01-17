---
name: learnings
description: Capture lessons from the current PR for future reference.
---

> **Note:** The name "learnings" is used ironically. The correct word is "lessons". But corporate jargon has infected the industry, so here we are.

You are reviewing the current PR and conversation to capture useful lessons in `/LEARNINGS.md`.

## When to use

Run this skill just before merging a PR, to capture insights that could help future work.

## What to capture

Review the full conversation history and look for:

1. **Code review feedback** - Issues identified during review that required fixes
2. **Backtracking** - Things the user asked to undo or do materially differently
3. **Non-obvious solutions** - Approaches that weren't immediately apparent
4. **Project-specific patterns** - Conventions or patterns discovered during this work
5. **Loops** - Instances where we spun wheels trying to solve a problem
6. **Time wasting** - Situations where we stopped and asked the user for a decision where we could have resolved the question ourselves with a bit more work
7. **False assumptions** - Things we assumed that turned out to be wrong (mental model errors)
8. **Gotchas** - Subtle bugs or edge cases that could bite again
9. **Tool/command discoveries** - Useful CLI flags, APIs, or approaches that weren't obvious

Focus on lessons that are:
- Reusable in future work
- Not already documented elsewhere (CLAUDE.md, README, etc.)
- Specific enough to be actionable

Skip trivial things like typo fixes or simple formatting issues.

## Step 1: Get PR context

```bash
gh pr view --json number,title,body,headRefName
```

## Step 2: Check for existing LEARNINGS.md

Look for `/LEARNINGS.md` in the repository root.

**If the file exists:**
- Read it first
- Understand the existing structure and content
- Add new learnings that complement (not duplicate) existing ones
- Consider consolidating related items

**If the file doesn't exist:**
- Create it with the introduction below, then add learnings

## File structure

```markdown
# Learnings

Lessons captured from past work to inform future development. Updated when merging PRs.

---

## [Topic or Area]

- **Learning title**: Brief description of what was learned and why it matters.

```

## Step 3: Review the conversation

Scan the full conversation for:

1. **Problems caught in review** - What was wrong? What was the fix? What's the takeaway?
2. **User corrections** - Where did the user redirect the approach? Why was the original approach wrong?
3. **Surprises** - Anything unexpected about the codebase, tools, or approach?

For each potential learning, ask:
- Is this specific enough to be useful?
- Would this help avoid a similar mistake?
- Is this already documented elsewhere?

## Step 4: Update LEARNINGS.md

Write learnings that are:
- **Concise** - One or two sentences each
- **Actionable** - Clear what to do differently
- **Contextual** - Include enough context to understand why

Group related learnings under topic headings.

**Example learnings:**

```markdown
## Code style

- **Prefer symlinks over copies for dotfiles**: Symlinked config files stay in sync with the repo automatically. Use `ln -s` instead of `cp` for anything that might change.

## GitHub API

- **GraphQL filtering happens client-side**: GitHub's GraphQL API returns all results; filter in your code after fetching, not in the query.
```

## Step 5: Report to the user

Summarise:
- How many learnings were added
- What topics they cover
- Any existing learnings that were updated or consolidated

The changes are not committed automatically. The user should review before committing.
