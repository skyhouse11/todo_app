// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'init_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(InitViewModel)
const initViewModelProvider = InitViewModelProvider._();

final class InitViewModelProvider
    extends $NotifierProvider<InitViewModel, void> {
  const InitViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initViewModelHash();

  @$internal
  @override
  InitViewModel create() => InitViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$initViewModelHash() => r'06f135213f48dd8f6393a49765ff92abc3288c5e';

abstract class _$InitViewModel extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
