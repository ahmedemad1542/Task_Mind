import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'note_content_base.dart';
import 'note_content_types.dart';

part 'text_content.g.dart';

@HiveType(typeId: 5)
class TextContent extends NoteContent {
  @HiveField(4)
  final String text;

  @HiveField(5)
  final Map<String, String> styles; // Store as strings instead of TextStyle objects

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
    Map<String, String> styles = const {},
  }) {
    return TextContent(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      order: order,
      text: text,
      styles: styles,
    );
  }

  // Helper method to create TextContent with actual TextStyle objects
  factory TextContent.createWithStyles({
    required String text,
    required int order,
    Map<String, TextStyle> textStyles = const {},
  }) {
    final Map<String, String> serializedStyles = {};
    
    textStyles.forEach((key, style) {
      serializedStyles[key] = _serializeTextStyle(style);
    });

    return TextContent(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      order: order,
      text: text,
      styles: serializedStyles,
    );
  }

  TextContent copyWith({
    String? id,
    DateTime? createdAt,
    int? order,
    String? text,
    Map<String, String>? styles,
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
      'styles': styles,
    };
  }

  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      order: json['order'] as int,
      text: json['text'] as String,
      styles: Map<String, String>.from(json['styles'] ?? {}),
    );
  }

  // Helper methods for TextStyle conversion
  Map<String, TextStyle> get textStyles {
    final Map<String, TextStyle> result = {};
    styles.forEach((key, serialized) {
      result[key] = _deserializeTextStyle(serialized);
    });
    return result;
  }

  static String _serializeTextStyle(TextStyle style) {
    final Map<String, dynamic> data = {};
    
    if (style.color != null) data['color'] = style.color!.value;
    if (style.fontSize != null) data['fontSize'] = style.fontSize;
    if (style.fontWeight != null) data['fontWeight'] = style.fontWeight!.index;
    if (style.fontStyle != null) data['fontStyle'] = style.fontStyle!.index;
    if (style.decoration != null) {
      // Handle TextDecoration properly
      if (style.decoration == TextDecoration.none) data['decoration'] = 'none';
      else if (style.decoration == TextDecoration.underline) data['decoration'] = 'underline';
      else if (style.decoration == TextDecoration.overline) data['decoration'] = 'overline';
      else if (style.decoration == TextDecoration.lineThrough) data['decoration'] = 'lineThrough';
    }
    
    return data.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  static TextStyle _deserializeTextStyle(String serialized) {
    final Map<String, String> data = {};
    
    for (final pair in serialized.split(';')) {
      if (pair.isNotEmpty) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          data[parts[0]] = parts[1];
        }
      }
    }

    return TextStyle(
      color: data['color'] != null ? Color(int.parse(data['color']!)) : null,
      fontSize: data['fontSize'] != null ? double.parse(data['fontSize']!) : null,
      fontWeight: data['fontWeight'] != null ? FontWeight.values[int.parse(data['fontWeight']!)] : null,
      fontStyle: data['fontStyle'] != null ? FontStyle.values[int.parse(data['fontStyle']!)] : null,
      decoration: _parseTextDecoration(data['decoration']),
    );
  }

  static TextDecoration? _parseTextDecoration(String? decoration) {
    switch (decoration) {
      case 'none':
        return TextDecoration.none;
      case 'underline':
        return TextDecoration.underline;
      case 'overline':
        return TextDecoration.overline;
      case 'lineThrough':
        return TextDecoration.lineThrough;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [...super.props, text, styles];
}