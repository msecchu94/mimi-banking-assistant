# V1 Functional Scope

## 1. Objective

Define and freeze the functional scope of the first version of the
Hybrid AI Banking Assistant.

V1 is intended to demonstrate the core product principle defined in
`PRODUCT.md`:

> **AI understands. Backend validates and executes.**

The first version must demonstrate:

- Natural-language interaction with financial information.
- Financial queries backed by persistent synthetic data.
- Financial analysis performed by deterministic application logic.
- Conversational context for supported follow-up interactions.
- Controlled state-changing operations.
- Explicit confirmation before executing state-changing operations.

This document defines what V1 includes and, equally importantly, what
it intentionally excludes.

---

## 2. Account Balance

The user can request their account balance using natural language.

Example:

> "What's my balance?"

The returned balance must originate from the application's persistent
financial data source.

The LLM must not invent, calculate, or act as the authoritative source
for the account balance.

---

## 3. Transaction Queries

The user can request account transactions using natural language.

Examples:

> "Show me my latest transactions."

> "What transactions did I make this month?"

Transaction information must originate from persistent financial data.

### Supported Filters

The user can filter transactions using supported criteria such as:

- Time period.
- Spending category.
- Transaction type.

Filtering is part of the transaction query capability and is not
considered a separate financial feature.

---

## 4. Spending Analysis

The user can request an analysis of their spending for a supported
period.

Examples:

> "What did I spend the most on this month?"

> "How much did I spend on groceries?"

The application can:

- Calculate total spending.
- Group expenses by category.
- Calculate spending for a specific category.
- Analyze spending for a selected period.

All financial calculations must be performed by deterministic
application logic using persisted financial data.

The LLM must not be responsible for authoritative financial
calculations.

---

## 5. Spending Period Comparison

The user can compare spending between supported periods.

Example:

> "How does this month compare with last month?"

The application can:

- Retrieve financial data for both periods.
- Calculate totals for each period.
- Calculate the difference between periods.
- Provide the result to the conversational layer.

The comparison must be calculated by deterministic application logic.

---

## 6. Card Queries

The user can request information about their cards.

Example:

> "What's the status of my Visa?"

The application can return the card information required by supported
V1 flows, including:

- Card identification.
- Card type or recognizable reference.
- Current card status.

Card information must originate from persistent data.

---

## 7. Freeze Card

The user can request that a card be frozen.

Example:

> "I think I lost my Visa."

The assistant may interpret this request as an intention to freeze the
relevant card.

Before modifying card state, the application must:

1. Identify the relevant card.
2. Validate that the card exists.
3. Validate its current state.
4. Present the intended operation to the user.
5. Request explicit confirmation.
6. Execute the operation only after valid confirmation.
7. Persist the new card state.
8. Return the result to the user.

A successful freeze operation changes the card state from:

`ACTIVE → FROZEN`

A subsequent card query must reflect the persisted `FROZEN` state.

---

## 8. Unfreeze Card

The user can request that a previously frozen card be reactivated.

Before modifying card state, the application must:

1. Identify the relevant card.
2. Validate that the card exists.
3. Validate its current state.
4. Present the intended operation to the user.
5. Request explicit confirmation.
6. Execute the operation only after valid confirmation.
7. Persist the new card state.
8. Return the result to the user.

A successful unfreeze operation changes the card state from:

`FROZEN → ACTIVE`

A subsequent card query must reflect the persisted `ACTIVE` state.

---

## 9. Beneficiary Queries

The user can request their saved beneficiaries.

Beneficiaries are synthetic records stored in the application's
persistent data layer.

The beneficiary list can also be used by the simulated transfer flow.

V1 supports:

- Retrieving saved beneficiaries.
- Identifying an existing beneficiary during a transfer.

V1 does not require:

- Creating beneficiaries.
- Editing beneficiaries.
- Deleting beneficiaries.

---

## 10. Simulated Transfer

The user can request a simulated transfer to an existing saved
beneficiary.

Example:

> "Transfer 25,000 to Laura."

The application must:

1. Interpret the transfer request.
2. Identify the beneficiary.
3. Identify the amount.
4. Validate the source account.
5. Validate the beneficiary.
6. Validate the amount.
7. Validate that sufficient balance is available.
8. Present a summary of the operation.
9. Request explicit user confirmation.
10. Execute the transfer only after valid confirmation.
11. Persist the transfer.
12. Persist the corresponding financial state changes.
13. Return the result to the user.

The transfer operates exclusively on synthetic financial data.

No real money is transferred.

