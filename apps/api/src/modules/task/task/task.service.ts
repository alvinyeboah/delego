import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { TaskGateway } from './task.gateway';

@Injectable()
export class TaskService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskGateway: TaskGateway,
  ) {}

  list(workspaceId: string) {
    return this.prisma.task.findMany({
      where: { workspaceId },
      orderBy: { createdAt: 'desc' },
      include: { priorityScores: true, attachments: true, comments: true },
    });
  }

  create(input: {
    workspaceId: string;
    title: string;
    description?: string;
    priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  }) {
    return this.prisma.task.create({ data: input }).then((task: unknown) => {
      this.taskGateway.notifyTaskUpdated(task as Record<string, unknown>);
      return task;
    });
  }

  updateStatus(
    taskId: string,
    status:
      | 'OPEN'
      | 'IN_PROGRESS'
      | 'BLOCKED'
      | 'DONE'
      | 'CANCELLED'
      | 'REVIEW_REQUIRED',
    reason?: string,
  ) {
    return this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      const task = await tx.task.update({
        where: { id: taskId },
        data: { status, version: { increment: 1 } },
      });
      await tx.taskStatusHistory.create({ data: { taskId, status, reason } });
      this.taskGateway.notifyTaskUpdated(task as Record<string, unknown>);
      return task;
    });
  }
}
