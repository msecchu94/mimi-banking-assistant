from collections.abc import Iterator
from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID, uuid4

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import Engine

from mimi.api.accounts import get_account_queries
from mimi.api.app import create_app
from mimi.composition import Container
from mimi.config import Settings
from mimi.domain.entities import Account, Money, Transaction
from mimi.domain.enums import (
    AccountStatus,
    Currency,
    TransactionCategory,
    TransactionType,
)
from mimi.infrastructure.database.models import (
    AccountModel,
    CustomerModel,
    TransactionModel,
)
from mimi.infrastructure.database.session import create_session_factory

CUSTOMER_ID = UUID("44444444-4444-4444-8444-444444444444")
SAVINGS = Account(
    UUID("11111111-1111-4111-8111-111111111111"),
    CUSTOMER_ID,
    "Cuenta principal",
    Money(Decimal("150000.5"), Currency.ARS),
    AccountStatus.ACTIVE,
)
DOLLARS = Account(
    UUID("22222222-2222-4222-8222-222222222222"),
    CUSTOMER_ID,
    "Caja de ahorro en dólares",
    Money(Decimal("1200"), Currency.USD),
    AccountStatus.INACTIVE,
)
SALARY = Transaction(
    id=UUID("33333333-3333-4333-8333-333333333333"),
    account_id=SAVINGS.id,
    amount=Money(Decimal("85000"), Currency.ARS),
    type=TransactionType.CREDIT,
    category=TransactionCategory.TRANSFER,
    description="Martín López",
    occurred_at=datetime(2026, 10, 9, 13, 18, tzinfo=UTC),
    transfer_id=None,
)


class StubAccountQueries:
    def __init__(self) -> None:
        self.accounts: list[Account] = [SAVINGS, DOLLARS]
        self.transactions: list[Transaction] = [SALARY]
        self.transaction_calls: list[tuple[UUID, UUID | None, int]] = []
        self.error: Exception | None = None

    def list_accounts(self, customer_id: UUID) -> list[Account]:
        if self.error is not None:
            raise self.error
        return self.accounts

    def list_recent_transactions(
        self, customer_id: UUID, account_id: UUID | None, limit: int
    ) -> list[Transaction]:
        if self.error is not None:
            raise self.error
        self.transaction_calls.append((customer_id, account_id, limit))
        return self.transactions


@pytest.fixture
def stub(app: FastAPI) -> StubAccountQueries:
    stub = StubAccountQueries()
    app.dependency_overrides[get_account_queries] = lambda: stub
    return stub


@pytest.fixture
def api(app: FastAPI, stub: StubAccountQueries) -> Iterator[TestClient]:
    with TestClient(app, raise_server_exceptions=False) as client:
        yield client


def assert_metadata(body: dict[str, object]) -> None:
    metadata = body["metadata"]
    assert isinstance(metadata, dict)
    assert set(metadata) == {"request_id", "timestamp"}


def test_lists_accounts_with_exact_balances(api: TestClient) -> None:
    response = api.get("/accounts")

    assert response.status_code == 200
    body = response.json()
    assert body["accounts"] == [
        {
            "id": str(SAVINGS.id),
            "name": "Cuenta principal",
            "balance": {"amount": "150000.50", "currency": "ARS"},
            "status": "ACTIVE",
        },
        {
            "id": str(DOLLARS.id),
            "name": "Caja de ahorro en dólares",
            "balance": {"amount": "1200.00", "currency": "USD"},
            "status": "INACTIVE",
        },
    ]
    assert_metadata(body)


def test_lists_no_accounts_as_empty(api: TestClient, stub: StubAccountQueries) -> None:
    stub.accounts = []

    response = api.get("/accounts")

    assert response.status_code == 200
    assert response.json()["accounts"] == []


