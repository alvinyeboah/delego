import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { SyncService } from './sync.service';

@Controller('sync')
@UseGuards(JwtAuthGuard)
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Get('pull')
  pull(
    @Query('workspaceId') workspaceId: string,
    @Query('since') since?: string,
  ) {
    return this.syncService.pull(workspaceId, since);
  }

  @Post('conflict')
  createConflict(
    @Body()
    body: {
      taskId: string;
      userId: string;
      localVersion: number;
      serverVersion: number;
      resolution?: string;
    },
  ) {
    return this.syncService.pushConflictRecord(body);
  }
}
