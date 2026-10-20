from decimal import Decimal

# Amounts must be exactly representable by the persisted NUMERIC(18, 2) columns.
_CENT = Decimal("0.01")
_AMOUNT_UPPER_BOUND = Decimal(10) ** 16


def is_valid_transfer_amount(amount: Decimal) -> bool:
    return (
        amount.is_finite()
        and _CENT <= amount < _AMOUNT_UPPER_BOUND
        and amount.quantize(_CENT) == amount
    )
