import { Module } from '@nestjs/common';
import { JobsService } from './jobs/jobs.service';
import { OcrModule } from '../ocr/ocr.module';
import { ScoringModule } from '../scoring/scoring.module';

@Module({
  imports: [OcrModule, ScoringModule],
  providers: [JobsService],
  exports: [JobsService],
})
export class JobsModule {}
