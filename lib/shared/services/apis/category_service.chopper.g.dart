// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'category_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$CategoryService extends CategoryService {
  _$CategoryService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = CategoryService;

  @override
  Future<CategoryListResponse> getCategories({
    int? page,
    int? perPage,
    bool? showInactive,
    CategorySort? sort,
  }) async {
    final Uri $url = Uri.parse('/api/v1/categories');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'show_inactive': showInactive,
      'sort': sort,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response<CategoryListResponse> $response = await client
        .send<CategoryListResponse, CategoryListResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<CategoryResponse> createCategory(AddCategoryRequest body) async {
    final Uri $url = Uri.parse('/api/v1/categories');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    final Response<CategoryResponse> $response = await client
        .send<CategoryResponse, CategoryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<CategoryResponse> getCategory(int id) async {
    final Uri $url = Uri.parse('/api/v1/categories/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    final Response<CategoryResponse> $response = await client
        .send<CategoryResponse, CategoryResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<dynamic>> updateCategory(int id, UpdateCategoryRequest body) {
    final Uri $url = Uri.parse('/api/v1/categories/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    return client.send<dynamic, dynamic>($request);
  }

  @override
  Future<Response<dynamic>> deleteCategory(int id) {
    final Uri $url = Uri.parse('/api/v1/categories/${id}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
