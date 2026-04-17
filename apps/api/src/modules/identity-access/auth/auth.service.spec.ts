import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test } from '@nestjs/testing';
import * as argon2 from 'argon2';
import { AuthService } from './auth.service';
import { PrismaService } from '../../../common/prisma/prisma.service';

describe('AuthService', () => {
  it('returns contract-safe login payload shape', async () => {
    const passwordHash = await argon2.hash('password123', {
      type: argon2.argon2id,
      memoryCost: 19_456,
      timeCost: 2,
      parallelism: 1,
    });
    const prismaMock = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'user_1',
          email: 'ops@delego.com',
          tenantId: 'tenant_1',
          firstName: 'Ops',
          lastName: 'Lead',
          passwordHash,
        }),
      },
      workspace: {
        findFirst: jest.fn().mockResolvedValue({ id: 'ws_1' }),
      },
    };
    const jwtMock = {
      sign: jest.fn().mockReturnValue('token'),
    };
    const configMock = {
      getOrThrow: jest.fn().mockReturnValue('secret-secret-secret'),
      get: jest.fn().mockReturnValue('15m'),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prismaMock },
        { provide: JwtService, useValue: jwtMock },
        { provide: ConfigService, useValue: configMock },
      ],
    }).compile();

    const service = moduleRef.get(AuthService);
    const result = await service.login({
      email: 'ops@delego.com',
      password: 'password123',
    });

    expect(typeof result.accessToken).toBe('string');
    expect(typeof result.refreshToken).toBe('string');
    expect(result.defaultWorkspaceId).toBe('ws_1');
    expect(result.user.id).toBe('user_1');
    expect(result.user.email).toBe('ops@delego.com');
    expect(result.user.tenantId).toBe('tenant_1');
  });
});
