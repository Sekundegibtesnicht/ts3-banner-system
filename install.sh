#!/usr/bin/env bash

# ─────────────────────────────────────────────────────
#  TBS – TeamSpeak Banner System Installer
#  by Greenbox Studio
#  https://github.com/Sekundegibtesnicht/ts3-banner-system
#
#  Usage:
#    bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)
#    or: sudo ./install.sh
# ─────────────────────────────────────────────────────

set -e

# ═══════════════════════════════════════════════════
#  CONSTANTS
# ═══════════════════════════════════════════════════

INSTALL_DIR="/opt/ts-banner"
SERVICE_NAME="ts-banner"
USER_NAME="ts-banner"
REPO_URL="https://github.com/Sekundegibtesnicht/ts3-banner-system.git"
VERSION="1.0.0"
BANNER_PORT=3200
LANG="en"
WT_WIDTH=72
WT_HEIGHT=18
WT_TITLE="TBS Installer v$VERSION – Greenbox Studio"
LOG_FILE="/tmp/tbs-install.log"

# ═══════════════════════════════════════════════════
#  i18n
# ═══════════════════════════════════════════════════

declare -A DE
DE[welcome_title]="Willkommen"
DE[welcome_text]="\nWillkommen beim TBS Installer!\n\nTeamSpeak Banner System v$VERSION\nby Greenbox Studio\n\nDer Installer richtet alles automatisch ein:\n  • Node.js & Git\n  • System-Abhängigkeiten\n  • Repository klonen / updaten\n  • TypeScript kompilieren\n  • systemd Service\n  • nginx (optional)"
DE[root_error]="Bitte als root ausführen:\n\nsudo ./install.sh\n\noder:\n\nbash <(curl -s ...)"
DE[os_error]="Kein unterstütztes Betriebssystem erkannt.\nNur Ubuntu/Debian werden unterstützt."
DE[config_title]="Konfiguration"
DE[config_text]="Möchtest du jetzt die TeamSpeak-Daten eingeben?"
DE[ts_host]="TeamSpeak Server IP/Hostname:"
DE[ts_query_port]="ServerQuery Port:"
DE[ts_server_port]="TeamSpeak Server Port:"
DE[ts_username]="ServerQuery Benutzername:"
DE[ts_password]="ServerQuery Passwort:"
DE[banner_port]="Banner HTTP Port:"
DE[config_saved]="Konfiguration gespeichert!"
DE[config_skip]="config.example.json wurde als config.json kopiert.\nBitte später anpassen:\n\nnano $INSTALL_DIR/config.json"
DE[config_exists]="config.json existiert bereits und wird beibehalten."
DE[nginx_title]="nginx"
DE[nginx_text]="Möchtest du nginx als Reverse Proxy einrichten?"
DE[nginx_domain]="Domain oder IP-Adresse für das Banner (z.B. banner.example.com oder 123.45.67.89):"
DE[nginx_done]="nginx wurde konfiguriert für:"
DE[nginx_fail]="nginx Konfigurationstest fehlgeschlagen.\nBitte manuell prüfen."
DE[nginx_skip]="nginx wird übersprungen."
DE[nginx_installing]="nginx wird installiert..."
DE[nginx_installed]="nginx wurde installiert."
DE[done_title]="Installation abgeschlossen!"
DE[done_text]="\n✓ TBS wurde erfolgreich installiert!\n\nInstalliert in:  $INSTALL_DIR\nBanner URL:      http://localhost:PORT/banner.png\nService:         systemctl status $SERVICE_NAME\n\nNützliche Befehle:\n  systemctl status  $SERVICE_NAME\n  journalctl -u $SERVICE_NAME -f\n  systemctl restart $SERVICE_NAME\n  nano $INSTALL_DIR/config.json\n\nZum Updaten dieses Script erneut ausführen."

