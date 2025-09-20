import 'package:hive/hive.dart';

part 'note_content_types.g.dart';

@HiveType(typeId: 3)
enum NoteContentType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  audio,
}