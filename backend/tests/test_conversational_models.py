from enum import StrEnum

import pytest
from sqlalchemy import DateTime, Enum, Numeric, String, Table, Text, Uuid
from sqlalchemy.dialects.postgresql import ARRAY, JSONB

from mimi.domain.enums import (
    ConversationFlowState,
    ConversationStatus,
    Currency,
    MessageRole,
    PendingOperationType,
)
from mimi.infrastructure.database.base import Base
from mimi.infrastructure.database.models import ConversationModel

ALL_TABLES = {
    "customers",
    "accounts",
    "cards",
    "transactions",
    "beneficiaries",
    "transfers",
    "conversations",
    "messages",
}


def table(name: str) -> Table:
    return Base.metadata.tables[name]


def test_all_persistence_tables_are_registered_on_base_metadata() -> None:
    assert set(Base.metadata.tables) == ALL_TABLES


@pytest.mark.parametrize("table_name", ["conversations", "messages"])
def test_primary_key_is_uuid_id(table_name: str) -> None:
    primary_key = list(table(table_name).primary_key.columns)

    assert [column.name for column in primary_key] == ["id"]
    assert isinstance(primary_key[0].type, Uuid)


def test_only_pending_operation_columns_are_nullable() -> None:
    nullable = {
        f"{table_name}.{column.name}"
        for table_name in ("conversations", "messages")
        for column in table(table_name).columns
        if column.nullable
    }

    assert nullable == {
        "conversations.pending_operation_type",
        "conversations.pending_operation_id",
        "conversations.pending_source_account_id",
        "conversations.pending_beneficiary_id",
        "conversations.pending_amount",
        "conversations.pending_currency",
        "conversations.pending_card_id",
        "conversations.pending_missing_fields",
    }


@pytest.mark.parametrize("table_name", sorted(ALL_TABLES))
def test_columns_have_no_defaults(table_name: str) -> None:
    for column in table(table_name).columns:
        assert column.default is None, column.name
        assert column.server_default is None, column.name


@pytest.mark.parametrize(
    "column_path",
    ["conversations.created_at", "conversations.updated_at", "messages.created_at"],
)
def test_datetimes_are_timezone_aware(column_path: str) -> None:
    table_name, column_name = column_path.split(".")
    column_type = table(table_name).c[column_name].type

    assert isinstance(column_type, DateTime)
    assert column_type.timezone


def test_context_is_jsonb() -> None:
    assert isinstance(table("conversations").c.context.type, JSONB)


def test_pending_missing_fields_is_varchar_array() -> None:
    column_type = table("conversations").c.pending_missing_fields.type

    assert isinstance(column_type, ARRAY)
    assert isinstance(column_type.item_type, String)


def test_pending_amount_is_numeric_18_2() -> None:
    column_type = table("conversations").c.pending_amount.type

    assert isinstance(column_type, Numeric)
    assert (column_type.precision, column_type.scale) == (18, 2)


def test_message_content_is_text() -> None:
    assert isinstance(table("messages").c.content.type, Text)


@pytest.mark.parametrize(
    ("column_path", "enum_class"),
    [
        ("conversations.status", ConversationStatus),
        ("conversations.flow_state", ConversationFlowState),
        ("conversations.pending_operation_type", PendingOperationType),
        ("conversations.pending_currency", Currency),
        ("messages.role", MessageRole),
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


def test_foreign_keys_reference_documented_tables() -> None:
    foreign_keys = {
        f"{table_name}.{fk.parent.name}": fk.target_fullname
        for table_name in ("conversations", "messages")
        for fk in table(table_name).foreign_keys
    }

    assert foreign_keys == {
        "conversations.customer_id": "customers.id",
        "conversations.pending_source_account_id": "accounts.id",
        "conversations.pending_beneficiary_id": "beneficiaries.id",
        "conversations.pending_card_id": "cards.id",
        "messages.conversation_id": "conversations.id",
    }


def test_messages_are_indexed_for_ordered_history() -> None:
    indexes = {
        index.name: [column.name for column in index.columns]
        for index in table("messages").indexes
    }

    assert indexes == {
        "ix_messages_conversation_id_created_at_id": [
            "conversation_id",
            "created_at",
            "id",
        ]
    }


def test_conversational_relationships_never_load_implicitly() -> None:
    relationships = {
        f"{mapper.class_.__name__}.{relationship.key}": relationship
        for mapper in Base.registry.mappers
        if mapper.tables[0].name in {"conversations", "messages"}
        for relationship in mapper.relationships
    }

    assert set(relationships) == {
        "ConversationModel.customer",
        "ConversationModel.messages",
        "MessageModel.conversation",
    }
    assert all(rel.lazy == "raise" for rel in relationships.values())


def test_messages_are_ordered_by_created_at_then_id() -> None:
    order_by = ConversationModel.messages.property.order_by

    assert order_by is not False
    assert [column.name for column in order_by] == ["created_at", "id"]
