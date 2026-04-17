import { Injectable } from '@nestjs/common';

@Injectable()
export class OcrService {
  extractTextFromImage(storageKey: string) {
    return {
      storageKey,
      text: `Simulated OCR text for ${storageKey}`,
      confidence: 0.82,
    };
  }
}
