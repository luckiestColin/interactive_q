import 'package:json_annotation/json_annotation.dart';
import 'answer.dart';

part 'flowItem.g.dart';

@JsonSerializable(explicitToJson: true)
class FlowItem
{
  FlowItem({
    required this.itemId,
    required this.heading,
    this.lastAnswer,
    this.answers
  });
  @JsonKey(name: 'item_id')
  final int itemId;
  final String heading;
  @JsonKey(name: 'last_answer')
  int? lastAnswer;
  List<Answer>? answers;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory FlowItem.fromJson(Map<String, dynamic> json) => _$FlowItemFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$FlowItemToJson(this);
}
