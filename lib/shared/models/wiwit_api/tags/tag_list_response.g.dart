// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagListResponse _$TagListResponseFromJson(Map<String, dynamic> json) =>
    TagListResponse(
      data: (json['data'] as List<dynamic>)
          .map((e) => TagResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TagListResponseToJson(TagListResponse instance) =>
    <String, dynamic>{'data': instance.data, 'meta': instance.meta};
