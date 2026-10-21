---
name: reexplain
description: Use when the user says the last message did not land, asks for simpler words, or invokes /reexplain. Re-explains it in plain words with their own vocabulary, then checks understanding with one question.
disable-model-invocation: true
---

# Reexplain

Explain the last message again from a different angle. Do not repeat the same sentences more slowly.

1. **Anchor.** One sentence: what the answer is for, in the context of what they were doing.
2. **Plain words.** Short sentences, no jargon. Use only terms from their notes (`chapter-NN/notes.md`, if present) or lessons they have reached. If a new term is unavoidable, define it in one line.
3. **One example or analogy,** small and concrete. Not a second one unless they ask.
4. **Gap.** If a missing prerequisite caused the confusion, name it by lesson number instead of teaching it inline.
5. **Check.** End with one question that makes them answer in their own words.

Keep it under about 150 words. If it still does not land, ask which word or step lost them instead of rephrasing a third time.
