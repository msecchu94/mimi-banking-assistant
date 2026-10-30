import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/error/failure.dart';
import 'package:mimi/core/error/failure_mapper.dart';
import 'package:mimi/core/network/network_exception.dart';

ApiErrorException _apiError(String code) =>
    ApiErrorException(statusCode: 409, code: code, requestId: 'req-1');

void main() {
  group('mapNetworkException', () {
    test('maps connection errors to ConnectionFailure', () {
      expect(
        mapNetworkException(const ConnectionException()),
        const ConnectionFailure(),
      );
    });

    test('maps API errors to BackendFailure with the contract code', () {
      expect(
        mapNetworkException(_apiError('PENDING_OPERATION_CONFLICT')),
        const BackendFailure(
          code: BackendErrorCode.pendingOperationConflict,
          requestId: 'req-1',
        ),
      );
    });

    test('decodes every error code of the contract', () {
      const contractCodes = {
        'INVALID_REQUEST': BackendErrorCode.invalidRequest,
        'INVALID_INTERACTION': BackendErrorCode.invalidInteraction,
        'CONVERSATION_NOT_FOUND': BackendErrorCode.conversationNotFound,
        'CONVERSATION_CLOSED': BackendErrorCode.conversationClosed,
        'ACCOUNT_NOT_FOUND': BackendErrorCode.accountNotFound,
        'CARD_NOT_FOUND': BackendErrorCode.cardNotFound,
        'BENEFICIARY_NOT_FOUND': BackendErrorCode.beneficiaryNotFound,
        'INSUFFICIENT_FUNDS': BackendErrorCode.insufficientFunds,
        'INVALID_AMOUNT': BackendErrorCode.invalidAmount,
        'INVALID_ACCOUNT_STATE': BackendErrorCode.invalidAccountState,
        'INVALID_CARD_STATE': BackendErrorCode.invalidCardState,
        'PENDING_OPERATION_CONFLICT': BackendErrorCode.pendingOperationConflict,
        'INVALID_CONVERSATION_STATE': BackendErrorCode.invalidConversationState,
        'INTERNAL_ERROR': BackendErrorCode.internalError,
        'SERVICE_UNAVAILABLE': BackendErrorCode.serviceUnavailable,
      };

      for (final MapEntry(key: wire, value: code) in contractCodes.entries) {
        expect(
          mapNetworkException(_apiError(wire)),
          isA<BackendFailure>().having((f) => f.code, 'code', code),
          reason: wire,
        );
      }
    });

    test('keeps a code added by the backend as unknown', () {
      expect(
        mapNetworkException(_apiError('NEW_BACKEND_CODE')),
        isA<BackendFailure>().having(
          (f) => f.code,
          'code',
          BackendErrorCode.unknown,
        ),
      );
    });

    test('maps unreadable responses and other errors to UnexpectedFailure', () {
      expect(
        mapNetworkException(const InvalidResponseException(statusCode: 502)),
        const UnexpectedFailure(),
      );
      expect(
        mapNetworkException(const UnknownNetworkException()),
        const UnexpectedFailure(),
      );
    });
  });
}
