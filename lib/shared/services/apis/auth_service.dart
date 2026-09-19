import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/auth/login_request.dart';
import '../../models/wiwit_api/auth/login_response.dart';

part 'auth_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/auth')
abstract class AuthService extends ChopperService {
  static AuthService create([ChopperClient? client]) => _$AuthService(client);

  @POST(path: '/login')
  Future<LoginResponse> login(@Body() LoginRequest body);
}
