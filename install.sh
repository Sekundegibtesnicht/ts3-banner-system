#!/bin/bash
# ══════════════════════════════════════════════════════════════════
#  TeamSpeak Banner System – Interactive Installer
#  https://github.com/Sekundegibtesnicht/ts3-banner-system
#
#  Usage:   chmod +x install.sh && sudo ./install.sh
#  Supports: Ubuntu 20+, Debian 11+
# ══════════════════════════════════════════════════════════════════
set -e

# ── Colors & Formatting ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Constants ──
INSTALL_DIR="/opt/ts-banner"
SERVICE_NAME="ts-banner"
USER_NAME="ts-banner"
REPO_URL="https://github.com/Sekundegibtesnicht/ts3-banner-system.git"
VERSION="1.0.0"

# ══════════════════════════════════════════════════
#  LANGUAGE SYSTEM
# ══════════════════════════════════════════════════

LANG_CODE="en"

# ── German ──
declare -A DE
DE[welcome]="Willkommen beim"
DE[version]="Version"
DE[select_lang]="Sprache wählen / Select language"
DE[german]="Deutsch"
DE[english]="English"
DE[choice]="Auswahl"
DE[root_error]="Bitte als root ausführen: sudo ./install.sh"
DE[checking_system]="Prüfe System"
DE[os_detected]="Betriebssystem erkannt"
DE[os_not_supported]="Nicht unterstützt! Nur Ubuntu/Debian."
DE[step]="Schritt"
DE[of]="von"
DE[installing_nodejs]="Node.js installieren"
DE[nodejs_found]="Node.js gefunden"
DE[nodejs_installing]="Node.js 20 LTS wird installiert..."
DE[nodejs_installed]="Node.js installiert"
DE[installing_deps]="System-Abhängigkeiten installieren"
DE[deps_canvas]="Installiere Build-Tools für node-canvas..."
DE[deps_done]="System-Abhängigkeiten installiert"
DE[creating_user]="System-Benutzer erstellen"
DE[user_exists]="Benutzer existiert bereits"
DE[user_created]="Benutzer erstellt"
DE[copying_files]="Projektdateien kopieren"
DE[files_copied]="Dateien kopiert"
DE[configure]="Konfiguration"
DE[configure_now]="Möchtest du jetzt konfigurieren? (j/n)"
DE[ts_host]="TeamSpeak Server IP/Hostname"
DE[ts_query_port]="ServerQuery Port"
DE[ts_server_port]="TeamSpeak Server Port"
DE[ts_username]="ServerQuery Benutzername"
DE[ts_password]="ServerQuery Passwort"
DE[banner_port]="Banner-System Port"
DE[config_saved]="Konfiguration gespeichert"
DE[config_later]="Config später anpassen: nano $INSTALL_DIR/config.json"
DE[installing_npm]="NPM Pakete installieren"
DE[npm_done]="NPM Pakete installiert"
DE[compiling]="TypeScript kompilieren"
DE[compile_done]="Kompilierung erfolgreich"
DE[compile_fail]="Kompilierung fehlgeschlagen!"
DE[permissions]="Berechtigungen setzen"
DE[permissions_done]="Berechtigungen gesetzt"
DE[service_install]="Systemd Service einrichten"
DE[service_enabled]="Service aktiviert & gestartet"
DE[setup_nginx]="nginx einrichten? (j/n)"
DE[nginx_not_found]="nginx nicht installiert – überspringe"
DE[nginx_configured]="nginx konfiguriert"
DE[nginx_domain]="Domain für Banner"
DE[complete]="Installation abgeschlossen!"
DE[summary]="Zusammenfassung"
DE[installed_to]="Installiert in"
DE[service_status]="Service Status"
DE[banner_url]="Banner URL"
DE[commands]="Nützliche Befehle"
DE[cmd_status]="Status prüfen"
DE[cmd_logs]="Live-Logs"
DE[cmd_restart]="Neustart"
DE[cmd_config]="Config bearbeiten"
DE[cmd_stop]="Stoppen"
DE[enjoy]="Viel Spaß mit deinem Banner!"
DE[yes]="j"
DE[default]="Standard"
DE[progress_bar_label]="Fortschritt"

