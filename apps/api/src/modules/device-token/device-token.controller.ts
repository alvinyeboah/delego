import { Body, Controller, Delete, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../identity-access/auth/guards/jwt-auth.guard';
import type { JwtPayload } from '../identity-access/auth/strategies/jwt.strategy';
import { DeviceTokenService } from './device-token.service';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';

@Controller('device-tokens')
@UseGuards(JwtAuthGuard)
export class DeviceTokenController {
  constructor(private readonly deviceTokenService: DeviceTokenService) {}

  @Post()
  register(@Req() req: { user: JwtPayload }, @Body() body: RegisterDeviceTokenDto) {
    return this.deviceTokenService.register(req.user.sub, body);
  }

  @Get()
  list(@Req() req: { user: JwtPayload }) {
    return this.deviceTokenService.listForUser(req.user.sub);
  }

  @Delete(':id')
  remove(@Req() req: { user: JwtPayload }, @Param('id') id: string) {
    return this.deviceTokenService.deleteForUser(req.user.sub, id);
  }
}
