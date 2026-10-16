// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_category_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddCategoryRequest _$AddCategoryRequestFromJson(Map<String, dynamic> json) =>
    AddCategoryRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$AddCategoryRequestToJson(AddCategoryRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'is_active': instance.isActive,
    };
