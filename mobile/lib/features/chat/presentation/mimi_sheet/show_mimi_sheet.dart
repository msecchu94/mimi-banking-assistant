import 'package:flutter/material.dart';

import 'mimi_sheet.dart';

/// Provisional: `background` at ~60% dims, without blurring, what is behind
/// Mimi, so the banking screen stays recognisable.
const _barrierColor = Color(0x99071A1F);

/// Demo aid, off by default: build with
/// `--dart-define=MIMI_COMPOSER_AUTOFOCUS=true` to focus the composer when
/// Mimi opens (see [MimiSheet.autofocusComposer]).
const _autofocusComposer = bool.fromEnvironment('MIMI_COMPOSER_AUTOFOCUS');

/// Opens Mimi over the current screen, in its compact detent.
///
/// Mimi is a modal sheet, not a navigation destination; it continues the
/// shared conversation each time it opens.
Future<void> showMimiSheet(
  BuildContext context, {
  bool autofocusComposer = _autofocusComposer,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  // MimiSheet owns its drag behavior and detents.
  enableDrag: false,
  backgroundColor: Colors.transparent,
  elevation: 0,
  barrierColor: _barrierColor,
  barrierLabel: 'Cerrar Mimi',
  builder: (_) => MimiSheet(autofocusComposer: autofocusComposer),
);
