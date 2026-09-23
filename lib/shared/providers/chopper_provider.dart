import 'package:chopper/chopper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/wiwit_api/analytics/txn_overview_response.dart';
import '../models/wiwit_api/auth/login_response.dart';
import '../models/wiwit_api/categories/category_list_response.dart';
import '../models/wiwit_api/categories/category_response.dart';
import '../models/wiwit_api/instance/instance_response.dart';
import '../models/wiwit_api/profile/profile_response.dart';
import '../models/wiwit_api/transactions/transaction_list_response.dart';
import '../models/wiwit_api/transactions/transaction_response.dart';
import '../services/apis/analytics_service.dart';
import '../services/apis/auth_service.dart';
import '../services/apis/category_service.dart';
import '../services/apis/instance_service.dart';
import '../services/apis/profile_service.dart';
import '../services/apis/transaction_service.dart';
import '../services/networking/auth_interceptor.dart';
import '../services/networking/json_serializable_converter.dart';
import '../services/networking/problem_details_interceptor.dart';
import 'auth_provider.dart';
import 'server_url_provider.dart';

part 'chopper_provider.g.dart';

/// Example: A missing server URL is a programming error.
Duration? _neverRetry(int retryCount, Object error) => null;

/// The single client every API service talks through.
@Riverpod(keepAlive: true, retry: _neverRetry)
ChopperClient chopperClient(Ref ref) {
  final serverUrl = ref.watch(serverUrlProvider).value;

  if (serverUrl == null || serverUrl.isEmpty) {
    throw StateError('No server URL configured.');
  }

  final converter = JsonSerializableConverter({
    TxnOverviewResponse: TxnOverviewResponse.fromJson,
    LoginResponse: LoginResponse.fromJson,
    CategoryListResponse: CategoryListResponse.fromJson,
    CategoryResponse: CategoryResponse.fromJson,
    TransactionListResponse: TransactionListResponse.fromJson,
    TransactionResponse: TransactionResponse.fromJson,
    ProfileResponse: ProfileResponse.fromJson,
    InstanceResponse: InstanceResponse.fromJson,
  });

  final client = ChopperClient(
    baseUrl: Uri.parse(serverUrl),
    services: [
      AuthService.create(),
      AnalyticsService.create(),
      CategoryService.create(),
      TransactionService.create(),
      ProfileService.create(),
      InstanceService.create(),
    ],
    converter: converter,
    errorConverter: converter,
    interceptors: [
      const ProblemDetailsInterceptor(),
      AuthInterceptor(
        readToken: () => ref.read(authTokenProvider.future),
        onUnauthorized: (token) =>
            ref.read(authTokenProvider.notifier).clearTokenIfMatches(token),
      ),
    ],
  );

  ref.onDispose(client.dispose);

  return client;
}

@Riverpod(keepAlive: true, retry: _neverRetry)
AuthService authService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<AuthService>();

@Riverpod(keepAlive: true, retry: _neverRetry)
AnalyticsService analyticsService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<AnalyticsService>();

@Riverpod(keepAlive: true, retry: _neverRetry)
CategoryService categoryService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<CategoryService>();

@Riverpod(keepAlive: true, retry: _neverRetry)
TransactionService transactionService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<TransactionService>();

@Riverpod(keepAlive: true, retry: _neverRetry)
ProfileService profileService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<ProfileService>();

@Riverpod(keepAlive: true, retry: _neverRetry)
InstanceService instanceService(Ref ref) =>
    ref.watch(chopperClientProvider).getService<InstanceService>();
