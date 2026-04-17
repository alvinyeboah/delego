import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class SyncService {
  constructor(private readonly prisma: PrismaService) {}

  async pull(workspaceId: string, sinceIso?: string) {
    const since = sinceIso ? new Date(sinceIso) : new Date(0);
    const tasks = await this.prisma.task.findMany({
      where: { workspaceId, updatedAt: { gt: since } },
      orderBy: { updatedAt: 'asc' },
    });
    return { tasks, checkpoint: new Date().toISOString() };
  }

  pushConflictRecord(input: {
    taskId: string;
    userId: string;
    localVersion: number;
    serverVersion: number;
    resolution?: string;
  }) {
    return this.prisma.conflictRecord.create({ data: input });
  }
}
