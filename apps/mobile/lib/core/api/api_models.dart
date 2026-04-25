import 'delego_json.dart';

/// Payload from `GET /auth/me` (JWT `validate` returns the decoded access-token claims).
class JwtMeDto {
  JwtMeDto({
    required this.sub,
    required this.email,
    required this.tenantId,
  });

  final String sub;
  final String email;
  final String tenantId;

  factory JwtMeDto.fromJson(Map<String, dynamic> json) {
    return JwtMeDto(
      sub: parseRequiredString(json['sub'], 'JwtMe.sub'),
      email: parseRequiredString(json['email'], 'JwtMe.email'),
      tenantId: parseRequiredString(json['tenantId'], 'JwtMe.tenantId'),
    );
  }
}

/// Prisma `Notification` row as returned by `GET /notification/:userId` and `POST /notification`.
class NotificationDto {
  NotificationDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.readAtIso,
    required this.createdAtIso,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String? readAtIso;
  final String createdAtIso;

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: parseRequiredString(json['id'], 'Notification.id'),
      userId: parseRequiredString(json['userId'], 'Notification.userId'),
      title: parseRequiredString(json['title'], 'Notification.title'),
      body: parseRequiredString(json['body'], 'Notification.body'),
      readAtIso: parseOptionalIso(json['readAt']),
      createdAtIso: parseRequiredIso(json['createdAt'], 'Notification.createdAt'),
    );
  }
}

/// Prisma `AuditLog` row as returned by `GET /audit/:tenantId` and `POST /audit`.
class AuditLogDto {
  AuditLogDto({
    required this.id,
    required this.tenantId,
    this.actorUserId,
    required this.action,
    required this.resource,
    this.resourceId,
    this.metadata,
    required this.createdAtIso,
  });

  final String id;
  final String tenantId;
  final String? actorUserId;
  final String action;
  final String resource;
  final String? resourceId;
  final Object? metadata;
  final String createdAtIso;

  factory AuditLogDto.fromJson(Map<String, dynamic> json) {
    return AuditLogDto(
      id: parseRequiredString(json['id'], 'AuditLog.id'),
      tenantId: parseRequiredString(json['tenantId'], 'AuditLog.tenantId'),
      actorUserId: parseOptionalString(json['actorUserId']),
      action: parseRequiredString(json['action'], 'AuditLog.action'),
      resource: parseRequiredString(json['resource'], 'AuditLog.resource'),
      resourceId: parseOptionalString(json['resourceId']),
      metadata: json['metadata'],
      createdAtIso: parseRequiredIso(json['createdAt'], 'AuditLog.createdAt'),
    );
  }
}

/// Prisma `DomainEventOutbox` row as returned by `POST /analytics-event`.
class DomainEventOutboxDto {
  DomainEventOutboxDto({
    required this.id,
    required this.tenantId,
    required this.eventType,
    required this.payload,
    this.processedAtIso,
    required this.createdAtIso,
  });

  final String id;
  final String tenantId;
  final String eventType;
  final Map<String, dynamic> payload;
  final String? processedAtIso;
  final String createdAtIso;

  factory DomainEventOutboxDto.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    if (rawPayload is! Map) {
      throw const FormatException('DomainEventOutbox.payload must be a JSON object');
    }
    return DomainEventOutboxDto(
      id: parseRequiredString(json['id'], 'DomainEventOutbox.id'),
      tenantId: parseRequiredString(json['tenantId'], 'DomainEventOutbox.tenantId'),
      eventType: parseRequiredString(json['eventType'], 'DomainEventOutbox.eventType'),
      payload: Map<String, dynamic>.from(rawPayload),
      processedAtIso: parseOptionalIso(json['processedAt']),
      createdAtIso: parseRequiredIso(json['createdAt'], 'DomainEventOutbox.createdAt'),
    );
  }
}

/// Prisma `ConflictRecord` row as returned by `POST /sync/conflict`.
class ConflictRecordDto {
  ConflictRecordDto({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.localVersion,
    required this.serverVersion,
    this.resolution,
    required this.createdAtIso,
  });

  final String id;
  final String taskId;
  final String userId;
  final int localVersion;
  final int serverVersion;
  final String? resolution;
  final String createdAtIso;

  factory ConflictRecordDto.fromJson(Map<String, dynamic> json) {
    return ConflictRecordDto(
      id: parseRequiredString(json['id'], 'ConflictRecord.id'),
      taskId: parseRequiredString(json['taskId'], 'ConflictRecord.taskId'),
      userId: parseRequiredString(json['userId'], 'ConflictRecord.userId'),
      localVersion: parseRequiredInt(json['localVersion'], 'ConflictRecord.localVersion'),
      serverVersion: parseRequiredInt(json['serverVersion'], 'ConflictRecord.serverVersion'),
      resolution: parseOptionalString(json['resolution']),
      createdAtIso: parseRequiredIso(json['createdAt'], 'ConflictRecord.createdAt'),
    );
  }
}

/// Prisma `CaptureImage` nested on capture session create.
class CaptureImageDto {
  CaptureImageDto({
    required this.id,
    required this.captureSessionId,
    required this.storageKey,
    this.ocrText,
    required this.createdAtIso,
  });

  final String id;
  final String captureSessionId;
  final String storageKey;
  final String? ocrText;
  final String createdAtIso;

  factory CaptureImageDto.fromJson(Map<String, dynamic> json) {
    return CaptureImageDto(
      id: parseRequiredString(json['id'], 'CaptureImage.id'),
      captureSessionId: parseRequiredString(json['captureSessionId'], 'CaptureImage.captureSessionId'),
      storageKey: parseRequiredString(json['storageKey'], 'CaptureImage.storageKey'),
      ocrText: parseOptionalString(json['ocrText']),
      createdAtIso: parseRequiredIso(json['createdAt'], 'CaptureImage.createdAt'),
    );
  }
}

