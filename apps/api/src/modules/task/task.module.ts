import { Module } from '@nestjs/common';
import { TaskController } from './task/task.controller';
import { TaskService } from './task/task.service';
import { TaskGateway } from './task/task.gateway';

@Module({
  controllers: [TaskController],
  providers: [TaskService, TaskGateway],
})
export class TaskModule {}
