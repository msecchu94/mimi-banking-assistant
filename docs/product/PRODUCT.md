# Hybrid AI Banking Assistant

## Product Overview

Hybrid AI Banking Assistant is a conversational financial assistant
designed for a fictional digital banking or fintech application.

The product allows users to interact with financial information using
natural language while maintaining deterministic and controlled flows
for financial operations.

The project demonstrates how conversational AI can be integrated with
a real application architecture without delegating financial authority
to a Large Language Model.

---

## Business Problem

Users of digital banking and fintech applications often need to
navigate multiple screens, menus and predefined flows to access
financial information or perform common operations.

Traditional menu-based chatbots provide predictable behavior but are
often rigid and require users to adapt to predefined interaction paths.

Fully generative assistants provide a more natural interaction model,
but financial operations require deterministic validation, explicit
confirmation and controlled execution.

This project explores a hybrid approach that combines the flexibility
of natural-language interaction with deterministic banking workflows.

---

## Target User

The target user is a customer of a digital banking or fintech
application who wants to interact with financial services in a simpler
and more conversational way.

The user should be able to:

- Consult account balances.
- Review transactions.
- Understand spending patterns.
- Compare financial periods.
- Manage cards.
- Perform common financial operations through natural language.

For the V1 demonstration, the application operates with a predefined
synthetic customer.

Real authentication and real banking accounts are outside the scope
of the project.

---

## Value Proposition

Allow users to interact with their finances using natural language
without sacrificing the control, validation and predictability required
for financial operations.

The assistant provides conversational flexibility for understanding
what the user wants while delegating financial calculations, business
rules and state-changing operations to deterministic backend services.

---

## Natural Language Interaction

Users interact with the assistant using natural language rather than
predefined commands.

Example requests:

- "How much did I spend this month?"
- "What did I spend the most on?"
- "And compared with last month?"
- "I think I lost my Visa."
- "Transfer 25,000 to Laura."

The AI layer may identify:

- User intent.
- Relevant entities.
- Temporal references.
- Conversational context.

Natural-language understanding does not provide authority to execute
financial operations.

---

## Hybrid Interaction Model

The application combines conversational AI with deterministic
application flows.

### Conversational interactions

Conversational interactions are primarily used to understand what the
user wants and to retrieve or analyze financial information.

Examples:

- Balance queries.
- Transaction queries.
- Spending analysis.
- Period comparisons.

### Structured financial interactions

When an operation modifies financial state, the conversation transitions
into a controlled application flow.

Examples:

- Freezing a card.
- Unfreezing a card.
- Making a simulated transfer.

A typical state-changing operation follows this flow:

Natural language request
→ Intent detection
→ Entity extraction
→ Backend validation
→ Structured confirmation
→ Deterministic use case
→ Persistence
→ Result

Operations that modify financial state require explicit user
confirmation before execution.

---

## Synthetic Financial Data

The application does not use real banking information.

All customers, accounts, cards, balances, beneficiaries, transactions
and transfers are synthetic and exist exclusively for demonstration and
development purposes.

The synthetic financial data is stored in the application's persistent
database.

Synthetic data does not mean simulated application behavior.

Financial information is not hardcoded into chatbot responses.
Queries and operations execute against the persistent data layer through
real application use cases.

For example, if a simulated transfer changes an account balance, a
subsequent balance query must retrieve the updated balance from the
database.

The same principle applies to other state changes, such as freezing or
unfreezing a card.

---

## AI Responsibilities

The Large Language Model is responsible for understanding language,
not for controlling financial state.

The AI layer may:

- Understand natural language.
- Detect user intent.
- Extract entities.
- Interpret conversational context.
- Interpret temporal references.
- Generate natural-language responses from grounded application data.

The LLM is never the financial source of truth.

---

## Backend Responsibilities

The backend is responsible for all authoritative financial behavior.

The backend must:

- Retrieve financial information.
- Calculate balances and spending.
- Apply business rules.
- Validate financial operations.
- Execute approved operations.
- Persist state changes.
- Return authoritative financial results.

The LLM must never:

- Invent balances.
- Invent transactions.
- Invent financial state.
- Modify financial records directly.
- Freeze or unfreeze cards directly.
- Execute transfers.
- Bypass backend validation.
- Bypass required confirmation flows.

---

## Core Design Principle

> **AI understands. Backend validates and executes.**

Natural language provides the interaction layer.

Deterministic application services provide the financial authority.

---

## Data Disclaimer

All financial information presented by this project is fictional and
synthetically generated.

The application does not connect to real banks, real accounts, payment
networks or financial services.

No operation performed by the application moves or represents real
money.