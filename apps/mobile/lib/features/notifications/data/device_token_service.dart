import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceTokenService {
  static const _k = 'delego_device_push_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String> getOrCreateToken() async {
    final existing = await _storage.read(key: _k);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    const uuid = Uuid();
    final token = 'delego-${uuid.v4()}';
    await _storage.write(key: _k, value: token);
    return token;
  }

  Future<void> resetToken() async {
    await _storage.delete(key: _k);
  }
}
