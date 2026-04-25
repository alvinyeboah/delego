import 'package:dio/dio.dart';

import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class MediaRepository {
  MediaRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<MediaUploadDto> uploadFile({required String filePath, String? filename}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: filename),
    });
    final response = await _apiClient.postMultipart('/media/upload', form);
    return MediaUploadDto.fromJson(asStringKeyedMap(response.data, 'POST /media/upload'));
  }

  Future<MediaUploadDto> uploadBytes({required List<int> bytes, required String filename}) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final response = await _apiClient.postMultipart('/media/upload', form);
    return MediaUploadDto.fromJson(asStringKeyedMap(response.data, 'POST /media/upload'));
  }
}
