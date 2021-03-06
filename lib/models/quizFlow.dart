import 'package:json_annotation/json_annotation.dart';
import 'section.dart';

part 'quizFlow.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizFlow
{
  QuizFlow({
    required this.sections,
  });
  final List<Section> sections;


  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory QuizFlow.fromJson(Map<String, dynamic> json) => _$QuizFlowFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$QuizFlowToJson(this);
}
