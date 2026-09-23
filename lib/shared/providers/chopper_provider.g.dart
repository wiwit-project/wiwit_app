// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chopper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single client every API service talks through.

@ProviderFor(chopperClient)
final chopperClientProvider = ChopperClientProvider._();

/// The single client every API service talks through.

final class ChopperClientProvider
    extends $FunctionalProvider<ChopperClient, ChopperClient, ChopperClient>
    with $Provider<ChopperClient> {
  /// The single client every API service talks through.
  ChopperClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'chopperClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chopperClientHash();

  @$internal
  @override
  $ProviderElement<ChopperClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChopperClient create(Ref ref) {
    return chopperClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChopperClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChopperClient>(value),
    );
  }
}

String _$chopperClientHash() => r'9f8b04bc2552c445cf3cf47cd4ea80e027477ddb';

@ProviderFor(authService)
final authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  AuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'authServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'b6c48e48d9487d892c0d1fec1e4c92f1a7d212cb';

@ProviderFor(analyticsService)
final analyticsServiceProvider = AnalyticsServiceProvider._();

final class AnalyticsServiceProvider
    extends
        $FunctionalProvider<
          AnalyticsService,
          AnalyticsService,
          AnalyticsService
        >
    with $Provider<AnalyticsService> {
  AnalyticsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'analyticsServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsServiceHash();

  @$internal
  @override
  $ProviderElement<AnalyticsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnalyticsService create(Ref ref) {
    return analyticsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnalyticsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnalyticsService>(value),
    );
  }
}

String _$analyticsServiceHash() => r'096e2c6cc13412bfdb7878d79da8afae9962b8a2';

@ProviderFor(categoryService)
final categoryServiceProvider = CategoryServiceProvider._();

final class CategoryServiceProvider
    extends
        $FunctionalProvider<CategoryService, CategoryService, CategoryService>
    with $Provider<CategoryService> {
  CategoryServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'categoryServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryServiceHash();

  @$internal
  @override
  $ProviderElement<CategoryService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryService create(Ref ref) {
    return categoryService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryService>(value),
    );
  }
}

String _$categoryServiceHash() => r'0f30b97b69cec31de8f8ff6d1aeebeb897bf3c93';

@ProviderFor(transactionService)
final transactionServiceProvider = TransactionServiceProvider._();

final class TransactionServiceProvider
    extends
        $FunctionalProvider<
          TransactionService,
          TransactionService,
          TransactionService
        >
    with $Provider<TransactionService> {
  TransactionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'transactionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionServiceHash();

  @$internal
  @override
  $ProviderElement<TransactionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionService create(Ref ref) {
    return transactionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionService>(value),
    );
  }
}

String _$transactionServiceHash() =>
    r'9fc521e183ce4fcdcab5e9d5924a1f9ca4c44e59';

@ProviderFor(profileService)
final profileServiceProvider = ProfileServiceProvider._();

final class ProfileServiceProvider
    extends $FunctionalProvider<ProfileService, ProfileService, ProfileService>
    with $Provider<ProfileService> {
  ProfileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'profileServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileServiceHash();

  @$internal
  @override
  $ProviderElement<ProfileService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProfileService create(Ref ref) {
    return profileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileService>(value),
    );
  }
}

String _$profileServiceHash() => r'8d24f3b9093f56c157ef5516b675e70b2c360174';

@ProviderFor(instanceService)
final instanceServiceProvider = InstanceServiceProvider._();

final class InstanceServiceProvider
    extends
        $FunctionalProvider<InstanceService, InstanceService, InstanceService>
    with $Provider<InstanceService> {
  InstanceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'instanceServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$instanceServiceHash();

  @$internal
  @override
  $ProviderElement<InstanceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InstanceService create(Ref ref) {
    return instanceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InstanceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InstanceService>(value),
    );
  }
}

String _$instanceServiceHash() => r'f0dffc25855b2e073db30364fb5f604a7019c735';
