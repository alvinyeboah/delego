import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { AuditService } from './audit.service';

@Controller('audit')
@UseGuards(JwtAuthGuard)
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get(':tenantId')
  getTenantAudit(@Param('tenantId') tenantId: string) {
    return this.auditService.listByTenant(tenantId);
  }

  @Post()
  createAudit(
    @Body()
    body: {
      tenantId: string;
      actorUserId?: string;
      action: string;
      resource: string;
      resourceId?: string;
      metadata?: Record<string, unknown>;
    },
  ) {
    return this.auditService.log(body);
  }
}
