import express from "express";
import cors from "cors";
import { appConfig } from "./config.js";
import { t } from "./i18n.js";
import { initTeamSpeak, getServerInfo, getClients, getChannels, disconnectTeamSpeak } from "./teamspeak.js";
import { renderBanner } from "./renderer.js";

const app = express();
app.use(cors());

// ── Banner als PNG Bild ──
app.get("/banner.png", async (_req, res) => {
  try {
    const buffer = await renderBanner();
    res.set({
      "Content-Type": "image/png",
      "Content-Length": buffer.length.toString(),
      "Cache-Control": `public, max-age=${appConfig.cacheTTL}`,
      "X-Banner-System": "ts-banner/1.0",
    });
    res.send(buffer);
  } catch (err: any) {
    console.error(`[Server] ${t().serverBannerError}:`, err);
    console.error("[Server] Stack:", err?.stack);
    res.status(500).json({ error: t().serverBannerRenderFail, details: err?.message });
  }
});

// ── JSON API: Server-Info ──
app.get("/api/info", async (_req, res) => {
  try {
    const info = await getServerInfo();
    res.json(info);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// ── JSON API: Online Clients ──
app.get("/api/clients", async (_req, res) => {
  try {
    const clients = await getClients();
    res.json(clients);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// ── JSON API: Channels ──
app.get("/api/channels", async (_req, res) => {
  try {
    const channels = await getChannels();
    res.json(channels);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

// ── Health Check ──
app.get("/health", (_req, res) => {
  res.json({ status: "ok", uptime: process.uptime() });
});

// ── Vorschau-Seite ──
app.get("/", (_req, res) => {
  const i = t();
  res.send(`<!DOCTYPE html>
<html lang="${appConfig.lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${i.previewTitle}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background: #0d1117;
      color: #e6edf3;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 20px;
    }
    h1 {
      font-size: 1.5rem;
      margin-bottom: 10px;
      color: #58a6ff;
    }
    p { color: #8b949e; margin-bottom: 20px; font-size: 0.9rem; }
    .banner-container {
      border: 1px solid #30363d;
      border-radius: 12px;
      overflow: hidden;
      box-shadow: 0 8px 32px rgba(0,0,0,0.4);
    }
    img { display: block; max-width: 100%; height: auto; }
    .info {
      margin-top: 20px;
      background: #161b22;
      border: 1px solid #30363d;
      border-radius: 8px;
      padding: 16px 20px;
      max-width: 600px;
      width: 100%;
    }
    .info h2 { font-size: 1rem; color: #58a6ff; margin-bottom: 8px; }
    .info code {
      background: #0d1117;
      padding: 2px 6px;
      border-radius: 4px;
      color: #7ee787;
      font-size: 0.85rem;
    }
    .info p { margin: 6px 0; }
    .refresh-btn {
      margin-top: 12px;
      background: #238636;
      color: #fff;
      border: none;
      padding: 8px 18px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.85rem;
    }
    .refresh-btn:hover { background: #2ea043; }
  </style>
</head>
<body>
  <h1>${i.previewTitle}</h1>
  <p>${i.previewSubtitle} &bull; Auto-Refresh ${appConfig.cacheTTL}s</p>
  <div class="banner-container">
    <img id="banner" src="/banner.png" alt="${i.previewTitle}" />
  </div>
  <div class="info">
    <h2>${i.previewEndpoints}</h2>
    <p>Banner-URL: <code>/banner.png</code></p>
    <p>Server-Info: <code>/api/info</code></p>
    <p>Client-Liste: <code>/api/clients</code></p>
    <p>Channel-Liste: <code>/api/channels</code></p>
    <button class="refresh-btn" onclick="document.getElementById('banner').src='/banner.png?t='+Date.now()">${i.previewRefresh}</button>
  </div>
  <script>
    setInterval(() => {
      document.getElementById('banner').src = '/banner.png?t=' + Date.now();
    }, ${appConfig.cacheTTL * 1000});
  </script>
</body>
</html>`);
});

// ── Server starten ──
async function start() {
  console.log("╔══════════════════════════════════════╗");
  console.log("║   TeamSpeak Banner System v1.0       ║");
  console.log("╚══════════════════════════════════════╝");

  initTeamSpeak().catch(console.error);

  app.listen(appConfig.port, () => {
    console.log(`[Server] ${t().serverRunning} ${appConfig.port}`);
    console.log(`[Server] ${t().serverBannerUrl}: http://localhost:${appConfig.port}/banner.png`);
    console.log(`[Server] ${t().serverPreviewUrl}: http://localhost:${appConfig.port}/`);
  });
}

// ── Graceful Shutdown ──
process.on("SIGINT", async () => {
  console.log(`\n[Server] ${t().serverShutdown}`);
  await disconnectTeamSpeak();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  await disconnectTeamSpeak();
  process.exit(0);
});

start().catch(console.error);
