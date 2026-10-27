# Using the Mimi API locally

A practical guide to running the backend and exercising the Chat API by hand.
The wire format is defined in
[API_CONTRACT.md](../architecture/API_CONTRACT.md); this guide only shows how
to use it.

## 1. Run the backend

Requirements: Python 3.12+, a running PostgreSQL and an OpenAI API key.

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
cp .env.example .env
```

Edit `.env`:

| Variable | Value |
|---|---|
| `MIMI_DATABASE_URL` | `postgresql+psycopg://USER:PASSWORD@localhost:5432/mimi` |
| `MIMI_LLM_MODEL` | The OpenAI model to use |
| `MIMI_LLM_API_KEY` | Your OpenAI API key; never commit it |
| `MIMI_DEMO_CUSTOMER_ID` | Keep the value from `.env.example`: the seeded customer |
| `MIMI_TIMEZONE` | Timezone used to resolve periods (default Buenos Aires) |

The app does not start without the database URL, the LLM settings or the demo
customer ID.

Create the schema, load the demo data and start the server:

```bash
alembic upgrade head
python -m mimi.infrastructure.database.seed          # add --reset to reseed
uvicorn mimi.main:app --reload
```

- Health check: `GET http://localhost:8000/health` → `{"status": "ok"}`
- Swagger UI: <http://localhost:8000/docs> (ReDoc at `/redoc`, schema at
  `/openapi.json`)

V1 has no authentication: every request acts for the seeded demo customer,
Valentina Ruiz.

### Demo data

The seed creates two accounts (`Cuenta principal` in ARS, `Caja de ahorro en
dólares` in USD), three cards (Visa debit `4821` and Mastercard credit `5307`,
both active, and Visa credit `9134`, frozen), five beneficiaries (Laura Gómez,
Martín Pérez, Lucía Fernández, Diego Romero, Sofía Benítez) and three months of
transactions before the seed's reference date (default: today).

Every balance, total and transfer in a response is read from or written to
PostgreSQL. The LLM only interprets the message; it never produces financial
data. Amounts in the examples below are illustrative: yours depend on the
seed date and on transfers you have made.

## 2. Start a conversation

```bash
curl -s -X POST localhost:8000/conversations
```

```json
{
  "conversation_id": "7b1e6f0c-2a9d-4c55-9b0e-3f7c1d2a8e41",
  "conversation_state": "READY",
  "metadata": { "request_id": "…", "timestamp": "2026-10-27T15:04:05Z" }
}
```

Reuse that `conversation_id` in every `/chat` request: context for follow-ups
and any pending operation belong to the conversation. A new conversation
starts with no context.

```bash
CONV=7b1e6f0c-2a9d-4c55-9b0e-3f7c1d2a8e41

chat() {
  curl -s -X POST localhost:8000/chat \
    -H 'Content-Type: application/json' \
    -d "{\"conversation_id\": \"$CONV\", \"message\": \"$1\"}"
}
```

## 3. Send a message

`POST /chat` takes either a free-text `message` or a structured `interaction`,
never both.

```bash
chat "¿Cuánta plata tengo?"
```

```json
{
  "conversation_id": "7b1e6f0c-2a9d-4c55-9b0e-3f7c1d2a8e41",
  "message": "Estos son tus saldos: Cuenta principal: 1236480.75 ARS; Caja de ahorro en dólares: 2450.00 USD.",
  "intent": "GET_BALANCE",
  "conversation_state": "READY",
  "ui": { "type": "TEXT", "data": {} },
  "metadata": { "request_id": "…", "timestamp": "…" }
}
```

Clients render `ui` by its `type`, and `message` is the text to show. Money
is always a string with two decimals plus a currency.

## 4. Expenses

```bash
chat "¿En qué gasté más este mes?"
```

