import { BadGatewayException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class CaptureService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

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

  async runWorkerPipeline(storageKey: string): Promise<unknown> {
    const raw = this.config.get<string>('WORKER_URL', 'http://127.0.0.1:3010');
    const base = raw.replace(/\/+$/, '');
    const url = `${base}/simulate/capture`;
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ storageKey }),
    });
    const text = await res.text();
    let body: unknown;
    try {
      body = text ? JSON.parse(text) : null;
    } catch {
      body = text;
    }
    if (!res.ok) {
      throw new BadGatewayException({
        message: 'Worker pipeline request failed',
        status: res.status,
        body,
      });
    }
    return body;
  }
}
