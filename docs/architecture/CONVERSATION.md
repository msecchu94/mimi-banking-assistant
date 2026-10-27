# Conversational State Model

## 1. Overview

Mimi uses a small deterministic conversational state machine to coordinate
multi-step banking operations.

The conversational layer is responsible for:

- understanding user requests;
- preserving relevant context within the active Conversation;
- collecting missing information;
- maintaining at most one pending state-changing operation;
- requesting explicit confirmation when required;
- routing confirmed operations to deterministic Application Use Cases.

The conversational layer does not own financial truth and does not authorize
financial execution.

The core principle remains:

> AI understands. Backend validates and executes.

---

## 2. Conversation Lifecycle vs Flow State

Conversation lifecycle and conversational flow are separate concepts.

The Conversation entity defines its lifecycle:

```text
ConversationStatus
├── ACTIVE
└── CLOSED
```

A conversation's operational flow uses:

```text
ConversationFlowState
├── READY
├── COLLECTING_DATA
└── WAITING_CONFIRMATION
```

These concepts must not be mixed.

For example:

```text
Conversation.status = ACTIVE
flow_state = WAITING_CONFIRMATION
```

means that the conversation is active and currently contains an operation
awaiting explicit user confirmation.

`COMPLETED`, `CANCELLED`, and `FAILED` are operation outcomes, not persistent
Conversation flow states.

After a terminal operation outcome, the active conversation returns to
`READY`.

---

## 3. Flow States

### 3.1 READY

`READY` is the default conversational state.

In this state:

- no state-changing operation is pending;
- free conversation may be handled;
- read-only financial queries may be executed;
- a new state-changing operation may be initiated.

Invariant:

```text
READY
→ pending_operation == null
```

Examples:

```text
"Hello Mimi."
"What's my balance?"
"What did I spend the most on this month?"
"Freeze my Visa."
"Transfer 25,000 to Laura."
```

Free conversation and read-only financial queries normally return to `READY`
after being handled.

---

### 3.2 COLLECTING_DATA

`COLLECTING_DATA` means that a state-changing operation has been identified
but does not yet contain all required resolved and valid data.

Invariant:

```text
COLLECTING_DATA
→ pending_operation != null
→ missing_fields != empty
```

Example:

```text
User:
"Transfer to Laura."

Pending operation:
type = TRANSFER
beneficiary_id = resolved
amount = missing
```

Mimi may request:

```text
"What amount would you like to transfer?"
```

The operation remains in `COLLECTING_DATA` until all required information has
been resolved and pre-validated.

---

### 3.3 WAITING_CONFIRMATION

`WAITING_CONFIRMATION` means that a state-changing operation contains all
required resolved data, has passed pre-validation, and is waiting for explicit
user authorization.

Invariant:

```text
WAITING_CONFIRMATION
→ pending_operation != null
→ missing_fields == empty
```

Reaching this state means:

- the operation type is known;
- required fields are complete;
- referenced domain objects have been resolved;
- candidate parameters are valid;
- the operation passed pre-validation;
- explicit confirmation is still required.

It does not guarantee that execution will succeed.

The operation must be revalidated against current financial state after
confirmation and before execution.

---

## 4. Conversational Context

Conversational context and pending operations are separate concerns.

Conversational context preserves information required to understand follow-up
requests within the active Conversation.

Example:

```text
User:
"What did I spend on dining this month?"

User:
"And last month?"
```

The second message may rely on context from the previous financial query.

Conceptually, conversational context may contain information such as:

```text
ConversationContext
├── last_intent
├── relevant_references
└── temporal_context
```

This structure is conceptual. Its exact persistence representation is an
implementation decision.

Conversational context must contain only information useful for continuing the
active conversation.

It must not become an unrestricted store of historical variables.

Context is limited to the active Conversation and is not inherited by a new
Conversation.

---

## 5. Pending Operations

A `PendingOperation` represents an incomplete or unconfirmed state-changing
operation.

V1 supports:

```text
PendingOperationType
├── TRANSFER
├── FREEZE_CARD
└── UNFREEZE_CARD
```

Read-only operations do not create a `PendingOperation`.

