import 'package:flutter/material.dart';

import '../../../../shared/design_system/components/mimi_button.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../../../shared/design_system/mimi_typography.dart';
import '../home_mock_data.dart';

/// The savings account the Home summarises, on a dark teal banking surface.
///
/// Only data the account summary actually carries is shown; no CBU or copy
/// action is rendered until that data exists.
class AccountSummaryCard extends StatelessWidget {
  const AccountSummaryCard({super.key, required this.account});

  static const _iconSize = 22.0;
  static const _iconTile = 44.0;
  static const _lineGap = 2.0;
  static const _verDatosLift = MimiSpacing.sm;

  static const _decoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF15393F), Color(0xFF0E2B30)],
    ),
    // `primary` at ~18%: a quiet teal edge, not a highlight.
    border: Border.fromBorderSide(BorderSide(color: Color(0x2E19C6B3))),
    borderRadius: BorderRadius.all(Radius.circular(MimiRadius.lg)),
    boxShadow: [
      BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );

  final HomeAccountSummary account;

  @override
  Widget build(BuildContext context) {
    final secondary = MimiTypography.labelMedium.copyWith(
      color: MimiColors.textSecondary,
    );

    return DecoratedBox(
      decoration: _decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MimiRadius.lg),
        child: CustomPaint(
          painter: const _WavePainter(),
          child: Padding(
            // "Ver datos" carries its own inset and 48 px target, so it closes
            // the card flush with the bottom edge and its label lines up with
            // the start inset; the other insets stay compact.
            padding: const EdgeInsetsDirectional.fromSTEB(
              MimiSpacing.lg,
              MimiSpacing.md,
              MimiSpacing.sm,
              0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: MimiColors.surface,
                    borderRadius: BorderRadius.all(
                      Radius.circular(MimiRadius.md),
                    ),
                  ),
                  child: SizedBox.square(
                    dimension: _iconTile,
                    child: Icon(
                      Icons.account_balance_outlined,
                      size: _iconSize,
                      color: MimiColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: MimiSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.title,
                        style: MimiTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: MimiColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: _lineGap),
                      Text(account.status, style: secondary),
                      const SizedBox(height: _lineGap),
                      Row(
                        children: [
                          Text('Alias:', style: secondary),
                          const SizedBox(width: MimiSpacing.xs),
                          Flexible(
                            child: Text(
                              account.alias,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: MimiTypography.labelMedium.copyWith(
                                color: MimiColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Account details are outside FL-06. Lifted into the
                      // empty top of its own 48 px target, clear of the wave,
                      // without changing the card's height.
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Transform.translate(
                          offset: const Offset(0, -_verDatosLift),
                          child: MimiButton(
                            label: 'Ver datos',
                            variant: MimiButtonVariant.text,
                            trailingIcon: Icons.chevron_right,
                            onPressed: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A faint teal swell along the card's lower edge; decorative only.
class _WavePainter extends CustomPainter {
  const _WavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.25, h * 0.66, w * 0.45, h * 0.98, w * 0.7, h * 0.86)
      ..cubicTo(w * 0.85, h * 0.79, w * 0.95, h * 0.82, w, h * 0.86)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0x0D19C6B3));
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => false;
}
