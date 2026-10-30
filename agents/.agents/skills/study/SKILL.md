---
name: study
description: Use when the user wants their notes explained or connected, wants tutoring in mathematics or programming foundations, or wants active-recall questions. Recall happens in chat.
---

# Study

## Context

This skill works from any directory and on any machine, so it names no fixed paths. Read the notes the user asks about. Notes live next to the project they belong to (for example `chapter-NN/notes.md` in a learning project); resolve a named note against the working directory first, and ask for the path if it is not there. Recent test feedback (its "Next" sections) can help calibrate. Ask which topic or notes to use if unspecified. Notes are the user's own writing: read them, never edit them unless explicitly asked. Never assume access to missing conversations or infer competence from note ownership.

Calibrate from the notes and the user's answers; do not impose a new curriculum or assume advanced readiness. Connect to numerical methods, probability, algorithms, performance, and finance when genuinely relevant—not as decoration.

## Explain mode

- Start from the user's question and prerequisites. Define notation and assumptions.
- Give a coherent explanation across the selected notes rather than separate summaries.
- Include intuition, precise definitions, derivations or proofs where appropriate, and worked examples and counterexamples.
- In programming, distinguish language guarantees from implementation details; in mathematics, distinguish proof from empirical evidence.
- Surface misconceptions and contradictions in source notes. Notes are not infallible.
- Verify consequential claims against a primary source (the lesson, cppreference, the ISO draft for C++) instead of memory, following the user-level uncertainty rule. Note anything that depends on the language standard version.
- Offer a small understanding check. If the user is solving an exercise, prefer hints and questions unless a full solution is requested.
- Allow challenging material without skipping necessary foundations.

## Active-recall mode

In interactive recall, ask one question at a time and wait for the user's attempt. Mix explanation in their own words, derivation, prediction, debugging, counterexamples, and application. Adapt difficulty to actual responses. Verify the reasoning, not just matching words. Mix old and new: unless the user names a topic, draw about a third of the questions from earlier chapters or from weak points in recent "Next" sections, and vary topics instead of drilling one. Give specific corrective feedback; when the user requests hint-first practice, allow a retry before revealing the solution.

When the user wants recall questions to keep, give them in chat for the user to add to their notes. Use questions that test understanding and transfer, not recognition or memorized wording, and leave out answers unless requested. Write into a note only on explicit request, preserving the user's existing questions. When reviewing the user's own recall questions, say which test understanding and which only test recall of wording, and suggest sharper versions.

## Persistence boundaries

Explain and quiz in conversation by default. Invoking this skill does not authorize saving notes, tests, or progress files. Assistant memory follows the user-level memory rule.

For a mock examination and formal grading, use the `test` skill instead of creating a second testing workflow here. For a bug in the user's own code, use `debug`. When the user says an explanation did not land, `reexplain` is the short form.
