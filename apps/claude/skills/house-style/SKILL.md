---
name: house-style
description: "Make writing read like a human wrote it, not a language model. Strips AI tells (unlock, leverage, seamless, em-dash overload, tricolons, 'not X but Y', bold-everything) and applies an Economist-inspired house style: short words, active voice, concrete specifics, New Zealand English. WHEN: de-AI this draft, make this sound less like AI, house style pass, review for AI tells, edit for style, tighten this writing, why does this read as AI-generated, style check this document."
license: MIT
metadata:
  author: cauldnz
  version: "1.0.0"
---

<!--
Forked from https://gist.github.com/cauldnz/c6da42c6881654b833dd5189b398495e
(secret gist, cauldnz "House Style", updated 2026-08-31), MIT per its frontmatter.
Adapted: Australian English changed to New Zealand English throughout, the
"personal skill, not committed to any repo" note corrected, and the author's own
worked examples replaced with neutral ones (this repo is public and the gist is
unlisted). Added after testing against a published essay: essays in scope with
the counts as a guide, back-loaded payoffs, more intensifiers, and framing devices
exempt from the antithesis count. Upstream wording is otherwise unchanged.
-->

# House Style — write like a human, not a model

Use this skill when drafting or reviewing customer-facing prose (position papers,
executive summaries, briefs, emails), or essays and posts in the author's own voice.
For those, the counts below are a guide, not a quota, and "every claim earns a
number, name or date" applies to factual claims, not to opinion.
The goal: writing that reads as if a sharp,
plain-spoken human wrote it. The benchmark is the Economist's house style —
concise, concrete, active, unshowy.

This skill does not change repo files unless the user explicitly asks you to apply
it to a named document.

**Companion skill — `economist-style`.** This skill is the *anti-AI* layer (cadence
tells, em-dash overload, tricolons, bold-everything, "not X — Y"). The companion
`economist-style` skill is the *positive editorial standard* (clarity, precision,
punctuation, numbers, dialect-matching, common errors) with detailed reference files.
For a full edit pass, apply both: use `economist-style` for line-level editing and this
skill to strip the machine-written feel. They are designed to be used together.

## How to run a pass

When asked to apply house style or "de-AI" a document:

1. **Read the whole thing first.** Style is about rhythm across paragraphs, not
   single words. Don't start editing on the first line.
2. **Diagnose, then fix.** Tell the user the top 3–4 tells driving the
   "AI" feel in *their* draft before rewriting. Usually it's cadence (em-dashes,
   tricolons, bold density, antithesis constructions), not vocabulary.
3. **Edit conservatively.** Preserve meaning, evidence citations, proper nouns
   (product, standard and project names), numbers, and the author's intent. Never invent
   facts to make a sentence flow.
4. **Show the change, not just the result.** For a review pass, surface the
   specific lines and the reason. For an edit pass, make the change and note what
   you cut and why.
5. **Read aloud.** If a sentence sounds like a brochure or a press release,
   rewrite it.

## The two kinds of AI tell

### A. Vocabulary tells (easy to spot, easy to fix)
Replace the word with the specific thing it's hiding.

- **Promo verbs:** unlock, leverage, harness, empower, streamline, supercharge,
  elevate, foster, drive, enable, facilitate, utilise.
- **Inflated adjectives:** seamless, robust, scalable, cutting-edge, holistic,
  comprehensive, bespoke, world-class, transformative, pivotal, crucial, vital,
  key (as an adjective), powerful, innovative, next-generation.
- **Abstract nouns:** landscape, journey, realm, ecosystem, synergy, solution(s),
  capabilities, paradigm, space (as in "the AI space").

Fix: name what actually happens. "Unlock value from data" →
"let an analyst answer the question without filing a ticket."

### B. Cadence tells (what actually makes it *feel* like AI — the bigger problem)

- **"Not just X, it's Y" / "It's not about X, it's about Y."** The model's
  favourite pivot. Allow at most one per document. A framing device the piece is
  built on (a repeated heading pattern such as "AI is not…", a sustained metaphor)
  doesn't count; judge the pivots that remain.
