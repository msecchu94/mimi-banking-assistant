import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter, lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/design_system/components/mimi_composer.dart';
import '../../../../shared/design_system/mimi_tokens.dart';
import '../../domain/models/chat_ui.dart';
import '../chat_controller.dart';
import '../chat_state.dart';
import '../conversation/chat_conversation.dart';
import 'measure_size.dart';
import 'mimi_presentation.dart';

/// Mimi as a bottom sheet with two detents over one shared conversation.
///
/// Compact fits the presentation and composer; expanded fills the screen
/// below the status bar. The pinned handle always drags the sheet; the
/// conversation hands drags over to the sheet when it cannot scroll further.
/// Dragging down from compact dismisses Mimi.
class MimiSheet extends ConsumerStatefulWidget {
  const MimiSheet({super.key, this.autofocusComposer = false});

  /// Demo aid: focus the composer once per opening, as soon as the
  /// conversation is ready for text, without expanding the sheet.
  ///
  /// Never while the conversation starts, a request is in flight, the latest
  /// reply awaits a tap (confirmation or card selection), or after the user
  /// collapsed the sheet.
  final bool autofocusComposer;

  /// The sheet's visible surface, whose height reflects the detent.
  static const surfaceKey = Key('mimi-sheet-surface');

  @override
  ConsumerState<MimiSheet> createState() => _MimiSheetState();
}

