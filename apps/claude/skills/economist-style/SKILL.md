---
name: economist-style
description: Line-level editorial standard based on The Economist style guide, adapted for New Zealand English. Clarity, precision, brevity, punctuation, numbers, dates, currency, capitalisation, te reo Māori conventions. Use when editing prose, documentation or any written text that needs an editing pass. Pairs with house-style, which strips AI tells; use both for a full pass.
---

<!--
Forked from https://github.com/TAJD/economist-style-guide-plugin @ cfb132d (2026-08-01), MIT.
Vendored rather than installed as a plugin because it is adapted, not used verbatim:
reference/DIALECT-CONVENTIONS.md now leads with New Zealand English, and the date,
currency, large-number, dash, honorific and institution rules below follow NZ usage
rather than the Economist's own. A Register section relaxes the tone rules for
first-person essays and posts.
Upstream wording is otherwise unchanged (US spelling in filenames included).
-->

# The Economist Style Guide

Apply these principles to all written content, including markdown files, HTML, code documentation, and technical writing.

## Core Principles

1. **Clarity first**: Use short words, active voice, and concrete examples
2. **Precision**: Replace vague quantifiers with specific numbers and facts
3. **Brevity**: Choose concise over verbose expressions
4. **Dialect awareness**: Default to New Zealand English. Match a document that already uses another dialect consistently rather than converting it

## Orwell's Six Elementary Rules

The guide's introduction rests on George Orwell's six rules (from "Politics and the English Language", 1946): clarity of thought first, then say it as simply as possible.

1. Never use a metaphor, simile or other figure of speech which you are used to seeing in print
2. Never use a long word where a short one will do
3. If it is possible to cut out a word, always cut it out
4. Never use the passive where you can use the active
5. Never use a foreign phrase, a scientific word or a jargon word if you can think of an everyday English equivalent
6. Break any of these rules sooner than say anything outright barbarous

## Tone: The "Do Nots"

In the spirit of the guide's introduction:

- **Do not be stuffy**: Use everyday speech, not the language of lawyers or bureaucrats
- **Do not be hectoring or arrogant**: Those who disagree are not necessarily stupid; persuade with evidence, not assertion
- **Do not be too pleased with yourself**: Let analysis speak; avoid self-congratulation
- **Do not be too chatty**: Maintain professional distance
- **Do not be too didactic**: Guide, don't lecture
- **Get straight in and be lucid**: No throat-clearing openings; edit ruthlessly; cut anything superfluous

## Analysis Workflow

When reviewing text, follow this sequence:

### 0. Load the Signature Rules
Read `reference/ECONOMIST-SIGNATURE.md` first — a one-page distillation of the rules that make copy recognizably Economist (numbers, dates, commas, quotes, honorifics, headings). Most reviews need only this plus the quick checks below; load the detailed files only when a deeper check is warranted.

### 1. Detect Document Dialect
**Default is New Zealand English** (-ise, -our, -re; 1 June 2026; $ means NZD; metric).
Before making suggestions, check what the document already does:
- Look for spellings like "colour" vs "color", "organise" vs "organize"
- Check date formats (1 June 2026 vs June 1st 2026 vs June 1, 2026)
- Observe punctuation style (single vs double quotes)
- **A document consistently in another dialect keeps it.** Flag internal
  inconsistency; don't convert a deliberately American or British document
- New writing, and anything for a New Zealand audience, uses NZ English

### 2. Structural Review
- Check for buried ledes (main point should come first)
- Verify logical flow and argument structure
- Ensure each paragraph has a clear purpose

### 3. Clarity Analysis
For detailed passive voice and clarity rules, read `reference/CLARITY.md`

Quick checks:
- Flag passive voice constructions
- Identify jargon and suggest plain alternatives
- Find unnecessarily complex words
- Detect hedge words that weaken statements

### 4. Precision Check
For detailed precision rules, read `reference/PRECISION.md`

Quick checks:
- Identify vague quantifiers ("many", "often", "significant")
- Flag weasel words and empty fillers
- Flag clichés and dead metaphors ("game-changer", "perfect storm")
- Suggest specific numbers or evidence
- Remove redundant phrases

