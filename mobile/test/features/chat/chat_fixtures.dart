// Wire payloads taken from the Chat API contract (API_CONTRACT.md).

const conversationId = '9e47b4c1-4a8c-4a3c-98d2-a31c9c87e641';
const operationId = '5b0c7d2e-3f41-4a6b-9c8d-1e2f3a4b5c6d';
const cardId = '16e39f21-93b5-48b5-a8dc-90ad03ea5dd1';

const metadataJson = {
  'request_id': 'req-50dc23a1',
  'timestamp': '2026-10-09T16:30:00Z',
};

const conversationResponseJson = {
  'conversation_id': conversationId,
  'conversation_state': 'READY',
  'metadata': metadataJson,
};

Map<String, dynamic> chatResponseJson({
  Map<String, dynamic> ui = textUiJson,
  String intent = 'GET_BALANCE',
  String conversationState = 'READY',
}) => {
  'conversation_id': conversationId,
  'message': 'Your available balance is 120000.00 ARS.',
  'intent': intent,
  'conversation_state': conversationState,
  'ui': ui,
  'metadata': metadataJson,
};

const apiErrorJson = {
  'code': 'CONVERSATION_NOT_FOUND',
  'message': 'The requested conversation was not found.',
  'request_id': 'req-91af23c1',
  'timestamp': '2026-10-09T16:31:04Z',
};

const cardJson = {
  'id': cardId,
  'brand': 'VISA',
  'type': 'DEBIT',
  'last_four': '4821',
  'status': 'ACTIVE',
};

const textUiJson = <String, dynamic>{
  'type': 'TEXT',
  'data': <String, dynamic>{},
};

const cardListUiJson = {
  'type': 'CARD_LIST',
  'data': {
    'cards': [cardJson],
  },
};

const cardSelectorUiJson = {
  'type': 'CARD_SELECTOR',
  'data': {
    'cards': [cardJson],
  },
};

const beneficiaryListUiJson = {
  'type': 'BENEFICIARY_LIST',
  'data': {
    'beneficiaries': [
      {
        'id': 'b43b2bd2-ef66-46a7-93b5-b617ee28c40e',
        'name': 'Laura',
        'account_reference': '****4582',
        'bank_name': null,
      },
    ],
  },
};

const transferConfirmationUiJson = {
  'type': 'CONFIRMATION',
  'data': {
    'operation_id': operationId,
    'title': 'Confirm transfer',
    'summary': {
      'type': 'TRANSFER',
      'amount': {'amount': '25000.00', 'currency': 'ARS'},
      'beneficiary': 'Laura',
    },
    'actions': [
      {'type': 'CONFIRM', 'label': 'Confirm'},
      {'type': 'CANCEL', 'label': 'Cancel'},
    ],
  },
};

const cardConfirmationUiJson = {
  'type': 'CONFIRMATION',
  'data': {
    'operation_id': operationId,
    'title': 'Congelar tarjeta',
    'summary': {'type': 'CARD', 'card': cardJson},
    'actions': [
      {'type': 'CONFIRM', 'label': 'Confirmar'},
      {'type': 'CANCEL', 'label': 'Cancelar'},
    ],
  },
};

const expenseSummaryUiJson = {
  'type': 'EXPENSE_SUMMARY',
  'data': {
    'period': {'from': '2026-10-01', 'to': '2026-10-31'},
    'currencies': [
      {
        'total': {'amount': '185000.00', 'currency': 'ARS'},
        'categories': [
          {
            'category': 'DINING',
            'amount': {'amount': '85000.00', 'currency': 'ARS'},
          },
        ],
      },
    ],
  },
};

const expenseComparisonUiJson = {
  'type': 'EXPENSE_COMPARISON',
  'data': {
    'current_period': {'from': '2026-10-01', 'to': '2026-10-31'},
    'previous_period': {'from': '2026-09-01', 'to': '2026-09-30'},
    'currencies': [
      {
        'current_total': {'amount': '185000.00', 'currency': 'ARS'},
        'previous_total': {'amount': '160000.00', 'currency': 'ARS'},
        'difference': {'amount': '25000.00', 'currency': 'ARS'},
        'change': 'INCREASE',
      },
    ],
  },
};

const transactionListUiJson = {
  'type': 'TRANSACTION_LIST',
  'data': {
    'transactions': [
      {
        'id': '9eab44a2-c710-4a0c-beb7-c24de95a9820',
        'description': 'Supermarket',
        'amount': {'amount': '24500.00', 'currency': 'ARS'},
        'type': 'DEBIT',
        'category': 'GROCERIES',
        'occurred_at': '2026-10-08T18:30:00Z',
      },
    ],
  },
};

const transferSummaryUiJson = {
  'type': 'TRANSFER_SUMMARY',
  'data': {
    'transfer_id': 'c919db94-a92f-4bc5-9355-32e90a10c632',
    'beneficiary': 'Laura',
    'amount': {'amount': '25000.00', 'currency': 'ARS'},
    'status': 'COMPLETED',
    'executed_at': '2026-10-09T16:30:00Z',
  },
};

/// One example per contract `ui.type`.
const uiExamples = <Map<String, dynamic>>[
  textUiJson,
  cardListUiJson,
  cardSelectorUiJson,
  beneficiaryListUiJson,
  transferConfirmationUiJson,
  cardConfirmationUiJson,
  expenseSummaryUiJson,
  expenseComparisonUiJson,
  transactionListUiJson,
  transferSummaryUiJson,
];
