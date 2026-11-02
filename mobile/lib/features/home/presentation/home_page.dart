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
  /// Scroll space reserved below the content so the FAB never covers it.
  static const _fabClearance =
      MimiSpacing.minTouchTarget + MimiSpacing.lg + MimiSpacing.xl2;

  bool _balanceHidden = false;

  @override
  Widget build(BuildContext context) {
    const data = homeMockData;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  MimiSpacing.screenInset,
                  MimiSpacing.lg,
                  MimiSpacing.screenInset,
                  _fabClearance,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HomeHeader(
                      firstName: data.firstName,
                      accountDescription: data.accountDescription,
                    ),
                    const SizedBox(height: MimiSpacing.md),
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
                    const SizedBox(height: MimiSpacing.xl2),
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
                    end: MimiSpacing.screenInset,
                    bottom: MimiSpacing.lg,
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
