import 'package:json_annotation/json_annotation.dart';
import 'flowItem.dart';

part 'section.g.dart';

@JsonSerializable(explicitToJson: true)
class Section
{
  Section({
    required this.header,
    required this.flowItems
  });
  final String header;

  @JsonKey(name: 'flow_items')
  final List<FlowItem> flowItems;

  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Section.fromJson(Map<String, dynamic> json) => _$SectionFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$SectionToJson(this);
}
