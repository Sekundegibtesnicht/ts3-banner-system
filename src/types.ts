export interface ServerInfo {
  name: string;
  platform: string;
  version: string;
  clientsOnline: number;
  maxClients: number;
  channelsOnline: number;
  uptime: number;
  ping: number;
}

export interface ClientInfo {
  nickname: string;
  isAway: boolean;
  channelId: number;
  connectionTime: number;
}

export interface ChannelInfo {
  id: number;
  name: string;
  totalClients: number;
  neededSubscribePower: number;
}
