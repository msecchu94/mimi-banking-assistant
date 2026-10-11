# Mimi — Agent Instructions

Mimi is a hybrid conversational AI banking assistant.

**Stack:** Flutter/Dart · Python/FastAPI · PostgreSQL · LLM

**Core principle:**

> AI understands. Backend validates and executes.

Use pragmatic Clean Architecture. Prefer simple, explicit designs over
speculative abstractions.

## Context

Load only the documentation relevant to the current task. Do not read all
project documentation by default.

| Concern | Read |
|---|---|
| V1 scope | `docs/product/V1_SCOPE.md` |
| Architecture | `docs/architecture/ARCHITECTURE.md` |
| Domain | `docs/architecture/DOMAIN_MODEL.md` |
| Conversation | `docs/architecture/CONVERSATION.md` |
| Chat API | `docs/architecture/API_CONTRACT.md` |
| AI / safety | `docs/architecture/AI_SAFETY.md` |

Use `docs/product/PRODUCT.md` and `PRODUCT_IDENTITY.md` only when product
context or identity is relevant.

If documents conflict, stop and report the conflict. Do not silently choose
an interpretation.

## Architecture

- Domain is framework-independent.
- Application owns Use Cases and declares required external ports.
- Infrastructure implements Application Ports.
- Frameworks and transport concerns stay at the edges.
- FastAPI/HTTP concerns must not leak into Application or Domain.
- Concrete dependencies are wired explicitly at the Composition Root.
- Conversation Engine orchestrates conversation, not financial rules.
- Financial operations and validation belong to deterministic backend logic.
- Flutter renders and manages presentation; it does not reproduce banking or
  conversational business logic.
- Add abstractions only when they solve a concrete problem.

## Backend

- Use typed Python and follow existing project conventions.
- Use `Decimal`, never `float`, for money.
- Use UUIDs for documented domain identifiers.
- Use timezone-aware datetimes.
- Routers delegate; they do not contain business logic.
- Financial state/results must originate from persistent backend data.
- Do not hardcode financial truth into conversational responses.
- Map semantic application errors to HTTP only at the API boundary.

## Flutter

- Keep HTTP/Dio/DTO concerns in Data.
- Do not leak transport errors or DTOs into Presentation.
- Map API failures to application-level failure semantics.
- Use Cases expose explicit success/failure results according to the approved
  architecture.
- Presentation maps application results to view state.
- Render the typed Chat API contract; do not infer banking behavior from
  `intent` or recreate backend conversation state.
- Do not add an `Either`/FP dependency without approval.

## AI

For AI work, follow `AI_SAFETY.md`.

Always preserve these invariants:

- LLM output is untrusted until validated.
- The LLM may interpret language and produce candidate intents/entities.
- The LLM never owns financial truth or authoritative calculations.
- The LLM never modifies state, executes operations, or authorizes them.
- Validation and explicit confirmation cannot be bypassed.
- Avoid LLM calls for deterministic structured interactions.

## Scope and Dependencies

Implement only the approved task.

Do not:

- expand V1 without approval;
- implement speculative/post-V1 functionality;
- refactor unrelated code;
- add infrastructure "for later";
- add dependencies without a concrete need;
- silently make significant architectural decisions.

Before adding a meaningful dependency, explain why the existing stack is
insufficient and request approval.

If the task requires crossing an approved architecture or scope boundary,
stop and ask.

## Testing

Add appropriate tests for behavioral changes.

Prioritize Domain invariants, Use Cases, financial calculations, conversation
transitions, confirmation/revalidation, state-changing operations,
repositories, API contracts, and error mapping.

Test relevant success and failure paths. Test behavior, not implementation
details.

Do not weaken valid tests to make an implementation pass.

Run relevant formatting, static analysis, and tests before handoff.

## Documentation

Keep documentation modular, concise, and non-redundant.

Do not create new `.md` files unless required. Update existing documentation
only when an approved decision changes.

Do not restate documentation in plans or reports unless necessary.

## Workflow

Unless explicitly instructed otherwise:

1. **Inspect** — Check task, `git status`, relevant code/tests, and only the
   required documentation. Do not modify files.
2. **Plan** — Give a concise plan: changes, affected files, tests, dependencies,
   and unresolved architectural decisions.
3. **Review** — Stop and wait for approval.
4. **Implement** — Implement only the approved plan. Stop if a material
   deviation becomes necessary.
5. **Test** — Run relevant format/analyze/tests and report failures honestly.
6. **Review diff** — Inspect `git diff` and `git status` for accidental changes,
   scope creep, debug code, secrets, unnecessary dependencies, and missing
   tests.
7. **Handoff** — Concisely report changes, tests/results, concerns, and a
   suggested commit message. Return control to the user.

Keep plans and handoffs concise.

## Git and Safety

The user owns the final commit.

Do not `commit`, `push`, `rebase`, force-push, discard changes, or run
destructive Git commands unless explicitly requested.

Never expose or commit secrets, credentials, tokens, passwords, or local
environment values.

Do not modify unrelated user changes or generated files unless required by
the approved task.