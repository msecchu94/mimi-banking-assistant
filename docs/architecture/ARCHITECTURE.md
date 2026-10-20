# Architecture

## 1. Overview

Mimi is a hybrid conversational AI assistant for digital banking.

Its architecture separates natural-language understanding, conversational
orchestration, business logic, and infrastructure concerns.

The core architectural principle is:

> **AI understands. Backend validates and executes.**

The LLM is a language-understanding component. It is not the source of
financial truth and has no authority to execute financial operations or
modify financial state.

The architecture follows pragmatic Clean Architecture principles:
dependencies point toward internal abstractions, frameworks remain at the
boundaries, and abstractions are introduced only when they provide a clear
architectural or testing benefit.

---

## 2. High-Level Architecture

```text
┌──────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
│                                                              │
│                Presentation / App / Data                     │
└──────────────────────────────┬───────────────────────────────┘
                               │
                            REST / JSON
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                     FastAPI / API Layer                      │
│                                                              │
│                Routers / DTOs / HTTP concerns                │
└──────────────────────────────┬───────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────┐
│                    Conversation Engine                       │
│                                                              │
│   Intent routing              Conversation context           │
│   Entity handling             Flow orchestration             │
│   Pending operations          Confirmation / cancellation    │
└──────────────┬───────────────────────────────┬───────────────┘
               │                               │
               │ uses                          │ invokes
               ▼                               ▼
        LLM Provider Port              Application Use Cases
               ▲                               │
               │ implements                    ├──────► Domain
               │                               │
      ┌────────┴─────────┐                     ▼
      │ Concrete LLM     │              Application Ports
      │ Adapter          │                     ▲
      │                  │                     │ implements
      │ Infrastructure   │            ┌────────┴───────────┐
      └──────────────────┘            │   Infrastructure   │
                                      │                    │
                                      │ SQLAlchemy         │
                                      │ Repository         │
                                      │ Adapters           │
                                      └────────┬───────────┘
                                               │
                                               ▼
                                        ┌──────────────┐
                                        │ PostgreSQL   │
                                        └──────────────┘
```

The concrete system is assembled by a Composition Root that connects
internal abstractions with infrastructure implementations.

---

## 3. Architectural Components

### 3.1 Flutter App

The Flutter application is the client of the backend.

It is responsible for:

- rendering the conversational interface;
- sending natural-language messages and structured user actions;
- rendering UI states returned by the backend;
- managing client-side presentation state;
- communicating with the backend through REST.

Flutter must not own financial business rules or decide whether a financial
operation is authorized to execute.

The backend remains authoritative for conversational flows and financial
operations.

---

### 3.2 FastAPI / API Layer

FastAPI provides the HTTP boundary of the backend.

It is responsible for:

- exposing REST endpoints;
- request and response serialization;
- API-boundary validation;
- translating HTTP requests into application entry points;
- translating application results and errors into HTTP responses;
- participating in dependency wiring at the framework boundary.

API routers must not contain financial business logic.

FastAPI-specific concerns must remain outside the Domain and Application
layers.

---

### 3.3 Conversation Engine

The Conversation Engine is the orchestrator of conversational interactions.

It is responsible for:

- determining how an incoming interaction should be processed;
- requesting LLM interpretation when natural-language understanding is needed;
- handling interpreted intents and entities;
- maintaining conversational context;
- maintaining the state of multi-step flows;
- tracking pending operations;
- determining when additional information is required;
- orchestrating explicit confirmation and cancellation;
- routing conversational requests to the appropriate Application Use Case.

The Conversation Engine owns conversational decisions.

It does not:

- implement financial business rules;
- determine authoritative financial values;
- access PostgreSQL directly;
- access repository implementations directly;
- allow the LLM to execute operations.

The Conversation Engine may determine that an operation is ready to be
requested, but the corresponding Application Use Case determines whether
that operation is valid according to application and domain rules.

External LLM interpretation runs outside database transactions and locks.
Afterwards, the Conversation Engine locks and revalidates the conversation,
then persists the turn and routes it deterministically, all in one
transaction.

---

### 3.4 LLM Provider

The LLM Provider is an internal port consumed by the conversational layer.

It separates Mimi's conversational logic from any specific LLM vendor or SDK.

The LLM may be used to:

- interpret natural-language input;
- classify intents;
- extract entities;
- interpret temporal references;
- resolve conversational language;
- generate natural-language responses from grounded application results.

When generating a response from application results, all financial facts must
come from deterministic application data supplied to the LLM. The LLM may
verbalize those facts but must not invent, calculate, or alter financial state.

