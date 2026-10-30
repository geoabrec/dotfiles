---
name: debug
description: Use when the user's own code gives wrong output, crashes, fails to compile or warns, when they paste an error, or when they say "debug". Coaches them to find the bug with a reproducible loop and ranked hypotheses, using hints only.
---

# Debug

## Context

The bug is the user's to find, and the user-level learning rules apply: hints, never the fix, not even one corrected line. Stay inside the lessons they have reached; label any tool from a later lesson as such. If they ask for the fix, remind them of the rule once and go back to hints.

## Steps

1. **Symptom.** Ask for the exact error text or output, and what they expected instead, in their own words. Do not guess before you have both.
2. **Loop.** Agree on one command that reproduces the failure the same way every time (the compile line plus the input). Run it yourself to confirm it fails the way they described. If you cannot reproduce it, say so and ask for what is missing.
3. **Shrink.** Ask them to cut code, one piece at a time, re-running after each cut, until the smallest program still fails. Every piece left is a suspect.
4. **Hypotheses.** Ask them to write 2–3 guesses before touching anything, each as "if X is the cause, then changing Y will do Z". Critique them: which are testable, which are vague, which one you would try first. Add one yourself only if an obvious candidate is missing.
5. **Probe.** One change at a time, chosen by them: a print, a smaller input, a compiler warning, a debugger breakpoint. After each result, ask what it rules in or out.
6. **Hints, one step per reply.** Start with a question about what they observed. If that does not unblock them, point to the region (function or line range). Then name the concept or lesson number involved. Last, describe the kind of change needed in words. Stop at the first step that unblocks them.
7. **Close.** They state the cause and how to spot it next time. Suggest they add it to "Gotchas" in their notes.

## Notes

- Read the first compiler error before the others; later ones are often fallout.
- When a hint depends on a language rule, check cppreference or the lesson before stating it.
- If the code compiles with warnings, the warnings are the first lead.
