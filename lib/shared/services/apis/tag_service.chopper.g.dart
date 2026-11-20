// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'tag_service.dart';

// **************************************************************************
// ChopperGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
final class _$TagService extends TagService {
  _$TagService([ChopperClient? client]) {
    if (client == null) return;
    this.client = client;
  }

  @override
  final Type definitionType = TagService;

  @override
  Future<TagListResponse> getTags({int? page, int? perPage}) async {
    final Uri $url = Uri.parse('/api/v1/tags');
    final Map<String, dynamic> $params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    final Request $request = Request(
      'GET',
      $url,
      client.baseUrl,
      parameters: $params,
    );
    final Response<TagListResponse> $response = await client
        .send<TagListResponse, TagListResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<TagResponse> createTag(TagRequest body) async {
    final Uri $url = Uri.parse('/api/v1/tags');
    final $body = body;
    final Request $request = Request('POST', $url, client.baseUrl, body: $body);
    final Response<TagResponse> $response = await client
        .send<TagResponse, TagResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<TagResponse> getTag(int id) async {
    final Uri $url = Uri.parse('/api/v1/tags/${id}');
    final Request $request = Request('GET', $url, client.baseUrl);
    final Response<TagResponse> $response = await client
        .send<TagResponse, TagResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<TagResponse> updateTag(int id, TagRequest body) async {
    final Uri $url = Uri.parse('/api/v1/tags/${id}');
    final $body = body;
    final Request $request = Request(
      'PATCH',
      $url,
      client.baseUrl,
      body: $body,
    );
    final Response<TagResponse> $response = await client
        .send<TagResponse, TagResponse>($request);
    return $response.bodyOrThrow;
  }

  @override
  Future<Response<dynamic>> deleteTag(int id) {
    final Uri $url = Uri.parse('/api/v1/tags/${id}');
    final Request $request = Request('DELETE', $url, client.baseUrl);
    return client.send<dynamic, dynamic>($request);
  }
}
