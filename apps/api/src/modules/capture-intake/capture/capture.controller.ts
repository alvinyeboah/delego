import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { CaptureService } from './capture.service';

@Controller('capture')
@UseGuards(JwtAuthGuard)
export class CaptureController {
  constructor(private readonly captureService: CaptureService) {}

  @Post('session')
  createSession(
    @Body()
    body: {
      workspaceId: string;
      createdById: string;
      latitude?: number;
      longitude?: number;
      deviceModel?: string;
      capturedAt?: string;
      imageStorageKey: string;
    },
  ) {
    return this.captureService.createSession(body);
  }
}
