---
name: study
description: Explain and connect the user's notes, tutor advanced mathematics and programming foundations, or run active recall. Recall happens in chat.
---

# Study

## Context

This skill works from any directory and on any machine, so it names no fixed paths. It needs one location, the user's **practice folder**, which holds their saved tests and a `CLAUDE.md` with the practice rules. Find it in this order:
1. Where the user's instructions or saved memory say it is.
2. A folder named `practice` or `.practice` in the working directory or one of its parents.
3. Otherwise ask once, then record the answer (assistant memory, or the user-level instructions if the user prefers) so it is not asked again.

If a recorded location no longer exists, ask for the new one; do not create a replacement. If the user has no practice folder, continue without one.

Read the practice folder's `CLAUDE.md`, which names the user's profile and where notes that belong to no project live, then that profile and the notes the user asks about. Notes live next to the project they belong to (for example `chapter-NN/notes.md` in a learning project); resolve a named note against the working directory first, then the loose-notes location the rules file names. Recent test feedback in the practice folder (its "Next" sections) can help calibrate. Ask which topic or notes to use if unspecified. Notes are the user's own writing: read them, never edit them unless explicitly asked. Never assume access to missing conversations or infer competence from note ownership.

Use recorded prerequisites to calibrate; do not impose a new curriculum or assume advanced readiness. Connect to numerical methods, probability, algorithms, performance, and finance when genuinely relevant—not as decoration.

## Explain mode

- Start from the user's question and prerequisites. Define notation and assumptions.
- Give a coherent explanation across the selected notes rather than separate summaries.
- Include intuition, precise definitions, derivations or proofs where appropriate, and worked examples and counterexamples.
- In programming, distinguish language guarantees from implementation details; in mathematics, distinguish proof from empirical evidence.
- Surface misconceptions and contradictions in source notes. Notes are not infallible; verify consequential claims when practical, and state uncertainty.
- Offer a small understanding check. If the user is solving an exercise, prefer hints and questions unless a full solution is requested.
- Allow challenging material without skipping necessary foundations or forcing finance examples.

## Active-recall mode

In interactive recall, ask one question at a time and wait for the user's attempt. Mix explanation in their own words, derivation, prediction, debugging, counterexamples, and application. Adapt difficulty to actual responses. Verify the reasoning, not just matching words. Give specific corrective feedback; when the user requests hint-first practice, allow a retry before revealing the solution.

When the user wants recall questions to keep, give them in chat for the user to add to their notes. Use questions that test understanding and transfer, not recognition or memorized wording, and leave out answers unless requested. Write into a note only on explicit request, preserving the user's existing questions. When reviewing the user's own recall questions, say which test understanding and which only test recall of wording, and suggest sharper versions.

## Persistence boundaries

Explain and quiz in conversation by default. Invoking this skill does not authorize saving notes, tests, or progress files. Assistant memory is saved automatically under the user-level `CLAUDE.md`.

For a saved mock examination and formal grading, use the `test` skill instead of creating a second testing workflow here.