# ── English ──
declare -A EN
EN[welcome]="Welcome to"
EN[version]="Version"
EN[select_lang]="Sprache wählen / Select language"
EN[german]="Deutsch"
EN[english]="English"
EN[choice]="Choice"
EN[root_error]="Please run as root: sudo ./install.sh"
EN[checking_system]="Checking system"
EN[os_detected]="OS detected"
EN[os_not_supported]="Not supported! Ubuntu/Debian only."
EN[step]="Step"
EN[of]="of"
EN[installing_nodejs]="Install Node.js"
EN[nodejs_found]="Node.js found"
EN[nodejs_installing]="Installing Node.js 20 LTS..."
EN[nodejs_installed]="Node.js installed"
EN[installing_deps]="Install system dependencies"
EN[deps_canvas]="Installing build tools for node-canvas..."
EN[deps_done]="System dependencies installed"
EN[creating_user]="Create system user"
EN[user_exists]="User already exists"
EN[user_created]="User created"
EN[copying_files]="Copy project files"
EN[files_copied]="Files copied"
EN[configure]="Configuration"
EN[configure_now]="Configure now? (y/n)"
EN[ts_host]="TeamSpeak Server IP/Hostname"
EN[ts_query_port]="ServerQuery Port"
EN[ts_server_port]="TeamSpeak Server Port"
EN[ts_username]="ServerQuery Username"
EN[ts_password]="ServerQuery Password"
EN[banner_port]="Banner system port"
EN[config_saved]="Configuration saved"
EN[config_later]="Edit config later: nano $INSTALL_DIR/config.json"
EN[installing_npm]="Install NPM packages"
EN[npm_done]="NPM packages installed"
EN[compiling]="Compile TypeScript"
EN[compile_done]="Compilation successful"
EN[compile_fail]="Compilation failed!"
EN[permissions]="Set permissions"
EN[permissions_done]="Permissions set"
EN[service_install]="Setup systemd service"
EN[service_enabled]="Service enabled & started"
EN[setup_nginx]="Setup nginx? (y/n)"
EN[nginx_not_found]="nginx not installed – skipping"
EN[nginx_configured]="nginx configured"
EN[nginx_domain]="Domain for banner"
EN[complete]="Installation complete!"
EN[summary]="Summary"
EN[installed_to]="Installed to"
EN[service_status]="Service status"
EN[banner_url]="Banner URL"
EN[commands]="Useful commands"
EN[cmd_status]="Check status"
EN[cmd_logs]="Live logs"
EN[cmd_restart]="Restart"
EN[cmd_config]="Edit config"
EN[cmd_stop]="Stop"
EN[enjoy]="Enjoy your banner!"
EN[yes]="y"
EN[default]="Default"
EN[progress_bar_label]="Progress"

# ── Get translated string ──
msg() {
  if [ "$LANG_CODE" = "de" ]; then
    echo "${DE[$1]}"
  else
    echo "${EN[$1]}"
  fi
}

# ══════════════════════════════════════════════════
#  UI HELPERS
# ══════════════════════════════════════════════════

banner_art() {
  echo -e "${CYAN}"
  cat << 'EOF'
  ╔════════════════════════════════════════════════════════════╗
  ║                                                            ║
  ║   ████████╗███████╗██████╗     ██████╗  █████╗ ███╗   ██╗  ║
  ║      ██╔══╝██╔════╝╚════██╗    ██╔══██╗██╔══██╗████╗  ██║  ║
  ║      ██║   ███████╗ █████╔╝    ██████╔╝███████║██╔██╗ ██║  ║
  ║      ██║   ╚════██║ ╚═══██╗    ██╔══██╗██╔══██║██║╚██╗██║  ║
  ║      ██║   ███████║██████╔╝    ██████╔╝██║  ██║██║ ╚████║  ║
  ║      ╚═╝   ╚══════╝╚═════╝     ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝  ║
  ║                                                            ║
  ║              TeamSpeak Banner System                       ║
  ║                                                            ║
  ╚════════════════════════════════════════════════════════════╝
EOF
  echo -e "${NC}"
}

separator() {
  echo -e "${DIM}  ────────────────────────────────────────────────────${NC}"
}

step_header() {
  local step_num=$1
  local total=$2
  local title=$3
  echo ""
  echo -e "  ${BLUE}┌──────────────────────────────────────────────┐${NC}"
  echo -e "  ${BLUE}│${NC}  ${BOLD}$(msg step) ${step_num} $(msg of) ${total}${NC} ${DIM}─${NC} ${CYAN}${title}${NC}"
  echo -e "  ${BLUE}└──────────────────────────────────────────────┘${NC}"
}

progress_bar() {
  local current=$1
  local total=$2
  local width=40
  local percentage=$((current * 100 / total))
  local filled=$((current * width / total))
  local empty=$((width - filled))
  
  printf "\r  ${DIM}$(msg progress_bar_label):${NC} ${CYAN}["
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "]${NC} ${BOLD}${percentage}%%${NC}  "
}

ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