DE[step_git]="Git installieren..."
DE[step_node]="Node.js installieren..."
DE[step_deps]="Build-Tools installieren..."
DE[step_user]="System-Benutzer anlegen..."
DE[step_repo]="Repository klonen/updaten..."
DE[step_npm]="NPM Pakete installieren..."
DE[step_build]="TypeScript kompilieren..."
DE[step_service]="systemd Service einrichten..."

declare -A EN
EN[welcome_title]="Welcome"
EN[welcome_text]="\nWelcome to the TBS Installer!\n\nTeamSpeak Banner System v$VERSION\nby Greenbox Studio\n\nThe installer sets up everything automatically:\n  • Node.js & Git\n  • System dependencies\n  • Clone / update repository\n  • Compile TypeScript\n  • systemd service\n  • nginx (optional)"
EN[root_error]="Please run as root:\n\nsudo ./install.sh\n\nor:\n\nbash <(curl -s ...)"
EN[os_error]="No supported OS detected.\nOnly Ubuntu/Debian are supported."
EN[config_title]="Configuration"
EN[config_text]="Do you want to enter TeamSpeak credentials now?"
EN[ts_host]="TeamSpeak Server IP/Hostname:"
EN[ts_query_port]="ServerQuery Port:"
EN[ts_server_port]="TeamSpeak Server Port:"
EN[ts_username]="ServerQuery Username:"
EN[ts_password]="ServerQuery Password:"
EN[banner_port]="Banner HTTP Port:"
EN[config_saved]="Configuration saved!"
EN[config_skip]="config.example.json was copied as config.json.\nPlease edit it later:\n\nnano $INSTALL_DIR/config.json"
EN[config_exists]="config.json already exists and will be kept."
EN[nginx_title]="nginx"
EN[nginx_text]="Do you want to set up nginx as a reverse proxy?"
EN[nginx_domain]="Domain or IP address for the banner (e.g. banner.example.com or 123.45.67.89):"
EN[nginx_done]="nginx was configured for:"
EN[nginx_fail]="nginx config test failed.\nPlease check manually."
EN[nginx_skip]="nginx skipped."
EN[nginx_installing]="Installing nginx..."
EN[nginx_installed]="nginx was installed."
EN[done_title]="Installation Complete!"
EN[done_text]="\n✓ TBS was installed successfully!\n\nInstalled to:    $INSTALL_DIR\nBanner URL:      http://localhost:PORT/banner.png\nService:         systemctl status $SERVICE_NAME\n\nUseful commands:\n  systemctl status  $SERVICE_NAME\n  journalctl -u $SERVICE_NAME -f\n  systemctl restart $SERVICE_NAME\n  nano $INSTALL_DIR/config.json\n\nTo update, run this script again."

EN[step_git]="Installing Git..."
EN[step_node]="Installing Node.js..."
EN[step_deps]="Installing build tools..."
EN[step_user]="Creating system user..."
EN[step_repo]="Cloning/updating repository..."
EN[step_npm]="Installing NPM packages..."
EN[step_build]="Compiling TypeScript..."
EN[step_service]="Setting up systemd service..."

t() {
    if [ "$LANG" = "de" ]; then echo "${DE[$1]}"; else echo "${EN[$1]}"; fi
}

# ═══════════════════════════════════════════════════
#  HELPERS
# ═══════════════════════════════════════════════════

ensure_whiptail() {
    if ! command -v whiptail &> /dev/null; then
        echo "Installing whiptail..."
        apt-get update -qq > /dev/null 2>&1
        apt-get install -y whiptail > /dev/null 2>&1
    fi
}

wt_msg() {
    whiptail --title "$WT_TITLE" --msgbox "$1" $WT_HEIGHT $WT_WIDTH
}

wt_yesno() {
    whiptail --title "$WT_TITLE" --yesno "$1" $WT_HEIGHT $WT_WIDTH
}

wt_input() {
    local prompt=$1
    local default=$2
    whiptail --title "$WT_TITLE" --inputbox "$prompt" $WT_HEIGHT $WT_WIDTH "$default" 3>&1 1>&2 2>&3
}

