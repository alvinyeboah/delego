import { randomUUID } from 'node:crypto';
import * as fs from 'node:fs';
import * as path from 'node:path';

import {
  Controller,
  Post,
  Req,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import type { Express } from 'express';

import { JwtAuthGuard } from '../identity-access/auth/guards/jwt-auth.guard';
import type { JwtPayload } from '../identity-access/auth/strategies/jwt.strategy';

function mediaRoot(): string {
  return process.env.MEDIA_ROOT?.trim() || path.join(process.cwd(), 'uploads');
}

@Controller('media')
@UseGuards(JwtAuthGuard)
export class MediaController {
  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: 50 * 1024 * 1024 },
      storage: diskStorage({
        destination: (_req, _file, cb) => {
          const root = mediaRoot();
          fs.mkdirSync(root, { recursive: true });
          cb(null, root);
        },
        filename: (_req, file, cb) => {
          const ext = path.extname(file.originalname) || '.bin';
          cb(null, `${randomUUID()}${ext}`);
        },
      }),
    }),
  )
  upload(
    @UploadedFile() file: Express.Multer.File,
    @Req() req: { user: JwtPayload },
  ): { storageKey: string; mimeType: string; sizeBytes: number; uploadedBy: string } {
    return {
      storageKey: file.path,
      mimeType: file.mimetype,
      sizeBytes: file.size,
      uploadedBy: req.user.sub,
    };
  }
}
