from uuid import UUID, uuid4

import pytest

from mimi.application.errors import BeneficiaryNotFoundError, NotFoundError
from mimi.application.use_cases.get_beneficiary import GetBeneficiary
from mimi.domain.entities import Beneficiary

CUSTOMER_ID = uuid4()
OTHER_CUSTOMER_ID = uuid4()


class FakeBeneficiaryRepository:
    def __init__(self, beneficiaries: list[Beneficiary]) -> None:
        self._beneficiaries = {b.id: b for b in beneficiaries}

    def list_by_customer(self, customer_id: UUID) -> list[Beneficiary]:
        raise AssertionError("beneficiary resolution must not list beneficiaries")

    def get(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary | None:
        beneficiary = self._beneficiaries.get(beneficiary_id)
        if beneficiary is None or beneficiary.customer_id != customer_id:
            return None
        return beneficiary


def make_beneficiary(*, customer_id: UUID = CUSTOMER_ID) -> Beneficiary:
    return Beneficiary(
        id=uuid4(),
        customer_id=customer_id,
        name="Juan Pérez",
        account_reference="0110599520000001234567",
        bank_name="Banco Nación",
    )


def test_resolves_owned_beneficiary() -> None:
    beneficiary = make_beneficiary()
    other = make_beneficiary()
    repository = FakeBeneficiaryRepository([beneficiary, other])

    result = GetBeneficiary(repository).execute(CUSTOMER_ID, beneficiary.id)

    assert result == beneficiary


def test_rejects_unknown_beneficiary() -> None:
    repository = FakeBeneficiaryRepository([make_beneficiary()])

    with pytest.raises(BeneficiaryNotFoundError) as exc_info:
        GetBeneficiary(repository).execute(CUSTOMER_ID, uuid4())

    assert isinstance(exc_info.value, NotFoundError)
    assert exc_info.value.code == "BENEFICIARY_NOT_FOUND"


def test_rejects_beneficiary_owned_by_another_customer() -> None:
    other = make_beneficiary(customer_id=OTHER_CUSTOMER_ID)
    repository = FakeBeneficiaryRepository([other])

    with pytest.raises(BeneficiaryNotFoundError):
        GetBeneficiary(repository).execute(CUSTOMER_ID, other.id)
