import { Module } from '@nestjs/common';
import { AnalyticsEventController } from './analytics-event/analytics-event.controller';
import { AnalyticsEventService } from './analytics-event/analytics-event.service';

@Module({
  controllers: [AnalyticsEventController],
  providers: [AnalyticsEventService],
})
export class AnalyticsEventModule {}