At most one state-changing `PendingOperation` may exist in a Conversation at
a time.

Conceptually:

```text
PendingOperation
├── type
├── data
├── missing_fields
└── operation_id: UUID?
```

`operation_id` exists only while the operation is `WAITING_CONFIRMATION`. It
identifies that confirmation request: every operation that passes
pre-validation receives a new `operation_id`, including a corrected one, and
`CONFIRM` must name it.

The exact persistence structure is intentionally not defined here.

---

## 6. Typed Pending Operation Data

Pending operation data must be operation-specific rather than an unrestricted
generic collection of values.

### 6.1 Transfer

```text
TransferOperationData
├── source_account_id: UUID?
├── beneficiary_id: UUID?
├── amount: Money?
└── unresolved_amount: Decimal?
```

Required fields:

```text
source_account_id
beneficiary_id
amount
```

`unresolved_amount` preserves a valid amount the user stated before its
currency could be determined, for example "Transfer 25,000 to Laura" when the
customer has accounts in more than one currency. It is a candidate, not
resolved data: `amount` remains a missing field.

It becomes `amount` once its currency is determined, either stated by the user
or taken from the resolved source account, and always before pre-validation.
A resolved `amount` is never converted to the currency of a source account
selected later; it is cleared and requested again.

---

### 6.2 Freeze Card

```text
FreezeCardOperationData
└── card_id: UUID?
```

Required field:

```text
card_id
```

---

### 6.3 Unfreeze Card

```text
UnfreezeCardOperationData
└── card_id: UUID?
```

Required field:

```text
card_id
```

Pending operation data should store resolved domain identifiers whenever
possible.

For example:

```text
"Laura"
   ↓
resolve beneficiary
   ↓
beneficiary_id
```

and:

```text
"my Visa"
   ↓
resolve card
   ↓
card_id
```

Once a reference has been resolved, execution must not depend on asking the
LLM to resolve the original text again.

---

## 7. Missing and Invalid Data

The LLM may extract candidate information from natural language, but it does
not determine whether an operation is complete or executable.

The application determines:

- required fields;
- resolved references;
- missing fields;
- ambiguous references;
- parameter validity;
- whether pre-validation succeeds.

Conceptually:

```text
LLM
 ↓
candidate intent + entities
 ↓
Conversation Engine / Application
 ↓
resolve references
validate candidate data
determine missing fields
```

`missing_fields` represents required information that is:

- missing;
- unresolved;
- ambiguous; or
- invalid.

Resolved operation data should contain valid candidate values.

Example:

```text
"Transfer -50 to Laura."
```

must not result in a valid resolved transfer amount of `-50`.

The amount remains unresolved or invalid and Mimi requests a valid amount.

---

## 8. Read-Only Financial Queries

Read-only financial queries do not require a persistent multi-step flow state
when they can be handled synchronously.

Examples include:

```text
GET_BALANCE
GET_TRANSACTIONS
ANALYZE_EXPENSES
COMPARE_EXPENSES
GET_CARDS
```

A read-only query may be executed while the conversation is:

```text
READY
COLLECTING_DATA
WAITING_CONFIRMATION
```

If a pending state-changing operation exists, executing a read-only query does
not cancel, replace, or modify that operation.

Example:

```text
Pending:
TRANSFER 25,000 → Laura

User:
"What's my balance?"

        ↓

Execute balance query

        ↓

Return balance

        ↓

TRANSFER remains pending
```

Mimi may remind the user that the previous operation remains pending when
useful.

### Period Defaults

Symbolic periods are resolved to calendar periods in the configured
application timezone.

When the user omits a period:

- `ANALYZE_EXPENSES` uses `CURRENT_MONTH`.
- `COMPARE_EXPENSES` derives the omitted side only from these pairs:
  `TODAY ↔ YESTERDAY`, `CURRENT_WEEK ↔ PREVIOUS_WEEK`,
  `CURRENT_MONTH ↔ PREVIOUS_MONTH`. If both periods are omitted, or the stated
  period has no pair, the comparison is not executed.
- `GET_TRANSACTIONS` applies no temporal filter and no implicit limit.

Defaults apply only to omitted periods, never to unsupported ones.