def test_lists_recent_transactions_of_an_account(
    api: TestClient, stub: StubAccountQueries, test_settings: Settings
) -> None:
    response = api.get(
        "/transactions", params={"account_id": str(SAVINGS.id), "limit": 3}
    )

    assert response.status_code == 200
    body = response.json()
    assert body["transactions"] == [
        {
            "id": str(SALARY.id),
            "description": "Martín López",
            "amount": {"amount": "85000.00", "currency": "ARS"},
            "type": "CREDIT",
            "category": "TRANSFER",
            "occurred_at": "2026-10-09T13:18:00Z",
        }
    ]
    assert_metadata(body)
    assert stub.transaction_calls == [(test_settings.demo_customer_id, SAVINGS.id, 3)]


def test_lists_transactions_without_account_filter(
    api: TestClient, stub: StubAccountQueries, test_settings: Settings
) -> None:
    response = api.get("/transactions", params={"limit": 3})

    assert response.status_code == 200
    assert stub.transaction_calls == [(test_settings.demo_customer_id, None, 3)]


@pytest.mark.parametrize(
    "params",
    [
        {},
        {"limit": 0},
        {"limit": 51},
        {"limit": "three"},
        {"limit": 3, "account_id": "not-a-uuid"},
    ],
)
def test_rejects_invalid_transaction_queries(
    api: TestClient, stub: StubAccountQueries, params: dict[str, str | int]
) -> None:
    response = api.get("/transactions", params=params)

    assert response.status_code == 422
    assert response.json()["code"] == "INVALID_REQUEST"
    assert stub.transaction_calls == []


@pytest.mark.parametrize("path", ["/accounts", "/transactions?limit=3"])
def test_unexpected_failure_is_an_internal_error(
    api: TestClient, stub: StubAccountQueries, path: str
) -> None:
    stub.error = RuntimeError("database down")

    response = api.get(path)

    assert response.status_code == 500
    assert response.json()["code"] == "INTERNAL_ERROR"


@pytest.mark.integration
def test_home_reads_round_trip_over_http(
    migrated_engine: Engine, test_container: Container, test_settings: Settings
) -> None:
    customer = CustomerModel(
        id=test_settings.demo_customer_id, first_name="Ana", last_name="Ruiz"
    )
    savings = AccountModel(
        id=SAVINGS.id,
        customer=customer,
        name=SAVINGS.name,
        balance=Decimal("150000.50"),
        currency=Currency.ARS,
        status=AccountStatus.ACTIVE,
    )
    dollars = AccountModel(
        id=DOLLARS.id,
        customer=customer,
        name=DOLLARS.name,
        balance=Decimal("1200.00"),
        currency=Currency.USD,
        status=AccountStatus.ACTIVE,
    )

    def transaction(account: AccountModel, hour: int) -> TransactionModel:
        return TransactionModel(
            id=uuid4(),
            account=account,
            amount=Decimal("100.00"),
            currency=account.currency,
            type=TransactionType.DEBIT,
            category=TransactionCategory.GROCERIES,
            description="Supermercado",
            occurred_at=datetime(2026, 10, 9, hour, tzinfo=UTC),
            transfer_id=None,
        )

    savings_rows = [transaction(savings, hour) for hour in (9, 10, 11, 12)]
    newest_dollars = transaction(dollars, 13)
    with create_session_factory(migrated_engine).begin() as session:
        session.add_all([customer, savings, dollars, *savings_rows, newest_dollars])

    with TestClient(create_app(test_container)) as client:
        accounts = client.get("/accounts")
        transactions = client.get(
            "/transactions", params={"account_id": str(SAVINGS.id), "limit": 3}
        )

    assert accounts.status_code == 200
    assert [a["balance"] for a in accounts.json()["accounts"]] == [
        {"amount": "1200.00", "currency": "USD"},
        {"amount": "150000.50", "currency": "ARS"},
    ]
    assert transactions.status_code == 200
    assert [t["id"] for t in transactions.json()["transactions"]] == [
        str(row.id) for row in reversed(savings_rows[1:])
    ]
