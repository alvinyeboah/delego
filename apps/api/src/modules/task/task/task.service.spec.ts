import { Test } from '@nestjs/testing';
import { TaskService } from './task.service';
import { PrismaService } from '../../../common/prisma/prisma.service';
import { TaskGateway } from './task.gateway';

describe('TaskService', () => {
  it('maps database task into API contract shape', async () => {
    const now = new Date('2026-04-17T12:00:00.000Z');
    const prismaMock = {
      task: {
        findMany: jest.fn().mockResolvedValue([
          {
            id: 'task_1',
            workspaceId: 'ws_1',
            title: 'Inspect dropoff',
            description: 'Gate B',
            status: 'OPEN',
            priority: 'HIGH',
            assigneeUserId: null,
            version: 1,
            updatedAt: now,
            createdAt: now,
          },
        ]),
      },
    };
    const gatewayMock = {
      notifyTaskUpdated: jest.fn(),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        TaskService,
        { provide: PrismaService, useValue: prismaMock },
        { provide: TaskGateway, useValue: gatewayMock },
      ],
    }).compile();

    const service = moduleRef.get(TaskService);
    const tasks = await service.list('ws_1');
    expect(tasks).toEqual([
      {
        id: 'task_1',
        workspaceId: 'ws_1',
        title: 'Inspect dropoff',
        description: 'Gate B',
        status: 'OPEN',
        priority: 'HIGH',
        assigneeUserId: null,
        version: 1,
        updatedAtIso: '2026-04-17T12:00:00.000Z',
        createdAtIso: '2026-04-17T12:00:00.000Z',
      },
    ]);
  });
});
