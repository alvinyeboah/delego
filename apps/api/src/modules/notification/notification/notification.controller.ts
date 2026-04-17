import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../identity-access/auth/guards/jwt-auth.guard';
import { NotificationService } from './notification.service';

@Controller('notification')
@UseGuards(JwtAuthGuard)
export class NotificationController {
  constructor(private readonly notificationService: NotificationService) {}

  @Get(':userId')
  list(@Param('userId') userId: string) {
    return this.notificationService.list(userId);
  }

  @Post()
  create(@Body() body: { userId: string; title: string; body: string }) {
    return this.notificationService.create(body);
  }
}
