import 'package:flutter/material.dart';

import '../mimi_tokens.dart';
import '../mimi_typography.dart';

/// DS-03 Mimi Composer: conversational text entry and send action.
///
/// The text area grows with its content. Sending is available only when there
/// is text and [canSend] allows it. No voice or attachments (V1).
class MimiComposer extends StatelessWidget {
  const MimiComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.focusNode,
    this.canSend = true,
    this.hintText = 'Preguntale algo a Mimi',
  });

  /// Provisional (DESIGN_SYSTEM.md §14.1): 1 px outline of `textPrimary` at
  /// ~6%, as on elevated cards.
  static const _outline = BorderSide(color: Color(0x0FF4F8F8));

  /// Provisional (§14.6), as in MimiIconButton.
  static const _iconSize = 20.0;

  final TextEditingController controller;
  final FocusNode? focusNode;

  /// Receives the trimmed text.
  final ValueChanged<String> onSend;
  final bool canSend;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text.trim();
        final sendAvailable = canSend && text.isNotEmpty;
        void send() {
          if (sendAvailable) onSend(text);
        }

        return DecoratedBox(
          decoration: const ShapeDecoration(
            color: MimiColors.surface,
            shape: StadiumBorder(side: _outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => send(),
                  cursorColor: MimiColors.primary,
                  style: MimiTypography.bodyLarge.copyWith(
                    color: MimiColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: MimiTypography.bodyLarge.copyWith(
                      color: MimiColors.textMuted,
                    ),
                    contentPadding: const EdgeInsets.fromLTRB(
                      MimiSpacing.xl,
                      MimiSpacing.md,
                      0,
                      MimiSpacing.md,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                enabled: sendAvailable,
                label: 'Enviar',
                excludeSemantics: true,
                child: InkResponse(
                  onTap: sendAvailable ? send : null,
                  child: SizedBox.square(
                    dimension: MimiSpacing.minTouchTarget,
                    child: Icon(
                      Icons.send_rounded,
                      size: _iconSize,
                      color: sendAvailable
                          ? MimiColors.primary
                          : MimiColors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
