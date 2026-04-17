import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class CaptureService {
  constructor(private readonly prisma: PrismaService) {}

  createSession(input: {
    workspaceId: string;
    createdById: string;
    latitude?: number;
    longitude?: number;
    deviceModel?: string;
    capturedAt?: string;
    imageStorageKey: string;
  }) {
    return this.prisma.captureSession.create({
      data: {
        workspaceId: input.workspaceId,
        createdById: input.createdById,
        images: {
          create: [{ storageKey: input.imageStorageKey }],
        },
        metadata: {
          create: {
            latitude: input.latitude,
            longitude: input.longitude,
            deviceModel: input.deviceModel,
            capturedAt: input.capturedAt
              ? new Date(input.capturedAt)
              : undefined,
          },
        },
      },
      include: { images: true, metadata: true },
    });
  }
}
