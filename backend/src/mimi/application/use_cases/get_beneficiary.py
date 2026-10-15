from uuid import UUID

from mimi.application.errors import BeneficiaryNotFoundError
from mimi.application.repositories import BeneficiaryRepository
from mimi.domain.entities import Beneficiary


class GetBeneficiary:
    """Resolve one of the customer's saved beneficiaries by id.

    A beneficiary that does not exist or belongs to another customer is
    reported as not found.
    """

    def __init__(self, beneficiaries: BeneficiaryRepository) -> None:
        self._beneficiaries = beneficiaries

    def execute(self, customer_id: UUID, beneficiary_id: UUID) -> Beneficiary:
        beneficiary = self._beneficiaries.get(customer_id, beneficiary_id)
        if beneficiary is None:
            raise BeneficiaryNotFoundError()
        return beneficiary
