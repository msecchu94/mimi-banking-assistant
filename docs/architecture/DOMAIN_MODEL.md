# Domain Model

## 1. Overview

Mimi's domain model contains the minimum financial and conversational
concepts required by V1.

The model is intentionally small. It represents the current product scope
without introducing entities, states, or abstractions for hypothetical
future banking capabilities.

The domain is divided into two clearly separated areas:

```text
Financial Model
├── Customer
├── Account
├── Card
├── Transaction
├── Beneficiary
├── Transfer
└── Money [Value Object]

Conversational Model
├── Conversation
└── Message
```

The financial model owns financial state and business concepts.

The conversational model owns conversational history and session lifecycle.

A conversation may reference financial operations through application-level
context, but conversational entities do not own financial state or financial
business rules.

---

## 2. Financial Model

### 2.1 Customer

`Customer` represents the fictional banking customer that owns the financial
resources used by Mimi.

#### Properties

```text
Customer
├── id: UUID
├── first_name: str
└── last_name: str
```

#### Relationships

```text
Customer 1 ─── N Account
Customer 1 ─── N Beneficiary
Customer 1 ─── N Conversation
```

The relationship with `Conversation` connects the financial customer with the
conversational model without making conversations part of the financial model.

#### Rules

- A Customer may own one or more Accounts.
- A Customer may have zero or more saved Beneficiaries.
- A Customer may have multiple Conversations.
- Authentication, KYC, personal identification, and real user management are
  outside V1.

No customer lifecycle status is modeled because V1 does not require customer
state transitions.

---

### 2.2 Account

`Account` represents a customer's financial account and owns its current
persisted balance.

#### Properties

```text
Account
├── id: UUID
├── customer_id: UUID
├── name: str
├── balance: Money
└── status: AccountStatus
```

#### States

```text
AccountStatus
├── ACTIVE
└── INACTIVE
```

#### Relationships

```text
Customer 1 ─── N Account

Account 1 ─── N Transaction
Account 1 ─── N Card
```

An Account may also act as the source account of Transfers.

#### Rules

- An Account belongs to exactly one Customer.
- The Account balance is persisted.
- The Account balance cannot be negative in V1.
- Only an ACTIVE Account may be used as the source of a Transfer.
- Financial operations must use the same currency as the Account balance.
- Balance changes must occur through deterministic application logic.

No account type is modeled because V1 does not require different account
behaviors.

---

### 2.3 Card

`Card` represents a card associated with an Account.

V1 intentionally uses a simplified card model. Debit and credit cards are
represented by the same entity and are both associated with an Account.

This model does not attempt to represent a complete credit-card system.

#### Properties

```text
Card
├── id: UUID
├── account_id: UUID
├── type: CardType
├── brand: CardBrand
├── last_four: str
└── status: CardStatus
```

#### Types

```text
CardType
├── DEBIT
└── CREDIT
```

`CardBrand` represents the supported card brands present in the synthetic
dataset.

#### States

```text
CardStatus
├── ACTIVE
└── FROZEN
```

#### State Transitions

```text
ACTIVE ─────► FROZEN
FROZEN ─────► ACTIVE
```

#### Relationships

```text
Account 1 ─── N Card
```

The owning Customer is obtained through the associated Account:

```text
Card
  │
  ▼
Account
  │
  ▼
Customer
```

#### Rules

- A Card belongs to exactly one Account.
- A Card can only transition between ACTIVE and FROZEN in V1.
- Freezing or unfreezing a Card requires explicit user confirmation before
  execution.
- Full card numbers, CVV, PIN, and other sensitive payment credentials are not
  stored by the V1 domain model.
- Credit limits, statements, billing cycles, repayments, and credit financing
  behavior are outside V1.

---

### 2.4 Transaction

`Transaction` represents a financial movement associated with an Account.

Transactions provide the persistent financial history used by transaction
queries, filtering, spending analysis, and period comparisons.

#### Properties

```text
Transaction
├── id: UUID
├── account_id: UUID
├── amount: Money
├── type: TransactionType
├── category: TransactionCategory
├── description: str
├── occurred_at: datetime
└── transfer_id: UUID?
```

#### Types

```text
TransactionType
├── DEBIT
└── CREDIT
```

#### Categories

The initial V1 categories are:

