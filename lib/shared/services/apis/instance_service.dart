import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/instance/instance_response.dart';

part 'instance_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/instance')
abstract class InstanceService extends ChopperService {
  static InstanceService create([ChopperClient? client]) =>
      _$InstanceService(client);

  @GET()
  Future<InstanceResponse> getInstance();
}
