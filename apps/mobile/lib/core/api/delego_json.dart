/// Helpers to parse Nest/Prisma JSON shapes without guessing or silent fallbacks.
String? parseOptionalIso(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is DateTime) return value.toIso8601String();
  return null;
}

String parseRequiredIso(dynamic value, String fieldName) {
  final s = parseOptionalIso(value);
  if (s == null || s.isEmpty) {
    throw FormatException('Missing or invalid ISO date for $fieldName');
  }
  return s;
}

int parseRequiredInt(dynamic value, String fieldName) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('Missing or invalid int for $fieldName');
}

String parseRequiredString(dynamic value, String fieldName) {
  if (value is String) return value;
  throw FormatException('Missing or invalid string for $fieldName');
}

String? parseOptionalString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

Map<String, dynamic> asStringKeyedMap(Object? value, String fieldName) {
  if (value is! Map) {
    throw FormatException('$fieldName must be a JSON object');
  }
  return Map<String, dynamic>.from(value);
}
