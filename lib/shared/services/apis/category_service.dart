import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/categories/add_category_request.dart';
import '../../models/wiwit_api/categories/category_list_response.dart';
import '../../models/wiwit_api/categories/category_response.dart';
import '../../models/wiwit_api/categories/update_category_request.dart';
import '../../models/wiwit_api/enums.dart';

part 'category_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/categories')
abstract class CategoryService extends ChopperService {
  static CategoryService create([ChopperClient? client]) =>
      _$CategoryService(client);

  @GET()
  Future<CategoryListResponse> getCategories({
    @Query() int? page,
    @Query('per_page') int? perPage,
    @Query('show_inactive') bool? showInactive,
    @Query('sort') CategorySort? sort,
  });

  @POST()
  Future<CategoryResponse> createCategory(@Body() AddCategoryRequest body);

  @GET(path: '/{id}')
  Future<CategoryResponse> getCategory(@Path() int id);

  @PATCH(path: '/{id}')
  Future<Response> updateCategory(
    @Path() int id,
    @Body() UpdateCategoryRequest body,
  );

  @DELETE(path: '/{id}')
  Future<Response> deleteCategory(@Path() int id);
}
