import 'package:json_annotation/json_annotation.dart';

part 'tag_request.g.dart';

/// Body for creating or updating a tag.
@JsonSerializable()
class TagRequest {
  final String name;
  final String? description;
  final String? color;

  const TagRequest({required this.name, this.description, this.color});

  factory TagRequest.fromJson(Map<String, dynamic> json) =>
      _$TagRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TagRequestToJson(this);
}
