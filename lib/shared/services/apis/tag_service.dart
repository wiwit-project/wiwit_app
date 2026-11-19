import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/tags/tag_list_response.dart';
import '../../models/wiwit_api/tags/tag_request.dart';
import '../../models/wiwit_api/tags/tag_response.dart';

part 'tag_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/tags')
abstract class TagService extends ChopperService {
  static TagService create([ChopperClient? client]) => _$TagService(client);

  @GET()
  Future<TagListResponse> getTags({
    @Query() int? page,
    @Query('per_page') int? perPage,
  });

  @POST()
  Future<TagResponse> createTag(@Body() TagRequest body);

  @GET(path: '/{id}')
  Future<TagResponse> getTag(@Path() int id);

  @PATCH(path: '/{id}')
  Future<TagResponse> updateTag(@Path() int id, @Body() TagRequest body);

  @DELETE(path: '/{id}')
  Future<Response> deleteTag(@Path() int id);
}
