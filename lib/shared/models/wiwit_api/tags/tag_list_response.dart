import 'package:json_annotation/json_annotation.dart';

import '../pagination_meta.dart';
import 'tag_response.dart';

part 'tag_list_response.g.dart';

@JsonSerializable()
class TagListResponse {
  final List<TagResponse> data;
  final PaginationMeta meta;

  const TagListResponse({required this.data, required this.meta});

  factory TagListResponse.fromJson(Map<String, dynamic> json) =>
      _$TagListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TagListResponseToJson(this);
}
