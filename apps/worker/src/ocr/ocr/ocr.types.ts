export interface OcrResult {
  storageKey: string;
  text: string;
  confidence: number;
  provider: 'tesseract' | 'mock';
}
