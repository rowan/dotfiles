---
name: hyperskepticism
description: Use when debugging a non-trivial bug, investigating unexpected behaviour, or any time you catch yourself thinking "I found it" / "that's the smoking gun" / "must be X" without having actually proved it. Use proactively on any debugging task that isn't immediately obvious from the error message. Also use when code "just works now" without you understanding what changed.
---

# Hyperskepticism mode

Your #1 enemy is **premature closure** — reaching a conclusion before all the evidence is in, then fitting everything you see afterwards to that conclusion instead of challenging it. Doctors misdiagnose this way. Detectives convict the wrong person this way. You debug the wrong thing this way. After forming a theory, actively try to disprove it before acting on it.

The moment you think "I found it" or "that's the smoking gun" — stop. That's your cue to prove it from first principles.

## Known failure modes

You will be tempted to reach for easy explanations. Recognise the pattern and resist it.

| Easy explanation you'll reach for | What you must do instead |
|---|---|
| "LLM variance" / "non-deterministic output" | Run it 3 times. Do the outputs actually vary? Write an eval. Show the distribution. |
| "The 3rd-party API is flaky/rate-limiting" | Reproduce with a minimal test script. Show request, response, status code, timestamps. |
| "It's a timing/race condition" | Add logging with timestamps. Reproduce it deterministically. Show the interleaving. |
| "The test is flaky" | Run it 10 times. If it fails once, find out why THAT one failed. |
| "Must have been a transient network issue" | Check the logs. Show the actual error. Retry with verbose logging. |
| "The model didn't return the right format" | Show the prompt, the response, and explain WHY the format was wrong. Is the prompt ambiguous? |
| "I think the issue is X" (without checking) | Don't think. Look. Read the actual code path. Step through it. |

## Proof standard

- **Our code**: step through the exact code path. Pinpoint the exact line. Show the actual values at that point.
- **3rd-party APIs**: show the request and response. Reproduce with curl or a minimal script.
- **LLM behaviour**: run it multiple times. Show the actual outputs. If claiming variance, show the variance.
- **"It works now"**: that is NOT a resolution. What changed? If nothing changed, you don't understand the problem yet.

## Your knowledge has limits — account for them

- Your training data has a cutoff. API behaviour, library versions, and defaults may have changed
- When debugging against external services, check the current docs. Don't rely on what you "know"
- If your fix is based on how you think an API works, verify that assumption first

## Turtles all the way down — follow the chain, don't leap

- Never jump from A to C. Go A → B → C, verifying each link
- At every step ask: "if this is true, what else would also be true?" Then check whether those things are true
- If your theory predicts X, and X isn't there, your theory is wrong. Don't explain away the missing evidence
- Follow the causal chain to actual bytes, values, or log lines. Stop when you hit bedrock (a value you can print, a log line you can read, a response you can show), not when you hit a plausible-sounding story
- "It makes sense that..." is not proof. "I can see that on line 47, `x` is `nil` because..." is proof

## The rule

No assertions without evidence. If you can't show the proof, you haven't found the bug.
