import 'package:flutter/widgets.dart';

import '../mimi_tokens.dart';
import '../mimi_typography.dart';

/// DS-03 List Item: a feature-agnostic row.
///
/// The primary [title] anchors the row; [description] and [trailing] stay
/// subordinate. The row carries no background: the container decides it.
class MimiListItem extends StatelessWidget {
  const MimiListItem({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
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
