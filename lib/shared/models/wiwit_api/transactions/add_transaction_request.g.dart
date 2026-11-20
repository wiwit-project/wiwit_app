// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddTransactionRequest _$AddTransactionRequestFromJson(
  Map<String, dynamic> json,
) => AddTransactionRequest(
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  categoryId: (json['category_id'] as num?)?.toInt(),
  tagIds:
      (json['tag_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const [],
  notes: json['notes'] as String?,
  transactionDate: DateTime.parse(json['transaction_date'] as String),
);

Map<String, dynamic> _$AddTransactionRequestToJson(
  AddTransactionRequest instance,
) => <String, dynamic>{
  'title': instance.title,
  'amount': instance.amount,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'category_id': instance.categoryId,
  'tag_ids': instance.tagIds,
  'notes': instance.notes,
  'transaction_date': AddTransactionRequest._dateOnly(instance.transactionDate),
};

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.income: 'income',
};