```json
{
  "message": "Tus gastos del período suman 742310.50 ARS.",
  "intent": "ANALYZE_EXPENSES",
  "conversation_state": "READY",
  "ui": {
    "type": "EXPENSE_SUMMARY",
    "data": {
      "period": { "from": "2026-10-01", "to": "2026-10-31" },
      "currencies": [
        {
          "total": { "amount": "742310.50", "currency": "ARS" },
          "categories": [
            { "category": "GROCERIES", "amount": { "amount": "291911.00", "currency": "ARS" } },
            { "category": "FUEL", "amount": { "amount": "119200.00", "currency": "ARS" } }
          ]
        }
      ]
    }
  }
}
```

Other messages to try: `"¿Cuánto gasté en el super el mes pasado?"`,
`"Mostrame los movimientos de esta semana"` (`TRANSACTION_LIST`),
`"¿Gasté más que el mes pasado?"` (`EXPENSE_COMPARISON`).

### Contextual comparison

In the same conversation, a follow-up reuses the last query's category and
period:

```bash
chat "¿Cuánto gasté en el super este mes?"
chat "¿Y comparado con el mes pasado?"
```

```json
{
  "message": "Respecto del período comparado, en ARS gastaste 18420.35 más.",
  "intent": "COMPARE_EXPENSES",
  "ui": {
    "type": "EXPENSE_COMPARISON",
    "data": {
      "current_period": { "from": "2026-10-01", "to": "2026-10-31" },
      "previous_period": { "from": "2026-09-01", "to": "2026-09-30" },
      "currencies": [
        {
          "current_total": { "amount": "291911.00", "currency": "ARS" },
          "previous_total": { "amount": "273490.65", "currency": "ARS" },
          "difference": { "amount": "18420.35", "currency": "ARS" },
          "change": "INCREASE"
        }
      ]
    }
  }
}
```

Both totals are for groceries only, inherited from the first question. Other
follow-ups: `"¿Y el anterior?"`, `"¿Y en restaurantes?"`. Sent in a new
conversation, the same follow-up gets *"No tengo una consulta anterior a la
cual referirme."*

### Named calendar months

```bash
chat "¿Cuánto gasté en octubre?"
chat "Compará octubre con septiembre"
chat "Compará mis gastos de septiembre con agosto"
chat "¿Cuánto gasté en octubre de 2025?"
```

A month without a year is its most recent occurrence that is not in the
future. A future month, such as `"diciembre de 2027"`, is rejected with a
`TEXT` response and no query. Years alone (`"este año"`), date ranges and
rolling periods (`"los últimos 30 días"`) are not supported.

## 5. Card actions

State-changing operations are never executed from a message. They are
collected, validated and then wait for an explicit `CONFIRM`.

```bash
chat "Congelá mi tarjeta"
```

```json
{
  "message": "¿Qué tarjeta querés congelar?",
  "intent": "FREEZE_CARD",
  "conversation_state": "COLLECTING_DATA",
  "ui": {
    "type": "CARD_SELECTOR",
    "data": {
      "cards": [
        { "id": "c1f0…", "brand": "VISA", "type": "DEBIT", "last_four": "4821", "status": "ACTIVE" },
        { "id": "…", "brand": "MASTERCARD", "type": "CREDIT", "last_four": "5307", "status": "ACTIVE" },
        { "id": "…", "brand": "VISA", "type": "CREDIT", "last_four": "9134", "status": "FROZEN" }
      ]
    }
  }
}
```

Pick a card with a structured interaction:

```bash
curl -s -X POST localhost:8000/chat -H 'Content-Type: application/json' -d '{
  "conversation_id": "'"$CONV"'",
  "interaction": "SELECT_CARD",
  "payload": { "card_id": "c1f0…" }
}'
```

```json
{
  "message": "¿Confirmás que querés congelar la tarjeta Visa de débito terminada en 4821?",
  "intent": "FREEZE_CARD",
  "conversation_state": "WAITING_CONFIRMATION",
  "ui": {
    "type": "CONFIRMATION",
    "data": {
      "operation_id": "5a2c…",
      "title": "Congelar tarjeta",
      "summary": { "type": "CARD", "card": { "last_four": "4821", "status": "ACTIVE", "…": "…" } },
      "actions": [
        { "type": "CONFIRM", "label": "Confirmar" },
        { "type": "CANCEL", "label": "Cancelar" }
      ]
    }
  }
}
```

