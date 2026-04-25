import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_providers.dart';
import 'capture/data/capture_repository.dart';
import 'media/data/media_repository.dart';
import 'notifications/data/device_token_repository.dart';
import 'compliance/data/analytics_repository.dart';
import 'compliance/data/audit_repository.dart';
import 'notifications/data/device_token_service.dart';
import 'notifications/data/notification_repository.dart';
import 'sync/data/sync_queue_repository.dart';
import 'sync/data/sync_repository.dart';
import 'tenant/data/tenant_repository.dart';

final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  return CaptureRepository(ref.read(apiClientProvider));
});

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(ref.read(apiClientProvider));
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>((ref) {
  return SyncQueueRepository();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(apiClientProvider));
});

final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  return TenantRepository(ref.read(apiClientProvider));
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepository(ref.read(apiClientProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.read(apiClientProvider));
});

final deviceTokenServiceProvider = Provider<DeviceTokenService>((ref) {
  return DeviceTokenService();
});

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepository(ref.read(apiClientProvider));
});

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>((ref) {
  return DeviceTokenRepository(ref.read(apiClientProvider));
});
