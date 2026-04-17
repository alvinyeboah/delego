import { Module } from '@nestjs/common';
import { AssignmentController } from './assignment/assignment.controller';
import { AssignmentService } from './assignment/assignment.service';

@Module({
  controllers: [AssignmentController],
  providers: [AssignmentService],
})
export class AssignmentDispatchModule {}