The LLM must never:

- access repositories directly;
- access PostgreSQL directly;
- modify financial state;
- execute financial operations;
- determine authoritative balances, transactions, or financial calculations;
- bypass Application Use Cases;
- bypass business validation;
- bypass explicit confirmation requirements.

LLM output is interpreted as input to deterministic application logic, not as
authorization or financial truth.

The application should avoid invoking the LLM when the current interaction
can be handled deterministically.

---

### 3.5 Application Layer

The Application layer defines what the system can do.

It contains:

- Application Use Cases;
- ports required by Use Cases and application services.

Use Cases are responsible for:

- coordinating domain behavior;
- applying application-level validation;
- requesting external capabilities through ports;
- executing approved operations;
- returning deterministic application results.

Examples of application operations include balance queries, transaction
queries, spending analysis, card operations, and simulated transfers.

The Application layer must not depend directly on:

- FastAPI;
- SQLAlchemy;
- PostgreSQL;
- a specific LLM SDK or vendor.

---

### 3.6 Application Ports

Application Ports define capabilities required from external systems.

A port describes **what the application needs**, not how that capability is
implemented.

Examples include:

```text
AccountRepository
CardRepository
TransactionRepository
TransferRepository
LLMProvider
```

Concrete implementations belong to Infrastructure.

This allows the same Use Case or conversational component to work with
different implementations without modification.

For persistence:

```text
AccountRepository
       ▲
       │ implements
       ├──────── PostgresAccountRepository
       │
       └──────── InMemoryAccountRepository
```

The same principle applies to the LLM:

```text
LLMProvider
    ▲
    │ implements
    ├──────── ConcreteLLMProvider
    │
    └──────── FakeLLMProvider
```

This separation supports testing and prevents application logic from depending
on infrastructure details.

---

### 3.7 Domain

The Domain contains the core financial concepts and business rules.

It may contain:

- entities;
- value objects;
- domain rules and invariants;
- domain-specific errors or behavior.

The Domain does not know how data is persisted, how HTTP works, or which LLM
provider is being used.

It must remain independent from:

- Flutter;
- FastAPI;
- SQLAlchemy;
- PostgreSQL;
- specific LLM providers.

The detailed domain model is defined separately from this document.

---

### 3.8 Infrastructure

Infrastructure contains adapters for external technologies.

It is responsible for implementing Application Ports using concrete technical
solutions.

Examples include:

- SQLAlchemy repository implementations;
- PostgreSQL persistence;
- concrete LLM integrations;
- other external adapters required by the application.

Infrastructure may depend on Application and Domain abstractions.

Application and Domain must not depend on Infrastructure implementations.

---

### 3.9 PostgreSQL

PostgreSQL is the persistent data store for Mimi's synthetic financial data
and application state.

Financial information exposed by Mimi must originate from persistent data
rather than hardcoded conversational responses.

State-changing operations must persist their effects so that subsequent
queries observe the updated state.

PostgreSQL is an infrastructure detail and must not be accessed directly from
the Conversation Engine, Application Use Cases, or API routers.

---

## 4. Dependency Direction

Mimi follows the Dependency Inversion Principle.

High-level application logic depends on abstractions rather than concrete
infrastructure implementations.

```text
API / Conversation
        │
        ▼
    Application
      /      \
     ▼        ▼
 Domain     Ports
              ▲
              │ implements
       Infrastructure
              │
              ▼
         PostgreSQL
```

Dependencies toward external technology are inverted through ports.

For persistence:

```text
Use Case
   │
   ▼
Repository Port
   ▲
   │ implements
PostgreSQL Repository Adapter
```

For language models:

```text
Conversation Engine
        │
        ▼
    LLMProvider
        ▲
        │ implements
Concrete LLM Adapter
```

The concrete implementation can therefore be replaced without changing the
consumer of the abstraction.

---

## 5. Composition Root and Dependency Wiring

Declaring abstractions is not sufficient. The application requires a
composition boundary responsible for connecting abstractions with concrete
implementations.

The Composition Root is responsible for assembling the runtime object graph.

Conceptually:

```text
                     Composition Root
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
Conversation Engine    Use Cases       LLMProvider
                           │                │
                           ▼                ▼
                  Repository Ports      LLM Adapter
                           │
                           ▼
                  Repository Adapters
                           │
                           ▼
                      PostgreSQL
```

For example, production wiring may resolve:

```text
AccountRepository → PostgresAccountRepository
LLMProvider        → ConcreteLLMProvider
```

while tests may resolve:

