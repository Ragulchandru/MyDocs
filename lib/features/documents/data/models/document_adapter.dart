// lib/features/documents/data/models/document_adapter.dart

import 'package:hive/hive.dart';
import '../../domain/models/document.dart';

class DocumentAdapter extends TypeAdapter<Document> {
  @override
  final int typeId = 100;

  @override
  Document read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Document(
      id: fields[0] as String,
      name: fields[1] as String,
      fileName: fields[2] as String,
      extension: fields[3] as String,
      filePath: fields[4] as String,
      fileType: DocumentType.values[fields[5] as int],
      fileSize: fields[6] as int,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      lastViewedPage: (fields[9] as int?) ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, Document obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.extension)
      ..writeByte(4)
      ..write(obj.filePath)
      ..writeByte(5)
      ..write(obj.fileType.index)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.lastViewedPage);
  }
}
