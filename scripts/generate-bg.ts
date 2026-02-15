/**
 * Generiert ein Standard-Hintergrundbild (1024x300) als Platzhalter.
 * Einmal ausführen: npx tsx scripts/generate-bg.ts
 */
import { createCanvas } from "canvas";
import fs from "node:fs";
import path from "node:path";

const W = 1024;
const H = 300;
const canvas = createCanvas(W, H);
const ctx = canvas.getContext("2d");

// Gradient
const grad = ctx.createLinearGradient(0, 0, W, H);
grad.addColorStop(0, "#0f0c29");
grad.addColorStop(0.4, "#302b63");
grad.addColorStop(0.7, "#24243e");
grad.addColorStop(1, "#0f0c29");
ctx.fillStyle = grad;
ctx.fillRect(0, 0, W, H);

// Subtle grid pattern
ctx.strokeStyle = "rgba(255, 255, 255, 0.03)";
ctx.lineWidth = 1;
for (let x = 0; x < W; x += 40) {
  ctx.beginPath();
  ctx.moveTo(x, 0);
  ctx.lineTo(x, H);
  ctx.stroke();
}
for (let y = 0; y < H; y += 40) {
  ctx.beginPath();
  ctx.moveTo(0, y);
  ctx.lineTo(W, y);
  ctx.stroke();
}

// Subtle circles
for (let i = 0; i < 6; i++) {
  const cx = Math.random() * W;
  const cy = Math.random() * H;
  const r = 30 + Math.random() * 80;
  const circleGrad = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
  circleGrad.addColorStop(0, "rgba(0, 180, 216, 0.08)");
  circleGrad.addColorStop(1, "transparent");
  ctx.fillStyle = circleGrad;
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, Math.PI * 2);
  ctx.fill();
}

const outPath = path.resolve("assets/background.png");
const buffer = canvas.toBuffer("image/png");
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, buffer);
console.log(`Background erstellt: ${outPath} (${buffer.length} bytes)`);
