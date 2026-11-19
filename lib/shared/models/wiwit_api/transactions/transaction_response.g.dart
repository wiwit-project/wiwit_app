// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
      amount: json['amount'] as String,
      category: json['category'] == null
          ? null
          : TransactionCategoryResponse.fromJson(
              json['category'] as Map<String, dynamic>,
            ),
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map(
                (e) =>
                    TransactionTagResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$TransactionResponseToJson(
  TransactionResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'amount': instance.amount,
  'category': instance.category,
  'tags': instance.tags,
  'notes': instance.notes,
  'transaction_date': instance.transactionDate.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};

TransactionCategoryResponse _$TransactionCategoryResponseFromJson(
  Map<String, dynamic> json,
) => TransactionCategoryResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$TransactionCategoryResponseToJson(
  TransactionCategoryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'is_active': instance.isActive,
};

TransactionTagResponse _$TransactionTagResponseFromJson(
  Map<String, dynamic> json,
) => TransactionTagResponse(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$TransactionTagResponseToJson(
  TransactionTagResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'color': instance.color,
};
