"""Read-only account and transaction endpoints used by the Home screen."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from pydantic import BaseModel, ConfigDict

from mimi.api.chat import (
    INTERNAL_ERROR_DESCRIPTION,
    get_container,
    get_customer_id,
    new_metadata,
)
from mimi.api.chat_models import Money as MoneyItem
from mimi.api.chat_models import ResponseMetadata, TransactionItem
from mimi.api.errors import error_responses, get_request_id
from mimi.application.account_queries import AccountQueries
from mimi.composition import Container
from mimi.domain.entities import Account, Money, Transaction
from mimi.domain.enums import AccountStatus

router = APIRouter()

MAX_TRANSACTIONS_LIMIT = 50

READ_ERRORS = error_responses(
    {
        422: "The request is invalid: INVALID_REQUEST.",
        500: INTERNAL_ERROR_DESCRIPTION,
    }
)


class _ApiModel(BaseModel):
    # Same wire conventions as the Chat API models.
    model_config = ConfigDict(
        extra="forbid", json_schema_serialization_defaults_required=True
    )


class AccountItem(_ApiModel):
    id: UUID
    name: str
    balance: MoneyItem
    status: AccountStatus


class AccountsResponse(_ApiModel):
    accounts: list[AccountItem]
    metadata: ResponseMetadata


class TransactionsResponse(_ApiModel):
    transactions: list[TransactionItem]
    metadata: ResponseMetadata


def get_account_queries(
    container: Annotated[Container, Depends(get_container)],
) -> AccountQueries:
    return container.account_queries


@router.get("/accounts", responses=READ_ERRORS)
def list_accounts(
    queries: Annotated[AccountQueries, Depends(get_account_queries)],
    customer_id: Annotated[UUID, Depends(get_customer_id)],
    request_id: Annotated[str, Depends(get_request_id)],
) -> AccountsResponse:
    """The customer's accounts with their persisted balances."""
    accounts = queries.list_accounts(customer_id)
    return AccountsResponse(
        accounts=[_account(account) for account in accounts],
        metadata=new_metadata(request_id),
    )


@router.get("/transactions", responses=READ_ERRORS)
def list_transactions(
    queries: Annotated[AccountQueries, Depends(get_account_queries)],
    customer_id: Annotated[UUID, Depends(get_customer_id)],
    request_id: Annotated[str, Depends(get_request_id)],
    limit: Annotated[int, Query(ge=1, le=MAX_TRANSACTIONS_LIMIT)],
    account_id: Annotated[UUID | None, Query()] = None,
) -> TransactionsResponse:
    """The customer's newest transactions, of one account when filtered."""
    transactions = queries.list_recent_transactions(customer_id, account_id, limit)
    return TransactionsResponse(
        transactions=[_transaction(t) for t in transactions],
        metadata=new_metadata(request_id),
    )


def _account(account: Account) -> AccountItem:
    return AccountItem(
        id=account.id,
        name=account.name,
        balance=_money(account.balance),
        status=account.status,
    )


def _transaction(transaction: Transaction) -> TransactionItem:
    return TransactionItem(
        id=transaction.id,
        description=transaction.description,
        amount=_money(transaction.amount),
        type=transaction.type,
        category=transaction.category,
        occurred_at=transaction.occurred_at,
    )


def _money(money: Money) -> MoneyItem:
    return MoneyItem(amount=money.amount, currency=money.currency)
