import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { AnalyticsEventService } from './analytics-event.service';

@Controller('analytics-event')
@UseGuards(JwtAuthGuard)
export class AnalyticsEventController {
  constructor(private readonly analyticsEventService: AnalyticsEventService) {}

  @Post()
  publish(
    @Body()
    body: {
      tenantId: string;
      eventType: string;
      payload: Record<string, unknown>;
    },
  ) {
    return this.analyticsEventService.publish(body);
  }
}
