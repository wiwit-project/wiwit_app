import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants.dart';
import 'chopper_provider.dart';
import 'storage_provider.dart';

part 'auth_provider.g.dart';

/// The bearer token for the current session, or `null` when signed out.
@Riverpod(keepAlive: true)
class AuthToken extends _$AuthToken {
  @override
  Future<String?> build() =>
      ref.watch(secureStorageProvider).read(key: kStoreApiBearerToken);

  Future<void> set(String token) async {
    await ref
        .read(secureStorageProvider)
        .write(key: kStoreApiBearerToken, value: token);

    state = AsyncData(token);
  }

  Future<void> clear() async {
    await ref.read(authServiceProvider).logout();
    await ref.read(secureStorageProvider).delete(key: kStoreApiBearerToken);

    state = const AsyncData(null);
  }

  /// Discards an expired session
  Future<void> clearTokenIfMatches(String token) async {
    if (state.value != token) return;

    await ref.read(secureStorageProvider).delete(key: kStoreApiBearerToken);
    if (state.value == token) state = const AsyncData(null);
  }
}

@Riverpod(keepAlive: true)
bool isAuthenticated(Ref ref) =>
    ref.watch(authTokenProvider).value?.isNotEmpty ?? false;
