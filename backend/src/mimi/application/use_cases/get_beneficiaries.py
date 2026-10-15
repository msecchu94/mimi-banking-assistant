from uuid import UUID

from mimi.application.repositories import BeneficiaryRepository
from mimi.domain.entities import Beneficiary


class GetBeneficiaries:
    """Return the customer's saved beneficiaries.

    Beneficiaries are returned in repository order. A customer without saved
    beneficiaries yields an empty list.
    """

    def __init__(self, beneficiaries: BeneficiaryRepository) -> None:
        self._beneficiaries = beneficiaries

    def execute(self, customer_id: UUID) -> list[Beneficiary]:
        return self._beneficiaries.list_by_customer(customer_id)
