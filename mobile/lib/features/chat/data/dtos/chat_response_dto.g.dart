// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConversationResponseDto _$ConversationResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_ConversationResponseDto',
  json,
  ($checkedConvert) {
    final val = _ConversationResponseDto(
      conversationId: $checkedConvert('conversation_id', (v) => v as String),
      conversationState: $checkedConvert(
        'conversation_state',
        (v) => v as String,
      ),
      metadata: $checkedConvert(
        'metadata',
        (v) => ResponseMetadataDto.fromJson(v as Map<String, dynamic>),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'conversationId': 'conversation_id',
    'conversationState': 'conversation_state',
  },
);

Map<String, dynamic> _$ConversationResponseDtoToJson(
  _ConversationResponseDto instance,
) => <String, dynamic>{
  'conversation_id': instance.conversationId,
  'conversation_state': instance.conversationState,
  'metadata': instance.metadata.toJson(),
};

_ChatResponseDto _$ChatResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_ChatResponseDto',
      json,
      ($checkedConvert) {
        final val = _ChatResponseDto(
          conversationId: $checkedConvert(
            'conversation_id',
            (v) => v as String,
          ),
          message: $checkedConvert('message', (v) => v as String),
          intent: $checkedConvert('intent', (v) => v as String),
          conversationState: $checkedConvert(
            'conversation_state',
            (v) => v as String,
          ),
          ui: $checkedConvert(
            'ui',
            (v) => UiResponseDto.fromJson(v as Map<String, dynamic>),
          ),
          metadata: $checkedConvert(
            'metadata',
            (v) => ResponseMetadataDto.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'conversationId': 'conversation_id',
        'conversationState': 'conversation_state',
      },
    );

Map<String, dynamic> _$ChatResponseDtoToJson(_ChatResponseDto instance) =>
    <String, dynamic>{
      'conversation_id': instance.conversationId,
      'message': instance.message,
      'intent': instance.intent,
      'conversation_state': instance.conversationState,
      'ui': instance.ui.toJson(),
      'metadata': instance.metadata.toJson(),
    };

_ResponseMetadataDto _$ResponseMetadataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ResponseMetadataDto', json, ($checkedConvert) {
      final val = _ResponseMetadataDto(
        requestId: $checkedConvert('request_id', (v) => v as String),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'requestId': 'request_id'});

Map<String, dynamic> _$ResponseMetadataDtoToJson(
  _ResponseMetadataDto instance,
) => <String, dynamic>{
  'request_id': instance.requestId,
  'timestamp': instance.timestamp.toIso8601String(),
};

TextUiDto _$TextUiDtoFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TextUiDto',
  json,
  ($checkedConvert) {
    final val = TextUiDto($type: $checkedConvert('type', (v) => v as String?));
    return val;
  },
  fieldKeyMap: const {r'$type': 'type'},
);

Map<String, dynamic> _$TextUiDtoToJson(TextUiDto instance) => <String, dynamic>{
  'type': instance.$type,
};

