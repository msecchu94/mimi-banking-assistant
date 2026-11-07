import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/design_system/components/mimi_fab.dart';
import '../../../shared/design_system/mimi_tokens.dart';
import '../../chat/presentation/mimi_sheet/show_mimi_sheet.dart';
import 'home_mock_data.dart';
import 'widgets/account_summary_card.dart';
import 'widgets/balance_section.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions.dart';

/// Mobile Banking Home (DS-04), showing local mock data.
@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// FAB inset above the safe area, raised so the entry point sits closer to
  /// the Movimientos section instead of the screen's bottom edge.
  static const _fabBottom = MimiSpacing.xl4 + MimiSpacing.xl;

  /// Scroll space reserved below the content so the FAB never covers it.
  static const _fabClearance =
      MimiSpacing.minTouchTarget + _fabBottom + MimiSpacing.lg;

  /// Home's horizontal inset, a step tighter than the default screen inset
  /// so the banking content reads as one compact column.
  static const _inset = MimiSpacing.lg;

  /// Restrained teal depth behind the content: a soft lift behind the
  /// balance area and a faint glow toward the Mimi entry point.
  static const _depth = [
    BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A252A), MimiColors.background, Color(0xFF071C21)],
        stops: [0, 0.55, 1],
      ),
    ),
    BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(-0.7, -0.95),
        radius: 1.1,
        colors: [Color(0x1419C6B3), Color(0x0019C6B3)],
      ),
    ),
    BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(1, 1),
        radius: 0.9,
        colors: [Color(0x0F22D3C5), Color(0x0022D3C5)],
      ),
    ),
  ];

  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    const data = homeMockData;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            for (final decoration in _depth)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(decoration: decoration),
                ),
              ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  _inset,
                  MimiSpacing.sm,
                  _inset,
                  _fabClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(
                      firstName: data.firstName,
                      accountDescription: data.accountDescription,
                    ),
                    const SizedBox(height: MimiSpacing.xs),
                    BalanceSection(
                      currency: data.currency,
                      balance: data.balance,
                      isHidden: _balanceHidden,
                      onToggleVisibility: () =>
                          setState(() => _balanceHidden = !_balanceHidden),
                    ),
                    const SizedBox(height: MimiSpacing.lg),
                    const QuickActions(),
                    const SizedBox(height: MimiSpacing.lg),
                    AccountSummaryCard(account: data.account),
                    const SizedBox(height: MimiSpacing.xl),
                    RecentTransactions(transactions: data.transactions),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: _inset,
                    bottom: _fabBottom,
                  ),
                  child: MimiFab(onPressed: () => showMimiSheet(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