```text
GROCERIES
DINING
TRANSPORT
FUEL
UTILITIES
SUBSCRIPTIONS
ENTERTAINMENT
SHOPPING
TRANSFER
OTHER
```

#### Relationships

```text
Account 1 ─── N Transaction

Transfer 1 ─── 0..1 Transaction
```

`transfer_id` is optional because most Transactions are not produced by a
Transfer.

#### Rules

- A Transaction belongs to exactly one Account.
- Transaction amount must be greater than zero.
- Transaction amount is always represented as a positive Money value.
- `DEBIT` or `CREDIT` determines the direction of the financial movement.
- A Transaction does not use the sign of its amount to represent direction.
- A Transaction associated with a Transfer uses the `TRANSFER` category.
- Transactions used by Mimi must originate from persistent data.

No transaction lifecycle status is modeled because V1 only requires completed
financial movements.

---

### 2.5 Beneficiary

`Beneficiary` represents a saved transfer recipient belonging to a Customer.

A Beneficiary is not another Mimi Customer and does not require a real user or
bank account inside the system.

#### Properties

```text
Beneficiary
├── id: UUID
├── customer_id: UUID
├── name: str
├── account_reference: str
└── bank_name: str?
```

#### Relationships

```text
Customer 1 ─── N Beneficiary

Beneficiary 1 ─── N Transfer
```

#### Rules

- A Beneficiary belongs to exactly one Customer.
- V1 Transfers may only target a saved Beneficiary.
- A Beneficiary does not imply the existence of another Customer.
- Beneficiary data is synthetic.

---

### 2.6 Transfer

`Transfer` represents an executed or attempted financial transfer initiated
after explicit user confirmation.

A Transfer is separate from the Transaction generated by a successful
transfer.

#### Properties

```text
Transfer
├── id: UUID
├── source_account_id: UUID
├── beneficiary_id: UUID
├── amount: Money
├── status: TransferStatus
├── created_at: datetime
└── executed_at: datetime?
```

#### States

```text
TransferStatus
├── COMPLETED
└── FAILED
```

#### Relationships

```text
Transfer N ─── 1 Account
Transfer N ─── 1 Beneficiary
Transfer 1 ─── 0..1 Transaction
```

#### Rules

- A Transfer uses exactly one source Account.
- A Transfer targets exactly one saved Beneficiary.
- Transfer amount must be greater than zero.
- Transfer currency must match the source Account currency.
- The source Account must be ACTIVE.
- The source Account must have sufficient balance.
- A successful Transfer updates the persisted Account balance.
- A successful Transfer produces one DEBIT Transaction.
- A COMPLETED Transfer has its resulting Transaction.
- A FAILED Transfer does not produce a financial movement.
- `FAILED` represents a confirmed Transfer whose execution was attempted but
  did not complete successfully.
- Validation failures occurring before execution do not create a Transfer.

A requested transfer awaiting user confirmation is **not** a `Transfer`
entity.

Before confirmation, it belongs to conversational flow state:

```text
Transfer Request
      │
      ▼
Pending Conversational Operation
      │
      ├── Cancel ─────► No Transfer created
      │
      └── Confirm
             │
             ▼
       Transfer Execution
             │
        ┌────┴────┐
        ▼         ▼
   COMPLETED    FAILED
```

The detailed representation of pending conversational operations is outside
the scope of this document.

---

## 3. Value Objects

### 3.1 Money

`Money` represents a monetary value together with its currency.

It is a Value Object rather than an Entity because its identity is determined
by its value.

#### Properties

```text
Money
├── amount: Decimal
└── currency: Currency
```

#### Rules

- Monetary amounts use decimal arithmetic and never floating-point arithmetic.
- Money values used by V1 are non-negative.
- Arithmetic between Money values requires matching currencies.
- Transaction amounts must be greater than zero.
- Transfer amounts must be greater than zero.
- Account balances must be greater than or equal to zero.

`Currency` represents a supported monetary currency and is not a separate
domain entity.

---

## 4. Conversational Model

The conversational model is separate from the financial model.

Its purpose is to represent conversational sessions and their persisted
message history.

It does not contain financial business rules or authoritative financial state.

---

### 4.1 Conversation

`Conversation` represents a conversational session between a Customer and
Mimi.

#### Properties

```text
Conversation
├── id: UUID
├── customer_id: UUID
├── status: ConversationStatus
├── created_at: datetime
└── updated_at: datetime
```

