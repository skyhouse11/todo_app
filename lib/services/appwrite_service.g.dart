// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appwrite_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(appwriteService)
const appwriteServiceProvider = AppwriteServiceProvider._();

final class AppwriteServiceProvider
    extends
        $FunctionalProvider<AppwriteService, AppwriteService, AppwriteService>
    with $Provider<AppwriteService> {
  const AppwriteServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appwriteServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appwriteServiceHash();

  @$internal
  @override
  $ProviderElement<AppwriteService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppwriteService create(Ref ref) {
    return appwriteService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppwriteService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppwriteService>(value),
    );
  }
}

String _$appwriteServiceHash() => r'65304aa7dccea86d796f658507547bf573d47bb6';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
