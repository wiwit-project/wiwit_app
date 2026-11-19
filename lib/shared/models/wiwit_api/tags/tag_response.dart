import 'package:json_annotation/json_annotation.dart';

part 'tag_response.g.dart';

@JsonSerializable()
class TagResponse {
  final int id;
  final String name;
  final String? description;
  final String? color;
  @JsonKey(name: 'transactions_count')
  final int transactionsCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const TagResponse({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.transactionsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TagResponse.fromJson(Map<String, dynamic> json) =>
      _$TagResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TagResponseToJson(this);
}
