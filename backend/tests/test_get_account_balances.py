from decimal import Decimal
from uuid import UUID, uuid4

from mimi.application.use_cases.get_account_balances import GetAccountBalances
from mimi.domain.entities import Account, Money
from mimi.domain.enums import AccountStatus, Currency

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()


class FakeAccountRepository:
    def __init__(self, accounts: list[Account]) -> None:
        self._accounts = accounts

    def list_by_customer(self, customer_id: UUID) -> list[Account]:
        return [a for a in self._accounts if a.customer_id == customer_id]

    def get_for_update(self, customer_id: UUID, account_id: UUID) -> Account | None:
        raise AssertionError("balance query must not lock accounts")

    def update_balance(self, account_id: UUID, balance: Money) -> None:
        raise AssertionError("balance query must not modify accounts")


def make_account(
    balance: Money,
    *,
    name: str = "Cuenta principal",
    status: AccountStatus = AccountStatus.ACTIVE,
    customer_id: UUID = CUSTOMER_ID,
) -> Account:
    return Account(
        id=uuid4(),
        customer_id=customer_id,
        name=name,
        balance=balance,
        status=status,
    )


def get_balances(
    accounts: list[Account], customer_id: UUID = CUSTOMER_ID
) -> list[Account]:
    return GetAccountBalances(FakeAccountRepository(accounts)).execute(customer_id)


def test_returns_single_account_balance() -> None:
    account = make_account(Money(Decimal("120000.50"), Currency.ARS))

    result = get_balances([account])

    assert result == [account]
    assert result[0].balance == Money(Decimal("120000.50"), Currency.ARS)


def test_returns_accounts_in_multiple_currencies_in_repository_order() -> None:
    ars = make_account(Money(Decimal("350000.75"), Currency.ARS), name="B")
    usd = make_account(Money(Decimal("1250.10"), Currency.USD), name="A")

    result = get_balances([ars, usd])

    assert result == [ars, usd]
    assert [account.balance for account in result] == [
        Money(Decimal("350000.75"), Currency.ARS),
        Money(Decimal("1250.10"), Currency.USD),
    ]


def test_includes_zero_balance_account() -> None:
    account = make_account(Money(Decimal("0.00"), Currency.USD))

    assert get_balances([account]) == [account]


def test_includes_inactive_account_with_its_status() -> None:
    account = make_account(
        Money(Decimal("500.00"), Currency.ARS), status=AccountStatus.INACTIVE
    )

    result = get_balances([account])

    assert result == [account]
    assert result[0].status is AccountStatus.INACTIVE


def test_returns_empty_list_when_customer_has_no_accounts() -> None:
    other = make_account(
        Money(Decimal("10.00"), Currency.ARS), customer_id=OTHER_CUSTOMER_ID
    )

    assert get_balances([other]) == []


def test_returns_only_the_requested_customers_accounts() -> None:
    own = make_account(Money(Decimal("100.00"), Currency.ARS))
    other = make_account(
        Money(Decimal("200.00"), Currency.ARS), customer_id=OTHER_CUSTOMER_ID
    )

    assert get_balances([own, other]) == [own]
