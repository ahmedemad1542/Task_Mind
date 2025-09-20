import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'note_content_base.dart';
import 'note_content_types.dart';
import 'text_content.dart';

part 'note_model.g.dart';

@HiveType(typeId: 2)
class NoteModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final List<NoteContent> contents;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final bool isPinned;

  @HiveField(8)
  final Color? color;

  const NoteModel({
    required this.id,
    required this.title,
    required this.category,
    required this.contents,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.isPinned = false,
    this.color,
  });

  factory NoteModel.create({
    required String title,
    required String category,
    List<NoteContent> contents = const [],
    List<String> tags = const [],
    bool isPinned = false,
    Color? color,
  }) {
    final now = DateTime.now();
    return NoteModel(
      id: const Uuid().v4(),
      title: title,
      category: category,
      contents: contents,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      isPinned: isPinned,
      color: color,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? category,
    List<NoteContent>? contents,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? isPinned,
    Color? color,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      contents: contents ?? this.contents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'contents': contents.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'color': color?.value,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      contents: (json['contents'] as List<dynamic>)
          .map((e) => NoteContent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isPinned: json['isPinned'] as bool? ?? false,
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }

  // Helper methods
  String get plainText {
    return contents
        .where((content) => content is TextContent)
        .map((content) => (content as TextContent).text)
        .join(' ');
  }

  int get wordCount {
    return plainText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }

  int get characterCount {
    return plainText.length;
  }

  bool get hasImages {
    return contents.any((content) => content.type == NoteContentType.image);
  }

  bool get hasAudio {
    return contents.any((content) => content.type == NoteContentType.audio);
  }

  int get imageCount {
    return contents.where((content) => content.type == NoteContentType.image).length;
  }

  int get audioCount {
    return contents.where((content) => content.type == NoteContentType.audio).length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        contents,
        createdAt,
        updatedAt,
        tags,
        isPinned,
        color,
      ];
} ?? this.path,
      duration: duration ?? this.duration,
      title: title ?? this.title,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
      'path': path,
      'duration': duration.inMilliseconds,
      'title': title,
    };
  }

  factory AudioContent.fromJson(Map<String, dynamic> json) {
    return AudioContent(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      order: json['order'] as int,
      path: json['path'] as String,
      duration: Duration(milliseconds: json['duration']),
      title: json['title'] as String?,
    );
  }

  @override
  List<Object?> get props => [...super.props, path, duration, title];
}