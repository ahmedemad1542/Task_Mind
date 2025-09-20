// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImageContentAdapter extends TypeAdapter<ImageContent> {
  @override
  final int typeId = 6;

  @override
  ImageContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ImageContent(
      id: fields[0] as String,
      createdAt: fields[1] as DateTime,
      order: fields[2] as int,
      path: fields[4] as String,
      caption: fields[5] as String?,
      width: fields[6] as double?,
      height: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, ImageContent obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.order)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.path)
      ..writeByte(5)
      ..write(obj.caption)
      ..writeByte(6)
      ..write(obj.width)
      ..writeByte(7)
      ..write(obj.height);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
