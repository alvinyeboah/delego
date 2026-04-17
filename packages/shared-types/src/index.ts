export const taskStatuses = [
  'OPEN',
  'IN_PROGRESS',
  'BLOCKED',
  'DONE',
  'CANCELLED',
  'REVIEW_REQUIRED',
] as const;

export type TaskStatus = (typeof taskStatuses)[number];

export const priorityLevels = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'] as const;
export type PriorityLevel = (typeof priorityLevels)[number];