fail() {
  echo -e "  ${RED}✗${NC} $1"
}

warn() {
  echo -e "  ${YELLOW}!${NC} $1"
}

info() {
  echo -e "  ${BLUE}›${NC} $1"
}

ask() {
  echo -en "  ${MAGENTA}?${NC} $1 ${DIM}$2${NC} "
}

spinner() {
  local pid=$1
  local msg=$2
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}${spin:i++%${#spin}:1}${NC} ${msg}"
    sleep 0.1
  done
  printf "\r"
}

TOTAL_STEPS=8
BANNER_PORT=3200

# ══════════════════════════════════════════════════
#  START
# ══════════════════════════════════════════════════

clear
banner_art

echo -e "  ${DIM}$(msg select_lang)${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} 🇩🇪  $(msg german)"
echo -e "  ${BOLD}2)${NC} 🇬🇧  $(msg english)"
echo ""
ask "$(msg choice)" "[1/2]"
read -r lang_choice
case "$lang_choice" in
  1|de|DE) LANG_CODE="de" ;;
  *) LANG_CODE="en" ;;
esac

echo ""
echo -e "  ${GREEN}►${NC} ${BOLD}$(msg welcome)${NC} TeamSpeak Banner System ${DIM}v${VERSION}${NC}"
separator

# ── Root Check ──
if [ "$EUID" -ne 0 ]; then
  fail "$(msg root_error)"
  exit 1
fi

# ══════════════════════════════════════════
#  STEP 1: System Check
# ══════════════════════════════════════════

step_header 1 $TOTAL_STEPS "$(msg checking_system)"

if [ -f /etc/os-release ]; then
  . /etc/os-release
  ok "$(msg os_detected): ${BOLD}$PRETTY_NAME${NC}"
else
  fail "$(msg os_not_supported)"
  exit 1
fi

progress_bar 1 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 2: Node.js
# ══════════════════════════════════════════

step_header 2 $TOTAL_STEPS "$(msg installing_nodejs)"

if command -v node &> /dev/null; then
  NODE_VER=$(node -v)
  ok "$(msg nodejs_found): ${BOLD}$NODE_VER${NC}"
else
  info "$(msg nodejs_installing)"
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
  apt-get install -y nodejs > /dev/null 2>&1
  ok "$(msg nodejs_installed): ${BOLD}$(node -v)${NC}"
fi

progress_bar 2 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 3: System Dependencies
# ══════════════════════════════════════════

step_header 3 $TOTAL_STEPS "$(msg installing_deps)"

info "$(msg deps_canvas)"
apt-get update -qq > /dev/null 2>&1
apt-get install -y build-essential libcairo2-dev libjpeg-dev libpango1.0-dev \
  libgif-dev librsvg2-dev pkg-config python3 git > /dev/null 2>&1 || true

ok "$(msg deps_done)"

progress_bar 3 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 4: User & Files
# ══════════════════════════════════════════

step_header 4 $TOTAL_STEPS "$(msg copying_files)"

# Create user
if id "$USER_NAME" &>/dev/null; then
  ok "$(msg user_exists): ${BOLD}$USER_NAME${NC}"
else
  useradd --system --no-create-home --shell /usr/sbin/nologin "$USER_NAME"
  ok "$(msg user_created): ${BOLD}$USER_NAME${NC}"
fi

# Create install dir
mkdir -p "$INSTALL_DIR"

# Copy files from script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/src" ]; then
  # Local install (from cloned repo)
  cp -r "$SCRIPT_DIR/src" "$INSTALL_DIR/"
  cp -r "$SCRIPT_DIR/assets" "$INSTALL_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/package.json" "$INSTALL_DIR/"
  cp "$SCRIPT_DIR/package-lock.json" "$INSTALL_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/tsconfig.json" "$INSTALL_DIR/"
  cp "$SCRIPT_DIR/nginx.conf" "$INSTALL_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/ts-banner.service" "$INSTALL_DIR/" 2>/dev/null || true
  cp "$SCRIPT_DIR/config.example.json" "$INSTALL_DIR/" 2>/dev/null || true
