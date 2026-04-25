import { IsString, MinLength } from 'class-validator';

export class RegisterDeviceTokenDto {
  @IsString()
  @MinLength(8)
  token!: string;

  @IsString()
  @MinLength(1)
  platform!: string;
}
