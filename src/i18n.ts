// ══════════════════════════════════════════════════
//  Internationalisierung (i18n)
//  Unterstützte Sprachen: "de" | "en"
// ══════════════════════════════════════════════════

export interface I18nStrings {
  // ── Banner-Texte ──
  dateLocale: string;
  online: string;
  channels: string;
  uptime: string;
  ping: string;
  noPlayers: string;
  lastJoined: string;
  sparklineLabel: string;
  sparklineLoading: string;

  // ── Konsole: Config ──
  configNotFound: string;

  // ── Konsole: Banner/Font ──
  fontLoaded: string;

  // ── Konsole: TeamSpeak ──
  tsConnecting: string;
  tsConnected: string;
  tsConnectionLost: string;
  tsError: string;
  tsConnectionFailed: string;
  tsRetry: string;
  tsServerInfoError: string;

  // ── Konsole: Server ──
  serverBannerError: string;
  serverRunning: string;
  serverBannerUrl: string;
  serverPreviewUrl: string;
  serverShutdown: string;
  serverBannerRenderFail: string;

  // ── Vorschau-Seite ──
  previewTitle: string;
  previewSubtitle: string;
  previewRefresh: string;
  previewEndpoints: string;
}

const de: I18nStrings = {
  // Banner
  dateLocale: "de-DE",
  online: "ONLINE",
  channels: "CHANNELS",
  uptime: "UPTIME",
  ping: "PING",
  noPlayers: "Keine Spieler online",
  lastJoined: "Zuletzt",
  sparklineLabel: "ONLINE VERLAUF",
  sparklineLoading: "Daten werden gesammelt…",

  // Config
  configNotFound: "config.json nicht gefunden! Kopiere config.example.json → config.json",

  // Font
  fontLoaded: "Font geladen",

  // TeamSpeak
  tsConnecting: "Verbinde zu",
  tsConnected: "Verbunden!",
  tsConnectionLost: "Verbindung verloren. Reconnect in 10s...",
  tsError: "Fehler",
  tsConnectionFailed: "Verbindung fehlgeschlagen",
  tsRetry: "Retry in 10s...",
  tsServerInfoError: "serverInfo Fehler",

  // Server
  serverBannerError: "Banner-Render Fehler",
  serverRunning: "Läuft auf Port",
  serverBannerUrl: "Banner",
  serverPreviewUrl: "Vorschau",
  serverShutdown: "Herunterfahren...",
  serverBannerRenderFail: "Banner konnte nicht gerendert werden",

  // Vorschau
  previewTitle: "TeamSpeak Banner",
  previewSubtitle: "Live-Vorschau – aktualisiert sich automatisch",
  previewRefresh: "Banner aktualisieren",
  previewEndpoints: "Endpunkte",
};

const en: I18nStrings = {
  // Banner
  dateLocale: "en-US",
  online: "ONLINE",
  channels: "CHANNELS",
  uptime: "UPTIME",
  ping: "PING",
  noPlayers: "No players online",
  lastJoined: "Last joined",
  sparklineLabel: "ONLINE HISTORY",
  sparklineLoading: "Collecting data…",

  // Config
  configNotFound: "config.json not found! Copy config.example.json → config.json",

  // Font
  fontLoaded: "Font loaded",

  // TeamSpeak
  tsConnecting: "Connecting to",
  tsConnected: "Connected!",
  tsConnectionLost: "Connection lost. Reconnect in 10s...",
  tsError: "Error",
  tsConnectionFailed: "Connection failed",
  tsRetry: "Retry in 10s...",
  tsServerInfoError: "serverInfo error",

  // Server
  serverBannerError: "Banner render error",
  serverRunning: "Running on port",
  serverBannerUrl: "Banner",
  serverPreviewUrl: "Preview",
  serverShutdown: "Shutting down...",
  serverBannerRenderFail: "Could not render banner",

  // Preview
  previewTitle: "TeamSpeak Banner",
  previewSubtitle: "Live preview – auto-refreshing",
  previewRefresh: "Refresh banner",
  previewEndpoints: "Endpoints",
};

const languages: Record<string, I18nStrings> = { de, en };

let currentLang: I18nStrings = de;

/**
 * Sprache initialisieren. Fallback: "de"
 */
export function initI18n(lang: string): void {
  currentLang = languages[lang] ?? de;
  console.log(`[i18n] Language: ${lang}`);
}

/**
 * Übersetzungs-Objekt abrufen
 */
export function t(): I18nStrings {
  return currentLang;
}
