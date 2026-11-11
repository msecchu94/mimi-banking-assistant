// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Home content loaded through [GetHomeSummary], or the failure that
/// prevented it. Failures are values, never thrown; invalidate to retry.
///
/// Reloads itself when Mimi reports a completed transfer, so Home shows the
/// backend's updated balance and transactions without waiting for the sheet
/// to close. Nothing is derived from the reply; it only signals that the
/// backend's data changed.

@ProviderFor(homeContent)
final homeContentProvider = HomeContentProvider._();

/// Home content loaded through [GetHomeSummary], or the failure that
/// prevented it. Failures are values, never thrown; invalidate to retry.
///
/// Reloads itself when Mimi reports a completed transfer, so Home shows the
/// backend's updated balance and transactions without waiting for the sheet
/// to close. Nothing is derived from the reply; it only signals that the
/// backend's data changed.

final class HomeContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<Either<Failure, HomeViewData>>,
          Either<Failure, HomeViewData>,
          FutureOr<Either<Failure, HomeViewData>>
        >
    with
        $FutureModifier<Either<Failure, HomeViewData>>,
        $FutureProvider<Either<Failure, HomeViewData>> {
  /// Home content loaded through [GetHomeSummary], or the failure that
  /// prevented it. Failures are values, never thrown; invalidate to retry.
  ///
  /// Reloads itself when Mimi reports a completed transfer, so Home shows the
  /// backend's updated balance and transactions without waiting for the sheet
  /// to close. Nothing is derived from the reply; it only signals that the
  /// backend's data changed.
  HomeContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeContentProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeContentHash();

  @$internal
  @override
  $FutureProviderElement<Either<Failure, HomeViewData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Either<Failure, HomeViewData>> create(Ref ref) {
    return homeContent(ref);
  }
}

String _$homeContentHash() => r'd52a3f7ea8795073b6c514ea736f44a51edb5e3b';
