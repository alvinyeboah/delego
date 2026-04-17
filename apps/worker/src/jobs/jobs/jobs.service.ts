import { Injectable } from '@nestjs/common';
import { OcrService } from '../../ocr/ocr/ocr.service';
import { ScoringService } from '../../scoring/scoring/scoring.service';

@Injectable()
export class JobsService {
  constructor(
    private readonly ocrService: OcrService,
    private readonly scoringService: ScoringService,
  ) {}

  async processCapture(storageKey: string) {
    const ocr = await this.ocrService.extractTextFromImage(storageKey);
    const scoring = this.scoringService.scoreTask({
      urgencyWeight: 0.75,
      slaMinutes: 90,
      ageMinutes: 15,
    });
    return {
      ocr,
      scoring,
      reviewRequired: ocr.confidence < 0.7 || scoring.confidence < 0.65,
    };
  }
}
