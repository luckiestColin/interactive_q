// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profileColor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileColor _$ProfileColorFromJson(Map<String, dynamic> json) {
  return ProfileColor(
    ordinal: json['ordinal'] as int,
    argbValue: json['argb_value'] as int,
    name: json['name'] as String,
  );
}

Map<String, dynamic> _$ProfileColorToJson(ProfileColor instance) =>
    <String, dynamic>{
      'ordinal': instance.ordinal,
      'argb_value': instance.argbValue,
      'name': instance.name,
    };
