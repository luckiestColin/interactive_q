import 'package:json_annotation/json_annotation.dart';
import 'profileColor.dart';

part 'profile.g.dart';

@JsonSerializable(explicitToJson: true)
class Profile
{
  Profile({
    required this.profileColors,
  });

  @JsonKey(name: 'profile_colors')
  final List<ProfileColor> profileColors;


  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