---

## 9. State-Changing Operation Flow

The generic state-changing flow is:

```text
READY
  │
  ▼
State-changing intent detected
  │
  ▼
Resolve operation data
  │
  ├── incomplete / unresolved / ambiguous
  │          │
  │          ▼
  │   COLLECTING_DATA
  │          │
  │          ▼
  │   collect or correct data
  │          │
  └──────────┤
             ▼
       Pre-validation
          /       \
       invalid    valid
         │          │
         ▼          ▼
       READY   WAITING_CONFIRMATION
                    │
              explicit decision
                 /       \
            CONFIRM      CANCEL
               │            │
               ▼            ▼
          Revalidate     CANCELLED
               │            │
               ▼            │
         Execute Use Case   │
             /     \         │
      COMPLETED   FAILED     │
             \      |       /
              \     |      /
                   READY
```

`COMPLETED`, `FAILED`, and `CANCELLED` represent outcomes of the pending
operation.

They do not become persistent `ConversationFlowState` values.

---

## 10. Transfer Flow

### Complete Request

```text
READY

User:
"Transfer 25,000 to Laura."

        ↓

Interpret request
Resolve beneficiary
Resolve source account
Resolve amount
Pre-validate

        ↓

WAITING_CONFIRMATION

        ↓ CONFIRM

Revalidate current financial state

        ↓

Transfer Use Case

        ↓

COMPLETED or FAILED

        ↓

clear pending operation

        ↓

READY
```

---

### Missing Data

```text
READY

User:
"Transfer to Laura."

        ↓

beneficiary_id = resolved
amount = missing

        ↓

COLLECTING_DATA

Mimi:
"What amount would you like to transfer?"

        ↓

User provides valid amount

        ↓

Pre-validation

        ↓

WAITING_CONFIRMATION
```

---

## 11. Card Freeze and Unfreeze Flows

Freeze and unfreeze use the same generic state machine.

Example:

```text
READY

User:
"Freeze my Visa."

        ↓

Resolve card
Pre-validate

        ↓

WAITING_CONFIRMATION

        ↓ CONFIRM

Revalidate card state

        ↓

FreezeCard Use Case

        ↓

COMPLETED

        ↓

READY
```

If the card reference is ambiguous:

```text
READY
  ↓
COLLECTING_DATA
  ↓
resolve card_id
  ↓
pre-validation
  ↓
WAITING_CONFIRMATION
```

The same rules apply to `UNFREEZE_CARD`.

---

## 12. Explicit Confirmation

Every V1 state-changing operation requires explicit confirmation.

Structured confirmation actions are deterministic:

```text
CONFIRM
CANCEL
```

When received through a structured interaction, they do not require LLM
interpretation.

For example:

```text
WAITING_CONFIRMATION
        │
        ▼
CONFIRM(operation_id)
        │
        ▼
read PendingOperation
        │
        ▼
check operation_id
        │
        ▼
revalidate
        │
        ▼
execute corresponding Use Case
```

Textual responses such as:

```text
"yes"
"do it"
"confirm"
"no"
"cancel it"
"better not"
```

may require contextual interpretation.

An ambiguous response never authorizes a state-changing operation.

Example:

```text
"Maybe."
```

results in:

```text
WAITING_CONFIRMATION
        ↓
request explicit decision
        ↓
WAITING_CONFIRMATION
```

---

## 13. Parameter Corrections

The user may modify pending operation parameters before execution.

Example:

```text
Mimi:
"Confirm transferring 25,000 to Laura?"

User:
"No, make it 20,000."
```

This is a correction, not a cancellation.

The flow becomes:

```text
WAITING_CONFIRMATION
        ↓
update candidate amount
        ↓
validate
        ↓
request new confirmation
        ↓
WAITING_CONFIRMATION
```

Any material modification to a pending operation invalidates the previous
confirmation request.

A new explicit confirmation is always required after modification.

The corrected operation receives a new `operation_id`. A `CONFIRM` naming the
previous `operation_id` is rejected and neither executes nor changes the
corrected operation. A reply that states no new parameter value is not a
correction and keeps the current confirmation request.

The same rule applies to changes such as:

