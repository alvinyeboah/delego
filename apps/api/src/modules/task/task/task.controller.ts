import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { TaskService } from './task.service';

@Controller('task')
@UseGuards(JwtAuthGuard)
export class TaskController {
  constructor(private readonly taskService: TaskService) {}

  @Get('workspace/:workspaceId')
  list(@Param('workspaceId') workspaceId: string) {
    return this.taskService.list(workspaceId);
  }

  @Post()
  create(
    @Body()
    body: {
      workspaceId: string;
      title: string;
      description?: string;
      priority?: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
    },
  ) {
    return this.taskService.create(body);
  }

  @Patch(':taskId/status')
  updateStatus(
    @Param('taskId') taskId: string,
    @Body()
    body: {
      status:
        | 'OPEN'
        | 'IN_PROGRESS'
        | 'BLOCKED'
        | 'DONE'
        | 'CANCELLED'
        | 'REVIEW_REQUIRED';
      reason?: string;
    },
  ) {
    return this.taskService.updateStatus(taskId, body.status, body.reason);
  }
}
