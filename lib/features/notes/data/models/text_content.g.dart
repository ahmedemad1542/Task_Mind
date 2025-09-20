// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TextContentAdapter extends TypeAdapter<TextContent> {
  @override
  final int typeId = 5;

  @override
  TextContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TextContent(
      text: fields[4] as String,
      styles: (fields[5] as Map).cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TextContent obj) {
    writer
      ..writeByte(2)
      ..writeByte(4)
      ..write(obj.text)
      ..writeByte(5)
      ..write(obj.styles);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
