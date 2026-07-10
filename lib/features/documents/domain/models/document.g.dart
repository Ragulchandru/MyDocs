// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentImpl _$$DocumentImplFromJson(Map<String, dynamic> json) =>
    _$DocumentImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      fileName: json['fileName'] as String,
      extension: json['extension'] as String,
      filePath: json['filePath'] as String,
      fileType: $enumDecode(_$DocumentTypeEnumMap, json['fileType']),
      fileSize: (json['fileSize'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastViewedPage: (json['lastViewedPage'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$DocumentImplToJson(_$DocumentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'fileName': instance.fileName,
      'extension': instance.extension,
      'filePath': instance.filePath,
      'fileType': _$DocumentTypeEnumMap[instance.fileType]!,
      'fileSize': instance.fileSize,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastViewedPage': instance.lastViewedPage,
    };

const _$DocumentTypeEnumMap = {
  DocumentType.pdf: 'pdf',
  DocumentType.image: 'image',
};
