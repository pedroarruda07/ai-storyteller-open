import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
part 'story.g.dart';

@HiveType(typeId: 0)
class Story {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final DateTime creationDate;

  @HiveField(3)
  final Uint8List? photo;

  Story({
    required this.title,
    required this.text,
    required this.creationDate,
    this.photo,
  });

  factory Story.fromJson(Map<String, dynamic> json, Uint8List? photo) {
    return Story(
      title: json['Title'],
      text: json['Text'],
      creationDate: DateTime.now(),
      photo: photo
    );
  }

  @override
  String toString(){
   return "title: $title\ntext: $text";
  }
}