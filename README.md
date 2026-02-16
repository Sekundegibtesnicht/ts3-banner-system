# TBS – TeamSpeak Banner System

> by **Greenbox Studio**

Dynamisches TeamSpeak Server-Banner System mit TypeScript, Express & Canvas.  
Generiert live ein PNG-Bannerbild mit Serverdaten – perfekt für nginx.

![Banner Preview](https://img.shields.io/badge/Version-1.0.0-blue) ![Node](https://img.shields.io/badge/Node.js-18%2B-green) ![License](https://img.shields.io/badge/License-ISC-lightgrey)

## Installation (1 Befehl)

```bash
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

Oder manuell:

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git
cd ts3-banner-system
sudo ./install.sh
```

Der Installer hat ein **interaktives TUI** mit:
- ASCII-Art Header, Fortschrittsbalken & Spinner-Animationen
- Schritt-für-Schritt Anzeige `[3/8] Install Node.js`
- Sprachauswahl (🇩🇪 Deutsch / 🇬🇧 English) beim Start
- Interaktive Konfiguration der TS3-Zugangsdaten
- Automatisches systemd Service Setup & optional nginx
- Update: einfach denselben Befehl erneut ausführen (`git pull`)

## Features

- **Live Banner** – Dynamisch generiertes PNG unter `/banner.png`
- **ServerQuery** – Automatische Verbindung zum TeamSpeak mit Reconnect
- **Caching** – Konfigurierbares TTL für Performance
- **JSON API** – Server-Info, Client-Liste, Channel-Liste
- **Vorschau** – Eingebaute Web-Vorschau mit Auto-Refresh
- **nginx-ready** – Konfiguration & systemd Service inklusive
- **Multi-Language** – Deutsch & Englisch (erweiterbar)
- **Konfigurierbar** – Alle Features einzeln ein/ausschaltbar
- **Git-basiert** – Updates per `git pull` oder einfach Installer erneut ausführen
- **TUI Installer** – Fortschrittsbalken, Spinner, farbige Status-Icons

### Banner-Features (einzeln konfigurierbar)

| Feature | Beschreibung |
|---------|-------------|
| Clock | Uhrzeit + Datum mit konfigurierbarer Zeitzone |
| User Chips | Online-Spieler als Chips mit Status-Punkt |
| Progress Bar | Visueller Balken für Spielerauslastung |
| Sparkline | Mini-Graph der Online-History |
| Top Channel | Meistbesuchter Channel |
| Last Joined | Zuletzt beigetretener Spieler |
| Particles | Dekorative Sterne im Hintergrund |
| Accent Glow | Leuchteffekt hinter Cards |
| Gradient Line | Farbverlauf am unteren Rand |
| Event Text | Farbiger Badge mit Event-Text |
| Logo | Hintergrund-Watermark (eigenes Bild) |

## Schnellstart (lokal / Development)

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git
cd ts3-banner-system
npm install
cp config.example.json config.json
nano config.json   # TeamSpeak-Daten eintragen!

# Development (mit auto-reload)
npm run dev

# Production
npm run build
npm start
```

Das Banner ist dann erreichbar unter: `http://localhost:3200/banner.png`

## Endpoints

| Endpoint | Beschreibung |
|----------|-------------|
| `/banner.png` | Banner als PNG-Bild |
| `/api/info` | Server-Infos (JSON) |
| `/api/clients` | Online-Clients (JSON) |
| `/api/channels` | Channel-Liste (JSON) |
| `/health` | Health-Check |
| `/` | Web-Vorschau mit Auto-Refresh |

## Konfiguration

Alle Einstellungen in `config.json` (siehe `config.example.json`):

```jsonc
{
  "port": 3200,                    // Server-Port

  "teamspeak": {
    "host": "127.0.0.1",           // TS3 Server IP
    "queryPort": 10011,            // ServerQuery Port
    "serverPort": 9987,            // TS3 Server Port
    "username": "serveradmin",
    "password": "CHANGE_ME"
  },

  "banner": {
    "width": 1024,                 // Banner-Breite (px)
    "height": 300,                 // Banner-Höhe (px)
    "background": "assets/background.png",
    "font": "",                    // Pfad zu .ttf (leer = System-Font)
    "logo": "",                    // Pfad zu Logo-Bild (Watermark)
    "timezone": "Europe/Berlin",

    "colors": {
      "primary": "#ffffff",
      "secondary": "#8b949e",
      "accent": "#00b4d8",         // Hauptakzentfarbe
      "accentSecondary": "#7c3aed",
      "online": "#34d399",         // Online-Status
      "away": "#fbbf24",           // Away-Status
      "cardBg": "rgba(255, 255, 255, 0.05)",
      "cardBorder": "rgba(255, 255, 255, 0.08)"
    },

    "features": {                  // Einzeln ein/ausschaltbar
      "clock": true,
      "userChips": true,
      "progressBar": true,
      "sparkline": true,
      "topChannel": true,
      "lastJoined": true,
      "particles": true,
      "accentGlow": true,
      "gradientLine": true,
      "eventText": ""              // Leer = deaktiviert
    }
  },

  "lang": "de",                   // "de" oder "en"
  "cacheTTL": 30                   // Cache in Sekunden
}
```

## Linux Server Deployment

**Schnellinstallation (1 Befehl):**

```bash
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

Der Installer fragt interaktiv nach Sprache, TS3-Daten und richtet alles automatisch ein: 
git clone → npm install → TypeScript build → systemd Service → optional nginx.

**Manuell:**

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git /opt/ts-banner
cd /opt/ts-banner
sudo ./install.sh
```

**Update:**

```bash
# Einfach Installer erneut ausführen – er macht automatisch git pull
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

**Nützliche Befehle:**

```bash
systemctl status ts-banner      # Status
journalctl -u ts-banner -f       # Logs
systemctl restart ts-banner      # Neustart
nano /opt/ts-banner/config.json  # Config bearbeiten
```

## Eigene Sprache hinzufügen

In `src/i18n.ts` ein neues Sprach-Objekt anlegen:

```typescript
const fr: I18nStrings = {
  dateLocale: "fr-FR",
  online: "EN LIGNE",
  channels: "CANAUX",
  // ... alle Keys ausfüllen
};

// In languages registrieren:
const languages: Record<string, I18nStrings> = { de, en, fr };
```

Dann in `config.json`: `"lang": "fr"`

## Projektstruktur

```
├── src/
│   ├── config.ts       # Config laden & typen
│   ├── i18n.ts         # Sprach-System (de/en)
│   ├── types.ts        # TypeScript Interfaces
│   ├── teamspeak.ts    # TS3 ServerQuery Client
│   ├── history.ts      # Online-History für Sparkline
│   ├── renderer.ts     # Canvas Banner-Rendering
│   └── server.ts       # Express HTTP Server
├── assets/
│   └── background.png  # Banner-Hintergrund
├── config.example.json # Beispiel-Konfiguration
├── config.json         # Deine Konfiguration (gitignored)
├── install.sh          # Linux Auto-Installer
├── nginx.conf          # nginx Reverse Proxy Config
├── ts-banner.service   # systemd Service
├── package.json
└── tsconfig.json
```

## Voraussetzungen

- **Node.js 18+**
- **TeamSpeak 3 Server** mit aktiviertem ServerQuery
- Für `canvas`: Build-Tools (`build-essential`, `libcairo2-dev`, etc. – werden von `install.sh` automatisch installiert)

## License

ISC – Greenbox Studio
