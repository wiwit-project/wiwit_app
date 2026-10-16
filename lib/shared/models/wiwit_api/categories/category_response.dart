import 'package:json_annotation/json_annotation.dart';

part 'category_response.g.dart';

@JsonSerializable()
/// Represents the category response
class CategoryResponse {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'transactions_count')
  final int transactionsCount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  CategoryResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.transactionsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryResponseToJson(this);

  CategoryResponse copyWith({
    String? name,
    String? description,
    bool? isActive,
  }) => CategoryResponse(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    isActive: isActive ?? this.isActive,
    transactionsCount: transactionsCount,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  String toString() {
    return 'CategoryResponse(id: $id, name: $name, description: $description, isActive: $isActive)';
  }
}