wt_password() {
    local prompt=$1
    whiptail --title "$WT_TITLE" --passwordbox "$prompt" $WT_HEIGHT $WT_WIDTH 3>&1 1>&2 2>&3
}

wt_gauge() {
    local pct=$1
    local msg=$2
    echo -e "XXX\n$pct\n$msg\nXXX"
}

run_step() {
    local cmd=$1
    eval "$cmd" >> "$LOG_FILE" 2>&1 || true
}

# ═══════════════════════════════════════════════════
#  MAIN INSTALLATION
# ═══════════════════════════════════════════════════

do_install() {
    {
        # ── Step 1: Git (12%) ──
        wt_gauge 0 "$(t step_git)"
        if ! command -v git &> /dev/null; then
            apt-get update -qq >> "$LOG_FILE" 2>&1
            apt-get install -y git >> "$LOG_FILE" 2>&1
        fi

        # ── Step 2: Node.js (25%) ──
        wt_gauge 12 "$(t step_node)"
        if ! command -v node &> /dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_20.x | bash - >> "$LOG_FILE" 2>&1
            apt-get install -y nodejs >> "$LOG_FILE" 2>&1
        fi

        # ── Step 3: Dependencies (38%) ──
        wt_gauge 25 "$(t step_deps)"
        apt-get install -y build-essential libcairo2-dev libjpeg-dev libpango1.0-dev \
            libgif-dev librsvg2-dev pkg-config python3 >> "$LOG_FILE" 2>&1 || true

        # ── Step 4: User (45%) ──
        wt_gauge 38 "$(t step_user)"
        if ! id "$USER_NAME" &>/dev/null; then
            useradd --system --no-create-home --shell /usr/sbin/nologin "$USER_NAME"
        fi

        # ── Step 5: Repository (55%) ──
        wt_gauge 45 "$(t step_repo)"
        if [ -d "$INSTALL_DIR/.git" ]; then
            cd "$INSTALL_DIR"
            git stash >> "$LOG_FILE" 2>&1 || true
            git pull origin main >> "$LOG_FILE" 2>&1
            git stash pop >> "$LOG_FILE" 2>&1 || true
        else
            git clone "$REPO_URL" "$INSTALL_DIR" >> "$LOG_FILE" 2>&1
        fi

        # ── Step 6: NPM Install (70%) ──
        wt_gauge 55 "$(t step_npm)"
        cd "$INSTALL_DIR"
        npm install --omit=dev >> "$LOG_FILE" 2>&1

        # ── Step 7: Build (85%) ──
        wt_gauge 70 "$(t step_build)"
        npm install --save-dev typescript >> "$LOG_FILE" 2>&1
        npx tsc >> "$LOG_FILE" 2>&1 || true
        npm prune --omit=dev >> "$LOG_FILE" 2>&1 || true

        # ── Step 8: Service (100%) ──
        wt_gauge 85 "$(t step_service)"

        chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
        [ -f "$INSTALL_DIR/config.json" ] && chmod 600 "$INSTALL_DIR/config.json"

        cat > "/etc/systemd/system/${SERVICE_NAME}.service" << SERVICEEOF
[Unit]
Description=TeamSpeak Banner System – Greenbox Studio
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
        systemctl enable "$SERVICE_NAME" >> "$LOG_FILE" 2>&1
        systemctl start "$SERVICE_NAME" >> "$LOG_FILE" 2>&1 || true

        wt_gauge 100 "✓ Done!"
        sleep 1

    } | whiptail --title "$WT_TITLE" --gauge "Starting..." 8 $WT_WIDTH 0
}

# ═══════════════════════════════════════════════════
#  CONFIGURATION DIALOG
# ═══════════════════════════════════════════════════

