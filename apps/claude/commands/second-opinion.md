---
description: Get a second opinion on the current diff from Codex or Gemini. Use for larger or complex PRs as a complement to in-session reviews.
argument-hint: "[codex|gemini] [optional: specific focus]"
allowed-tools: ["Bash", "Read", "Glob", "Grep"]
---

# Second opinion

Invoke an external AI CLI (Codex or Gemini) to review the current change. Supplements — doesn't replace — the in-session `code-reviewer` / `security-reviewer` / `spec-checker` sub-agents.

**Arguments:** `$ARGUMENTS`

## Parse

- First word is `codex` or `gemini`. Default: `codex`
- Remainder is an optional focus hint (e.g. "security", "performance", "look for race conditions"). If empty, do a general review
- Both CLIs are installed. If one is missing, stop and say so rather than silently falling back

## Context

- Confirm there's a diff to review: `git diff --stat main...HEAD` (or against the current PR base if different)
- If the current branch has no changes against base, stop and say so — nothing to review
- Don't dump the diff into the prompt; the CLIs have filesystem access and can read it themselves

## Execute

Use a 10-minute timeout (`timeout 600`) since review runs can take a while.

### Codex

Codex has a purpose-built `review` subcommand. Prefer it:

```bash
timeout 600 codex review --base main
```

With a focus hint:

```bash
timeout 600 codex exec --full-auto "Review the diff against main. Focus on: <hint>"
```

### Gemini

Gemini is headless via `-p`. Pipe the diff in as context:

```bash
git diff main...HEAD | timeout 600 gemini -p "Review these changes for bugs, security issues, and code quality. <hint if any>"
```

If either CLI hangs or errors out, try once with simpler flags, then give up and report the failure rather than guessing.

## Report

- Show the full external output verbatim
- Then add a short synthesis noting:
  - Findings that overlap with sub-agent reviews already run in this session
  - New issues the external reviewer flagged that we missed
  - Any disagreements worth discussing

Don't re-do the review yourself. The point is the alternate-model perspective.
