import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { TenantService } from './tenant.service';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';

@Controller('tenant')
@UseGuards(JwtAuthGuard)
export class TenantController {
  constructor(private readonly tenantService: TenantService) {}

  @Get()
  getTenants() {
    return this.tenantService.listTenants();
  }

  @Post(':tenantId/organizations')
  createOrganization(
    @Param('tenantId') tenantId: string,
    @Body() body: { name: string },
  ) {
    return this.tenantService.createOrganization(tenantId, body.name);
  }

  @Post('organizations/:organizationId/workspaces')
  createWorkspace(
    @Param('organizationId') organizationId: string,
    @Body() body: { name: string },
  ) {
    return this.tenantService.createWorkspace(organizationId, body.name);
  }
}