```text
AccountRepository → InMemoryAccountRepository
LLMProvider        → FakeLLMProvider
```

Consumers remain unchanged.

FastAPI may participate in dependency injection at the outer boundary, but
FastAPI dependency mechanisms must not leak into Application or Domain code.

Use Cases and application services receive their dependencies explicitly
through abstractions.

The exact physical implementation of the Composition Root is an implementation
detail and is not defined by this architecture document.

---

## 6. Conversation and Business Boundary

Conversational orchestration and financial business logic are separate
responsibilities.

For example, given:

> "Transfer 25,000 to Laura."

the conversational layer may determine:

```text
Intent: TRANSFER_MONEY
Amount: 25000
Beneficiary: Laura
```

The Conversation Engine may then determine which application operation is
being requested and whether the conversational flow has enough information to
continue.

It does not decide whether the financial operation itself is valid.

Application logic is responsible for deterministic validation such as:

```text
Does the beneficiary exist?
Is the amount valid?
Does the source account exist?
Is sufficient balance available?
Can the operation be executed?
```

This creates a strict boundary:

```text
Conversation Engine
        │
        │ What is the user trying to do?
        ▼
Application Use Case
        │
        │ Is this operation valid and executable?
        ▼
Domain / Ports
```

---

## 7. State-Changing Operation Flow

A state-changing conversational operation follows a controlled path.

```text
Natural-Language Request
          │
          ▼
 Conversation Engine
          │
          ▼
 LLM Interpretation
   (when required)
          │
          ▼
  Intent + Entities
          │
          ▼
Conversation Orchestration
          │
          ▼
Application Validation
          │
          ▼
   Pending Operation
          │
          ▼
Explicit Confirmation
          │
          ▼
 Application Execution
          │
          ▼
 Repository Port
          │
          ▼
Infrastructure Adapter
          │
          ▼
      PostgreSQL
```

Natural-language interpretation does not represent authorization.

Application validation may occur before confirmation so that the user can be
presented with a valid and meaningful operation summary.

Execution of the state-changing operation occurs only after the required
explicit confirmation.

The Conversation Engine orchestrates this workflow but does not duplicate the
financial validation rules owned by Application and Domain.

---

## 8. Conversational State Ownership

Conversational state belongs to Mimi's application, not to the LLM.

The application is responsible for preserving the information required by
supported multi-step interactions.

This may include:

- active conversational context;
- pending operation;
- collected operation data;
- missing information;
- confirmation state.

The LLM may interpret messages using this context, but it is not the
authoritative owner of conversational state.

The concrete conversational state model is defined separately from this
document.

---

## 9. Deterministic Interaction Path

Not every user interaction requires an LLM invocation.

If the application already has enough structured information to determine the
next step, the interaction should remain deterministic.

Conceptually:

```text
Incoming Interaction
        │
        ▼
Conversation Engine
        │
        ├── Natural language requiring interpretation ──► LLM
        │
        └── Structured / known interaction ─────────────► Deterministic path
```

For example, a structured confirmation action for an existing pending
operation does not require the LLM to reinterpret the user's intent.

This reduces unnecessary:

- token usage;
- latency;
- external model dependency;
- nondeterministic behavior.

---

## 10. Architectural Constraints

The following constraints apply across the architecture:

1. **AI understands; backend validates and executes.**
2. Financial truth must originate from persistent application data.
3. The LLM must never execute financial operations or modify financial state.
4. LLM output must never be treated as authorization.
5. State-changing operations require explicit confirmation.
6. The Conversation Engine owns conversational orchestration, not financial
   business rules.
7. Application Use Cases own application operations and deterministic
   validation.
8. External capabilities are accessed through internal ports.
9. Infrastructure implements internal ports.
10. Application and Domain must not depend on infrastructure implementations.
11. FastAPI and framework-specific dependency injection must remain at the
    outer application boundary.
12. Conversational state belongs to the application, not to the LLM.
13. Deterministic interactions should avoid unnecessary LLM calls.
14. API routers must not contain business logic.
15. New abstractions must solve a current architectural need rather than a
    speculative future requirement.
16. Architecture decisions must not implicitly expand the frozen V1 scope.

---

## 11. Scope of This Document

This document defines the high-level architecture and dependency boundaries
of Mimi.

It intentionally does not define:

- the detailed domain model;
- database schemas;
- concrete conversational states;
- the final REST or Chat API contract;
- detailed backend folder structure;
- detailed Flutter architecture;
- concrete LLM vendor configuration;
- deployment infrastructure.

Those concerns are defined by their corresponding architecture and
implementation decisions.