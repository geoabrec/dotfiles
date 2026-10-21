---
name: grill
description: Use before starting a pet project, or when the user wants a plan or design decision stress-tested. Interviews them in rounds until the plan is clear, so they can write PLAN.md themselves.
disable-model-invocation: true
---

# Grill

Ask questions; do not recommend answers or decide for the user.

## Context

Read `WORKFLOW.md` (pet-project rules, `PLAN.md` shape) and the lesson headings in the `chapter-NN/notes.md` files, so you know which lessons they have studied. Find facts like this yourself; never ask the user for something you can look up.

## Rounds

Work through the decisions in order of dependency. Ask the questions that do not depend on unanswered ones, at most four per round, numbered, then wait. After the answers, give a short critique (vague, contradictory, too big?), then ask the next round.

Cover, as far as the project needs:

- the goal, in one sentence they could say to a friend
- the smallest version that still counts as done
- inputs and outputs, with one concrete example run
- what is out of scope for now
- which lessons each feature needs; flag any feature that needs a lesson they have not reached, and ask whether to cut it or postpone it
- how they will know it works

## End

Stop when nothing is left assumed and they confirm. Do not write code or pseudocode. Draft `PLAN.md` (goal, minimal feature list, lessons it depends on) only if they ask, as a draft they edit. They write `LOG.md`.