Naming the card goes straight to confirmation: `"Congelá la Visa de
débito"`, `"Descongelá la que termina en 9134"`.

## 6. Transfers

```bash
chat "Transferile 25000 pesos a Laura"
```

```json
{
  "message": "¿Confirmás la transferencia de 25000.00 ARS a Laura Gómez desde Cuenta principal?",
  "intent": "TRANSFER_MONEY",
  "conversation_state": "WAITING_CONFIRMATION",
  "ui": {
    "type": "CONFIRMATION",
    "data": {
      "operation_id": "9d41…",
      "title": "Confirmar transferencia",
      "summary": {
        "type": "TRANSFER",
        "amount": { "amount": "25000.00", "currency": "ARS" },
        "beneficiary": "Laura Gómez"
      },
      "actions": [ "…" ]
    }
  }
}
```

Missing details are asked one at a time (`COLLECTING_DATA`), and each reply in
the same conversation fills them in:

```text
"Quiero transferirle a Martín"  →  "¿Desde qué cuenta querés transferir?"
"Desde la cuenta principal"     →  "¿Cuánto querés transferir?"
"10 lucas"                      →  confirmation for 10000.00 ARS to Martín Pérez
```

Corrections such as `"No, mejor a Diego"` are applied before confirming. Each
correction issues a new `operation_id`.

## 7. Confirm or cancel

Confirm with the `operation_id` from the latest `CONFIRMATION`:

```bash
curl -s -X POST localhost:8000/chat -H 'Content-Type: application/json' -d '{
  "conversation_id": "'"$CONV"'",
  "interaction": "CONFIRM",
  "payload": { "operation_id": "9d41…" }
}'
```

```json
{
  "message": "La transferencia de 25000.00 ARS a Laura Gómez se realizó con éxito.",
  "intent": "TRANSFER_MONEY",
  "conversation_state": "READY",
  "ui": {
    "type": "TRANSFER_SUMMARY",
    "data": {
      "transfer_id": "…",
      "beneficiary": "Laura Gómez",
      "amount": { "amount": "25000.00", "currency": "ARS" },
      "status": "COMPLETED",
      "executed_at": "…"
    }
  }
}
```

The operation is revalidated against PostgreSQL when confirmed. Ask for the
balance again to see the debit.

Cancel the pending operation (no payload):

```bash
curl -s -X POST localhost:8000/chat -H 'Content-Type: application/json' -d '{
  "conversation_id": "'"$CONV"'",
  "interaction": "CANCEL"
}'
```

→ `"Listo, cancelé la transferencia. No se realizó ningún cambio."`, state
`READY`. Typing "cancelar" does not cancel: use the interaction.

Read-only questions can be asked while an operation is pending, and it stays
pending.

## 8. Errors

Errors share one shape:

```json
{
  "code": "INSUFFICIENT_FUNDS",
  "message": "The account does not have sufficient funds.",
  "request_id": "…",
  "timestamp": "…"
}
```

| Try | Status | `code` |
|---|---|---|
| A `conversation_id` that does not exist | 404 | `CONVERSATION_NOT_FOUND` |
| Both `message` and `interaction`, or a blank message | 422 | `INVALID_REQUEST` |
| `"Transferile 50000000 pesos a Laura"` | 422 | `INSUFFICIENT_FUNDS` |
| Selecting the frozen Visa `9134` to freeze | 409 | `INVALID_CARD_STATE` |
| `CONFIRM` with an old or wrong `operation_id` | 409 | `INVALID_INTERACTION` |
| A new transfer while a card operation is pending | 409 | `PENDING_OPERATION_CONFLICT` |
| LLM unreachable or bad API key | 503 | `SERVICE_UNAVAILABLE` |

A failed pre-validation or confirmation discards the operation, and the
conversation returns to `READY`. `CONFIRM` or `CANCEL` with nothing pending is
not an error: it returns a `TEXT` response saying there is nothing to confirm
or cancel.

The full list of codes and statuses is in
[API_CONTRACT.md](../architecture/API_CONTRACT.md).
