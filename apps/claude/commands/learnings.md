---
description: Capture lessons from the current PR and conversation into LEARNINGS.md, consolidating and pruning the file as you go.
allowed-tools: ["Bash", "Read", "Edit", "Write", "Grep", "Glob"]
---

> **Note:** The name "learnings" is used ironically. The correct word is "lessons". But corporate jargon has infected the industry, so here we are.

You are reviewing the current PR and conversation to capture useful lessons in `/LEARNINGS.md`,
and leaving the file smaller and sharper than a pure append would.

## When to use

Run this command just before merging a PR.

## The one rule that keeps the file usable

**One section per topic. If the topic exists, add to it.**

Never create `## Testing (continued)`, `## Testing (PR #123)`, or any other variant of a heading
that is already there. A per-PR heading mixes two taxonomies, topic and chronology, and a file
carrying both grows a section per PR instead of a section per subject.

Appending is always the easier move in the moment. Do not take it.

## Step 1: Get PR context

```bash
gh pr view --json number,title,body,headRefName
```

## Step 2: Read LEARNINGS.md in full

If it doesn't exist, create it with the structure at the bottom of this file and skip to Step 4.

Read the whole thing, not the headings. You cannot merge into a section you haven't read, and
you cannot spot a duplicate of an entry you've only skimmed past.

## Step 3: Consolidate and prune — before adding anything

This step is required on every run, not when the file "feels" messy. It is cheap when done each
time and expensive when deferred.

**Find duplicate headings mechanically:**

```bash
grep -c '^## ' LEARNINGS.md                  # total headings
grep '^## ' LEARNINGS.md | sort -u | wc -l   # distinct headings
```

Different numbers mean duplicate or `(continued)` sections. Merge them into one section per topic
before going further.

**Find duplicate entries.** Scan the bold titles for two entries making the same claim. Merge them
into one, keeping the strongest evidence from each — an entry that says "this bit three times, in
these three ways" is more persuasive than three entries that each say it once.

**Prune.** An entry earns removal when any of these is true:

- It is now documented in `AGENTS.md`, `CLAUDE.md`, or the README. Those are read every session;
  LEARNINGS is not. Keep any *judgement* the docs omit, drop the mechanics they cover.
- It is about a dependency, API, or tool no longer in the project.
- It describes a migration that has since completed.
- A later entry supersedes it.

Removing something real is worse than keeping something stale, so when in doubt keep it — but
apply the four triggers honestly, because a file nobody trusts to be current is a file nobody reads.

## Step 4: Review the conversation

Look for:

1. **Review feedback** — issues found in review that required fixes
2. **Backtracking** — things the user asked to undo or do differently
3. **False assumptions** — things asserted confidently that turned out wrong. These are the most
   valuable entries in the file and the easiest to leave out, because writing one means recording
   a mistake.
4. **Non-obvious solutions** — approaches that weren't apparent up front
5. **Project-specific patterns** — conventions discovered during the work
6. **Loops and wheel-spinning** — where time went and why
7. **Questions escalated that you could have answered** — a file read or a query that would have
   settled it
8. **Gotchas** — subtle bugs or edge cases that could bite again
9. **Tool discoveries** — flags, APIs, or approaches that weren't obvious

For each candidate, ask:

- Would this change what someone does next time? If not, skip it.
- Is it already in the file, or in `AGENTS.md` / `CLAUDE.md`?
- Is it specific enough to act on? "Be careful with X" is not a lesson.

Skip typos, formatting, and anything a compiler would have caught.

## Step 5: Add the new lessons

Into the existing sections. Create a new section only when the topic genuinely isn't represented.

**Entry shape — the title is the lesson, the body is the evidence:**

```markdown
- **Name the lesson as a claim or an instruction**: then the evidence, tightly. Keep the specific
  number, symbol, or error string when that is what makes it persuasive; cut the narrative once the
  lesson stands without it.
```

A reader scanning bold titles should get the lesson without the bodies. If the title only makes
sense after reading the body, the title is wrong.

Cut the incident retelling. "We spent two hours discovering that..." is throat-clearing; the lesson
is what you discovered.

## Step 6: Check nothing was lost

Consolidating silently destroys value if you let it. Diff the entry titles:

```bash
# before editing
sed -n 's/^- \*\*\([^*]*\)\*\*.*/\1/p' LEARNINGS.md | sort > /tmp/learnings-before.txt
# after editing
sed -n 's/^- \*\*\([^*]*\)\*\*.*/\1/p' LEARNINGS.md | sort > /tmp/learnings-after.txt
diff /tmp/learnings-before.txt /tmp/learnings-after.txt
```

Account for every removed title as **merged into X** or **pruned because Y**. Anything you cannot
account for was dropped by accident — restore it. Reworded titles will show as a remove plus an
add; confirm each pair is the same lesson rather than assuming it.

## Step 7: Report

- How many lessons were added, and under which topics
- What was merged, and what was pruned with the reason
- The before/after entry and heading counts
- Anything you judged too marginal to include, so the user can overrule you

Do not commit. The user reviews first.

## File structure

For a file that doesn't exist yet:

```markdown
# Learnings

Lessons from past work, kept because they were expensive to learn. Updated when merging PRs.

One section per topic — add to the section, don't append a new one. Anything that belongs in
`AGENTS.md` (how to run the build, the lint gate, the release train) lives there instead.

---

## [Topic]

- **The lesson, as a claim or instruction**: the evidence, tightly.
```