else
  # Remote install (download from GitHub)
  info "Cloning from GitHub..."
  git clone --depth 1 "$REPO_URL" /tmp/ts-banner-install > /dev/null 2>&1
  cp -r /tmp/ts-banner-install/src "$INSTALL_DIR/"
  cp -r /tmp/ts-banner-install/assets "$INSTALL_DIR/" 2>/dev/null || true
  cp /tmp/ts-banner-install/package.json "$INSTALL_DIR/"
  cp /tmp/ts-banner-install/package-lock.json "$INSTALL_DIR/" 2>/dev/null || true
  cp /tmp/ts-banner-install/tsconfig.json "$INSTALL_DIR/"
  cp /tmp/ts-banner-install/nginx.conf "$INSTALL_DIR/" 2>/dev/null || true
  cp /tmp/ts-banner-install/ts-banner.service "$INSTALL_DIR/" 2>/dev/null || true
  cp /tmp/ts-banner-install/config.example.json "$INSTALL_DIR/" 2>/dev/null || true
  rm -rf /tmp/ts-banner-install
fi

ok "$(msg files_copied) → ${BOLD}$INSTALL_DIR${NC}"

progress_bar 4 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 5: Configuration
# ══════════════════════════════════════════

step_header 5 $TOTAL_STEPS "$(msg configure)"

if [ -f "$INSTALL_DIR/config.json" ]; then
  ok "config.json $(msg user_exists)"
  warn "$(msg config_later)"
  CONFIG_EXISTS=true
else
  ask "$(msg configure_now)" ""
  read -r do_config
  
  YES_CHAR=$(msg yes)
  
  if [[ "$do_config" =~ ^[$YES_CHAR]$ ]] || [[ "$do_config" =~ ^[yYjJ]$ ]]; then
    echo ""
    
    # TS Host
    ask "$(msg ts_host)" "[$(msg default): 127.0.0.1]"
    read -r TS_HOST
    TS_HOST=${TS_HOST:-127.0.0.1}
    
    # Query Port
    ask "$(msg ts_query_port)" "[$(msg default): 10011]"
    read -r TS_QPORT
    TS_QPORT=${TS_QPORT:-10011}
    
    # Server Port
    ask "$(msg ts_server_port)" "[$(msg default): 9987]"
    read -r TS_SPORT
    TS_SPORT=${TS_SPORT:-9987}
    
    # Username
    ask "$(msg ts_username)" "[$(msg default): serveradmin]"
    read -r TS_USER
    TS_USER=${TS_USER:-serveradmin}
    
    # Password
    ask "$(msg ts_password)" ""
    read -rs TS_PASS
    echo ""
    
    # Banner Port
    ask "$(msg banner_port)" "[$(msg default): 3200]"
    read -r BANNER_PORT_INPUT
    BANNER_PORT=${BANNER_PORT_INPUT:-3200}
    
    # Language for banner
    BANNER_LANG="$LANG_CODE"
    
    # Generate config.json
    cat > "$INSTALL_DIR/config.json" << CONFIGEOF
{
  "port": $BANNER_PORT,

  "teamspeak": {
    "host": "$TS_HOST",
    "queryPort": $TS_QPORT,
    "serverPort": $TS_SPORT,
    "username": "$TS_USER",
    "password": "$TS_PASS"
  },

  "banner": {
    "width": 1024,
    "height": 300,
    "background": "assets/background.png",
    "font": "",
    "logo": "",
    "timezone": "Europe/Berlin",

    "colors": {
      "primary": "#ffffff",
      "secondary": "#8b949e",
      "accent": "#00b4d8",
      "accentSecondary": "#7c3aed",
      "online": "#34d399",
      "away": "#fbbf24",
      "cardBg": "rgba(255, 255, 255, 0.05)",
      "cardBorder": "rgba(255, 255, 255, 0.08)"
    },

    "features": {
      "clock": true,
      "userChips": true,
      "progressBar": true,
      "sparkline": true,
      "topChannel": true,
      "lastJoined": true,
      "particles": true,
      "accentGlow": true,
      "gradientLine": true,
      "eventText": ""
    }
  },

  "lang": "$BANNER_LANG",

  "cacheTTL": 30
}
CONFIGEOF
    
    echo ""
    ok "$(msg config_saved)"
  else
    # Copy example
    cp "$INSTALL_DIR/config.example.json" "$INSTALL_DIR/config.json"
    warn "$(msg config_later)"
  fi
fi

progress_bar 5 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 6: NPM Install & Build
# ══════════════════════════════════════════

step_header 6 $TOTAL_STEPS "$(msg installing_npm)"

cd "$INSTALL_DIR"

npm install --omit=dev > /dev/null 2>&1 &
spinner $! "$(msg installing_npm)..."
wait $!
ok "$(msg npm_done)"

echo ""
info "$(msg compiling)..."

