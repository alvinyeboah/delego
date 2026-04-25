import { BadRequestException, Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import type { JwtPayload } from '../../identity-access/auth/strategies/jwt.strategy';
import { CaptureService } from './capture.service';

@Controller('capture')
@UseGuards(JwtAuthGuard)
export class CaptureController {
  constructor(private readonly captureService: CaptureService) {}

  @Post('session')
  createSession(
    @Req() req: { user: JwtPayload },
    @Body()
    body: {
      workspaceId: string;
      createdById?: string;
      latitude?: number;
      longitude?: number;
      deviceModel?: string;
      capturedAt?: string;
      imageStorageKey: string;
    },
  ) {
    return this.captureService.createSession({
      ...body,
      createdById: req.user.sub,
    });
  }

  @Post('pipeline/run')
  runPipeline(@Body() body: { storageKey: string }) {
    const key = body?.storageKey?.trim();
    if (!key) {
      throw new BadRequestException('storageKey is required');
    }
    return this.captureService.runWorkerPipeline(key);
  }
}
