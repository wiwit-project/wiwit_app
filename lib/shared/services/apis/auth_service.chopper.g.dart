// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'auth_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$AuthService extends AuthService {
  _$AuthService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = AuthService;

  @override
  Future<LoginResponse> login(LoginRequest body) async {
    final Uri $url = Uri.parse('/api/v1/auth/login');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    final Response<LoginResponse> $response = await client
        .send<LoginResponse, LoginResponse>($request);
    return $response.bodyOrThrow;
  }
}