CardListUiDto _$CardListUiDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CardListUiDto', json, ($checkedConvert) {
      final val = CardListUiDto(
        data: $checkedConvert(
          'data',
          (v) => CardsDataDto.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$CardListUiDtoToJson(CardListUiDto instance) =>
    <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

CardSelectorUiDto _$CardSelectorUiDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CardSelectorUiDto', json, ($checkedConvert) {
      final val = CardSelectorUiDto(
        data: $checkedConvert(
          'data',
          (v) => CardsDataDto.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$CardSelectorUiDtoToJson(CardSelectorUiDto instance) =>
    <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

BeneficiaryListUiDto _$BeneficiaryListUiDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('BeneficiaryListUiDto', json, ($checkedConvert) {
  final val = BeneficiaryListUiDto(
    data: $checkedConvert(
      'data',
      (v) => BeneficiaryListDataDto.fromJson(v as Map<String, dynamic>),
    ),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$BeneficiaryListUiDtoToJson(
  BeneficiaryListUiDto instance,
) => <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

ConfirmationUiDto _$ConfirmationUiDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ConfirmationUiDto', json, ($checkedConvert) {
      final val = ConfirmationUiDto(
        data: $checkedConvert(
          'data',
          (v) => ConfirmationDataDto.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$ConfirmationUiDtoToJson(ConfirmationUiDto instance) =>
    <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

ExpenseSummaryUiDto _$ExpenseSummaryUiDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExpenseSummaryUiDto', json, ($checkedConvert) {
      final val = ExpenseSummaryUiDto(
        data: $checkedConvert(
          'data',
          (v) => ExpenseSummaryDataDto.fromJson(v as Map<String, dynamic>),
        ),
        $type: $checkedConvert('type', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$ExpenseSummaryUiDtoToJson(
  ExpenseSummaryUiDto instance,
) => <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

ExpenseComparisonUiDto _$ExpenseComparisonUiDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ExpenseComparisonUiDto', json, ($checkedConvert) {
  final val = ExpenseComparisonUiDto(
    data: $checkedConvert(
      'data',
      (v) => ExpenseComparisonDataDto.fromJson(v as Map<String, dynamic>),
    ),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$ExpenseComparisonUiDtoToJson(
  ExpenseComparisonUiDto instance,
) => <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

TransactionListUiDto _$TransactionListUiDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TransactionListUiDto', json, ($checkedConvert) {
  final val = TransactionListUiDto(
    data: $checkedConvert(
      'data',
      (v) => TransactionListDataDto.fromJson(v as Map<String, dynamic>),
    ),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TransactionListUiDtoToJson(
  TransactionListUiDto instance,
) => <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

TransferSummaryUiDto _$TransferSummaryUiDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TransferSummaryUiDto', json, ($checkedConvert) {
  final val = TransferSummaryUiDto(
    data: $checkedConvert(
      'data',
      (v) => TransferSummaryDataDto.fromJson(v as Map<String, dynamic>),
    ),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TransferSummaryUiDtoToJson(
  TransferSummaryUiDto instance,
) => <String, dynamic>{'data': instance.data.toJson(), 'type': instance.$type};

_CardsDataDto _$CardsDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CardsDataDto', json, ($checkedConvert) {
      final val = _CardsDataDto(
        cards: $checkedConvert(
          'cards',
          (v) => (v as List<dynamic>)
              .map((e) => CardDto.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CardsDataDtoToJson(_CardsDataDto instance) =>
    <String, dynamic>{'cards': instance.cards.map((e) => e.toJson()).toList()};

_BeneficiaryListDataDto _$BeneficiaryListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_BeneficiaryListDataDto', json, ($checkedConvert) {
  final val = _BeneficiaryListDataDto(
    beneficiaries: $checkedConvert(
      'beneficiaries',
      (v) => (v as List<dynamic>)
          .map((e) => BeneficiaryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$BeneficiaryListDataDtoToJson(
  _BeneficiaryListDataDto instance,
) => <String, dynamic>{
  'beneficiaries': instance.beneficiaries.map((e) => e.toJson()).toList(),
};

_ConfirmationDataDto _$ConfirmationDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ConfirmationDataDto', json, ($checkedConvert) {
      final val = _ConfirmationDataDto(
        operationId: $checkedConvert('operation_id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        summary: $checkedConvert(
          'summary',
          (v) => ConfirmationSummaryDto.fromJson(v as Map<String, dynamic>),
        ),
        actions: $checkedConvert(
          'actions',
          (v) => (v as List<dynamic>)
              .map(
                (e) =>
                    ConfirmationActionDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    }, fieldKeyMap: const {'operationId': 'operation_id'});

Map<String, dynamic> _$ConfirmationDataDtoToJson(
  _ConfirmationDataDto instance,
) => <String, dynamic>{
  'operation_id': instance.operationId,
  'title': instance.title,
  'summary': instance.summary.toJson(),
  'actions': instance.actions.map((e) => e.toJson()).toList(),
};

_ExpenseSummaryDataDto _$ExpenseSummaryDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ExpenseSummaryDataDto', json, ($checkedConvert) {
  final val = _ExpenseSummaryDataDto(
    period: $checkedConvert(
      'period',
      (v) => ExpensePeriodDto.fromJson(v as Map<String, dynamic>),
    ),
    currencies: $checkedConvert(
      'currencies',
      (v) => (v as List<dynamic>)
          .map((e) => CurrencyExpensesDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$ExpenseSummaryDataDtoToJson(
  _ExpenseSummaryDataDto instance,
) => <String, dynamic>{
  'period': instance.period.toJson(),
  'currencies': instance.currencies.map((e) => e.toJson()).toList(),
};

_ExpenseComparisonDataDto _$ExpenseComparisonDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_ExpenseComparisonDataDto',
  json,
  ($checkedConvert) {
    final val = _ExpenseComparisonDataDto(
      currentPeriod: $checkedConvert(
        'current_period',
        (v) => ExpensePeriodDto.fromJson(v as Map<String, dynamic>),
      ),
      previousPeriod: $checkedConvert(
        'previous_period',
        (v) => ExpensePeriodDto.fromJson(v as Map<String, dynamic>),
      ),
      currencies: $checkedConvert(
        'currencies',
        (v) => (v as List<dynamic>)
            .map(
              (e) => CurrencyComparisonDto.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'currentPeriod': 'current_period',
    'previousPeriod': 'previous_period',
  },
);

Map<String, dynamic> _$ExpenseComparisonDataDtoToJson(
  _ExpenseComparisonDataDto instance,
) => <String, dynamic>{
  'current_period': instance.currentPeriod.toJson(),
  'previous_period': instance.previousPeriod.toJson(),
  'currencies': instance.currencies.map((e) => e.toJson()).toList(),
};

_TransactionListDataDto _$TransactionListDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_TransactionListDataDto', json, ($checkedConvert) {
  final val = _TransactionListDataDto(
    transactions: $checkedConvert(
      'transactions',
      (v) => (v as List<dynamic>)
          .map((e) => TransactionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  );
  return val;
});

Map<String, dynamic> _$TransactionListDataDtoToJson(
  _TransactionListDataDto instance,
) => <String, dynamic>{
  'transactions': instance.transactions.map((e) => e.toJson()).toList(),
};

_TransferSummaryDataDto _$TransferSummaryDataDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_TransferSummaryDataDto',
  json,
  ($checkedConvert) {
    final val = _TransferSummaryDataDto(
      transferId: $checkedConvert('transfer_id', (v) => v as String),
      beneficiary: $checkedConvert('beneficiary', (v) => v as String),
      amount: $checkedConvert(
        'amount',
        (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
      ),
      status: $checkedConvert('status', (v) => v as String),
      executedAt: $checkedConvert(
        'executed_at',
        (v) => DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {'transferId': 'transfer_id', 'executedAt': 'executed_at'},
);

Map<String, dynamic> _$TransferSummaryDataDtoToJson(
  _TransferSummaryDataDto instance,
) => <String, dynamic>{
  'transfer_id': instance.transferId,
  'beneficiary': instance.beneficiary,
  'amount': instance.amount.toJson(),
  'status': instance.status,
  'executed_at': instance.executedAt.toIso8601String(),
};

_MoneyDto _$MoneyDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_MoneyDto', json, ($checkedConvert) {
      final val = _MoneyDto(
        amount: $checkedConvert('amount', (v) => v as String),
        currency: $checkedConvert('currency', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$MoneyDtoToJson(_MoneyDto instance) => <String, dynamic>{
  'amount': instance.amount,
  'currency': instance.currency,
};

_CardDto _$CardDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CardDto', json, ($checkedConvert) {
      final val = _CardDto(
        id: $checkedConvert('id', (v) => v as String),
        brand: $checkedConvert('brand', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        lastFour: $checkedConvert('last_four', (v) => v as String),
        status: $checkedConvert('status', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'lastFour': 'last_four'});

Map<String, dynamic> _$CardDtoToJson(_CardDto instance) => <String, dynamic>{
  'id': instance.id,
  'brand': instance.brand,
  'type': instance.type,
  'last_four': instance.lastFour,
  'status': instance.status,
};

_BeneficiaryDto _$BeneficiaryDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      '_BeneficiaryDto',
      json,
      ($checkedConvert) {
        final val = _BeneficiaryDto(
          id: $checkedConvert('id', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          accountReference: $checkedConvert(
            'account_reference',
            (v) => v as String,
          ),
          bankName: $checkedConvert('bank_name', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'accountReference': 'account_reference',
        'bankName': 'bank_name',
      },
    );

Map<String, dynamic> _$BeneficiaryDtoToJson(_BeneficiaryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'account_reference': instance.accountReference,
      'bank_name': instance.bankName,
    };

_TransactionDto _$TransactionDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_TransactionDto', json, ($checkedConvert) {
      final val = _TransactionDto(
        id: $checkedConvert('id', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        amount: $checkedConvert(
          'amount',
          (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
        ),
        type: $checkedConvert('type', (v) => v as String),
        category: $checkedConvert('category', (v) => v as String),
        occurredAt: $checkedConvert(
          'occurred_at',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    }, fieldKeyMap: const {'occurredAt': 'occurred_at'});

Map<String, dynamic> _$TransactionDtoToJson(_TransactionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'amount': instance.amount.toJson(),
      'type': instance.type,
      'category': instance.category,
      'occurred_at': instance.occurredAt.toIso8601String(),
    };

_ExpensePeriodDto _$ExpensePeriodDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_ExpensePeriodDto', json, ($checkedConvert) {
      final val = _ExpensePeriodDto(
        from: $checkedConvert('from', (v) => v as String),
        to: $checkedConvert('to', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ExpensePeriodDtoToJson(_ExpensePeriodDto instance) =>
    <String, dynamic>{'from': instance.from, 'to': instance.to};

_CurrencyExpensesDto _$CurrencyExpensesDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CurrencyExpensesDto', json, ($checkedConvert) {
      final val = _CurrencyExpensesDto(
        total: $checkedConvert(
          'total',
          (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
        ),
        categories: $checkedConvert(
          'categories',
          (v) => (v as List<dynamic>)
              .map(
                (e) => CategoryExpenseDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CurrencyExpensesDtoToJson(
  _CurrencyExpensesDto instance,
) => <String, dynamic>{
  'total': instance.total.toJson(),
  'categories': instance.categories.map((e) => e.toJson()).toList(),
};

_CategoryExpenseDto _$CategoryExpenseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('_CategoryExpenseDto', json, ($checkedConvert) {
      final val = _CategoryExpenseDto(
        category: $checkedConvert('category', (v) => v as String),
        amount: $checkedConvert(
          'amount',
          (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$CategoryExpenseDtoToJson(_CategoryExpenseDto instance) =>
    <String, dynamic>{
      'category': instance.category,
      'amount': instance.amount.toJson(),
    };

_CurrencyComparisonDto _$CurrencyComparisonDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  '_CurrencyComparisonDto',
  json,
  ($checkedConvert) {
    final val = _CurrencyComparisonDto(
      currentTotal: $checkedConvert(
        'current_total',
        (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
      ),
      previousTotal: $checkedConvert(
        'previous_total',
        (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
      ),
      difference: $checkedConvert(
        'difference',
        (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
      ),
      change: $checkedConvert('change', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'currentTotal': 'current_total',
    'previousTotal': 'previous_total',
  },
);

Map<String, dynamic> _$CurrencyComparisonDtoToJson(
  _CurrencyComparisonDto instance,
) => <String, dynamic>{
  'current_total': instance.currentTotal.toJson(),
  'previous_total': instance.previousTotal.toJson(),
  'difference': instance.difference.toJson(),
  'change': instance.change,
};

TransferConfirmationSummaryDto _$TransferConfirmationSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('TransferConfirmationSummaryDto', json, ($checkedConvert) {
  final val = TransferConfirmationSummaryDto(
    amount: $checkedConvert(
      'amount',
      (v) => MoneyDto.fromJson(v as Map<String, dynamic>),
    ),
    beneficiary: $checkedConvert('beneficiary', (v) => v as String),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$TransferConfirmationSummaryDtoToJson(
  TransferConfirmationSummaryDto instance,
) => <String, dynamic>{
  'amount': instance.amount.toJson(),
  'beneficiary': instance.beneficiary,
  'type': instance.$type,
};

CardConfirmationSummaryDto _$CardConfirmationSummaryDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CardConfirmationSummaryDto', json, ($checkedConvert) {
  final val = CardConfirmationSummaryDto(
    card: $checkedConvert(
      'card',
      (v) => CardDto.fromJson(v as Map<String, dynamic>),
    ),
    $type: $checkedConvert('type', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {r'$type': 'type'});

Map<String, dynamic> _$CardConfirmationSummaryDtoToJson(
  CardConfirmationSummaryDto instance,
) => <String, dynamic>{'card': instance.card.toJson(), 'type': instance.$type};

_ConfirmationActionDto _$ConfirmationActionDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('_ConfirmationActionDto', json, ($checkedConvert) {
  final val = _ConfirmationActionDto(
    type: $checkedConvert('type', (v) => v as String),
    label: $checkedConvert('label', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$ConfirmationActionDtoToJson(
  _ConfirmationActionDto instance,
) => <String, dynamic>{'type': instance.type, 'label': instance.label};
