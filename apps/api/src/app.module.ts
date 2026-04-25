import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule } from '@nestjs/throttler';
import * as Joi from 'joi';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { IdentityAccessModule } from './modules/identity-access/identity-access.module';
import { TenantOrgModule } from './modules/tenant-org/tenant-org.module';
import { AuditComplianceModule } from './modules/audit-compliance/audit-compliance.module';
import { TaskModule } from './modules/task/task.module';
import { CaptureIntakeModule } from './modules/capture-intake/capture-intake.module';
import { AssignmentDispatchModule } from './modules/assignment-dispatch/assignment-dispatch.module';
import { NotificationModule } from './modules/notification/notification.module';
import { SyncModule } from './modules/sync/sync.module';
import { AnalyticsEventModule } from './modules/analytics-event/analytics-event.module';
import { DeviceTokenModule } from './modules/device-token/device-token.module';
import { MediaModule } from './modules/media/media.module';
import { PrismaModule } from './common/prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: Joi.object({
        PORT: Joi.number().default(3000),
        DATABASE_URL: Joi.string().uri().required(),
        JWT_ACCESS_SECRET: Joi.string().min(16).required(),
        JWT_REFRESH_SECRET: Joi.string().min(16).required(),
        JWT_ACCESS_TTL: Joi.string().default('15m'),
        JWT_REFRESH_TTL: Joi.string().default('30d'),
        CORS_ORIGINS: Joi.string().optional(),
        MEDIA_ROOT: Joi.string().optional(),
        WORKER_URL: Joi.string().uri().optional(),
      }),
    }),
    ThrottlerModule.forRoot([
      {
        ttl: 60_000,
        limit: 120,
      },
    ]),
    PrismaModule,
    IdentityAccessModule,
    TenantOrgModule,
    AuditComplianceModule,
    TaskModule,
    CaptureIntakeModule,
    MediaModule,
    DeviceTokenModule,
    AssignmentDispatchModule,
    NotificationModule,
    SyncModule,
    AnalyticsEventModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
