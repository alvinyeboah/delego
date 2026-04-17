import {
  MessageBody,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({ namespace: 'tasks', cors: true })
export class TaskGateway {
  @WebSocketServer()
  server!: Server;

  notifyTaskUpdated(task: Record<string, unknown>) {
    this.server.emit('task.updated', task);
  }

  @SubscribeMessage('task.joinWorkspace')
  handleJoinWorkspace(@MessageBody() body: { workspaceId: string }) {
    return { joined: body.workspaceId };
  }
}
