import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';
import '../../domain/models/chat_reply.dart';
import '../../domain/models/chat_ui.dart';
import '../chat_controller.dart';
import '../chat_state.dart';
import '../formatting/failure_message.dart';
import 'message_bubble.dart';
import 'replies/beneficiary_list_view.dart';
import 'replies/card_list_view.dart';
import 'replies/card_selector_view.dart';
import 'replies/confirmation_view.dart';
import 'replies/expense_comparison_view.dart';
import 'replies/expense_summary_view.dart';
import 'replies/transaction_list_view.dart';
import 'replies/transfer_summary_view.dart';

/// The conversation with Mimi, rendered from the shared [ChatState].
class ChatConversation extends ConsumerWidget {
  const ChatConversation({super.key});

  /// Provisional: a message waiting for its reply is shown slightly muted.
  static const _sendingOpacity = 0.72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatControllerProvider);
    final controller = ref.read(chatControllerProvider.notifier);

    final children = switch (state) {
      ChatInitial() ||
      ChatStarting() => [const _Status('Conectando con Mimi…')],
      ChatStartFailed() => [
        _Notice(
          message: 'No pudimos iniciar la conversación.',
          actionLabel: 'Reintentar',
          onAction: controller.start,
        ),
      ],
      final ChatActive active => [
        for (final (index, entry) in active.transcript.indexed)
          switch (entry) {
            UserMessage(:final text) => MessageBubble(
              text: text,
              author: MessageAuthor.user,
            ),
            AssistantReply(:final reply) => _AssistantReply(
              reply: reply,
              // Only the latest reply may act, and only while idle.
              actionable:
                  index == active.latestReplyIndex &&
                  active.pendingAction == null,
              controller: controller,
            ),
          },
        if (active.pendingAction case SendMessageAction(:final message))
          Opacity(
            opacity: _sendingOpacity,
            child: MessageBubble(text: message, author: MessageAuthor.user),
          ),
        if (active.pendingAction != null) const _Status('Mimi está pensando…'),
        if (active.lastFailure case ChatActionFailure(:final failure))
          _Notice(
            message: failureMessage(failure),
            actionLabel: endsConversation(failure)
                ? 'Nueva conversación'
                : null,
            onAction: controller.start,
          ),
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final child in children) ...[
          const SizedBox(height: MimiSpacing.md),
          child,
        ],
      ],
    );
  }
}

class _AssistantReply extends StatelessWidget {
  const _AssistantReply({
    required this.reply,
    required this.actionable,
    required this.controller,
  });

  final ChatReply reply;
  final bool actionable;
  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    // TEXT is the backend message alone.
    final structured = switch (reply.ui) {
      final ExpenseSummaryUi ui => ExpenseSummaryView(ui: ui),
      final ExpenseComparisonUi ui => ExpenseComparisonView(ui: ui),
      final CardListUi ui => CardListView(ui: ui),
      final TransactionListUi ui => TransactionListView(ui: ui),
      final BeneficiaryListUi ui => BeneficiaryListView(ui: ui),
      final TransferSummaryUi ui => TransferSummaryView(ui: ui),
      final ConfirmationUi ui => ConfirmationView(
        ui: ui,
        actionable: actionable,
        onConfirm: controller.confirm,
        onCancel: controller.cancel,
      ),
      final CardSelectorUi ui => CardSelectorView(
        ui: ui,
        actionable: actionable,
        onSelect: controller.selectCard,
      ),
      TextUi() => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MessageBubble(text: reply.message, author: MessageAuthor.mimi),
        if (structured != null) ...[
          const SizedBox(height: MimiSpacing.sm),
          structured,
        ],
      ],
    );
  }
}

/// A quiet line about what Mimi is doing. Static: motion is deferred.
class _Status extends StatelessWidget {
  const _Status(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '✦',
          style: MimiTypography.labelLarge.copyWith(color: MimiColors.primary),
        ),
        const SizedBox(width: MimiSpacing.sm),
        Flexible(
          child: Text(
            text,
            style: MimiTypography.bodyMedium.copyWith(
              color: MimiColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// A failure, stated with an icon and words rather than color alone.
class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.actionLabel, this.onAction});

  /// Provisional (DESIGN_SYSTEM.md §14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    final onAction = this.onAction;

    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          size: _iconSize,
          color: MimiColors.error,
        ),
        const SizedBox(width: MimiSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: MimiTypography.bodyMedium.copyWith(
              color: MimiColors.textPrimary,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          MimiButton(
            label: actionLabel,
            variant: MimiButtonVariant.text,
            onPressed: onAction,
          ),
      ],
    );
  }
}
