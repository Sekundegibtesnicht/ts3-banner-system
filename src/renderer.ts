import { createCanvas, loadImage, registerFont } from "canvas";
import { appConfig } from "./config.js";
import { t } from "./i18n.js";
import { getServerInfo, getClients, getTopChannel, findNewestClient, getLastJoined } from "./teamspeak.js";
import { getOnlineHistory, getHistoryMax } from "./history.js";
import type { ServerInfo, ClientInfo } from "./types.js";
import path from "node:path";
import fs from "node:fs";

// ── Font registrieren ──
const fontPath = appConfig.banner.font;
if (fontPath && fs.existsSync(fontPath)) {
  registerFont(path.resolve(fontPath), { family: "BannerFont" });
  console.log(`[Banner] ${t().fontLoaded}: ${fontPath}`);
}

const F = fontPath && fs.existsSync(fontPath) ? "BannerFont" : "sans-serif";

// ── Cache ──
let cachedBuffer: Buffer | null = null;
let cacheTimestamp = 0;

// ══════════════════════════════════════════════════════
//  HELPERS
// ══════════════════════════════════════════════════════

function formatUptime(seconds: number): string {
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  if (d > 0) return `${d}d ${h}h`;
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m`;
}

function roundRect(ctx: any, x: number, y: number, w: number, h: number, r: number): void {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
}

function hexToRgba(hex: string, alpha: number): string {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

/** Seeded pseudo-random für konsistente Partikel-Positionen */
function seededRandom(seed: number): () => number {
  let s = seed;
  return () => {
    s = (s * 16807 + 0) % 2147483647;
    return s / 2147483647;
  };
}

// ══════════════════════════════════════════════════════
//  DRAWING PRIMITIVES
// ══════════════════════════════════════════════════════

function drawParticles(ctx: any, W: number, H: number, accent: string): void {
  const rng = seededRandom(42);
  const count = 35;

  for (let i = 0; i < count; i++) {
    const x = rng() * W;
    const y = rng() * H;
    const size = rng() * 2 + 0.5;
    const alpha = rng() * 0.35 + 0.05;

    ctx.beginPath();
    ctx.arc(x, y, size, 0, Math.PI * 2);
    ctx.fillStyle = hexToRgba(accent, alpha);
    ctx.fill();
  }
}

function drawAccentGlow(ctx: any, x: number, y: number, w: number, h: number, color: string): void {
  const glow = ctx.createRadialGradient(x + w / 2, y + h / 2, 0, x + w / 2, y + h / 2, Math.max(w, h));
  glow.addColorStop(0, hexToRgba(color, 0.12));
  glow.addColorStop(0.5, hexToRgba(color, 0.04));
  glow.addColorStop(1, "rgba(0, 0, 0, 0)");
  ctx.fillStyle = glow;
  ctx.fillRect(x - 20, y - 20, w + 40, h + 40);
}

function drawStatCard(
  ctx: any,
  x: number,
  y: number,
  w: number,
  h: number,
  value: string,
  label: string,
  colors: typeof appConfig.banner.colors,
  glowEnabled: boolean
): void {
  if (glowEnabled) {
    drawAccentGlow(ctx, x, y, w, h, colors.accent);
  }

  // Card BG
  ctx.fillStyle = colors.cardBg;
  roundRect(ctx, x, y, w, h, 8);
  ctx.fill();
  ctx.strokeStyle = colors.cardBorder;
  ctx.lineWidth = 1;
  roundRect(ctx, x, y, w, h, 8);
  ctx.stroke();

  // Value
  ctx.font = `bold 20px "${F}"`;
  ctx.fillStyle = colors.accent;
  ctx.textAlign = "center";
  ctx.fillText(value, x + w / 2, y + 28);

  // Label
  ctx.font = `11px "${F}"`;
  ctx.fillStyle = colors.secondary;
  ctx.fillText(label, x + w / 2, y + 46);
}

function drawProgressBar(
  ctx: any,
  x: number,
  y: number,
  w: number,
  h: number,
  current: number,
  max: number,
  colors: typeof appConfig.banner.colors
): void {
  const ratio = max > 0 ? Math.min(current / max, 1) : 0;

  // Track BG
  roundRect(ctx, x, y, w, h, h / 2);
  ctx.fillStyle = "rgba(255, 255, 255, 0.06)";
  ctx.fill();

  // Filled portion
  if (ratio > 0) {
    const fillW = Math.max(h, w * ratio); // mindestens runde Ecke
    const grad = ctx.createLinearGradient(x, y, x + fillW, y);
    grad.addColorStop(0, colors.accent);
    grad.addColorStop(1, colors.accentSecondary);
    roundRect(ctx, x, y, fillW, h, h / 2);
    ctx.fillStyle = grad;
    ctx.fill();
  }

  // Percentage text
  ctx.font = `bold 10px "${F}"`;
  ctx.fillStyle = colors.primary;
  ctx.textAlign = "left";
  ctx.fillText(`${current}/${max}  (${Math.round(ratio * 100)}%)`, x + w + 10, y + h / 2 + 4);
}

function drawSparkline(
  ctx: any,
  x: number,
  y: number,
  w: number,
  h: number,
  data: number[],
  maxVal: number,
  colors: typeof appConfig.banner.colors
): void {
  if (data.length < 2) {
    ctx.font = `11px "${F}"`;
    ctx.fillStyle = colors.secondary;
    ctx.textAlign = "left";
    ctx.fillText(t().sparklineLoading, x, y + h / 2 + 4);
    return;
  }

  // BG Card
  roundRect(ctx, x, y, w, h, 6);
  ctx.fillStyle = "rgba(255, 255, 255, 0.03)";
  ctx.fill();

  const padding = 6;
  const graphW = w - padding * 2;
  const graphH = h - padding * 2;
  const step = graphW / (data.length - 1);

  // Fill area
  ctx.beginPath();
  ctx.moveTo(x + padding, y + padding + graphH);
  data.forEach((val, i) => {
    const px = x + padding + i * step;
    const py = y + padding + graphH - (val / maxVal) * graphH;
    if (i === 0) ctx.lineTo(px, py);
    else ctx.lineTo(px, py);
  });
  ctx.lineTo(x + padding + (data.length - 1) * step, y + padding + graphH);
  ctx.closePath();

  const fillGrad = ctx.createLinearGradient(x, y, x, y + h);
  fillGrad.addColorStop(0, hexToRgba(colors.accent, 0.25));
  fillGrad.addColorStop(1, hexToRgba(colors.accent, 0.02));
  ctx.fillStyle = fillGrad;
  ctx.fill();

  // Line
  ctx.beginPath();
  data.forEach((val, i) => {
    const px = x + padding + i * step;
    const py = y + padding + graphH - (val / maxVal) * graphH;
    if (i === 0) ctx.moveTo(px, py);
    else ctx.lineTo(px, py);
  });
  ctx.strokeStyle = colors.accent;
  ctx.lineWidth = 1.5;
  ctx.stroke();

  // Latest dot
  const lastX = x + padding + (data.length - 1) * step;
  const lastY = y + padding + graphH - (data[data.length - 1] / maxVal) * graphH;
  ctx.beginPath();
  ctx.arc(lastX, lastY, 3, 0, Math.PI * 2);
  ctx.fillStyle = colors.accent;
  ctx.fill();
}

function drawUserChips(
  ctx: any,
  x: number,
  y: number,
  maxWidth: number,
  clients: ClientInfo[],
  colors: typeof appConfig.banner.colors
): number {
  if (clients.length === 0) {
    ctx.font = `12px "${F}"`;
    ctx.fillStyle = colors.secondary;
    ctx.textAlign = "left";
    ctx.fillText(t().noPlayers, x, y + 16);
    return y + 28;
  }

  const maxShow = 6;
  const shown = clients.slice(0, maxShow);
  let chipX = x;

  ctx.textAlign = "left";

  for (const client of shown) {
    const name =
      client.nickname.length > 14
        ? client.nickname.slice(0, 12) + "…"
        : client.nickname;

    ctx.font = `12px "${F}"`;
    const nameW = ctx.measureText(name).width;
    const chipW = nameW + 24;
    const chipH = 24;

    if (chipX + chipW > x + maxWidth) break;

    // Chip BG
    ctx.fillStyle = colors.cardBg;
    roundRect(ctx, chipX, y, chipW, chipH, 12);
    ctx.fill();
    ctx.strokeStyle = colors.cardBorder;
    ctx.lineWidth = 0.5;
    roundRect(ctx, chipX, y, chipW, chipH, 12);
    ctx.stroke();

    // Status dot
    const dotColor = client.isAway ? colors.away : colors.online;
    ctx.beginPath();
    ctx.arc(chipX + 10, y + chipH / 2, 2.5, 0, Math.PI * 2);
    ctx.fillStyle = dotColor;
    ctx.fill();

    // Name
    ctx.fillStyle = colors.primary;
    ctx.font = `12px "${F}"`;
    ctx.fillText(name, chipX + 18, y + 16);

    chipX += chipW + 6;
  }

  if (clients.length > maxShow) {
    ctx.fillStyle = colors.secondary;
    ctx.font = `11px "${F}"`;
    ctx.fillText(`+${clients.length - maxShow}`, chipX + 4, y + 16);
  }

  return y + 30;
}

// ══════════════════════════════════════════════════════
//  MAIN RENDER
// ══════════════════════════════════════════════════════

export async function renderBanner(): Promise<Buffer> {
  const now = Date.now();
  if (cachedBuffer && now - cacheTimestamp < appConfig.cacheTTL * 1000) {
    return cachedBuffer;
  }

  const { width: W, height: H, background, colors, features, logo, timezone } = appConfig.banner;
  const canvas = createCanvas(W, H);
  const ctx = canvas.getContext("2d");

  // ─── 1. Hintergrund ───
  const bgPath = path.resolve(background);
  if (background && fs.existsSync(bgPath)) {
    try {
      const img = await loadImage(bgPath);
      ctx.drawImage(img, 0, 0, W, H);
    } catch {
      drawDefaultBg(ctx, W, H);
    }
  } else {
    drawDefaultBg(ctx, W, H);
  }

  // Dunkles Overlay
  const overlay = ctx.createLinearGradient(0, 0, 0, H);
  overlay.addColorStop(0, "rgba(8, 10, 18, 0.60)");
  overlay.addColorStop(1, "rgba(8, 10, 18, 0.82)");
  ctx.fillStyle = overlay;
  ctx.fillRect(0, 0, W, H);

  // ─── 2. Logo als Hintergrund-Watermark ───
  if (logo && fs.existsSync(path.resolve(logo))) {
    try {
      const logoImg = await loadImage(path.resolve(logo));
      const logoSize = H * 0.75; // 75% der Bannerhöhe
      const logoX = W - logoSize - 40; // rechts positioniert
      const logoY = (H - logoSize) / 2; // vertikal zentriert

      ctx.save();
      ctx.globalAlpha = 0.07; // sehr dezent/durchsichtig
      ctx.drawImage(logoImg, logoX, logoY, logoSize, logoSize);
      ctx.restore();
    } catch {
      // Logo konnte nicht geladen werden
    }
  }

  // ─── 2b. Particles ───
  if (features.particles) {
    drawParticles(ctx, W, H, colors.accent);
  }

  // ─── 3. Daten laden ───
  const [info, clients, topChannel, newestClient] = await Promise.all([
    getServerInfo(),
    getClients(),
    features.topChannel ? getTopChannel() : Promise.resolve(null),
    features.lastJoined ? findNewestClient() : Promise.resolve(""),
  ]);

  const lastJoined = features.lastJoined ? getLastJoined() : "";
  const historyData = features.sparkline ? getOnlineHistory() : [];
  const historyMax = features.sparkline ? getHistoryMax() : 1;

  // ─── Layout Konstanten ───
  const LEFT_X = 36;
  const RIGHT_PANEL_W = 260;
  const RIGHT_X = W - RIGHT_PANEL_W - 30;
  const LEFT_MAX_W = RIGHT_X - LEFT_X - 20;

  let cursorY = 30; // vertikaler Cursor links

  // ─── 4. Servername ───
  const nameX = LEFT_X;

  ctx.font = `bold 28px "${F}"`;
  ctx.fillStyle = colors.primary;
  ctx.textAlign = "left";
  ctx.fillText(info.name, nameX, cursorY + 26);

  // Subtile Linie unter dem Namen
  const lineGrad = ctx.createLinearGradient(LEFT_X, cursorY + 38, LEFT_MAX_W + LEFT_X, cursorY + 38);
  lineGrad.addColorStop(0, hexToRgba(colors.accent, 0.5));
  lineGrad.addColorStop(1, "rgba(0, 0, 0, 0)");
  ctx.strokeStyle = lineGrad;
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.moveTo(LEFT_X, cursorY + 38);
  ctx.lineTo(LEFT_MAX_W + LEFT_X, cursorY + 38);
  ctx.stroke();

  cursorY += 50;

  // ─── 5. Event Text Badge ───
  if (features.eventText && features.eventText.length > 0) {
    const evtText = features.eventText;
    ctx.font = `bold 12px "${F}"`;
    const evtW = ctx.measureText(evtText).width + 20;
    const evtH = 22;
    const evtX = nameX;
    const evtY = cursorY - 6;

    // Badge BG
    const badgeGrad = ctx.createLinearGradient(evtX, evtY, evtX + evtW, evtY);
    badgeGrad.addColorStop(0, colors.accentSecondary);
    badgeGrad.addColorStop(1, colors.accent);
    roundRect(ctx, evtX, evtY, evtW, evtH, 4);
    ctx.fillStyle = badgeGrad;
    ctx.fill();

    // Badge Text
    ctx.fillStyle = "#ffffff";
    ctx.font = `bold 11px "${F}"`;
    ctx.textAlign = "left";
    ctx.fillText(evtText, evtX + 10, evtY + 15);

    cursorY += 22;
  }

  // ─── 6. Stat Cards ───
  const cardW = 120;
  const cardH = 56;
  const cardGap = 10;

  const stats = [
    { label: t().online, value: `${info.clientsOnline} / ${info.maxClients}` },
    { label: t().channels, value: `${info.channelsOnline}` },
    { label: t().uptime, value: formatUptime(info.uptime) },
  ];

  if (info.ping > 0) {
    stats.push({ label: t().ping, value: `${info.ping}ms` });
  }

  stats.forEach((stat, i) => {
    const cx = LEFT_X + i * (cardW + cardGap);
    drawStatCard(ctx, cx, cursorY, cardW, cardH, stat.value, stat.label, colors, features.accentGlow);
  });

  cursorY += cardH + 12;

  // ─── 7. Progress Bar ───
  if (features.progressBar) {
    const barW = Math.min(stats.length * (cardW + cardGap) - cardGap, LEFT_MAX_W * 0.55);
    drawProgressBar(ctx, LEFT_X, cursorY, barW, 10, info.clientsOnline, info.maxClients, colors);
    cursorY += 22;
  }

  // ─── 8. User Chips ───
  if (features.userChips) {
    cursorY = drawUserChips(ctx, LEFT_X, cursorY, LEFT_MAX_W, clients, colors);
    cursorY += 4;
  }

  // ─── 9. Top Channel + Last Joined (bottom left) ───
  const infoLineY = Math.max(cursorY, H - 50);
  ctx.textAlign = "left";
  ctx.font = `11px "${F}"`;

  let infoX = LEFT_X;

  if (features.topChannel && topChannel) {
    const tcName =
      topChannel.name.length > 22
        ? topChannel.name.slice(0, 20) + "…"
        : topChannel.name;

    // Icon
    ctx.fillStyle = colors.accent;
    ctx.font = `bold 11px "${F}"`;
    ctx.fillText("★", infoX, infoLineY);
    infoX += 14;

    ctx.fillStyle = colors.secondary;
    ctx.font = `11px "${F}"`;
    ctx.fillText(`${tcName} (${topChannel.clients})`, infoX, infoLineY);
    infoX += ctx.measureText(`${tcName} (${topChannel.clients})`).width + 20;
  }

  if (features.lastJoined) {
    const joinName = lastJoined || newestClient || "";
    if (joinName) {
      const jn = joinName.length > 18 ? joinName.slice(0, 16) + "…" : joinName;
      ctx.fillStyle = colors.accentSecondary;
      ctx.font = `bold 11px "${F}"`;
      ctx.fillText("→", infoX, infoLineY);
      infoX += 14;

      ctx.fillStyle = colors.secondary;
      ctx.font = `11px "${F}"`;
      ctx.fillText(`${t().lastJoined}: ${jn}`, infoX, infoLineY);
    }
  }

  // ═══════════════════════════════════════
  //  RECHTE SEITE
  // ═══════════════════════════════════════

  let rightCursorY = 26;

  // ─── 10. Clock ───
  if (features.clock) {
    const tz = timezone || "Europe/Berlin";
    const now2 = new Date();
    const dl = t().dateLocale;
    const timeStr = now2.toLocaleTimeString(dl, {
      hour: "2-digit",
      minute: "2-digit",
      timeZone: tz,
    });
    const dateStr = now2.toLocaleDateString(dl, {
      weekday: "short",
      day: "2-digit",
      month: "short",
      year: "numeric",
      timeZone: tz,
    });

    const clockW = RIGHT_PANEL_W;
    const clockH = 82;
    const clockX = RIGHT_X;
    const clockY = rightCursorY;

    // Clock card
    if (features.accentGlow) {
      drawAccentGlow(ctx, clockX, clockY, clockW, clockH, colors.accentSecondary);
    }
    ctx.fillStyle = colors.cardBg;
    roundRect(ctx, clockX, clockY, clockW, clockH, 10);
    ctx.fill();
    ctx.strokeStyle = colors.cardBorder;
    ctx.lineWidth = 1;
    roundRect(ctx, clockX, clockY, clockW, clockH, 10);
    ctx.stroke();

    // Time
    ctx.font = `bold 38px "${F}"`;
    ctx.fillStyle = colors.primary;
    ctx.textAlign = "center";
    ctx.fillText(timeStr, clockX + clockW / 2, clockY + 46);

    // Date
    ctx.font = `12px "${F}"`;
    ctx.fillStyle = colors.secondary;
    ctx.fillText(dateStr, clockX + clockW / 2, clockY + 68);

    rightCursorY += clockH + 14;
  }

  // ─── 11. Sparkline ───
  if (features.sparkline) {
    const sparkW = RIGHT_PANEL_W;
    const sparkH = 70;
    const sparkX = RIGHT_X;
    const sparkY = rightCursorY;

    // Label
    ctx.font = `10px "${F}"`;
    ctx.fillStyle = colors.secondary;
    ctx.textAlign = "left";
    ctx.fillText(t().sparklineLabel, sparkX + 6, sparkY - 4);

    drawSparkline(ctx, sparkX, sparkY, sparkW, sparkH, historyData, historyMax, colors);

    rightCursorY += sparkH + 14;
  }

  // ─── 12. Gradient Accent Line am unteren Rand ───
  if (features.gradientLine) {
    const lineH = 3;
    const grad = ctx.createLinearGradient(0, H - lineH, W, H - lineH);
    grad.addColorStop(0, hexToRgba(colors.accent, 0.9));
    grad.addColorStop(0.4, hexToRgba(colors.accentSecondary, 0.6));
    grad.addColorStop(1, "rgba(0, 0, 0, 0)");
    ctx.fillStyle = grad;
    ctx.fillRect(0, H - lineH, W, lineH);
  }

  // ── Buffer ──
  const buffer = canvas.toBuffer("image/png");
  cachedBuffer = buffer;
  cacheTimestamp = now;
  return buffer;
}

// ── Default Hintergrund ──

function drawDefaultBg(ctx: any, w: number, h: number): void {
  const grad = ctx.createLinearGradient(0, 0, w, h);
  grad.addColorStop(0, "#0a0e1a");
  grad.addColorStop(0.5, "#121829");
  grad.addColorStop(1, "#0a0e1a");
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, w, h);
}
