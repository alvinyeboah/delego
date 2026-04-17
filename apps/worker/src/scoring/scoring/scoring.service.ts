import { Injectable } from '@nestjs/common';

@Injectable()
export class ScoringService {
  scoreTask(input: {
    urgencyWeight: number;
    slaMinutes: number;
    ageMinutes: number;
  }) {
    const score = Math.min(
      100,
      Math.round(
        input.urgencyWeight * 30 +
          (120 / Math.max(1, input.slaMinutes)) * 40 +
          Math.min(input.ageMinutes / 60, 1) * 30,
      ),
    );
    const priority =
      score >= 80
        ? 'CRITICAL'
        : score >= 60
          ? 'HIGH'
          : score >= 35
            ? 'MEDIUM'
            : 'LOW';
    return { score, priority, confidence: 0.7 };
  }
}
