import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/profile/profile_response.dart';

part 'profile_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/profile')
abstract class ProfileService extends ChopperService {
  static ProfileService create([ChopperClient? client]) =>
      _$ProfileService(client);

  @GET()
  Future<ProfileResponse> getProfile();
}
