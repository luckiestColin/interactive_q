import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'flowItem.dart';

part 'profileColor.g.dart';

@JsonSerializable()
class ProfileColor{
  ProfileColor({
    required this.ordinal,
    required this.argbValue,
    required this.name
  });
  final int ordinal;

  @JsonKey(name: 'argb_value')
  final int argbValue;
  final String name;


  /// A necessary factory constructor for creating a new User instance
  /// from a map. Pass the map to the generated `_$UserFromJson()` constructor.
  /// The constructor is named after the source class, in this case, User.
  factory ProfileColor.fromJson(Map<String, dynamic> json) => _$ProfileColorFromJson(json);

  /// `toJson` is the convention for a class to declare support for serialization
  /// to JSON. The implementation simply calls the private, generated
  /// helper method `_$UserToJson`.
  Map<String, dynamic> toJson() => _$ProfileColorToJson(this);
}