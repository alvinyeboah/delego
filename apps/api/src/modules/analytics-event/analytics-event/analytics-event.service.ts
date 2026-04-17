import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class AnalyticsEventService {
  constructor(private readonly prisma: PrismaService) {}

  publish(input: {
    tenantId: string;
    eventType: string;
    payload: Record<string, unknown>;
  }) {
    return this.prisma.domainEventOutbox.create({
      data: {
        ...input,
        payload: input.payload as Prisma.InputJsonValue,
      },
    });
  }
}