### 5. Dialect Conventions
Read `reference/DIALECT-CONVENTIONS.md` when the document uses New Zealand English
(for dates, currency, institutions and te reo Maori conventions), when the user asks
for a dialect check, or when the document is internally inconsistent.

### 6. Common Errors
For frequently encountered mistakes, read `reference/COMMON-ERRORS.md`

### 7. Punctuation Check
For detailed punctuation rules (commas, semicolons, dashes, quotation marks), read `reference/PUNCTUATION.md`

Quick checks:
- Verify comma usage (serial comma, restrictive clauses)
- Check dash and hyphen usage. NZ: spaced en dash ( – ) to set off a clause, no em dashes
- Ensure consistent quotation mark style

### 8. Numbers and Figures
For number formatting guidelines, read `reference/NUMBERS.md`

Quick checks:
- Spell out numbers one to ten, use numerals from 11
- Verify percentage formatting (% symbol, percentage points vs percentages)
- Check date and currency formatting

### 9. Structure Review
For document organisation guidelines, read `reference/STRUCTURE.md`

Quick checks:
- Each paragraph has a clear topic sentence
- Lead/opening hooks the reader
- Logical flow from paragraph to paragraph
- Conclusion adds value (not just summary)

### 10. Tone Assessment
For voice and register guidance, read `reference/TONE.md`

Quick checks:
- Authoritative but not arrogant
- Avoid excessive adjectives and intensifiers
- Neutral language on contested issues
- No preaching or lecturing
- People: full name on first mention, surname alone after (NZ; not the Economist's "Ms Yellen")
- First-person essays and posts: apply the Register section below instead of the pronoun and lecturing rules

### 11. Abbreviations (on-demand)
If the document contains abbreviations or acronyms, read `reference/ABBREVIATIONS.md`

### 12. Capitalisation (on-demand)
If there are capitalisation questions (titles, institutions, geographic terms), read `reference/CAPITALIZATION.md`

### 13. Special Contexts (on-demand)
For quotations, foreign words, lists, or tables, read `reference/SPECIAL-CONTEXTS.md`

### 14. Word Usage (on-demand)
For rulings on commonly misused words (aggravate, decimate, refute, unique...), read `reference/WORDS.md`

## Output Format

When providing feedback:

1. List issues by category (clarity, precision, dialect consistency if applicable)
2. Provide line/paragraph references
3. Show original text and suggested replacement
4. Explain the reasoning briefly

Example:
```
**Clarity Issue** (Para 2, Line 3)
Original: "The data was analysed by the research team"
Suggested: "The research team analysed the data"
Reason: Active voice is clearer and more direct
```

## Register: Essays, Newsletters and Posts

The Economist's tone rules are written for unsigned news analysis. For first-person
writing (essays, newsletters, blog posts, talks), apply these instead:

- **"We" is the default voice**: the writer and reader together, or the writer's team.
  Prefer it to "you" in most cases ("we get bland prose", not "you get bland prose")
- **"I" is fine** for the author's own experience, opinions and work ("I'm old enough
  to have seen…")
- **"You"** only for a direct instruction or exercise aimed at the reader ("Try this:
  sort your tasks by…"). Elsewhere, suggest "we"
- **Consistency within a paragraph**: flag a switch between "we" and "you" mid-paragraph
  unless the "you" is a direct instruction
- **Rhetorical questions** are allowed sparingly, to open a piece or pose the question a
  section answers
- **Exclamation marks** are rare, and only where the author is plainly being playful
- **Imperatives and calls to action** ("Stop bracing for…") are part of the form, not
  lecturing
- **A closing recap** that returns to a device set up earlier (a subtitle, a numbered
  list) counts as returning to the opening, not mere summary

Everything else (punctuation, hyphens, word choice, dialect, clichés) applies as normal.

## When Not to Apply

- Direct quotations (preserve original wording)
- The pronoun, rhetorical-question and lecturing rules, in first-person essays and posts
  (see Register above)
- Code examples (unless in comments/documentation)
- Technical terms with no plain alternative
- Proper nouns and brand names
- Established dialect/spelling patterns (match what's already there)
