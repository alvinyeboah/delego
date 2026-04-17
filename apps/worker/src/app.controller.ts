import { Body, Controller, Get, Post } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Post('simulate/capture')
  simulateCapture(@Body() body: { storageKey: string }) {
    return this.appService.simulateCapturePipeline(body.storageKey);
  }
}
