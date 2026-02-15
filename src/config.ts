import fs from "node:fs";
import path from "node:path";
import { initI18n } from "./i18n.js";

export interface AppConfig {
  port: number;

  ts: {
    host: string;
    queryPort: number;
    serverPort: number;
    username: string;
    password: string;
  };

  banner: {
    width: number;
    height: number;
    background: string;
    font: string;
    logo: string;
    timezone: string;
    colors: {
      primary: string;
      secondary: string;
      accent: string;
      accentSecondary: string;
      online: string;
      away: string;
      cardBg: string;
      cardBorder: string;
    };
    features: {
      clock: boolean;
      userChips: boolean;
      progressBar: boolean;
      sparkline: boolean;
      topChannel: boolean;
      lastJoined: boolean;
      particles: boolean;
      accentGlow: boolean;
      gradientLine: boolean;
      eventText: string;
    };
  };

  lang: string;

  cacheTTL: number;
}

function loadConfig(): AppConfig {
  const configPath = path.resolve("config.json");

  if (!fs.existsSync(configPath)) {
    console.error("[Config] config.json not found! Copy config.example.json → config.json");
    process.exit(1);
  }

  const raw = JSON.parse(fs.readFileSync(configPath, "utf-8"));
  const c = raw.banner?.colors ?? {};
  const f = raw.banner?.features ?? {};

  return {
    port: raw.port ?? 3200,

    ts: {
      host: raw.teamspeak?.host ?? "127.0.0.1",
      queryPort: raw.teamspeak?.queryPort ?? 10011,
      serverPort: raw.teamspeak?.serverPort ?? 9987,
      username: raw.teamspeak?.username ?? "serveradmin",
      password: raw.teamspeak?.password ?? "",
    },

    banner: {
      width: raw.banner?.width ?? 1024,
      height: raw.banner?.height ?? 300,
      background: raw.banner?.background ?? "",
      font: raw.banner?.font ?? "",
      logo: raw.banner?.logo ?? "",
      timezone: raw.banner?.timezone ?? "Europe/Berlin",
      colors: {
        primary: c.primary ?? "#ffffff",
        secondary: c.secondary ?? "#8b949e",
        accent: c.accent ?? "#00b4d8",
        accentSecondary: c.accentSecondary ?? "#7c3aed",
        online: c.online ?? "#34d399",
        away: c.away ?? "#fbbf24",
        cardBg: c.cardBg ?? "rgba(255, 255, 255, 0.05)",
        cardBorder: c.cardBorder ?? "rgba(255, 255, 255, 0.08)",
      },
      features: {
        clock: f.clock ?? true,
        userChips: f.userChips ?? true,
        progressBar: f.progressBar ?? true,
        sparkline: f.sparkline ?? true,
        topChannel: f.topChannel ?? true,
        lastJoined: f.lastJoined ?? true,
        particles: f.particles ?? true,
        accentGlow: f.accentGlow ?? true,
        gradientLine: f.gradientLine ?? true,
        eventText: f.eventText ?? "",
      },
    },

    lang: raw.lang ?? "de",

    cacheTTL: raw.cacheTTL ?? 30,
  };
}

export const appConfig = loadConfig();

// i18n initialisieren basierend auf Config
initI18n(appConfig.lang);
