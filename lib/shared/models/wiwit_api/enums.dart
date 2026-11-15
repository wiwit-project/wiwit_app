import 'package:json_annotation/json_annotation.dart';

/// Represents the transaction type
enum TransactionType { expense, income }

/// Represents the Problem Detail types
enum ProblemDetailType {
  @JsonValue("/problems/malformed-json")
  malformedJson("/problems/malformed-json"),
  @JsonValue("/problems/unauthenticated")
  unauthenticated("/problems/unauthenticated"),
  @JsonValue("/problems/insufficient-ability")
  insufficientAbility("/problems/insufficient-ability"),
  @JsonValue("/problems/not-found")
  notFound("/problems/not-found"),
  @JsonValue("/problems/conflict")
  conflict("/problems/conflict"),
  @JsonValue("/problems/unsupported-media-type")
  unsupportedMediaType("/problems/unsupported-media-type"),
  @JsonValue("/problems/validation-failed")
  validationFailed("/problems/validation-failed"),
  @JsonValue("/problems/too-many-requests")
  tooManyRequests("/problems/too-many-requests"),
  @JsonValue("/problems/internal-server-error")
  internalServerError("/problems/internal-server-error");

  ProblemDetailType(this.value);

  /// The problem detail title from API
  final String value;
}

/// Represents the ordering of the category list endpoint
enum CategorySort {
  @JsonValue("name")
  name("name"),
  @JsonValue("most_used")
  mostUsed("most_used");

  CategorySort(this.value);

  final String value;

  @override
  String toString() => value;
}
