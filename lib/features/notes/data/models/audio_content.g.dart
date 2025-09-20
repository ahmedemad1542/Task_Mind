// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_content.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioContentAdapter extends TypeAdapter<AudioContent> {
  @override
  final int typeId = 7;

  @override
  AudioContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioContent(
      path: fields[4] as String,
      duration: fields[5] as Duration,
      title: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioContent obj) {
    writer
      ..writeByte(3)
      ..writeByte(4)
      ..write(obj.path)
      ..writeByte(5)
      ..write(obj.duration)
      ..writeByte(6)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