# Need typescript for build
npm install --save-dev typescript > /dev/null 2>&1

npx tsc > /dev/null 2>&1 || {
  fail "$(msg compile_fail)"
  echo -e "  ${DIM}cd $INSTALL_DIR && npx tsc${NC}"
  exit 1
}

ok "$(msg compile_done)"

# Remove devDependencies after build
npm prune --omit=dev > /dev/null 2>&1 || true

progress_bar 6 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 7: Permissions & Service
# ══════════════════════════════════════════

step_header 7 $TOTAL_STEPS "$(msg service_install)"

# Permissions
chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR/config.json"
ok "$(msg permissions_done)"

# Install systemd service
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

cat > "$SERVICE_FILE" << SERVICEEOF
[Unit]
Description=TeamSpeak Banner System
After=network.target

[Service]
Type=simple
User=$USER_NAME
Group=$USER_NAME
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/node dist/server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production

NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$INSTALL_DIR
PrivateTmp=true

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME" > /dev/null 2>&1
systemctl start "$SERVICE_NAME" 2>/dev/null || true

ok "$(msg service_enabled)"

progress_bar 7 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  STEP 8: nginx (optional)
# ══════════════════════════════════════════

step_header 8 $TOTAL_STEPS "nginx (optional)"

if command -v nginx &> /dev/null; then
  ask "$(msg setup_nginx)" ""
  read -r do_nginx
  
  if [[ "$do_nginx" =~ ^[yYjJ]$ ]]; then
    ask "$(msg nginx_domain)" "[banner.example.com]"
    read -r NGINX_DOMAIN
    NGINX_DOMAIN=${NGINX_DOMAIN:-banner.example.com}
    
    cat > "/etc/nginx/sites-available/ts-banner" << NGINXEOF
server {
    listen 80;
    server_name $NGINX_DOMAIN;

    access_log /var/log/nginx/ts-banner.access.log;
    error_log  /var/log/nginx/ts-banner.error.log;

    location /banner.png {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_cache_valid 200 30s;
        add_header X-Cache-Status \$upstream_cache_status;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    location /health {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
    }

    location / {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
NGINXEOF
    
    ln -sf /etc/nginx/sites-available/ts-banner /etc/nginx/sites-enabled/
    
    if nginx -t > /dev/null 2>&1; then
      systemctl reload nginx
      ok "$(msg nginx_configured): ${BOLD}$NGINX_DOMAIN${NC}"
    else
      warn "nginx config test failed – check manually"
    fi
  else
    info "nginx – skipped"
  fi
else
  info "$(msg nginx_not_found)"
fi

progress_bar 8 $TOTAL_STEPS
echo ""

# ══════════════════════════════════════════
#  COMPLETE
# ══════════════════════════════════════════

sleep 1

echo ""
echo -e "${GREEN}"
cat << 'EOF'
  ╔════════════════════════════════════════════════════════════╗
  ║                                                            ║
  ║           ✓  Installation Complete!                        ║
  ║                                                            ║
  ╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "  ${BOLD}$(msg summary)${NC}"
separator
echo ""
echo -e "  ${DIM}$(msg installed_to):${NC}  ${BOLD}$INSTALL_DIR${NC}"
echo -e "  ${DIM}$(msg service_status):${NC}  ${GREEN}● active${NC}"
echo -e "  ${DIM}$(msg banner_url):${NC}     ${CYAN}http://localhost:${BANNER_PORT}/banner.png${NC}"
echo ""

if [ -n "$NGINX_DOMAIN" ] && [ "$NGINX_DOMAIN" != "banner.example.com" ]; then
  echo -e "  ${DIM}nginx:${NC}          ${CYAN}http://${NGINX_DOMAIN}/banner.png${NC}"
  echo ""
fi

separator
echo ""
echo -e "  ${BOLD}$(msg commands):${NC}"
echo ""
echo -e "  ${DIM}$(msg cmd_status):${NC}   systemctl status $SERVICE_NAME"
echo -e "  ${DIM}$(msg cmd_logs):${NC}    journalctl -u $SERVICE_NAME -f"
echo -e "  ${DIM}$(msg cmd_restart):${NC}     systemctl restart $SERVICE_NAME"
echo -e "  ${DIM}$(msg cmd_config):${NC}  nano $INSTALL_DIR/config.json"
echo -e "  ${DIM}$(msg cmd_stop):${NC}      systemctl stop $SERVICE_NAME"
echo ""
separator
echo ""
echo -e "  ${MAGENTA}$(msg enjoy)${NC}"
echo ""
