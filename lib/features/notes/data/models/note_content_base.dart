import 'package:equatable/equatable.dart';
import 'note_content_types.dart';

// Remove Hive annotations from abstract class
abstract class NoteContent extends Equatable {
  final String id;
  final NoteContentType type;
  final DateTime createdAt;
  final int order;

  const NoteContent({
    required this.id,
    required this.type,
    required this.createdAt,
    required this.order,
  });

  Map<String, dynamic> toJson();
  
  factory NoteContent.fromJson(Map<String, dynamic> json) {
    final type = NoteContentType.values[json['type']];
    switch (type) {
      case NoteContentType.text:
        // We'll import these dynamically to avoid circular imports
        throw UnimplementedError('Import TextContent.fromJson in your code');
      case NoteContentType.image:
        throw UnimplementedError('Import ImageContent.fromJson in your code');
      case NoteContentType.audio:
        throw UnimplementedError('Import AudioContent.fromJson in your code');
    }
  }

  @override
  List<Object?> get props => [id, type, createdAt, order];
}