- **Tricolon overload.** Everything arrives in threes ("fewer tools, fewer
  contracts, fewer integration points"). Keep the strongest; break the rest into
  twos or fours so the rhythm varies.
- **"How vs why" antithesis.** "X is *how*; Y is *why it matters*." Elegant once,
  a tic when repeated. One per document.
- **Back-loaded payoff.** A long abstract subject, a weak verb ("is how", "is what",
  "that's how", "is where") and the point arriving last. Lead with what the reader
  cares about: "A feedback loop that honestly assesses each round is how the time
  and money pays off" → "The payback (both time and money) comes from a feedback
  loop that honestly assesses each round." Test: the main verb arrives within about
  eight words.
- **Em-dash overload.** When nearly every bullet or sentence hangs a clause off an
  em-dash, that alone reads as machine-written. Aim for ≤1 dash per paragraph;
  convert the rest to commas, full stops, or colons. The one that stays is a
  spaced en dash ( – ) in New Zealand English, never an em dash.
- **Bold-everything.** If six phrases per paragraph are bold, emphasis means
  nothing. Reserve bold for headers and genuinely scannable labels.
- **Throat-clearing / empty intensifiers:** "It's important to note that," "The
  reality is," "At its core," "Needless to say," "is real" ("the urgency is real").
  Delete them. Also cut "actually", "genuinely", "truly", "literally" and "really"
  unless they correct something the reader believes. Stacked manner adverbs
  (carefully, deliberately, intentionally, purposefully) are the same tic: keep one
  at most.
- **Hedging clusters:** "can help to potentially improve." Pick one.
- **Metronome rhythm.** Every sentence the same length and shape. Vary it: put a
  6-word sentence next to a 20-word one.

## Economist-inspired tenets (the positive target)

Built on Orwell's six rules:

1. **Cut every word you can.** If the sentence survives deletion, delete.
2. **Short word over long:** use (not utilise), help (not facilitate), about (not
   regarding), enough (not sufficient), build (not construct).
3. **Active voice, real subjects:** "The finance team approved the plan," not "the plan was
   approved."
4. **No jargon where an everyday word exists.** Keep necessary proper nouns and
   technical terms; drop filler jargon (operationalise, paradigm, leverage).
5. **Avoid stale metaphors** you've seen in print before.
6. **One idea per sentence. Short sentences.**
7. **Specific over abstract.** Numbers, names, dates beat adjectives. Every claim
   earns a number/name/date or gets cut.
8. **Confident, plain, lightly sceptical voice.** State things; don't sell them.
   No hype, no salesmanship.
9. **Break a rule rather than write something barbarous.** Clarity beats dogma.

## The checklist (apply to any draft)

- [ ] Dashes ≤ ~1 per paragraph, as a spaced en dash ( – ), never an em dash;
      rest → commas / full stops.
- [ ] Bold only for headers and scannable labels, not mid-sentence emphasis.
- [ ] No banned-until-justified words: unlock, leverage, seamless, robust,
      holistic, empower, streamline, transformative, pivotal, crucial, key (adj),
      realm, journey, landscape, comprehensive, bespoke.
- [ ] No throat-clearing: "it's important to note," "the reality is," "at its
      core," "is real."
- [ ] ≤1 "not X but Y" and ≤1 "how vs why" antithesis in the whole document,
      not counting a deliberate framing device.
- [ ] Tricolons: keep the strong ones, break the rest into 2s or 4s.
- [ ] Sentence rhythm varies: each paragraph mixes a short (<10-word) sentence
      with a longer one.
- [ ] Active voice with real subjects; short word over long.
- [ ] Every claim has a number, name, or date — or it's cut.
- [ ] New Zealand English: organise, optimise, behaviour, programme, modernise.
      Dates as "1 June 2026"; a bare $ is NZD; macrons on te reo Māori. For the full
      set of conventions, use the `economist-style` skill's DIALECT-CONVENTIONS
      reference.
- [ ] Read-aloud test passed: doesn't sound like a brochure.

## What NOT to do

- Don't turn this into a find-and-replace. The fix is rhythm and specificity, not
  a banned-word list. A draft can contain zero banned words and still read as AI.
- Don't strip the author's voice or flatten genuinely good lines into grey prose.
- Don't remove evidence citations, assumptions flags, numbers, or proper nouns.
- Don't add hedging, qualifiers, or "balance" the author didn't ask for.
