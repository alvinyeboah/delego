import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class AssignmentService {
  constructor(private readonly prisma: PrismaService) {}

  assignTask(taskId: string, assigneeUserId: string) {
    return this.prisma.task.update({
      where: { id: taskId },
      data: {
        assigneeUserId,
        version: { increment: 1 },
      },
    });
  }
}
