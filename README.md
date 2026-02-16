# TBS – TeamSpeak Banner System

> by **Greenbox Studio**

Dynamic TeamSpeak server banner system built with TypeScript, Express & Canvas.  
Generates a live PNG banner image with server data – perfect for nginx.

![Version](https://img.shields.io/badge/Version-1.0.0-blue) ![Node](https://img.shields.io/badge/Node.js-18%2B-green) ![License](https://img.shields.io/badge/License-ISC-lightgrey)

## Installation (1 command)

```bash
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

Or manually:

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git
cd ts3-banner-system
sudo ./install.sh
```

The installer features a **graphical UI** (whiptail) with:
- Language selection (🇩🇪 German / 🇬🇧 English)
- Progress bar with live step tracking
- Interactive forms for TS3 credentials
- Automatic systemd service setup & optional nginx
- Update support – just run the same command again (`git pull`)

## Features

- **Live Banner** – Dynamically rendered PNG at `/banner.png`
- **ServerQuery** – Auto-connecting TeamSpeak client with reconnect
- **Caching** – Configurable TTL for performance
- **JSON API** – Server info, client list, channel list
- **Preview** – Built-in web preview with auto-refresh
- **nginx-ready** – Config & systemd service included
- **Multi-Language** – German & English (extensible)
- **Configurable** – All features individually toggleable
- **Git-based** – Update via `git pull` or re-run installer
- **GUI Installer** – whiptail-based graphical dialogs & progress bar

### Banner Features (individually configurable)

| Feature | Description |
|---------|-------------|
| Clock | Time & date with configurable timezone |
| User Chips | Online players as chips with status dot |
| Progress Bar | Visual bar for player capacity |
| Sparkline | Mini graph of online history |
| Top Channel | Most populated channel |
| Last Joined | Last player who connected |
| Particles | Decorative stars in the background |
| Accent Glow | Glow effect behind cards |
| Gradient Line | Color gradient at the bottom |
| Event Text | Colored badge with event text |
| Logo | Background watermark (custom image) |

## Quick Start (local / Development)

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git
cd ts3-banner-system
npm install
cp config.example.json config.json
nano config.json   # Enter your TeamSpeak credentials!

# Development (with auto-reload)
npm run dev

# Production
npm run build
npm start
```

Banner available at: `http://localhost:3200/banner.png`

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/banner.png` | Banner as PNG image |
| `/api/info` | Server info (JSON) |
| `/api/clients` | Online clients (JSON) |
| `/api/channels` | Channel list (JSON) |
| `/health` | Health check |
| `/` | Web preview with auto-refresh |

## Configuration

All settings in `config.json` (see `config.example.json`):

```jsonc
{
  "port": 3200,                    // Server port

  "teamspeak": {
    "host": "127.0.0.1",           // TS3 server IP
    "queryPort": 10011,            // ServerQuery port
    "serverPort": 9987,            // TS3 server port
    "username": "serveradmin",
    "password": "CHANGE_ME"
  },

  "banner": {
    "width": 1024,                 // Banner width (px)
    "height": 300,                 // Banner height (px)
    "background": "assets/background.png",
    "font": "",                    // Path to .ttf (empty = system font)
    "logo": "",                    // Path to logo image (watermark)
    "timezone": "Europe/Berlin",

    "colors": {
      "primary": "#ffffff",
      "secondary": "#8b949e",
      "accent": "#00b4d8",         // Main accent color
      "accentSecondary": "#7c3aed",
      "online": "#34d399",         // Online status
      "away": "#fbbf24",           // Away status
      "cardBg": "rgba(255, 255, 255, 0.05)",
      "cardBorder": "rgba(255, 255, 255, 0.08)"
    },

    "features": {                  // Toggle individually
      "clock": true,
      "userChips": true,
      "progressBar": true,
      "sparkline": true,
      "topChannel": true,
      "lastJoined": true,
      "particles": true,
      "accentGlow": true,
      "gradientLine": true,
      "eventText": ""              // Empty = disabled
    }
  },

  "lang": "de",                   // "de" or "en"
  "cacheTTL": 30                   // Cache in seconds
}
```

## Linux Server Deployment

**Quick install (1 command):**

```bash
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

The installer guides you through language, TS3 credentials and sets everything up automatically:  
git clone → npm install → TypeScript build → systemd service → optional nginx.

**Manual:**

```bash
git clone https://github.com/Sekundegibtesnicht/ts3-banner-system.git /opt/ts-banner
cd /opt/ts-banner
sudo ./install.sh
```

**Update:**

```bash
# Just re-run the installer – it automatically does git pull
bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
```

### Install Location

TBS is installed to `/opt/ts-banner/`. The config file is at `/opt/ts-banner/config.json`.

### Restart after Config Changes

After editing `config.json`, restart the service to apply changes:

```bash
nano /opt/ts-banner/config.json      # Edit config
sudo systemctl restart ts-banner     # Apply changes
```

### Autostart

During installation, the installer asks whether TBS should start on boot.  
You can change this anytime:

```bash
sudo systemctl enable ts-banner      # Enable autostart
sudo systemctl disable ts-banner     # Disable autostart
```

### Useful Commands

```bash
systemctl status ts-banner           # Status
journalctl -u ts-banner -f           # Live logs
sudo systemctl restart ts-banner     # Restart
sudo systemctl stop ts-banner        # Stop
sudo systemctl start ts-banner       # Start
nano /opt/ts-banner/config.json      # Edit config
```

## Adding a Language

Add a new language object in `src/i18n.ts`:

```typescript
const fr: I18nStrings = {
  dateLocale: "fr-FR",
  online: "EN LIGNE",
  channels: "CANAUX",
  // ... fill in all keys
};

// Register in languages:
const languages: Record<string, I18nStrings> = { de, en, fr };
```

Then in `config.json`: `"lang": "fr"`

## Project Structure

```
├── src/
│   ├── config.ts       # Config loading & types
│   ├── i18n.ts         # Language system (de/en)
│   ├── types.ts        # TypeScript interfaces
│   ├── teamspeak.ts    # TS3 ServerQuery client
│   ├── history.ts      # Online history for sparkline
│   ├── renderer.ts     # Canvas banner rendering
│   └── server.ts       # Express HTTP server
├── assets/
│   └── background.png  # Banner background
├── config.example.json # Example configuration
├── config.json         # Your configuration (gitignored)
├── install.sh          # Linux GUI installer
├── nginx.conf          # nginx reverse proxy config
├── ts-banner.service   # systemd service
├── package.json
└── tsconfig.json
```

## Requirements

- **Node.js 18+**
- **TeamSpeak 3 Server** with ServerQuery enabled
- For `canvas`: build tools (`build-essential`, `libcairo2-dev`, etc. – installed automatically by `install.sh`)

## License

ISC – Greenbox Studio
