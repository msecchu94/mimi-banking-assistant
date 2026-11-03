import 'package:flutter/widgets.dart';

import '../mimi_tokens.dart';
import '../mimi_typography.dart';

/// DS-03 List Item: a feature-agnostic row.
///
/// The primary [title] anchors the row; [leading], [description] and
/// [trailing] stay subordinate. The row carries no background: the container
/// decides it.
class MimiListItem extends StatelessWidget {
  const MimiListItem({
    super.key,
    required this.title,
    this.description,
    this.leading,
    this.trailing,
    this.titleMaxLines = 1,
  });

  final String title;
  final String? description;
  final Widget? leading;
  final Widget? trailing;

  /// Lines the [title] may wrap to before it is truncated.
  final int titleMaxLines;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final leading = this.leading;
    final trailing = this.trailing;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: MimiSpacing.minTouchTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MimiSpacing.lg,
          vertical: MimiSpacing.md,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading,
              const SizedBox(width: MimiSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: MimiTypography.bodyMedium.copyWith(
                      color: MimiColors.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: MimiSpacing.xs),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MimiTypography.caption.copyWith(
                        color: MimiColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: MimiSpacing.md),
              trailing,
            ],
          ],
        ),
      ),
    );
  }
}