/// Prisma `CaptureMetadata` nested on capture session create.
class CaptureMetadataDto {
  CaptureMetadataDto({
    required this.id,
    required this.captureSessionId,
    this.latitude,
    this.longitude,
    this.deviceModel,
    this.capturedAtIso,
  });

  final String id;
  final String captureSessionId;
  final double? latitude;
  final double? longitude;
  final String? deviceModel;
  final String? capturedAtIso;

  factory CaptureMetadataDto.fromJson(Map<String, dynamic> json) {
    return CaptureMetadataDto(
      id: parseRequiredString(json['id'], 'CaptureMetadata.id'),
      captureSessionId: parseRequiredString(json['captureSessionId'], 'CaptureMetadata.captureSessionId'),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      deviceModel: parseOptionalString(json['deviceModel']),
      capturedAtIso: parseOptionalIso(json['capturedAt']),
    );
  }
}

/// Prisma `CaptureSession` with `include: { images: true, metadata: true }` from `POST /capture/session`.
class OrganizationDto {
  OrganizationDto({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.createdAtIso,
    required this.updatedAtIso,
  });

  final String id;
  final String tenantId;
  final String name;
  final String createdAtIso;
  final String updatedAtIso;

  factory OrganizationDto.fromJson(Map<String, dynamic> json) {
    return OrganizationDto(
      id: parseRequiredString(json['id'], 'Organization.id'),
      tenantId: parseRequiredString(json['tenantId'], 'Organization.tenantId'),
      name: parseRequiredString(json['name'], 'Organization.name'),
      createdAtIso: parseRequiredIso(json['createdAt'], 'Organization.createdAt'),
      updatedAtIso: parseRequiredIso(json['updatedAt'], 'Organization.updatedAt'),
    );
  }
}

class WorkspaceDto {
  WorkspaceDto({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.createdAtIso,
    required this.updatedAtIso,
  });

  final String id;
  final String organizationId;
  final String name;
  final String createdAtIso;
  final String updatedAtIso;

  factory WorkspaceDto.fromJson(Map<String, dynamic> json) {
    return WorkspaceDto(
      id: parseRequiredString(json['id'], 'Workspace.id'),
      organizationId: parseRequiredString(json['organizationId'], 'Workspace.organizationId'),
      name: parseRequiredString(json['name'], 'Workspace.name'),
      createdAtIso: parseRequiredIso(json['createdAt'], 'Workspace.createdAt'),
      updatedAtIso: parseRequiredIso(json['updatedAt'], 'Workspace.updatedAt'),
    );
  }
}

class CaptureSessionDto {
  CaptureSessionDto({
    required this.id,
    required this.workspaceId,
    required this.createdById,
    required this.createdAtIso,
    required this.images,
    this.metadata,
  });

  final String id;
  final String workspaceId;
  final String createdById;
  final String createdAtIso;
  final List<CaptureImageDto> images;
  final CaptureMetadataDto? metadata;

  factory CaptureSessionDto.fromJson(Map<String, dynamic> json) {
    final imgs = (json['images'] as List<dynamic>?) ?? const [];
    final metaRaw = json['metadata'];
    return CaptureSessionDto(
      id: parseRequiredString(json['id'], 'CaptureSession.id'),
      workspaceId: parseRequiredString(json['workspaceId'], 'CaptureSession.workspaceId'),
      createdById: parseRequiredString(json['createdById'], 'CaptureSession.createdById'),
      createdAtIso: parseRequiredIso(json['createdAt'], 'CaptureSession.createdAt'),
      images: imgs
          .map((e) => CaptureImageDto.fromJson(asStringKeyedMap(e, 'CaptureSession.images[]')))
          .toList(),
      metadata: metaRaw == null
          ? null
          : CaptureMetadataDto.fromJson(asStringKeyedMap(metaRaw, 'CaptureSession.metadata')),
    );
  }
}

/// Response from `POST /media/upload`.
class MediaUploadDto {
  MediaUploadDto({
    required this.storageKey,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedBy,
  });

  final String storageKey;
  final String mimeType;
  final int sizeBytes;
  final String uploadedBy;

  factory MediaUploadDto.fromJson(Map<String, dynamic> json) {
    return MediaUploadDto(
      storageKey: parseRequiredString(json['storageKey'], 'MediaUpload.storageKey'),
      mimeType: parseRequiredString(json['mimeType'], 'MediaUpload.mimeType'),
      sizeBytes: parseRequiredInt(json['sizeBytes'], 'MediaUpload.sizeBytes'),
      uploadedBy: parseRequiredString(json['uploadedBy'], 'MediaUpload.uploadedBy'),
    );
  }
}

/// Prisma `DeviceToken` from `GET /device-tokens` / `POST /device-tokens`.
class DeviceTokenDto {
  DeviceTokenDto({
    required this.id,
    required this.userId,
    required this.token,
    required this.platform,
    required this.createdAtIso,
  });

  final String id;
  final String userId;
  final String token;
  final String platform;
  final String createdAtIso;

  factory DeviceTokenDto.fromJson(Map<String, dynamic> json) {
    return DeviceTokenDto(
      id: parseRequiredString(json['id'], 'DeviceToken.id'),
      userId: parseRequiredString(json['userId'], 'DeviceToken.userId'),
      token: parseRequiredString(json['token'], 'DeviceToken.token'),
      platform: parseRequiredString(json['platform'], 'DeviceToken.platform'),
      createdAtIso: parseRequiredIso(json['createdAt'], 'DeviceToken.createdAt'),
    );
  }
}
