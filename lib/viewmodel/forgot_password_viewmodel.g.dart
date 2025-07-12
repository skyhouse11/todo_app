// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(ForgotPasswordViewModel)
const forgotPasswordViewModelProvider = ForgotPasswordViewModelProvider._();

final class ForgotPasswordViewModelProvider
    extends $AsyncNotifierProvider<ForgotPasswordViewModel, void> {
  const ForgotPasswordViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordViewModelHash();

  @$internal
  @override
  ForgotPasswordViewModel create() => ForgotPasswordViewModel();
}

String _$forgotPasswordViewModelHash() =>
    r'ef16e0c044d34513debc7b5f88807be185213f75';

abstract class _$ForgotPasswordViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
