from enum import StrEnum

import pytest
from sqlalchemy import CHAR, DateTime, Enum, Numeric, Table, UniqueConstraint, Uuid
from sqlalchemy.orm import RelationshipProperty

from mimi.domain.enums import (
    AccountStatus,
    CardBrand,
    CardStatus,
    CardType,
    Currency,
    TransactionCategory,
    TransactionType,
    TransferStatus,
)
from mimi.infrastructure.database import models
from mimi.infrastructure.database.base import Base

FINANCIAL_TABLES = {
    "customers",
    "accounts",
    "cards",
    "transactions",
    "beneficiaries",
    "transfers",
}


def table(name: str) -> Table:
    return Base.metadata.tables[name]


def test_financial_tables_are_registered_on_base_metadata() -> None:
    assert FINANCIAL_TABLES <= set(Base.metadata.tables)


@pytest.mark.parametrize("table_name", sorted(FINANCIAL_TABLES))
def test_primary_key_is_uuid_id(table_name: str) -> None:
    primary_key = list(table(table_name).primary_key.columns)

    assert [column.name for column in primary_key] == ["id"]
    assert isinstance(primary_key[0].type, Uuid)


def test_only_optional_domain_fields_are_nullable() -> None:
    nullable = {
        f"{table_name}.{column.name}"
        for table_name in FINANCIAL_TABLES
        for column in table(table_name).columns
        if column.nullable
    }

    assert nullable == {
        "transactions.transfer_id",
        "beneficiaries.bank_name",
        "transfers.executed_at",
    }


@pytest.mark.parametrize(
    "column_path", ["accounts.balance", "transactions.amount", "transfers.amount"]
)
def test_money_amounts_are_numeric_18_2(column_path: str) -> None:
    table_name, column_name = column_path.split(".")
    column_type = table(table_name).c[column_name].type

    assert isinstance(column_type, Numeric)
    assert (column_type.precision, column_type.scale) == (18, 2)
    assert column_type.asdecimal


@pytest.mark.parametrize("table_name", ["accounts", "transactions", "transfers"])
def test_money_values_persist_their_currency(table_name: str) -> None:
    column_type = table(table_name).c.currency.type

    assert isinstance(column_type, Enum)
    assert column_type.enum_class is Currency


@pytest.mark.parametrize(
    "column_path",
    ["transactions.occurred_at", "transfers.created_at", "transfers.executed_at"],
)
def test_datetimes_are_timezone_aware(column_path: str) -> None:
    table_name, column_name = column_path.split(".")
    column_type = table(table_name).c[column_name].type

    assert isinstance(column_type, DateTime)
    assert column_type.timezone


@pytest.mark.parametrize(
    ("column_path", "enum_class"),
    [
        ("accounts.status", AccountStatus),
        ("cards.type", CardType),
        ("cards.brand", CardBrand),
        ("cards.status", CardStatus),
        ("transactions.type", TransactionType),
        ("transactions.category", TransactionCategory),
        ("transfers.status", TransferStatus),
    ],
)
def test_enums_are_stored_as_varchar_with_domain_values(
    column_path: str, enum_class: type[StrEnum]
) -> None:
    table_name, column_name = column_path.split(".")
    column_type = table(table_name).c[column_name].type

    assert isinstance(column_type, Enum)
    assert not column_type.native_enum
    assert column_type.enum_class is enum_class
    assert column_type.enums == [member.value for member in enum_class]


def test_last_four_is_char_4() -> None:
    column_type = table("cards").c.last_four.type

    assert isinstance(column_type, CHAR)
    assert column_type.length == 4


def test_foreign_keys_reference_documented_tables() -> None:
    foreign_keys = {
        f"{table_name}.{fk.parent.name}": fk.target_fullname
        for table_name in FINANCIAL_TABLES
        for fk in table(table_name).foreign_keys
    }

    assert foreign_keys == {
        "accounts.customer_id": "customers.id",
        "cards.account_id": "accounts.id",
        "transactions.account_id": "accounts.id",
        "transactions.transfer_id": "transfers.id",
        "beneficiaries.customer_id": "customers.id",
        "transfers.source_account_id": "accounts.id",
        "transfers.beneficiary_id": "beneficiaries.id",
    }


def test_transaction_transfer_id_is_unique() -> None:
    unique_columns = [
        [column.name for column in constraint.columns]
        for constraint in table("transactions").constraints
        if isinstance(constraint, UniqueConstraint)
    ]

    assert unique_columns == [["transfer_id"]]


def test_transactions_are_indexed_by_account_and_occurrence() -> None:
    indexes = {
        index.name: [column.name for column in index.columns]
        for index in table("transactions").indexes
    }

    assert indexes == {
        "ix_transactions_account_id_occurred_at": ["account_id", "occurred_at"]
    }


def test_relationships_match_domain_and_never_load_implicitly() -> None:
    relationships: dict[str, RelationshipProperty[object]] = {
        f"{mapper.class_.__name__}.{relationship.key}": relationship
        for mapper in Base.registry.mappers
        if mapper.tables[0].name in FINANCIAL_TABLES
        for relationship in mapper.relationships
    }

    assert set(relationships) == {
        "CustomerModel.accounts",
        "CustomerModel.beneficiaries",
        "CustomerModel.conversations",
        "AccountModel.customer",
        "AccountModel.cards",
        "AccountModel.transactions",
        "AccountModel.outgoing_transfers",
        "CardModel.account",
        "BeneficiaryModel.customer",
        "BeneficiaryModel.transfers",
        "TransferModel.source_account",
        "TransferModel.beneficiary",
        "TransferModel.transaction",
        "TransactionModel.account",
        "TransactionModel.transfer",
    }
    assert all(rel.lazy == "raise" for rel in relationships.values())
    assert not models.TransferModel.transaction.property.uselist
