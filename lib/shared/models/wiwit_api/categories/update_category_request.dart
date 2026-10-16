import 'package:json_annotation/json_annotation.dart';

part 'update_category_request.g.dart';

@JsonSerializable(includeIfNull: false)
class UpdateCategoryRequest {
  final String? name;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  UpdateCategoryRequest({this.name, this.description, this.isActive});

  factory UpdateCategoryRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCategoryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCategoryRequestToJson(this);
}
