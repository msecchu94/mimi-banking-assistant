import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/network/network_exception.dart';
import 'package:mimi/features/chat/data/dtos/chat_response_dto.dart';
import 'package:mimi/features/chat/data/mappers/chat_dto_mapper.dart';
import 'package:mimi/features/chat/domain/models/chat_reply.dart';
import 'package:mimi/features/chat/domain/models/chat_ui.dart';
import 'package:mimi/features/chat/domain/models/conversation.dart';
import 'package:mimi/features/chat/domain/models/money.dart';

import '../../chat_fixtures.dart';

ChatReply _reply(Map<String, dynamic> json) =>
    chatReplyFromDto(ChatResponseDto.fromJson(json));

ChatUi _ui(Map<String, dynamic> ui) => _reply(chatResponseJson(ui: ui)).ui;

Money _ars(String amount) => Money(amount: amount, currency: Currency.ars);

const _card = BankCard(
  id: cardId,
  brand: CardBrand.visa,
  type: CardType.debit,
  lastFour: '4821',
  status: CardStatus.active,
);

final _invalidResponse = throwsA(isA<InvalidResponseException>());

void main() {
  test('maps a started conversation', () {
    expect(
      conversationFromDto(
        ConversationResponseDto.fromJson(conversationResponseJson),
      ),
      const Conversation(id: conversationId, state: ConversationState.ready),
    );
  });

  test('maps the reply envelope', () {
    final reply = _reply(
      chatResponseJson(
        intent: 'FREEZE_CARD',
        conversationState: 'COLLECTING_DATA',
        ui: cardSelectorUiJson,
      ),
    );

    expect(reply.conversationId, conversationId);
    expect(reply.message, 'Your available balance is 120000.00 ARS.');
    expect(reply.intent, ChatIntent.freezeCard);
    expect(reply.conversationState, ConversationState.collectingData);
    expect(reply.ui, const ChatUi.cardSelector(cards: [_card]));
  });

  group('maps each ui type', () {
    test('TEXT and CARD_LIST', () {
      expect(_ui(textUiJson), const ChatUi.text());
      expect(_ui(cardListUiJson), const ChatUi.cardList(cards: [_card]));
    });

    test('BENEFICIARY_LIST', () {
      expect(
        _ui(beneficiaryListUiJson),
        const ChatUi.beneficiaryList(
          beneficiaries: [
            Beneficiary(
              id: 'b43b2bd2-ef66-46a7-93b5-b617ee28c40e',
              name: 'Laura',
              accountReference: '****4582',
              bankName: null,
            ),
          ],
        ),
      );
    });

    test('CONFIRMATION with a transfer or card summary', () {
      const actions = [
        ConfirmationAction(
          type: ConfirmationActionType.confirm,
          label: 'Confirm',
        ),
        ConfirmationAction(
          type: ConfirmationActionType.cancel,
          label: 'Cancel',
        ),
      ];
      expect(
        _ui(transferConfirmationUiJson),
        ChatUi.confirmation(
          operationId: operationId,
          title: 'Confirm transfer',
          summary: ConfirmationSummary.transfer(
            amount: _ars('25000.00'),
            beneficiary: 'Laura',
          ),
          actions: actions,
        ),
      );

      final card = _ui(cardConfirmationUiJson) as ConfirmationUi;
      expect(card.summary, const ConfirmationSummary.card(card: _card));
    });

    test('EXPENSE_SUMMARY with dates as UTC calendar days', () {
      expect(
        _ui(expenseSummaryUiJson),
        ChatUi.expenseSummary(
          period: ExpensePeriod(
            from: DateTime.utc(2026, 10, 1),
            to: DateTime.utc(2026, 10, 31),
          ),
          currencies: [
            CurrencyExpenses(
              total: _ars('185000.00'),
              categories: [
                CategoryExpense(
                  category: TransactionCategory.dining,
                  amount: _ars('85000.00'),
                ),
              ],
            ),
          ],
        ),
      );
    });

    test('EXPENSE_COMPARISON keeps the backend direction', () {
      expect(
        _ui(expenseComparisonUiJson),
        ChatUi.expenseComparison(
          currentPeriod: ExpensePeriod(
            from: DateTime.utc(2026, 10, 1),
            to: DateTime.utc(2026, 10, 31),
          ),
          previousPeriod: ExpensePeriod(
            from: DateTime.utc(2026, 9, 1),
            to: DateTime.utc(2026, 9, 30),
          ),
          currencies: [
            CurrencyComparison(
              currentTotal: _ars('185000.00'),
              previousTotal: _ars('160000.00'),
              difference: _ars('25000.00'),
              change: ExpenseChange.increase,
            ),
          ],
        ),
      );
    });

    test('TRANSACTION_LIST', () {
      expect(
        _ui(transactionListUiJson),
        ChatUi.transactionList(
          transactions: [
            Transaction(
              id: '9eab44a2-c710-4a0c-beb7-c24de95a9820',
              description: 'Supermarket',
              amount: _ars('24500.00'),
              type: TransactionType.debit,
              category: TransactionCategory.groceries,
              occurredAt: DateTime.utc(2026, 10, 8, 18, 30),
            ),
          ],
        ),
      );
    });

    test('TRANSFER_SUMMARY', () {
      expect(
        _ui(transferSummaryUiJson),
        ChatUi.transferSummary(
          transferId: 'c919db94-a92f-4bc5-9355-32e90a10c632',
          beneficiary: 'Laura',
          amount: _ars('25000.00'),
          status: TransferStatus.completed,
          executedAt: DateTime.utc(2026, 10, 9, 16, 30),
        ),
      );
    });
  });

  group('rejects values outside the contract', () {
    Map<String, dynamic> transferSummary(Map<String, dynamic> changes) =>
        chatResponseJson(
          ui: {
            'type': 'TRANSFER_SUMMARY',
            'data': {
              ...(transferSummaryUiJson['data']! as Map<String, dynamic>),
              ...changes,
            },
          },
        );

    test('an unknown intent or conversation state', () {
      expect(
        () => _reply(chatResponseJson(intent: 'OPEN_ACCOUNT')),
        _invalidResponse,
      );
      expect(
        () => _reply(chatResponseJson(conversationState: 'CLOSED')),
        _invalidResponse,
      );
    });

    test('an amount without exactly two decimals', () {
      for (final amount in ['25000', '25000.5', '25000.000', '1e3', '']) {
        expect(
          () => _reply(
            transferSummary({
              'amount': {'amount': amount, 'currency': 'ARS'},
            }),
          ),
          _invalidResponse,
          reason: amount,
        );
      }
    });

    test('an unknown currency', () {
      expect(
        () => _reply(
          transferSummary({
            'amount': {'amount': '1.00', 'currency': 'EUR'},
          }),
        ),
        _invalidResponse,
      );
    });

    test('a timestamp without timezone', () {
      expect(
        () => _reply(transferSummary({'executed_at': '2026-10-09T16:30:00'})),
        _invalidResponse,
      );
    });

    test('a malformed or impossible period date', () {
      for (final date in ['2026-02-30', '2026-10-01T00:00:00Z', '01/10/2026']) {
        expect(
          () => _reply(
            chatResponseJson(
              ui: {
                'type': 'EXPENSE_SUMMARY',
                'data': {
                  'period': {'from': date, 'to': '2026-10-31'},
                  'currencies': <Object>[],
                },
              },
            ),
          ),
          _invalidResponse,
          reason: date,
        );
      }
    });
  });

  test('keeps negative amounts as supplied by the backend', () {
    expect(_ars('-150.25').amount, '-150.25');
  });
}
