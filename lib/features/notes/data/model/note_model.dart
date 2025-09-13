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

  String get plainText {
    return contents
        .where((content) => content.type == NoteContentType.text)
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
}

@HiveType(typeId: 3)
enum NoteContentType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
  @HiveField(2)
  audio,
}

@HiveType(typeId: 4)
abstract class NoteContent extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final NoteContentType type;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
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
        return TextContent.fromJson(json);
      case NoteContentType.image:
        return ImageContent.fromJson(json);
      case NoteContentType.audio:
        return AudioContent.fromJson(json);
    }
  }

  @override
  List<Object?> get props => [id, type, createdAt, order];
}

@HiveType(typeId: 5)
class TextContent extends NoteContent {
  @HiveField(4)
  final String text;

  @HiveField(5)
  final Map<String, TextStyle> styles;

  const TextContent({
    required super.id,
    required super.createdAt,
    required super.order,
    required this.text,
    this.styles = const {},
  }) : super(type: NoteContentType.text);

  factory TextContent.create({
    required String text,
    required int order,
    Map<String, TextStyle> styles = const {},
  }) {
    return TextContent(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      order: order,
      text: text,
      styles: styles,
    );
  }

  TextContent copyWith({
    String? id,
    DateTime? createdAt,
    int? order,
    String? text,
    Map<String, TextStyle>? styles,
  }) {
    return TextContent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      text: text ?? this.text,
      styles: styles ?? this.styles,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
      'text': text,
      'styles': styles.map((key, value) => MapEntry(key, {
        'color': value.color?.value,
        'fontSize': value.fontSize,
        'fontWeight': value.fontWeight?.index,
        'fontStyle': value.fontStyle?.index,
        'decoration': value.decoration?.index,
      })),
    };
  }

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      order: json['order'] as int,
      text: json['text'] as String,
      styles: (json['styles'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          TextStyle(
            color: value['color'] != null ? Color(value['color']) : null,
            fontSize: value['fontSize']?.toDouble(),
            fontWeight: value['fontWeight'] != null 
                ? FontWeight.values[value['fontWeight']] 
                : null,
            fontStyle: value['fontStyle'] != null 
                ? FontStyle.values[value['fontStyle']] 
                : null,
            decoration: value['decoration'] != null 
                ? TextDecoration.values[value['decoration']] 
                : null,
          ),
        ),
      ) ?? {},
    );
  }

  @override
  List<Object?> get props => [...super.props, text, styles];
}

@HiveType(typeId: 6)
class ImageContent extends NoteContent {
  @HiveField(4)
  final String path;

  @HiveField(5)
  final String? caption;

  @HiveField(6)
  final double? width;

  @HiveField(7)
  final double? height;

  const ImageContent({
    required super.id,
    required super.createdAt,
    required super.order,
    required this.path,
    this.caption,
    this.width,
    this.height,
  }) : super(type: NoteContentType.image);

  factory ImageContent.create({
    required String path,
    required int order,
    String? caption,
    double? width,
    double? height,
  }) {
    return ImageContent(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      order: order,
      path: path,
      caption: caption,
      width: width,
      height: height,
    );
  }

  ImageContent copyWith({
    String? id,
    DateTime? createdAt,
    int? order,
    String? path,
    String? caption,
    double? width,
    double? height,
  }) {
    return ImageContent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
      path: path ?? this.path,
      caption: caption ?? this.caption,
      width: width ?? this.width,
      height: height ?? this.height,
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
      'caption': caption,
      'width': width,
      'height': height,
    };
  }

  factory ImageContent.fromJson(Map<String, dynamic> json) {
    return ImageContent(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      order: json['order'] as int,
      path: json['path'] as String,
      caption: json['caption'] as String?,
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [...super.props, path, caption, width, height];
}

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

  @override
  List<Object?> get props => [...super.props, path, duration, title];
}