do_configure() {
    if [ -f "$INSTALL_DIR/config.json" ]; then
        wt_msg "$(t config_exists)"
        return
    fi

    if wt_yesno "$(t config_text)"; then
        TS_HOST=$(wt_input "$(t ts_host)" "127.0.0.1")
        TS_QPORT=$(wt_input "$(t ts_query_port)" "10011")
        TS_SPORT=$(wt_input "$(t ts_server_port)" "9987")
        TS_USER=$(wt_input "$(t ts_username)" "serveradmin")
        TS_PASS=$(wt_password "$(t ts_password)")
        BANNER_PORT=$(wt_input "$(t banner_port)" "3200")

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
  "lang": "$LANG",
  "cacheTTL": 30
}
CONFIGEOF

        chown "$USER_NAME:$USER_NAME" "$INSTALL_DIR/config.json"
        chmod 600 "$INSTALL_DIR/config.json"

        # Restart service to pick up new config
        systemctl restart "$SERVICE_NAME" >> "$LOG_FILE" 2>&1 || true

        wt_msg "$(t config_saved)"
    else
        if [ -f "$INSTALL_DIR/config.example.json" ]; then
            cp "$INSTALL_DIR/config.example.json" "$INSTALL_DIR/config.json"
            chown "$USER_NAME:$USER_NAME" "$INSTALL_DIR/config.json"
            chmod 600 "$INSTALL_DIR/config.json"
        fi
        wt_msg "$(t config_skip)"
    fi
}

# ═══════════════════════════════════════════════════
#  NGINX DIALOG
# ═══════════════════════════════════════════════════

do_nginx() {
    if wt_yesno "$(t nginx_text)"; then
        # Install nginx if not present
        if ! command -v nginx &> /dev/null; then
            {
                wt_gauge 0 "$(t nginx_installing)"
                apt-get update -qq >> "$LOG_FILE" 2>&1
                apt-get install -y nginx >> "$LOG_FILE" 2>&1
                wt_gauge 100 "$(t nginx_installed)"
                sleep 1
            } | whiptail --title "$WT_TITLE" --gauge "$(t nginx_installing)" 8 $WT_WIDTH 0
        fi

        SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "banner.example.com")
        NGINX_DOMAIN=$(wt_input "$(t nginx_domain)" "$SERVER_IP")

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
    }

    location /api/ {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
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

        if nginx -t >> "$LOG_FILE" 2>&1; then
            systemctl reload nginx
            wt_msg "$(t nginx_done)\n\n$NGINX_DOMAIN"
        else
            wt_msg "$(t nginx_fail)"
        fi
    fi
}


# ═══════════════════════════════════════════════════
#  DONE DIALOG
# ═══════════════════════════════════════════════════

do_done() {
    local done_text
    done_text=$(t done_text)
    done_text="${done_text//PORT/$BANNER_PORT}"
    whiptail --title "$(t done_title)" --msgbox "$done_text" 22 $WT_WIDTH
}

# ═══════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════

# Root check (before whiptail is available)
if [ "$EUID" -ne 0 ]; then
    echo -e "\033[1;31m✗ Please run as root: sudo ./install.sh\033[0m"
    exit 1
fi

# Make sure whiptail is installed
ensure_whiptail

# Clean log
> "$LOG_FILE"

# ── Language selection ──
LANG_CHOICE=$(whiptail --title "$WT_TITLE" --menu \
    "\nSprache wählen / Select language\n" \
    12 $WT_WIDTH 2 \
    "en" "🇬🇧  English" \
    "de" "🇩🇪  Deutsch" \
    3>&1 1>&2 2>&3) || true

case "$LANG_CHOICE" in
    de) LANG="de" ;;
    *)  LANG="en" ;;
esac

# ── Welcome screen ──
wt_msg "$(t welcome_text)"

# ── OS check ──
if [ ! -f /etc/os-release ]; then
    wt_msg "$(t os_error)"
    exit 1
fi

# ── Run installation with gauge ──
do_install

# ── Configuration ──
do_configure

# ── nginx ──
do_nginx

# ── Done ──
do_done

exit 0
