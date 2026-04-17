import {
  BadRequestException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as argon2 from 'argon2';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async register(input: RegisterDto) {
    const existing = await this.prisma.user.findUnique({
      where: { email: input.email.toLowerCase() },
    });
    if (existing) {
      throw new BadRequestException('Email already in use');
    }

    const tenant = await this.prisma.tenant.create({
      data: { name: input.tenantName },
    });
    const passwordHash = await argon2.hash(input.password, {
      type: argon2.argon2id,
      memoryCost: 19_456,
      timeCost: 2,
      parallelism: 1,
    });
    const user = await this.prisma.user.create({
      data: {
        tenantId: tenant.id,
        email: input.email.toLowerCase(),
        passwordHash,
        firstName: input.firstName,
        lastName: input.lastName,
      },
    });
    const organization = await this.prisma.organization.create({
      data: {
        tenantId: tenant.id,
        name: `${tenant.name} Organization`,
      },
    });
    const workspace = await this.prisma.workspace.create({
      data: {
        organizationId: organization.id,
        name: 'Default Workspace',
      },
    });

    return this.issueTokens({
      userId: user.id,
      email: user.email,
      tenantId: user.tenantId,
      firstName: user.firstName,
      lastName: user.lastName,
      defaultWorkspaceId: workspace.id,
    });
  }

  async login(input: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: input.email.toLowerCase() },
    });
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const valid = await argon2.verify(user.passwordHash, input.password);
    if (!valid) {
      throw new UnauthorizedException('Invalid credentials');
    }
    const workspace = await this.prisma.workspace.findFirst({
      where: { organization: { tenantId: user.tenantId } },
      orderBy: { createdAt: 'asc' },
    });
    return this.issueTokens({
      userId: user.id,
      email: user.email,
      tenantId: user.tenantId,
      firstName: user.firstName,
      lastName: user.lastName,
      defaultWorkspaceId: workspace?.id ?? null,
    });
  }

  private issueTokens(input: {
    userId: string;
    email: string;
    tenantId: string;
    firstName: string;
    lastName: string;
    defaultWorkspaceId: string | null;
  }) {
    const payload = {
      sub: input.userId,
      email: input.email,
      tenantId: input.tenantId,
    };
    const accessToken = this.jwt.sign(payload, {
      secret: this.config.getOrThrow<string>('JWT_ACCESS_SECRET'),
      expiresIn: (this.config.get<string>('JWT_ACCESS_TTL') ?? '15m') as never,
    });
    const refreshToken = this.jwt.sign(payload, {
      secret: this.config.getOrThrow<string>('JWT_REFRESH_SECRET'),
      expiresIn: (this.config.get<string>('JWT_REFRESH_TTL') ?? '30d') as never,
    });
    return {
      accessToken,
      refreshToken,
      user: {
        id: input.userId,
        email: input.email,
        tenantId: input.tenantId,
        firstName: input.firstName,
        lastName: input.lastName,
      },
      defaultWorkspaceId: input.defaultWorkspaceId,
    };
  }
}
