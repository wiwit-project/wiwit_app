import 'dart:async';

import 'package:chopper/chopper.dart';

const _authorizationHeader = 'Authorization';

/// Adds the current bearer token for each requests.
class AuthInterceptor implements Interceptor {
  AuthInterceptor({required this.readToken, required this.onUnauthorized});

  /// Called before each request is sent.
  final Future<String?> Function() readToken;

  /// Called with the sent token after its request receives a 401.
  final Future<void> Function(String token) onUnauthorized;

  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
    Chain<BodyType> chain,
  ) async {
    final token = await readToken();

    if (token == null || token.isEmpty) return chain.proceed(chain.request);

    final response = await chain.proceed(
      applyHeader(chain.request, _authorizationHeader, 'Bearer $token'),
    );
    if (response.statusCode == 401) await onUnauthorized(token);
    return response;
  }
}
