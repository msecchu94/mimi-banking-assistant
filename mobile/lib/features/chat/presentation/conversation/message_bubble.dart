import 'package:flutter/material.dart';

import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';

enum MessageAuthor { user, mimi }

/// One conversational message. User messages sit on the trailing side with a
/// restrained `primary` tint; Mimi's sit on the leading side on `surface`.
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.author});

  /// Provisional: `primary` at ~16% fill and ~32% outline keeps the user's
  /// messages identifiable while `textPrimary` stays highly readable.
  static const _userFill = Color(0x2919C6B3);
  static const _userOutline = BorderSide(color: Color(0x5219C6B3));

  /// Provisional (DESIGN_SYSTEM.md §14.1), as on elevated cards.
  static const _mimiOutline = BorderSide(color: Color(0x0FF4F8F8));

  /// Bubbles leave room on the opposite side so authorship reads at a glance.
  static const _maxWidthFactor = 0.82;

  final String text;
  final MessageAuthor author;

  @override
  Widget build(BuildContext context) {
    final isUser = author == MessageAuthor.user;

    return Align(
      alignment: isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: _maxWidthFactor,
        alignment: isUser
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Align(
          alignment: isUser
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: isUser ? _userFill : MimiColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MimiRadius.lg),
                side: isUser ? _userOutline : _mimiOutline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MimiSpacing.lg,
                vertical: MimiSpacing.md,
              ),
              child: Text(
                text,
                style: MimiTypography.bodyLarge.copyWith(
                  color: MimiColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
