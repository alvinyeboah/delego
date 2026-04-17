import { Module } from '@nestjs/common';
import { CaptureController } from './capture/capture.controller';
import { CaptureService } from './capture/capture.service';

@Module({
  controllers: [CaptureController],
  providers: [CaptureService],
})
export class CaptureIntakeModule {}
