import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/error/failure.dart';
import '../../../shared/design_system/components/mimi_button.dart';
import '../../../shared/design_system/components/mimi_fab.dart';
import '../../../shared/design_system/mimi_tokens.dart';
import '../../../shared/design_system/mimi_typography.dart';
import '../../chat/presentation/mimi_sheet/show_mimi_sheet.dart';
import 'home_controller.dart';
import 'home_view_data.dart';
import 'widgets/account_summary_card.dart';
import 'widgets/balance_section.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions.dart';

/// Mobile Banking Home (DS-04), showing the customer's ARS account from the
/// backend.
@RoutePage()
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
    final content = ref.watch(homeContentProvider);

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
                    const HomeHeader(
                      firstName: homeFirstName,
                      accountDescription: homeAccountDescription,
                    ),
                    const SizedBox(height: MimiSpacing.xs),
                    ...switch (content) {
                      // Loaded content stays while it refreshes; only a first
                      // load or a retry after a failure shows the spinner.
                      AsyncData(value: Right(value: final data)) => _loaded(
                        data,
                      ),
                      AsyncValue(isLoading: true) => const [_HomeLoading()],
                      AsyncData(value: Left(value: final failure)) => [
                        _HomeError(failure: failure, onRetry: _retry),
                      ],
                      _ => [
                        _HomeError(
                          failure: const UnexpectedFailure(),
                          onRetry: _retry,
                        ),
                      ],
                    },
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

  List<Widget> _loaded(HomeViewData data) => [
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
  ];

  void _retry() => ref.invalidate(homeContentProvider);
}

/// Holds the balance area's place while the account loads.
class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: MimiSpacing.xl4),
      child: Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Cargando tu cuenta',
          color: MimiColors.primary,
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MimiSpacing.xl),
      child: Column(
        children: [
          Text(
            homeFailureMessage(failure),
            textAlign: TextAlign.center,
            style: MimiTypography.bodyMedium.copyWith(
              color: MimiColors.textSecondary,
            ),
          ),
          const SizedBox(height: MimiSpacing.md),
          MimiButton(
            label: 'Reintentar',
            variant: MimiButtonVariant.secondary,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

/// What the user is told when Home cannot load.
String homeFailureMessage(Failure failure) => switch (failure) {
  ConnectionFailure() =>
    'No pudimos conectarnos. Revisá tu conexión e intentá de nuevo.',
  _ => 'No pudimos cargar tu cuenta. Intentá de nuevo.',
};
