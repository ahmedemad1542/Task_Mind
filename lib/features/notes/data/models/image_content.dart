import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'note_content_base.dart';
import 'note_content_types.dart';

part 'image_content.g.dart';

@HiveType(typeId: 6)
class ImageContent extends NoteContent {
  @HiveField(0)
  @override
  final String id;

  @HiveField(1)
  @override
  final DateTime createdAt;

  @HiveField(2)
  @override
  final int order;

  @HiveField(3)
  @override
  final NoteContentType type;

  @HiveField(4)
  final String path;

  @HiveField(5)
  final String? caption;

  @HiveField(6)
  final double? width;

  @HiveField(7)
  final double? height;

  const ImageContent({
    required this.id,
    required this.createdAt,
    required this.order,
    required this.path,
    this.caption,
    this.width,
    this.height,
  }) : type = NoteContentType.image,
       super(
         id: id,
         type: NoteContentType.image,
         createdAt: createdAt,
         order: order,
       );
}
