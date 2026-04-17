import { IsIn, IsOptional, IsString } from 'class-validator';

export class UpdateTaskStatusDto {
  @IsIn([
    'OPEN',
    'IN_PROGRESS',
    'BLOCKED',
    'DONE',
    'CANCELLED',
    'REVIEW_REQUIRED',
  ])
  status!:
    | 'OPEN'
    | 'IN_PROGRESS'
    | 'BLOCKED'
    | 'DONE'
    | 'CANCELLED'
    | 'REVIEW_REQUIRED';

  @IsOptional()
  @IsString()
  reason?: string;
}
