// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagRequest _$TagRequestFromJson(Map<String, dynamic> json) => TagRequest(
  name: json['name'] as String,
  description: json['description'] as String?,
  color: json['color'] as String?,
);

Map<String, dynamic> _$TagRequestToJson(TagRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'color': instance.color,
    };
