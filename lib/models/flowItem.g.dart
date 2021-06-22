// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flowItem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlowItem _$FlowItemFromJson(Map<String, dynamic> json) {
  return FlowItem(
    itemId: json['item_id'] as int,
    heading: json['heading'] as String,
    lastAnswer: json['last_answer'] as int?,
    answers: (json['answers'] as List<dynamic>?)
        ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$FlowItemToJson(FlowItem instance) => <String, dynamic>{
      'item_id': instance.itemId,
      'heading': instance.heading,
      'last_answer': instance.lastAnswer,
      'answers': instance.answers?.map((e) => e.toJson()).toList(),
    };