Creating a new beneficiary during the transfer flow is outside the V1
scope.

---

## 11. Conversational Context

V1 maintains enough conversational context to resolve supported
follow-up requests within the active conversation.

Example:

User:

> "How much did I spend on groceries this month?"

Follow-up:

> "And last month?"

The application should understand that the follow-up refers to the same
spending category and requests information for the previous period.

Conversational context may include information such as:

- Previous intent.
- Relevant category.
- Relevant period.
- Selected card.
- Selected beneficiary.
- Pending operation.
- Information still required to complete an active flow.

V1 does not require long-term personal memory across unrelated user
sessions.

Conversational context exists to support the current conversation and
the V1 financial flows defined in this document.

---

## 12. Cancel an Operation in Progress

The user can cancel an operation that is currently in progress.

Examples:

> "Cancel."

> "No, leave it."

> "Never mind."

When an operation is cancelled:

- The pending operation is discarded.
- No pending financial state change is executed.
- Temporary operation state is cleared.
- The conversation can continue normally.

Cancellation applies particularly to state-changing flows such as:

- Card freezing.
- Card unfreezing.
- Simulated transfers.

---

## 13. Explicit Confirmation

Every V1 operation that modifies financial state requires explicit user
confirmation before execution.

This includes:

- Freezing a card.
- Unfreezing a card.
- Performing a simulated transfer.

Understanding the user's initial request is not considered
authorization to execute the operation.

The flow must follow this principle:

`Request → Understand → Validate → Present → Confirm → Execute → Persist`

The LLM cannot bypass the confirmation step.

---

## 14. V1 Included Features

The frozen V1 functional scope includes:

- Account balance queries.
- Transaction queries.
- Transaction filtering by supported criteria.
- Spending analysis.
- Spending comparison between periods.
- Card queries.
- Card freezing.
- Card unfreezing.
- Beneficiary queries.
- Simulated transfers to existing saved beneficiaries.
- Conversational context within the active conversation.
- Cancellation of operations in progress.
- Explicit confirmation for state-changing operations.
- Persistent financial state changes.

---

## 15. Out of Scope for V1

The following capabilities are explicitly excluded from V1.

### Real Banking Integration

- Real banking authentication.
- Real customer accounts.
- Real money.
- Open Banking integrations.
- Real payment execution.

### AI Capabilities

- Retrieval-Augmented Generation (RAG).
- Multiple AI agents.
- Autonomous financial operations.

### Communication

- Streaming responses.
- Push notifications.

### Platform and Infrastructure

- Microservices.
- Redis.
- Administrative panel.
- Multiple real users.

These exclusions are intentional and keep V1 focused on demonstrating
the core hybrid conversational banking model.

---

## 16. Potential Post-V1 Capabilities

The following capabilities may be evaluated after V1.

They are not commitments for future implementation.

Potential extensions include:

- RAG for financial policies, FAQs, or product documentation.
- Streaming conversational responses.
- Multiple specialized AI agents.
- Real authentication.
- Multiple application users.
- Open Banking integration.
- Additional banking operations.
- Beneficiary management.
- Push notifications.
- Administrative tools.
- Additional financial analytics.

Every post-V1 capability requires separate product and architecture
evaluation before implementation.

---

## 17. V1 Scope Boundary

A feature belongs to V1 only if it is explicitly defined in this
document.

New capabilities discovered during design or development must not be
added to V1 automatically.

They must be documented separately and evaluated as potential post-V1
work.

Technical implementation decisions must not implicitly expand the
functional scope defined by this document.

Changes to the frozen V1 scope require an explicit product decision.

---

## 18. Definition of V1

V1 is considered functionally complete when a user can:

1. Ask for financial information using natural language.
2. Retrieve account balances from persistent synthetic data.
3. Retrieve and filter transactions.
4. Analyze spending.
5. Compare spending between periods.
6. Continue supported queries using conversational context.
7. Consult cards and their current state.
8. Consult saved beneficiaries.
9. Freeze a card through a controlled confirmation flow.
10. Unfreeze a card through a controlled confirmation flow.
11. Request and confirm a simulated transfer to a saved beneficiary.
12. Cancel a pending state-changing operation.
13. Observe persisted financial state changes in subsequent queries.

All authoritative financial information, calculations, validations, and
state-changing operations remain controlled by deterministic application
logic.

---

## Scope Status

The functional scope defined in this document represents the frozen
scope for V1.

Features explicitly listed as included are part of V1.

Capabilities listed as out of scope or potential post-V1 work must not
be introduced into V1 without an explicit scope change.