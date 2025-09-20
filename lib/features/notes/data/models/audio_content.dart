import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'note_content_base.dart';
import 'note_content_types.dart';

part 'audio_content.g.dart';

@HiveType(typeId: 7)
class AudioContent extends NoteContent {
  @HiveField(4)
  final String path;

  @HiveField(5)
  final Duration duration;

  @HiveField(6)
  final String? title;

  const AudioContent({
    required super.id,
    required super.createdAt,
    required super.order,
    required this.path,
    required this.duration,
    this.title,
  }) : super(type: NoteContentType.audio);

  factory AudioContent.create({
    required String path,
    required int order,
    required Duration duration,
    String? title,
  }) {
    return AudioContent(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      order: order,
      path: path,
      duration: duration,
      title: title,
    );
  }

  AudioContent copyWith({
    String? id,
    DateTime? createdAt,
    int? order,
    String? path,
    Duration? duration,
    String? title,
  }) {
    return AudioContent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      path: path ?? this.path,
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

  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [...super.props, path, duration, title];
}