```text
"Send it to Carlos instead."
```

If the new value cannot be resolved or validated, the operation returns to
`COLLECTING_DATA` or terminates if pre-validation determines that it cannot
proceed.

---

## 14. Corrections During Data Collection

A user response while `COLLECTING_DATA` does not have to provide only the
currently requested field.

Example:

```text
Pending:
TRANSFER → Laura
amount = missing

Mimi:
"What amount would you like to transfer?"

User:
"Actually, send it to Carlos."
```

The beneficiary may be updated while the amount remains missing.

The operation stays in:

```text
COLLECTING_DATA
```

Mimi can then continue requesting the remaining information.

---

## 15. Ambiguous References

The system must not arbitrarily resolve ambiguous financial references.

Example:

```text
"Transfer 20,000 to Juan."
```

If multiple saved beneficiaries match:

```text
Juan Pérez
Juan García
```

the flow becomes:

```text
READY
 ↓
COLLECTING_DATA
 ↓
request beneficiary clarification
```

Only after the user identifies the intended beneficiary is the resolved
`beneficiary_id` stored.

The same rule applies to ambiguous card references.

---

## 16. Pre-Validation

A state-changing operation must pass pre-validation before entering
`WAITING_CONFIRMATION`.

Examples include:

- source Account exists;
- source Account is ACTIVE;
- Beneficiary exists and is saved;
- transfer amount is greater than zero;
- currencies are compatible;
- sufficient balance exists at pre-validation time;
- Card exists;
- requested Card state transition is currently valid.

An operation that is already known to be non-executable should not request
user confirmation.

Example:

```text
Transfer amount: 500,000
Current balance: 100,000
```

does not become:

```text
WAITING_CONFIRMATION
```

Instead, Mimi reports that the request cannot currently be executed and the
flow returns to `READY`.

Only executable candidate operations reach `WAITING_CONFIRMATION`.

---

## 17. Revalidation Before Execution

Pre-validation does not authorize future execution.

Financial state may change between the confirmation request and the user's
response.

Therefore:

```text
WAITING_CONFIRMATION
        ↓
      CONFIRM
        ↓
revalidate current state
        ↓
execute only if still valid
```

For example, a transfer may have passed pre-validation with sufficient funds
but fail revalidation if the current balance later becomes insufficient.

A pending operation stores resolved conversational parameters.

It does not represent authorization to execute and does not guarantee future
success.

---

## 18. Cancellation

Cancellation is allowed from any state containing a pending operation:

```text
COLLECTING_DATA
        │
        └── CANCEL
              ↓
          CANCELLED
              ↓
     clear pending operation
              ↓
            READY
```

and:

```text
WAITING_CONFIRMATION
        │
        └── CANCEL
              ↓
          CANCELLED
              ↓
     clear pending operation
              ↓
            READY
```

Cancellation before execution:

- does not create a financial Transfer;
- does not create a Transaction;
- does not modify Account balance;
- does not modify Card state.

A cancellation request received in `READY` has no financial effect because no
operation exists to cancel.

---

## 19. One Pending State-Changing Operation

V1 allows at most one pending state-changing operation per Conversation.

If another state-changing request arrives while an operation is pending, the
new operation is not started.

Example:

```text
Pending:
TRANSFER 25,000 → Laura

User:
"Freeze my Visa."
```

Mimi informs the user that the current operation must first be confirmed or
cancelled.

The existing pending operation remains unchanged.

V1 does not support:

- multiple simultaneous pending operations;
- pending-operation stacks;
- automatic replacement;
- automatic cancellation;
- suspended state-changing operations;
- replacement-confirmation subflows.

Read-only queries remain allowed while an operation is pending.

---

## 20. Confirmation or Cancellation Without a Pending Operation

A confirmation received when:

```text
flow_state = READY
pending_operation = null
```

must not execute or reconstruct an earlier operation.

The system remains in `READY`.

Likewise, cancellation without a pending operation has no financial effect.

Completed, failed, or cancelled operations must never be reconstructed from
Message history merely because the user later sends `CONFIRM` or `CANCEL`.

---

## 21. Repeated Confirmation

After successful execution:

