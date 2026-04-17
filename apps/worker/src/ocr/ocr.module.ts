import { Module } from '@nestjs/common';
import { OcrService } from './ocr/ocr.service';

@Module({
  providers: [OcrService],
  exports: [OcrService],
})
export class OcrModule {}
