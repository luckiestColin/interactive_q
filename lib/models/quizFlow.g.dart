// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quizFlow.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizFlow _$QuizFlowFromJson(Map<String, dynamic> json) {
  return QuizFlow(
    sections: (json['sections'] as List<dynamic>)
        .map((e) => Section.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$QuizFlowToJson(QuizFlow instance) => <String, dynamic>{
      'sections': instance.sections.map((e) => e.toJson()).toList(),
    };