```text
PendingOperation → cleared
flow_state → READY
```

A repeated `CONFIRM` therefore has no operation to execute.

It must not repeat the previous financial action.

This conversational rule complements, but does not replace, lower-level
execution safety mechanisms such as transactional consistency or idempotency.

Those mechanisms are outside the scope of this document.

---

## 22. Operation Failure

An operation may fail during revalidation or execution.

A conversational failure outcome does not necessarily imply that a financial
entity with a `FAILED` status was created.

For example:

```text
CONFIRM
   ↓
revalidation
   ↓
insufficient balance
```

is a failed conversational operation, but no financial `Transfer` is created
because execution was not attempted.

This preserves the financial model rule:

> Validation failures before execution do not create a Transfer.

A confirmed Transfer whose execution is actually attempted but does not
complete may be represented by the financial `Transfer` model according to
its domain rules.

After a terminal failure:

```text
clear pending operation
→ READY
```

---

## 23. Technical Failures

Technical failures must never be interpreted as successful financial
execution.

If authoritative execution success cannot be established, Mimi must not
report the operation as completed.

Detailed retry, transaction, idempotency, and infrastructure failure handling
are implementation concerns and are outside the scope of this conversational
state model.

---

## 24. Closing a Conversation

Closing an active Conversation invalidates any pending operation.

Conceptually:

```text
ACTIVE Conversation
+
PendingOperation

        ↓ CLOSE

clear PendingOperation
        ↓

ConversationStatus = CLOSED
```

A CLOSED Conversation cannot accept new Messages or execute a previously
pending operation.

A new Conversation does not inherit:

- pending operations;
- flow state;
- confirmation state;
- conversational references;
- previous Conversation context.

---

## 25. Persistence of Conversational State

Authoritative conversational flow state must survive independent API requests.

For example:

```text
Request 1
"Transfer 25,000 to Laura."

        ↓

WAITING_CONFIRMATION
```

followed by:

```text
Request 2
"Yes."
```

must allow the backend to recover the pending operation deterministically.

The system must not reconstruct authoritative flow state by asking the LLM to
reinterpret Message history.

The persisted conversational state must be sufficient to recover:

```text
flow_state
conversational context
pending operation, when present
```

This document defines the required behavior and information.

It intentionally does not define whether persistence uses database columns,
JSON structures, dedicated tables, or another storage representation.

---

## 26. State Invariants

The following invariants apply to V1:

1. `READY` implies no pending state-changing operation.
2. `COLLECTING_DATA` implies one pending operation with unresolved required
   information.
3. `WAITING_CONFIRMATION` implies one pending operation with complete,
   resolved, and pre-validated data.
4. At most one state-changing operation may be pending per Conversation.
5. Read-only queries never create a pending operation.
6. Read-only queries may execute without destroying an existing pending
   operation.
7. A second state-changing operation cannot start while another is pending.
8. Ambiguity never authorizes a state-changing operation.
9. Material parameter changes require a new explicit confirmation under a
   new `operation_id`; `CONFIRM` executes only the operation waiting under the
   `operation_id` it names.
10. Explicit confirmation is required before every state-changing execution.
11. Confirmation always triggers revalidation against current financial state.
12. Cancellation before execution produces no financial state change.
13. `CONFIRM` and `CANCEL` without a pending operation cannot reactivate an
    earlier operation.
14. Terminal outcomes clear the pending operation and return an active
    Conversation to `READY`.
15. Closing a Conversation invalidates its pending operation.
16. Authoritative flow state is persisted and is not reconstructed by the LLM
    from Message history.

---

## 27. Scope of This Document

This document defines the V1 conversational state machine, transitions,
temporary operation data, and behavioral invariants.

It intentionally does not define:

- HTTP request or response schemas;
- Flutter UI contracts;
- database schema;
- SQLAlchemy persistence models;
- repository implementations;
- LLM provider implementation;
- prompt templates;
- detailed intent/entity response schemas;
- transaction isolation;
- idempotency implementation;
- retry policies;
- authentication or authorization;
- long-term memory;
- multiple simultaneous state-changing operations.

Those concerns belong to their corresponding architecture or implementation
decisions.