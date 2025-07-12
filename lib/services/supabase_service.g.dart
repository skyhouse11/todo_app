// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(supabaseService)
const supabaseServiceProvider = SupabaseServiceProvider._();

final class SupabaseServiceProvider
    extends
        $FunctionalProvider<SupabaseService, SupabaseService, SupabaseService>
    with $Provider<SupabaseService> {
  const SupabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseServiceHash();

  @$internal
  @override
  $ProviderElement<SupabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseService create(Ref ref) {
    return supabaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseService>(value),
    );
  }
}

String _$supabaseServiceHash() => r'457a2e091e7a8f200bef1fa16fb8f065e8f5ee7d';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
