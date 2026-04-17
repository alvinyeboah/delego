import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { TaskGateway } from './task.gateway';
import { CreateTaskDto } from './dto/create-task.dto';

@Injectable()
export class TaskService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly taskGateway: TaskGateway,
  ) {}

  async list(workspaceId: string) {
    const tasks = await this.prisma.task.findMany({
      where: { workspaceId },
      orderBy: { createdAt: 'desc' },
      include: { priorityScores: true, attachments: true, comments: true },
    });
    return tasks.map((task) => ({
      id: task.id,
      workspaceId: task.workspaceId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeUserId: task.assigneeUserId,
      version: task.version,
      updatedAtIso: task.updatedAt.toISOString(),
      createdAtIso: task.createdAt.toISOString(),
    }));
  }

  async create(input: CreateTaskDto) {
    const task = await this.prisma.task.create({ data: input });
    const payload = {
      id: task.id,
      workspaceId: task.workspaceId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      assigneeUserId: task.assigneeUserId,
      version: task.version,
      updatedAtIso: task.updatedAt.toISOString(),
      createdAtIso: task.createdAt.toISOString(),
    };
    this.taskGateway.notifyTaskUpdated(payload);
    return payload;
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
      const payload = {
        id: task.id,
        workspaceId: task.workspaceId,
        title: task.title,
        description: task.description,
        status: task.status,
        priority: task.priority,
        assigneeUserId: task.assigneeUserId,
        version: task.version,
        updatedAtIso: task.updatedAt.toISOString(),
        createdAtIso: task.createdAt.toISOString(),
      };
      this.taskGateway.notifyTaskUpdated(payload);
      return payload;
    });
  }
}
