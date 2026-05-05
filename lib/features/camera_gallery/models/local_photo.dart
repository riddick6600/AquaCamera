import 'package:equatable/equatable.dart';
import 'package:path/path.dart' as p;

final class LocalPhoto extends Equatable {
  const LocalPhoto({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.createdAt,
    required this.sizeBytes,
    this.width,
    this.height,
    this.source = 'camera',
  });

  factory LocalPhoto.fromJson(
    Map<String, dynamic> json, {
    required String imagesDirectoryPath,
  }) {
    final fileName = _readFileName(json);

    return LocalPhoto(
      id: _requiredString(json, 'id'),
      fileName: fileName,
      filePath: p.join(imagesDirectoryPath, fileName),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
      sizeBytes: _requiredInt(json, 'sizeBytes'),
      width: _nullableInt(json['width']),
      height: _nullableInt(json['height']),
      source: json['source'] as String? ?? 'camera',
    );
  }

  final String id;
  final String fileName;
  final String filePath;
  final DateTime createdAt;
  final int sizeBytes;
  final int? width;
  final int? height;
  final String source;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'sizeBytes': sizeBytes,
      'width': width,
      'height': height,
      'source': source,
    };
  }

  @override
  List<Object?> get props => [
    id,
    fileName,
    filePath,
    createdAt,
    sizeBytes,
    width,
    height,
    source,
  ];

  static String _readFileName(Map<String, dynamic> json) {
    final fileName = json['fileName'];
    if (fileName is String && fileName.isNotEmpty) {
      return p.basename(fileName);
    }

    // Миграция старого формата метаданных, где сохранялся абсолютный путь.
    final legacyFilePath = _requiredString(json, 'filePath');
    return p.basename(legacyFilePath);
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    throw FormatException('Некорректное поле "$key" в метаданных фото.');
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = _nullableInt(json[key]);
    if (value != null) {
      return value;
    }

    throw FormatException('Некорректное поле "$key" в метаданных фото.');
  }

  static int? _nullableInt(Object? value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }
}
