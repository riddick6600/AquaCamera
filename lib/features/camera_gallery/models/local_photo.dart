import 'package:equatable/equatable.dart';

class LocalPhoto extends Equatable {
  const LocalPhoto({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.sizeBytes,
    this.width,
    this.height,
    this.source = 'camera',
  });

  factory LocalPhoto.fromJson(Map<String, dynamic> json) {
    return LocalPhoto(
      id: _requiredString(json, 'id'),
      filePath: _requiredString(json, 'filePath'),
      createdAt: DateTime.parse(_requiredString(json, 'createdAt')),
      sizeBytes: _requiredInt(json, 'sizeBytes'),
      width: _nullableInt(json['width']),
      height: _nullableInt(json['height']),
      source: json['source'] as String? ?? 'camera',
    );
  }

  final String id;
  final String filePath;
  final DateTime createdAt;
  final int sizeBytes;
  final int? width;
  final int? height;
  final String source;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
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
    filePath,
    createdAt,
    sizeBytes,
    width,
    height,
    source,
  ];
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }

  throw FormatException('Некорректное поле "$key" в метаданных фото.');
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = _nullableInt(json[key]);
  if (value != null) {
    return value;
  }

  throw FormatException('Некорректное поле "$key" в метаданных фото.');
}

int? _nullableInt(Object? value) {
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
