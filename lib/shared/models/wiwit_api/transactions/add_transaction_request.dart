import 'package:json_annotation/json_annotation.dart';

import '../enums.dart';

part 'add_transaction_request.g.dart';

@JsonSerializable()
/// The Add Transaction request payload
class AddTransactionRequest {
  final String title;
  final double amount;
  final TransactionType type;
  @JsonKey(name: 'category_id')
  final int? categoryId;

  @JsonKey(name: 'tag_ids')
  final List<int> tagIds;
  final String? notes;
  @JsonKey(name: 'transaction_date', toJson: _dateOnly)
  final DateTime transactionDate;

  AddTransactionRequest({
    required this.title,
    required this.amount,
    required this.type,
    this.categoryId,
    this.tagIds = const [],
    this.notes,
    required this.transactionDate,
  });

  factory AddTransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddTransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddTransactionRequestToJson(this);

  static String _dateOnly(DateTime value) =>
      value.toIso8601String().split('T').first;
}
