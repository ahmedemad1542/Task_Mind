// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_content_types.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteContentTypeAdapter extends TypeAdapter<NoteContentType> {
  @override
  final int typeId = 3;

  @override
  NoteContentType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteContentType.text;
      case 1:
        return NoteContentType.image;
      case 2:
        return NoteContentType.audio;
      default:
        return NoteContentType.text;
    }
  }

  @override
  void write(BinaryWriter writer, NoteContentType obj) {
    switch (obj) {
      case NoteContentType.text:
        writer.writeByte(0);
        break;
      case NoteContentType.image:
        writer.writeByte(1);
        break;
      case NoteContentType.audio:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteContentTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
