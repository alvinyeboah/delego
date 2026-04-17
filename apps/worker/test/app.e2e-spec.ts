/* eslint-disable @typescript-eslint/no-unsafe-assignment */
import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    process.env.OCR_PROVIDER = 'mock';
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Delego worker online');
  });

  it('/simulate/capture (POST)', async () => {
    const res = await request(app.getHttpServer())
      .post('/simulate/capture')
      .send({ storageKey: 'capture.png' })
      .expect(201);

    expect(res.body).toEqual(
      expect.objectContaining({
        ocr: expect.objectContaining({
          storageKey: 'capture.png',
          provider: 'mock',
        }),
        scoring: expect.any(Object),
        reviewRequired: expect.any(Boolean),
      }),
    );
  });

  afterEach(async () => {
    await app.close();
  });
});
