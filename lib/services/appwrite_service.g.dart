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

@ProviderFor(account)
const accountProvider = AccountProvider._();

final class AccountProvider
    extends $FunctionalProvider<Account, Account, Account>
    with $Provider<Account> {
  const AccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountHash();

  @$internal
  @override
  $ProviderElement<Account> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Account create(Ref ref) {
    return account(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Account value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Account>(value),
    );
  }
}

String _$accountHash() => r'b276aa167f7aeed32b67fbaf51d2012376334cff';

@ProviderFor(databases)
const databasesProvider = DatabasesProvider._();

final class DatabasesProvider
    extends $FunctionalProvider<Databases, Databases, Databases>
    with $Provider<Databases> {
  const DatabasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databasesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databasesHash();

  @$internal
  @override
  $ProviderElement<Databases> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Databases create(Ref ref) {
    return databases(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Databases value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Databases>(value),
    );
  }
}

String _$databasesHash() => r'4d7efcc53c029fd68fe7f12c7960d8993235153b';

@ProviderFor(storage)
const storageProvider = StorageProvider._();

final class StorageProvider
    extends $FunctionalProvider<Storage, Storage, Storage>
    with $Provider<Storage> {
  const StorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageHash();

  @$internal
  @override
  $ProviderElement<Storage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Storage create(Ref ref) {
    return storage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Storage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Storage>(value),
    );
  }
}

String _$storageHash() => r'4d1d7189f529eb7dc1c204fb31a988d49cd775d1';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
