from uuid import UUID, uuid4

from mimi.application.use_cases.get_beneficiaries import GetBeneficiaries
from mimi.domain.entities import Beneficiary

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()


class FakeBeneficiaryRepository:
    def __init__(self, beneficiaries: list[Beneficiary]) -> None:
        self._beneficiaries = beneficiaries

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        return [b for b in self._beneficiaries if b.customer_id == customer_id]

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        raise AssertionError("beneficiary listing must not resolve single records")


def make_beneficiary(
    *,
    name: str = "Juan Pérez",
    bank_name: str | None = "Banco Nación",
    customer_id: UUID = CUSTOMER_ID,
) -> Beneficiary:
    return Beneficiary(
        id=uuid4(),
        customer_id=customer_id,
        name=name,
        account_reference="0110599520000001234567",
        bank_name=bank_name,
    )


def get_beneficiaries(
    beneficiaries: list[Beneficiary], customer_id: UUID = CUSTOMER_ID
) -> list[Beneficiary]:
    return GetBeneficiaries(FakeBeneficiaryRepository(beneficiaries)).execute(
        customer_id
    )


def test_returns_single_beneficiary() -> None:
    beneficiary = make_beneficiary()

    assert get_beneficiaries([beneficiary]) == [beneficiary]


def test_returns_multiple_beneficiaries_in_repository_order() -> None:
    zoe = make_beneficiary(name="Zoe")
    ana = make_beneficiary(name="Ana")

    assert get_beneficiaries([zoe, ana]) == [zoe, ana]


def test_includes_beneficiary_without_bank_name() -> None:
    beneficiary = make_beneficiary(bank_name=None)

    result = get_beneficiaries([beneficiary])

    assert result == [beneficiary]
    assert result[0].bank_name is None


def test_returns_empty_list_when_customer_has_no_beneficiaries() -> None:
    other = make_beneficiary(customer_id=OTHER_CUSTOMER_ID)

    assert get_beneficiaries([other]) == []


def test_returns_only_the_requested_customers_beneficiaries() -> None:
    own = make_beneficiary()
    other = make_beneficiary(customer_id=OTHER_CUSTOMER_ID)

    assert get_beneficiaries([own, other]) == [own]
