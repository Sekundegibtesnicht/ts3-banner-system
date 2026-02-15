#!/bin/bash
set -e

# ══════════════════════════════════════════════════
#  TeamSpeak Banner System – Linux Installer
# ══════════════════════════════════════════════════
#  Verwendung:
#    chmod +x install.sh
#    sudo ./install.sh
#
#  Voraussetzungen:
#    - Ubuntu/Debian (apt) oder kompatibel
#    - Node.js 18+ (wird installiert falls nicht vorhanden)
#    - Root-Rechte (sudo)
# ══════════════════════════════════════════════════

INSTALL_DIR="/opt/ts-banner"
SERVICE_NAME="ts-banner"
USER_NAME="ts-banner"

echo ""
echo "══════════════════════════════════════════════"
echo "  TeamSpeak Banner System – Installer"
echo "══════════════════════════════════════════════"
echo ""

# ── Root-Check ──
if [ "$EUID" -ne 0 ]; then
  echo "❌ Bitte als root ausführen: sudo ./install.sh"
  exit 1
fi

# ── Node.js prüfen / installieren ──
if ! command -v node &> /dev/null; then
  echo "📦 Node.js nicht gefunden. Installiere Node.js 20 LTS..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt-get install -y nodejs
else
  NODE_VERSION=$(node -v)
  echo "✅ Node.js gefunden: $NODE_VERSION"
fi

# ── System-Dependencies für node-canvas ──
echo "📦 Installiere System-Abhängigkeiten für node-canvas..."
apt-get update -qq
apt-get install -y build-essential libcairo2-dev libjpeg-dev libpango1.0-dev \
  libgif-dev librsvg2-dev pkg-config python3 2>/dev/null || true

# ── Benutzer erstellen ──
if ! id "$USER_NAME" &>/dev/null; then
  echo "👤 Erstelle System-Benutzer: $USER_NAME"
  useradd --system --no-create-home --shell /usr/sbin/nologin "$USER_NAME"
fi

# ── Installationsverzeichnis ──
echo "📁 Erstelle $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# ── Dateien kopieren ──
echo "📋 Kopiere Projektdaten..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Wichtige Dateien/Ordner kopieren
cp -r "$SCRIPT_DIR/src" "$INSTALL_DIR/"
cp -r "$SCRIPT_DIR/assets" "$INSTALL_DIR/" 2>/dev/null || true
cp "$SCRIPT_DIR/package.json" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/tsconfig.json" "$INSTALL_DIR/"

# Config: nur kopieren wenn noch nicht vorhanden
if [ ! -f "$INSTALL_DIR/config.json" ]; then
  if [ -f "$SCRIPT_DIR/config.example.json" ]; then
    cp "$SCRIPT_DIR/config.example.json" "$INSTALL_DIR/config.json"
    echo ""
    echo "⚠️  config.json wurde aus config.example.json erstellt!"
    echo "   Bitte anpassen: nano $INSTALL_DIR/config.json"
    echo ""
  fi
else
  echo "✅ config.json existiert bereits (wird nicht überschrieben)"
fi

# ── npm install ──
echo "📦 Installiere npm Abhängigkeiten..."
cd "$INSTALL_DIR"
npm install --omit=dev 2>&1 | tail -1

# ── TypeScript kompilieren ──
echo "🔨 Kompiliere TypeScript..."
npx tsc 2>&1 || {
  echo "❌ TypeScript-Kompilierung fehlgeschlagen!"
  echo "   Prüfe: cd $INSTALL_DIR && npx tsc"
  exit 1
}

# ── Berechtigungen setzen ──
echo "🔒 Setze Berechtigungen..."
chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR/config.json"

# ── systemd Service installieren ──
echo "⚙️  Installiere systemd Service..."
cp "$SCRIPT_DIR/ts-banner.service" "/etc/systemd/system/${SERVICE_NAME}.service"
systemctl daemon-reload
systemctl enable "$SERVICE_NAME"

echo ""
echo "══════════════════════════════════════════════"
echo "  ✅ Installation abgeschlossen!"
echo "══════════════════════════════════════════════"
echo ""
echo "  Nächste Schritte:"
echo ""
echo "  1. Config anpassen:"
echo "     nano $INSTALL_DIR/config.json"
echo ""
echo "  2. Service starten:"
echo "     systemctl start $SERVICE_NAME"
echo ""
echo "  3. Status prüfen:"
echo "     systemctl status $SERVICE_NAME"
echo ""
echo "  4. Logs anschauen:"
echo "     journalctl -u $SERVICE_NAME -f"
echo ""
echo "  5. Banner testen:"
echo "     curl http://localhost:3200/health"
echo ""
echo "  Optional: nginx einrichten"
echo "     cp $SCRIPT_DIR/nginx.conf /etc/nginx/sites-available/ts-banner"
echo "     ln -s /etc/nginx/sites-available/ts-banner /etc/nginx/sites-enabled/"
echo "     nginx -t && systemctl reload nginx"
echo ""
