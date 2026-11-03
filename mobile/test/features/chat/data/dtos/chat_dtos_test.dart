import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mimi/features/chat/data/dtos/chat_request_dto.dart';
import 'package:mimi/features/chat/data/dtos/chat_response_dto.dart';

import '../../chat_fixtures.dart';

void main() {
  group('request DTOs serialize to the contract shape', () {
    test('message', () {
      expect(
        const MessageRequestDto(
          conversationId: conversationId,
          message: '¿Cuánta plata tengo?',
        ).toJson(),
        {'conversation_id': conversationId, 'message': '¿Cuánta plata tengo?'},
      );
    });

    test('CONFIRM carries the operation id', () {
      expect(
        const ConfirmRequestDto(
          conversationId: conversationId,
          payload: ConfirmPayloadDto(operationId: operationId),
        ).toJson(),
        {
          'conversation_id': conversationId,
          'interaction': 'CONFIRM',
          'payload': {'operation_id': operationId},
        },
      );
    });

    test('CANCEL omits the payload', () {
      expect(const CancelRequestDto(conversationId: conversationId).toJson(), {
        'conversation_id': conversationId,
        'interaction': 'CANCEL',
      });
    });

    test('SELECT_CARD carries the card id', () {
      expect(
        const SelectCardRequestDto(
          conversationId: conversationId,
          payload: SelectCardPayloadDto(cardId: cardId),
        ).toJson(),
        {
          'conversation_id': conversationId,
          'interaction': 'SELECT_CARD',
          'payload': {'card_id': cardId},
        },
      );
    });
  });

  group('response DTOs', () {
    test('decode a started conversation', () {
      final dto = ConversationResponseDto.fromJson(conversationResponseJson);

      expect(dto.conversationId, conversationId);
      expect(dto.conversationState, 'READY');
      expect(dto.metadata.requestId, 'req-50dc23a1');
      expect(dto.metadata.timestamp, DateTime.utc(2026, 10, 9, 16, 30));
    });

    test('decode every contract ui type to its variant', () {
      final expectedTypes = [
        isA<TextUiDto>(),
        isA<CardListUiDto>(),
        isA<CardSelectorUiDto>(),
        isA<BeneficiaryListUiDto>(),
        isA<ConfirmationUiDto>(),
        isA<ConfirmationUiDto>(),
        isA<ExpenseSummaryUiDto>(),
        isA<ExpenseComparisonUiDto>(),
        isA<TransactionListUiDto>(),
        isA<TransferSummaryUiDto>(),
      ];

      for (final (index, ui) in uiExamples.indexed) {
        final dto = ChatResponseDto.fromJson(chatResponseJson(ui: ui));
        expect(dto.ui, expectedTypes[index], reason: '${ui['type']}');
      }
    });

    test('decode nested keys, including `from` and nullable bank_name', () {
      final summary =
          ChatResponseDto.fromJson(chatResponseJson(ui: expenseSummaryUiJson))
                  .ui
              as ExpenseSummaryUiDto;
      expect(summary.data.period.from, '2026-10-01');
      expect(
        summary.data.currencies.single.categories.single.category,
        'DINING',
      );

      final beneficiaries =
          ChatResponseDto.fromJson(chatResponseJson(ui: beneficiaryListUiJson))
                  .ui
              as BeneficiaryListUiDto;
      expect(beneficiaries.data.beneficiaries.single.bankName, isNull);
      expect(
        beneficiaries.data.beneficiaries.single.accountReference,
        '****4582',
      );
    });

    test('reject an unknown ui type', () {
      expect(
        () => ChatResponseDto.fromJson(
          chatResponseJson(ui: {'type': 'ERROR', 'data': <String, dynamic>{}}),
        ),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('reject a missing required field', () {
      final json = chatResponseJson()..remove('conversation_state');

      expect(
        () => ChatResponseDto.fromJson(json),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('reject money transported as a number', () {
      expect(
        () => ChatResponseDto.fromJson(
          chatResponseJson(
            ui: {
              'type': 'TRANSFER_SUMMARY',
              'data': {
                ...(transferSummaryUiJson['data']! as Map<String, dynamic>),
                'amount': {'amount': 25000.0, 'currency': 'ARS'},
              },
            },
          ),
        ),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });
  });
}
