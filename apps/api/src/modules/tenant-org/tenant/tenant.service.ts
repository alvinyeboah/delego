import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../common/prisma/prisma.service';

@Injectable()
export class TenantService {
  constructor(private readonly prisma: PrismaService) {}

  listTenants() {
    return this.prisma.tenant.findMany({
      include: {
        organizations: {
          include: {
            workspaces: true,
          },
        },
      },
    });
  }

  createOrganization(tenantId: string, name: string) {
    return this.prisma.organization.create({
      data: { tenantId, name },
    });
  }

  createWorkspace(organizationId: string, name: string) {
    return this.prisma.workspace.create({
      data: { organizationId, name },
    });
  }
}
