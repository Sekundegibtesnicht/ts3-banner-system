import { TeamSpeak } from "ts3-nodejs-library";
import { appConfig } from "./config.js";
import { t } from "./i18n.js";
import type { ServerInfo, ClientInfo, ChannelInfo } from "./types.js";
import { recordOnlineCount } from "./history.js";

let tsClient: TeamSpeak | null = null;
let reconnectTimer: ReturnType<typeof setTimeout> | null = null;
let historyInterval: ReturnType<typeof setInterval> | null = null;
let lastJoinedUser: string = "";

/**
 * Verbindung zum TeamSpeak ServerQuery herstellen
 */
async function connect(): Promise<TeamSpeak> {
  const { ts } = appConfig;

  console.log(`[TS3] ${t().tsConnecting} ${ts.host}:${ts.queryPort}...`);

  const client = await TeamSpeak.connect({
    host: ts.host,
    queryport: ts.queryPort,
    serverport: ts.serverPort,
    username: ts.username,
    password: ts.password,
    nickname: "BannerBot",
  });

  client.on("close", () => {
    console.warn(`[TS3] ${t().tsConnectionLost}`);
    tsClient = null;
    if (reconnectTimer) clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(() => {
      initTeamSpeak().catch(console.error);
    }, 10_000);
  });

  client.on("error", (err) => {
    console.error(`[TS3] ${t().tsError}:`, err.message);
  });

  console.log(`[TS3] ${t().tsConnected}`);

  // History Tracking starten
  if (historyInterval) clearInterval(historyInterval);
  historyInterval = setInterval(async () => {
    try {
      const info = await getServerInfo();
      recordOnlineCount(info.clientsOnline);
    } catch { /* ignore */ }
  }, 60_000); // jede Minute

  // Initialen Wert setzen
  try {
    const info = await client.serverInfo();
    recordOnlineCount(Math.max(0, (Number(info.virtualserverClientsonline ?? 1)) - 1));
  } catch { /* ignore */ }

  return client;
}

/**
 * TeamSpeak-Verbindung initialisieren
 */
export async function initTeamSpeak(): Promise<void> {
  try {
    tsClient = await connect();
  } catch (err: any) {
    console.error(`[TS3] ${t().tsConnectionFailed}:`, err.message);
    console.log(`[TS3] ${t().tsRetry}`);
    if (reconnectTimer) clearTimeout(reconnectTimer);
    reconnectTimer = setTimeout(() => {
      initTeamSpeak().catch(console.error);
    }, 10_000);
  }
}

/**
 * Server-Infos abrufen
 */
export async function getServerInfo(): Promise<ServerInfo> {
  if (!tsClient) {
    return {
      name: "Server Offline",
      platform: "-",
      version: "-",
      clientsOnline: 0,
      maxClients: 0,
      channelsOnline: 0,
      uptime: 0,
      ping: 0,
    };
  }

  try {
    const info = await tsClient.serverInfo();

    return {
      name: String(info.virtualserverName ?? "TeamSpeak Server"),
      platform: String(info.virtualserverPlatform ?? "-"),
      version: String(info.virtualserverVersion ?? "-"),
      clientsOnline: (Number(info.virtualserverClientsonline ?? 1)) - 1, // -1 für den Query-Client
      maxClients: Number(info.virtualserverMaxclients ?? 0),
      channelsOnline: Number(info.virtualserverChannelsonline ?? 0),
      uptime: Number(info.virtualserverUptime ?? 0),
      ping: 0,
    };
  } catch (err: any) {
    console.error(`[TS3] ${t().tsServerInfoError}:`, err.message);
    return {
      name: "Fehler",
      platform: "-",
      version: "-",
      clientsOnline: 0,
      maxClients: 0,
      channelsOnline: 0,
      uptime: 0,
      ping: 0,
    };
  }
}

/**
 * Online-Clients abrufen
 */
export async function getClients(): Promise<ClientInfo[]> {
  if (!tsClient) return [];

  try {
    const clients = await tsClient.clientList({ clientType: 0 }); // nur echte Clients
    return clients.map((c) => ({
      nickname: c.nickname,
      isAway: (c as any).clientAway === 1,
      channelId: Number(c.cid),
      connectionTime: (c as any).connectionConnectedTime ?? 0,
    }));
  } catch {
    return [];
  }
}

/**
 * Channel-Liste abrufen
 */
export async function getChannels(): Promise<ChannelInfo[]> {
  if (!tsClient) return [];

  try {
    const channels = await tsClient.channelList();
    return channels.map((ch) => ({
      id: Number(ch.cid),
      name: ch.name,
      totalClients: ch.totalClients ?? 0,
      neededSubscribePower: ch.neededSubscribePower ?? 0,
    }));
  } catch {
    return [];
  }
}

/**
 * Aufräumen
 */
export async function disconnectTeamSpeak(): Promise<void> {
  if (reconnectTimer) clearTimeout(reconnectTimer);
  if (historyInterval) clearInterval(historyInterval);
  if (tsClient) {
    await tsClient.quit();
    tsClient = null;
  }
}

/**
 * Top-Channel (meiste Clients) abrufen
 */
export async function getTopChannel(): Promise<{ name: string; clients: number } | null> {
  if (!tsClient) return null;

  try {
    const channels = await tsClient.channelList();
    let top: { name: string; clients: number } | null = null;
    for (const ch of channels) {
      const count = ch.totalClients ?? 0;
      if (count > 0 && (!top || count > top.clients)) {
        top = { name: ch.name, clients: count };
      }
    }
    return top;
  } catch {
    return null;
  }
}

/**
 * Zuletzt beigetretenen User tracken & abrufen
 */
export function setLastJoined(name: string): void {
  lastJoinedUser = name;
}

export function getLastJoined(): string {
  return lastJoinedUser;
}

/**
 * Neuesten Client ermitteln (kürzeste Verbindungszeit)
 */
export async function findNewestClient(): Promise<string> {
  if (!tsClient) return "";

  try {
    const clients = await tsClient.clientList({ clientType: 0 });
    if (clients.length === 0) return "";

    let newest = clients[0];
    let shortestTime = Number((newest as any).connectionConnectedTime ?? Infinity);

    for (const c of clients) {
      const t = Number((c as any).connectionConnectedTime ?? Infinity);
      if (t < shortestTime) {
        shortestTime = t;
        newest = c;
      }
    }
    return newest.nickname;
  } catch {
    return "";
  }
}
