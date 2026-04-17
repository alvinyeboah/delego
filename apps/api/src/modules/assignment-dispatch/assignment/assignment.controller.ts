import { Body, Controller, Param, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { AssignmentService } from './assignment.service';

@Controller('assignment')
@UseGuards(JwtAuthGuard)
export class AssignmentController {
  constructor(private readonly assignmentService: AssignmentService) {}

  @Patch('task/:taskId')
  assignTask(
    @Param('taskId') taskId: string,
    @Body() body: { assigneeUserId: string },
  ) {
    return this.assignmentService.assignTask(taskId, body.assigneeUserId);
  }
}
