class CaptureService {
  Future<Map<String, Object?>> prepareCapturePayload({
    required String imageStorageKey,
    double? latitude,
    double? longitude,
    String? deviceModel,
  }) async {
    return {
      'imageStorageKey': imageStorageKey,
      'latitude': latitude,
      'longitude': longitude,
      'deviceModel': deviceModel,
      'capturedAt': DateTime.now().toIso8601String(),
    };
  }
}
