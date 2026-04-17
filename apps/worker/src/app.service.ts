import { Injectable } from '@nestjs/common';
import { JobsService } from './jobs/jobs/jobs.service';

@Injectable()
export class AppService {
  constructor(private readonly jobsService: JobsService) {}

  getHello(): string {
    return 'Delego worker online';
  }

  simulateCapturePipeline(storageKey: string) {
    return this.jobsService.processCapture(storageKey);
  }
}
