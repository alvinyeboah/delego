/* eslint-disable @typescript-eslint/no-unsafe-assignment */

import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as argon2 from 'argon2';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { PrismaService } from '../src/common/prisma/prisma.service';

interface AuthResponseBody {
  accessToken: string;
  refreshToken: string;
  defaultWorkspaceId: string | null;
  user: {
    id: string;
    tenantId: string;
  };
}

interface TaskResponseBody {
  id: string;
  workspaceId: string;
  status: string;
  updatedAtIso: string;
}

interface SyncResponseBody {
  tasks: unknown[];
  checkpoint: string;
}

describe('Production flow (e2e)', () => {
  let app: INestApplication<App>;
  let taskStore: Array<Record<string, unknown>>;

  beforeAll(async () => {
    const user = {
      id: 'user_1',
      email: 'ops@delego.com',
      passwordHash: await argon2.hash('password123', {
        type: argon2.argon2id,
        memoryCost: 19_456,
        timeCost: 2,
        parallelism: 1,
      }),
      firstName: 'Ops',
      lastName: 'Lead',
      tenantId: 'tenant_1',
    };
    taskStore = [];

    const prismaMock = {
      user: {
        findUnique: jest
          .fn()
          .mockImplementation(({ where }: { where: { email: string } }) => {
            return where.email === user.email ? user : null;
          }),
        create: jest
          .fn()
          .mockImplementation(({ data }: { data: Record<string, string> }) => {
            return {
              ...user,
              ...data,
            };
          }),
      },
      tenant: {
        create: jest
          .fn()
          .mockResolvedValue({ id: 'tenant_1', name: 'Delego Tenant' }),
      },
      organization: {
        create: jest
          .fn()
          .mockResolvedValue({ id: 'org_1', tenantId: 'tenant_1' }),
      },
      workspace: {
        create: jest.fn().mockResolvedValue({ id: 'ws_1' }),
        findFirst: jest.fn().mockResolvedValue({ id: 'ws_1' }),
      },
      task: {
        create: jest
          .fn()
          .mockImplementation(({ data }: { data: Record<string, unknown> }) => {
            const task = {
              id: 'task_1',
              workspaceId: data.workspaceId,
              title: data.title,
              description: data.description ?? null,
              status: 'OPEN',
              priority: data.priority ?? 'MEDIUM',
              assigneeUserId: null,
              version: 1,
              updatedAt: new Date('2026-04-17T13:00:00.000Z'),
              createdAt: new Date('2026-04-17T13:00:00.000Z'),
            };
            taskStore.push(task);
            return task;
          }),
        findMany: jest
          .fn()
          .mockImplementation(
            ({ where }: { where: { workspaceId: string } }) => {
              return taskStore.filter(
                (task) => task.workspaceId === where.workspaceId,
              );
            },
          ),
        update: jest
          .fn()
          .mockImplementation(
            ({
              where,
              data,
            }: {
              where: { id: string };
              data: Record<string, unknown>;
            }) => {
              const task = taskStore.find((item) => item.id === where.id);
              if (!task) {
                throw new Error('Task not found');
              }
              task.status = data.status;
              task.version = Number(task.version) + 1;
              task.updatedAt = new Date('2026-04-17T13:30:00.000Z');
              return task;
            },
          ),
      },
      taskStatusHistory: {
        create: jest.fn().mockResolvedValue({ id: 'hist_1' }),
      },
      captureSession: {
        create: jest.fn().mockResolvedValue({
          id: 'cap_1',
          images: [{ id: 'img_1', storageKey: 'capture.png' }],
          metadata: { latitude: 5.5, longitude: -0.2 },
        }),
      },
      conflictRecord: {
        create: jest.fn().mockResolvedValue({ id: 'conflict_1' }),
      },
      $transaction: jest.fn().mockImplementation(
        async (
          callback: (tx: {
            task: {
              update: (args: {
                where: { id: string };
                data: Record<string, unknown>;
              }) => Record<string, unknown>;
            };
            taskStatusHistory: {
              create: (args: {
                data: { taskId: string; status: string; reason?: string };
              }) => Promise<{ id: string }>;
            };
          }) => Promise<unknown>,
        ) => {
          return callback({
            task: {
              update: ({
                where,
                data,
              }: {
                where: { id: string };
                data: Record<string, unknown>;
              }) => {
                const task = taskStore.find((item) => item.id === where.id);
                if (!task) {
                  throw new Error('Task not found');
                }
                task.status = data.status;
                task.version = Number(task.version) + 1;
                task.updatedAt = new Date('2026-04-17T13:30:00.000Z');
                return task;
              },
            },
            taskStatusHistory: {
              create: () => Promise.resolve({ id: 'hist_1' }),
            },
          });
        },
      ),
    };

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue(prismaMock)
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('runs auth -> task -> capture -> sync lifecycle', async () => {
    const registerRes = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: 'newops@delego.com',
        password: 'password123',
        firstName: 'Ops',
        lastName: 'Lead',
        tenantName: 'Delego Tenant',
      })
      .expect(201);
    const registerBodyUnknown: unknown = registerRes.body;
    const registerBody = registerBodyUnknown as AuthResponseBody;
    expect(registerBody).toEqual(
      expect.objectContaining({
        accessToken: expect.any(String),
        refreshToken: expect.any(String),
        defaultWorkspaceId: 'ws_1',
      }),
    );

    const loginRes = await request(app.getHttpServer())
      .post('/auth/login')
      .send({
        email: 'ops@delego.com',
        password: 'password123',
      })
      .expect(201);

    const loginBodyUnknown: unknown = loginRes.body;
    const loginBody = loginBodyUnknown as AuthResponseBody;
    const token = loginBody.accessToken;
    expect(loginBody.user).toEqual(
      expect.objectContaining({
        id: 'user_1',
        tenantId: 'tenant_1',
      }),
    );

    const taskRes = await request(app.getHttpServer())
      .post('/task')
      .set('Authorization', `Bearer ${token}`)
      .send({
        workspaceId: 'ws_1',
        title: 'Inspect delivery note',
        priority: 'HIGH',
      })
      .expect(201);
    const taskBodyUnknown: unknown = taskRes.body;
    const taskBody = taskBodyUnknown as TaskResponseBody;
    expect(taskBody).toEqual(
      expect.objectContaining({
        id: 'task_1',
        workspaceId: 'ws_1',
        status: 'OPEN',
        updatedAtIso: expect.any(String),
      }),
    );

    await request(app.getHttpServer())
      .patch('/task/task_1/status')
      .set('Authorization', `Bearer ${token}`)
      .send({
        status: 'IN_PROGRESS',
        reason: 'Picked by operator',
      })
      .expect(200);

    const listRes = await request(app.getHttpServer())
      .get('/task/workspace/ws_1')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    const listBodyUnknown: unknown = listRes.body;
    const listBody = listBodyUnknown as TaskResponseBody[];
    expect(listBody[0]).toEqual(
      expect.objectContaining({
        id: 'task_1',
        status: 'IN_PROGRESS',
      }),
    );

    await request(app.getHttpServer())
      .post('/capture/session')
      .set('Authorization', `Bearer ${token}`)
      .send({
        workspaceId: 'ws_1',
        createdById: 'user_1',
        latitude: 5.5,
        longitude: -0.2,
        imageStorageKey: 'capture.png',
      })
      .expect(201);

    const syncRes = await request(app.getHttpServer())
      .get('/sync/pull')
      .set('Authorization', `Bearer ${token}`)
      .query({ workspaceId: 'ws_1' })
      .expect(200);
    const syncBodyUnknown: unknown = syncRes.body;
    const syncBody = syncBodyUnknown as SyncResponseBody;
    expect(syncBody).toEqual(
      expect.objectContaining({
        tasks: expect.any(Array),
        checkpoint: expect.any(String),
      }),
    );
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });
});
