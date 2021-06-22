// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'section.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Section _$SectionFromJson(Map<String, dynamic> json) {
  return Section(
    header: json['header'] as String,
    flowItems: (json['flow_items'] as List<dynamic>)
        .map((e) => FlowItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$SectionToJson(Section instance) => <String, dynamic>{
      'header': instance.header,
      'flow_items': instance.flowItems.map((e) => e.toJson()).toList(),
    };