class _MimiSheetState extends ConsumerState<MimiSheet>
    with TickerProviderStateMixin {
  static const _handleHeight = MimiSpacing.minTouchTarget;

  /// Space below the last conversation entry, part of the compact detent.
  static const _conversationEndPadding = MimiSpacing.lg;
  static const _settleDuration = Duration(milliseconds: 260);
  static const _settleCurve = Curves.easeOutCubic;

  /// A release faster than this (logical px/s) picks the detent by direction.
  static const _flingVelocity = 600.0;

  /// Dragged this fraction of the compact height below compact, it closes.
  static const _dismissFraction = 0.25;

  /// Provisional glass recipe (DESIGN_SYSTEM.md §14.1, §14.3): ~24 px blur
  /// and a 1 px `textPrimary` outline at ~6%.
  static const _blurSigma = 12.0;
  static const _outline = BorderSide(color: Color(0x0FF4F8F8));

  /// 0 is compact, 1 is expanded.
  late final _expansion = AnimationController(
    vsync: this,
    duration: _settleDuration,
  );

  /// How far below compact the sheet is being dragged, in logical px.
  late final _dismissOffset = AnimationController.unbounded(
    vsync: this,
    duration: _settleDuration,
  );

  final _scroll = ScrollController();
  final _text = TextEditingController();
  final _focus = FocusNode();

  double? _presentationHeight;
  double _conversationHeight = 0;
  double? _composerHeight;
  double _compactHeight = 0;
  double _expandedHeight = 0;
  double _keyboardInset = 0;
  bool _handingOff = false;

  /// Whether this opening no longer auto-focuses the composer: it already
  /// did, or the user collapsed the sheet.
  bool _autofocusSettled = false;

  /// Set while the composer gains focus automatically, which must not expand
  /// the sheet.
  bool _autofocusing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus) return;
      if (_autofocusing) {
        _autofocusing = false;
        return;
      }
      _animateTo(expanded: true);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(chatControllerProvider);
      _maybeAutofocus(state);
      if (state is ChatInitial || state is ChatStartFailed) {
        ref.read(chatControllerProvider.notifier).start();
      }
      // Reopened on an existing conversation: show its latest entries.
      if (state is ChatActive && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _expansion.dispose();
    _dismissOffset.dispose();
    _scroll.dispose();
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  bool get _isExpanded => _expansion.value > 0.5;

  void _animateTo({required bool expanded}) {
    if (!expanded) {
      _autofocusSettled = true;
      _focus.unfocus();
    }
    _expansion.animateTo(expanded ? 1 : 0, curve: _settleCurve);
  }

  /// Moves the sheet with a drag of [dy] logical px (positive is downwards).
  void _dragBy(double dy) {
    if (_dismissOffset.value > 0 || (_expansion.value == 0 && dy > 0)) {
      _dismissOffset.value = math.max(0, _dismissOffset.value + dy);
      return;
    }
    final range = math.max(_expandedHeight - _compactHeight, 1);
    _expansion.value -= dy / range;
  }

  /// Settles on a detent, or closes, after a drag released at [velocity]
  /// logical px/s (positive is downwards).
  void _settle(double velocity) {
    if (_dismissOffset.value > 0) {
      final closes =
          velocity > _flingVelocity ||
          _dismissOffset.value > _compactHeight * _dismissFraction;
      if (closes) {
        Navigator.of(context).pop();
      } else {
        _dismissOffset.animateTo(0, curve: _settleCurve);
      }
      return;
    }
    final expand = velocity.abs() > _flingVelocity ? velocity < 0 : _isExpanded;
    _animateTo(expanded: expand);
  }

  /// Hands drags the conversation cannot use (at either end) to the sheet.
  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    switch (notification) {
      // Only overscroll from the user's drag, not from a scroll animation.
      case OverscrollNotification(:final overscroll, dragDetails: != null):
        _handingOff = true;
        _dragBy(-overscroll);
      case ScrollEndNotification(:final dragDetails) when _handingOff:
        _handingOff = false;
        _settle(dragDetails?.velocity.pixelsPerSecond.dy ?? 0);
      default:
    }
    return false;
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: _settleDuration,
        curve: _settleCurve,
      );
    });
  }

  /// Focuses the composer when [MimiSheet.autofocusComposer] applies to
  /// [state]; see there for when it does not.
  void _maybeAutofocus(ChatState state) {
    if (!widget.autofocusComposer || _autofocusSettled) return;
    if (state is! ChatActive || state.pendingAction != null) return;
    final awaitsTap = switch (state.latestReply?.ui) {
      ConfirmationUi() || CardSelectorUi() => true,
      _ => false,
    };
    if (awaitsTap) return;

    _autofocusSettled = true;
    if (_focus.hasFocus) return;
    _autofocusing = true;
    _focus.requestFocus();
    // Focus changes apply in a microtask queued by requestFocus; by now the
    // listener has seen it, or no change happened.
    scheduleMicrotask(() => _autofocusing = false);
  }

  void _send(String message) {
    ref.read(chatControllerProvider.notifier).sendMessage(message);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatControllerProvider, (previous, next) {
      if (next is ChatActive) _scrollToEnd();
      _maybeAutofocus(next);
      // A message that failed to send goes back to the composer.
      if (next case ChatActive(
        lastFailure: ChatActionFailure(
          action: SendMessageAction(:final message),
        ),
      )) {
        final isNew = previous is! ChatActive || previous.lastFailure == null;
        if (isNew && _text.text.isEmpty) _text.text = message;
      }
    });

    final state = ref.watch(chatControllerProvider);
    final canSend = state is ChatActive && state.pendingAction == null;
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;
    if (keyboardInset != _keyboardInset) {
      // The software keyboard appearing for the composer means typing:
      // expand, as focusing by tap does.
      final keyboardShown = _keyboardInset == 0 && keyboardInset > 0;
      _keyboardInset = keyboardInset;
      _scrollToEnd();
      if (keyboardShown && _focus.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _focus.hasFocus) _animateTo(expanded: true);
        });
      }
    }
    final composerBottom = keyboardInset > 0
        ? MimiSpacing.sm
        : math.max(media.padding.bottom, MimiSpacing.sm);

    final surface = ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(MimiRadius.xl),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
        child: DecoratedBox(
          key: MimiSheet.surfaceKey,
          decoration: const ShapeDecoration(
            color: MimiColors.surfaceGlassStrong,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(MimiRadius.xl),
              ),
              side: _outline,
            ),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _expansion,
                builder: (context, _) => _Handle(
                  height: _handleHeight,
                  expanded: _isExpanded,
                  onToggle: () => _animateTo(expanded: !_isExpanded),
                  onDrag: _dragBy,
                  onRelease: _settle,
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onScroll,
                  child: ListView(
                    controller: _scroll,
                    padding: EdgeInsets.zero,
                    // Clamping, so a drag past either end reaches the sheet
                    // as overscroll instead of bouncing.
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      MeasureSize(
                        onChange: (size) =>
                            setState(() => _presentationHeight = size.height),
                        child: const MimiPresentation(),
                      ),
                      MeasureSize(
                        onChange: (size) =>
                            setState(() => _conversationHeight = size.height),
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(
                            MimiSpacing.screenInset,
                            0,
                            MimiSpacing.screenInset,
                            _conversationEndPadding,
                          ),
                          child: ChatConversation(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MeasureSize(
                onChange: (size) =>
                    setState(() => _composerHeight = size.height),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MimiSpacing.screenInset,
                    MimiSpacing.sm,
                    MimiSpacing.screenInset,
                    composerBottom,
                  ),
                  child: MimiComposer(
                    controller: _text,
                    focusNode: _focus,
                    canSend: canSend,
                    onSend: _send,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        _expandedHeight =
            constraints.maxHeight - MimiSpacing.sm - keyboardInset;
        final presentation = _presentationHeight;
        final composer = _composerHeight;
        // Before the first exchange, compact also fits the conversation's
        // status or failure notice, so a retry stays reachable. Afterwards
        // it keeps the presentation's size and shows the latest entries.
        final conversation = state is ChatActive && state.transcript.isNotEmpty
            ? _conversationEndPadding
            : _conversationHeight;
        _compactHeight = math.min(
          presentation != null && composer != null
              ? _handleHeight + presentation + conversation + composer
              : constraints.maxHeight / 2,
          _expandedHeight,
        );

        return AnimatedBuilder(
          animation: Listenable.merge([_expansion, _dismissOffset]),
          builder: (context, child) => Padding(
            padding: EdgeInsets.only(bottom: keyboardInset),
            child: Transform.translate(
              offset: Offset(0, _dismissOffset.value),
              child: SizedBox(
                height: lerpDouble(
                  _compactHeight,
                  _expandedHeight,
                  _expansion.value,
                ),
                child: child,
              ),
            ),
          ),
          child: surface,
        );
      },
    );
  }
}

/// The pinned drag handle. Tapping it toggles the detent, which also gives
/// assistive technologies a non-drag way to resize the sheet.
class _Handle extends StatelessWidget {
  const _Handle({
    required this.height,
    required this.expanded,
    required this.onToggle,
    required this.onDrag,
    required this.onRelease,
  });

  /// Provisional handle bar geometry.
  static const _barWidth = 36.0;
  static const _barHeight = 4.0;

  final double height;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<double> onDrag;
  final ValueChanged<double> onRelease;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: expanded ? 'Contraer Mimi' : 'Expandir Mimi',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        onVerticalDragEnd: (details) =>
            onRelease(details.velocity.pixelsPerSecond.dy),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: MimiColors.textMuted,
                borderRadius: BorderRadius.circular(MimiRadius.full),
              ),
              child: const SizedBox(width: _barWidth, height: _barHeight),
            ),
          ),
        ),
      ),
    );
  }
}