#### States

```text
ConversationStatus
├── ACTIVE
└── CLOSED
```

These states describe the lifecycle of the conversation itself.

They do not represent conversational flow states such as waiting for missing
information or waiting for confirmation.

#### Relationships

```text
Customer 1 ─── N Conversation

Conversation 1 ─── N Message
```

#### Rules

- A Conversation belongs to exactly one Customer.
- An ACTIVE Conversation may receive new Messages.
- A CLOSED Conversation preserves its history but cannot continue.
- Conversational context is limited to the active Conversation.
- A new Conversation does not inherit conversational memory from previous
  Conversations.

The detailed conversational state machine is defined separately.

---

### 4.2 Message

`Message` represents one persisted conversational interaction inside a
Conversation.

#### Properties

```text
Message
├── id: UUID
├── conversation_id: UUID
├── role: MessageRole
├── content: str
└── created_at: datetime
```

#### Roles

```text
MessageRole
├── USER
└── ASSISTANT
```

#### Relationships

```text
Conversation 1 ─── N Message
```

#### Rules

- A Message belongs to exactly one Conversation.
- A Message has exactly one role.
- Message content cannot be empty.
- `created_at` is immutable.
- System prompts are not persisted as domain Messages.
- Intent, extracted entities, financial references, and flow state are not
  properties of Message.

Messages represent conversational history. They are not the authoritative
source of conversational flow state.

---

## 5. Model Relationships

The complete V1 domain model can be represented conceptually as:

```text
                         Customer
                    ┌──────┼───────────┐
                    │      │           │
                    ▼      ▼           ▼
                 Account Beneficiary Conversation
                 │   │       ▲           │
                 │   │       │           ▼
                 │   │       │         Message
                 │   │       │
                 │   └──► Card
                 │
                 └────► Transaction
                           ▲
                           │
                           │ 0..1
                           │
                       Transfer
                       │      │
                       │      └────► Beneficiary
                       │
                       └───────────► Account
```

`Money` is used as a Value Object by:

```text
Money
  ▲
  ├── Account.balance
  ├── Transaction.amount
  └── Transfer.amount
```

The `Customer → Conversation` relationship connects the two models but does
not merge their responsibilities.

---

## 6. Financial and Conversational Boundary

A conversational request does not directly create or modify financial state.

For example:

```text
User Message
"Transfer 25,000 to Laura."
        │
        ▼
Conversation
        │
        ▼
Conversational Processing
        │
        ▼
Pending Conversational Operation
        │
        ▼
Explicit Confirmation
        │
        ▼
Application Use Case
        │
        ▼
Transfer
        │
        ├──► Account balance update
        │
        └──► Transaction
```

The pending operation belongs to conversational state.

The `Transfer`, Account balance change, and resulting `Transaction` belong to
the financial model.

This separation prevents conversational interpretation from becoming
financial authority.

---

## 7. Domain Invariants

The following invariants apply to the V1 domain model:

1. Financial state is persistent and authoritative.
2. Monetary values use `Decimal`, never floating-point arithmetic.
3. An Account balance cannot become negative.
4. Transaction and Transfer amounts must be greater than zero.
5. Money involved in the same financial operation must use the same currency.
6. Transaction direction is represented by `DEBIT` or `CREDIT`, not by the
   sign of the amount.
7. Only ACTIVE Accounts may originate Transfers.
8. Transfers may only target saved Beneficiaries.
9. State-changing financial operations require explicit confirmation before
   execution.
10. A pending conversational operation is not a financial Transfer.
11. Only successfully completed Transfers produce financial movement.
12. Card state changes are limited to ACTIVE and FROZEN in V1.
13. Conversational history and financial state remain separate concerns.
14. Conversation context is limited to the active Conversation.
15. The LLM is not the authoritative owner of either financial or
    conversational state.

---

## 8. Scope of This Document

This document defines the minimum domain model required by Mimi V1.

It intentionally does not define:

- database tables or SQLAlchemy models;
- database migrations;
- API DTOs or request/response contracts;
- repository interfaces;
- Application Use Cases;
- detailed conversational flow states;
- pending-operation representation;
- intent and entity schemas;
- LLM prompts or provider-specific structures;
- authentication or authorization;
- real banking integrations;
- credit-card billing behavior;
- long-term conversational memory.

Those concerns belong to their corresponding architecture or implementation
decisions.