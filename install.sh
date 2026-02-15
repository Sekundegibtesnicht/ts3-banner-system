#!/usr/bin/env bash

# ─────────────────────────────────────────────────────
#  TBS – TeamSpeak Banner System
#  by Greenbox Studio
#  https://github.com/Sekundegibtesnicht/ts3-banner-system
# ─────────────────────────────────────────────────────

# Colors
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
DIM='\033[2m'
BOLD='\033[1m'
NORMAL='\033[0;39m'

# Environment
INSTALL_DIR="/opt/ts-banner"
SERVICE_NAME="ts-banner"
USER_NAME="ts-banner"
REPO_URL="https://github.com/Sekundegibtesnicht/ts3-banner-system.git"
VERSION="1.0.0"
BANNER_PORT=3200
LANG_CODE="en"

# ─── i18n ───────────────────────────────────────────

declare -A DE
DE[root_error]="Du hast nicht genügend Rechte. Bitte mit sudo ausführen."
DE[select_lang]="Sprache wählen / Select language"
DE[welcome]="Willkommen beim TeamSpeak Banner System"
DE[os_found]="Es wurde ein System erkannt"
DE[os_not_found]="Es konnte kein unterstütztes System erkannt werden. Nur Ubuntu/Debian."
DE[node_found]="Node.js wurde gefunden"
DE[node_installing]="Node.js konnte nicht gefunden werden. Node.js 20 wird installiert."
DE[node_installed]="Node.js wurde installiert."
DE[git_found]="Git wurde gefunden"
DE[git_installing]="Git wurde nicht gefunden. Es wird nun installiert."
DE[git_installed]="Git wurde installiert."
DE[deps_installing]="Build-Tools für node-canvas werden installiert."
DE[deps_installed]="System-Abhängigkeiten wurden installiert."
DE[user_exists]="System-Benutzer existiert bereits"
DE[user_created]="System-Benutzer wurde erstellt"
DE[repo_exists]="Repository existiert bereits. Es wird aktualisiert (git pull)."
DE[repo_updated]="Repository wurde aktualisiert."
DE[repo_cloning]="Repository wird geklont..."
DE[repo_cloned]="Repository wurde geklont."
DE[config_exists]="Es existiert bereits eine config.json."
DE[config_ask]="Möchtest du jetzt konfigurieren? (j/n)"
DE[config_saved]="Konfiguration wurde gespeichert."
DE[config_later]="Du kannst die Konfiguration später anpassen:"
DE[ts_host]="TeamSpeak Server IP/Hostname"
DE[ts_query_port]="ServerQuery Port"
DE[ts_server_port]="TeamSpeak Server Port"
DE[ts_username]="ServerQuery Benutzername"
DE[ts_password]="ServerQuery Passwort"
DE[banner_port]="Banner-System Port"
DE[npm_installing]="NPM Pakete werden installiert. Das dauert einen Moment."
DE[npm_installed]="NPM Pakete wurden installiert."
DE[ts_compiling]="TypeScript wird kompiliert."
DE[ts_compiled]="Kompilierung erfolgreich."
DE[ts_compile_fail]="Kompilierung fehlgeschlagen! Debug mit:"
DE[perms_set]="Berechtigungen wurden gesetzt."
DE[service_installed]="Systemd Service wurde eingerichtet, aktiviert und gestartet."
DE[nginx_ask]="Möchtest du nginx einrichten? (j/n)"
DE[nginx_not_found]="nginx ist nicht installiert. Überspringe."
DE[nginx_domain]="Domain für das Banner"
DE[nginx_configured]="nginx wurde konfiguriert."
DE[nginx_test_fail]="nginx Konfigurationstest fehlgeschlagen. Bitte manuell prüfen."
DE[complete]="Die Installation wurde abgeschlossen. Viel Spaß! :)"
DE[installed_to]="Installiert in"
DE[status]="Service Status"
DE[url]="Banner URL"
DE[commands]="Nützliche Befehle"
DE[update_hint]="Um TBS zu aktualisieren, führe einfach erneut dieses Script aus."

declare -A EN
EN[root_error]="You do not have sufficient permissions. Please run with sudo."
EN[select_lang]="Sprache wählen / Select language"
EN[welcome]="Welcome to the TeamSpeak Banner System"
EN[os_found]="A supported system was detected"
EN[os_not_found]="No supported system detected. Ubuntu/Debian only."
EN[node_found]="Node.js was found"
EN[node_installing]="Node.js could not be found. Installing Node.js 20."
EN[node_installed]="Node.js was installed."
EN[git_found]="Git was found"
EN[git_installing]="Git was not found. Installing now."
EN[git_installed]="Git was installed."
EN[deps_installing]="Installing build tools for node-canvas."
EN[deps_installed]="System dependencies were installed."
EN[user_exists]="System user already exists"
EN[user_created]="System user was created"
EN[repo_exists]="Repository already exists. Updating (git pull)."
EN[repo_updated]="Repository was updated."
EN[repo_cloning]="Cloning repository..."
EN[repo_cloned]="Repository was cloned."
EN[config_exists]="A config.json already exists."
EN[config_ask]="Do you want to configure now? (y/n)"
EN[config_saved]="Configuration was saved."
EN[config_later]="You can edit the configuration later:"
EN[ts_host]="TeamSpeak Server IP/Hostname"
EN[ts_query_port]="ServerQuery Port"
EN[ts_server_port]="TeamSpeak Server Port"
EN[ts_username]="ServerQuery Username"
EN[ts_password]="ServerQuery Password"
EN[banner_port]="Banner system port"
EN[npm_installing]="Installing NPM packages. This may take a moment."
EN[npm_installed]="NPM packages were installed."
EN[ts_compiling]="Compiling TypeScript."
EN[ts_compiled]="Compilation successful."
EN[ts_compile_fail]="Compilation failed! Debug with:"
EN[perms_set]="Permissions were set."
EN[service_installed]="Systemd service was set up, enabled and started."
EN[nginx_ask]="Do you want to set up nginx? (y/n)"
EN[nginx_not_found]="nginx is not installed. Skipping."
EN[nginx_domain]="Domain for the banner"
EN[nginx_configured]="nginx was configured."
EN[nginx_test_fail]="nginx config test failed. Please check manually."
EN[complete]="Installation complete. Enjoy! :)"
EN[installed_to]="Installed to"
EN[status]="Service status"
EN[url]="Banner URL"
EN[commands]="Useful commands"
EN[update_hint]="To update TBS, simply run this script again."

t() {
    if [ "$LANG_CODE" = "de" ]; then
        echo "${DE[$1]}"
    else
        echo "${EN[$1]}"
    fi
}

# ─── Output Functions ───────────────────────────────

send_success() {
    echo -e "$GREEN✓ $1$NORMAL"
}

send_info() {
    echo -e "$BLUEℹ  $1$NORMAL"
}

send_warn() {
    echo -e "$YELLOW⚠ $1$NORMAL"
}

send_error() {
    echo -e "$RED✗ $1$NORMAL"
    exit 1
}

send_ask() {
    echo -en "$MAGENTA? $1$NORMAL "
}

# ─── Header ─────────────────────────────────────────

show_header() {
    echo ""
    echo -e "$CYAN"
    cat << 'EOF'
    ████████╗██████╗ ███████╗
       ██╔══╝██╔══██╗██╔════╝
       ██║   ██████╔╝███████╗
       ██║   ██╔══██╗╚════██║
       ██║   ██████╔╝███████║
       ╚═╝   ╚═════╝ ╚══════╝
EOF
    echo -e "$NORMAL"
    echo -e "    ${BOLD}TeamSpeak Banner System$NORMAL ${DIM}v$VERSION$NORMAL"
    echo -e "    ${DIM}by Greenbox Studio$NORMAL"
    echo ""
    echo -e "    ${DIM}─────────────────────────────────────$NORMAL"
    echo ""
}

# ─── Language Selection ─────────────────────────────

select_language() {
    echo -e "    ${DIM}$(t select_lang)$NORMAL"
    echo ""
    echo -e "    ${BOLD}1)$NORMAL 🇩🇪  Deutsch"
    echo -e "    ${BOLD}2)$NORMAL 🇬🇧  English"
    echo ""
    send_ask "[1/2]:"
    read -r lang_choice
    case "$lang_choice" in
        1|de|DE) LANG_CODE="de" ;;
        *) LANG_CODE="en" ;;
    esac
    echo ""
}

# ─── Root Check ─────────────────────────────────────

verify_root() {
    if [ "$EUID" -ne 0 ]; then
        send_error "$(t root_error)"
    fi
}

# ─── System Check ───────────────────────────────────

check_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        send_success "$(t os_found):$BLUE $PRETTY_NAME$NORMAL"
    else
        send_error "$(t os_not_found)"
    fi
}

# ─── Install Git ────────────────────────────────────

install_git() {
    if command -v git &> /dev/null; then
        send_success "$(t git_found):$BLUE $(git --version)$NORMAL"
    else
        send_info "$(t git_installing)"
        apt-get install -y git > /dev/null 2>&1
        send_success "$(t git_installed)"
    fi
}

# ─── Install Node.js ────────────────────────────────

install_nodejs() {
    if command -v node &> /dev/null; then
        NODE_VER=$(node -v)
        send_success "$(t node_found):$BLUE $NODE_VER$NORMAL"
    else
        send_info "$(t node_installing)"
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
        apt-get install -y nodejs > /dev/null 2>&1
        send_success "$(t node_installed)$BLUE $(node -v)$NORMAL"
    fi
}

# ─── Install System Dependencies ────────────────────

install_deps() {
    send_info "$(t deps_installing)"
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y build-essential libcairo2-dev libjpeg-dev libpango1.0-dev \
        libgif-dev librsvg2-dev pkg-config python3 > /dev/null 2>&1 || true
    send_success "$(t deps_installed)"
}

# ─── Create User ────────────────────────────────────

create_user() {
    if id "$USER_NAME" &>/dev/null; then
        send_success "$(t user_exists):$BLUE $USER_NAME$NORMAL"
    else
        useradd --system --no-create-home --shell /usr/sbin/nologin "$USER_NAME"
        send_success "$(t user_created):$BLUE $USER_NAME$NORMAL"
    fi
}

# ─── Clone / Pull Repository ────────────────────────

clone_or_pull() {
    if [ -d "$INSTALL_DIR/.git" ]; then
        send_info "$(t repo_exists)"
        cd "$INSTALL_DIR"
        git stash > /dev/null 2>&1 || true
        git pull origin main > /dev/null 2>&1
        git stash pop > /dev/null 2>&1 || true
        send_success "$(t repo_updated)"
    else
        send_info "$(t repo_cloning)"
        git clone "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1
        send_success "$(t repo_cloned)"
    fi
}

# ─── Configuration ──────────────────────────────────

configure() {
    if [ -f "$INSTALL_DIR/config.json" ]; then
        send_warn "$(t config_exists)"
        return
    fi

    send_ask "$(t config_ask)"
    read -r do_config

    if [[ "$do_config" =~ ^[yYjJ]$ ]]; then
        echo ""

        send_ask "$(t ts_host) ${DIM}[127.0.0.1]:${NORMAL} "
        read -r TS_HOST
        TS_HOST=${TS_HOST:-127.0.0.1}

        send_ask "$(t ts_query_port) ${DIM}[10011]:${NORMAL} "
        read -r TS_QPORT
        TS_QPORT=${TS_QPORT:-10011}

        send_ask "$(t ts_server_port) ${DIM}[9987]:${NORMAL} "
        read -r TS_SPORT
        TS_SPORT=${TS_SPORT:-9987}

        send_ask "$(t ts_username) ${DIM}[serveradmin]:${NORMAL} "
        read -r TS_USER
        TS_USER=${TS_USER:-serveradmin}

        send_ask "$(t ts_password): "
        read -rs TS_PASS
        echo ""

        send_ask "$(t banner_port) ${DIM}[3200]:${NORMAL} "
        read -r BANNER_PORT_INPUT
        BANNER_PORT=${BANNER_PORT_INPUT:-3200}

        BANNER_LANG="$LANG_CODE"

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
        send_success "$(t config_saved)"
    else
        cp "$INSTALL_DIR/config.example.json" "$INSTALL_DIR/config.json"
        send_warn "$(t config_later)"
        echo -e "    ${DIM}nano $INSTALL_DIR/config.json$NORMAL"
    fi
}

# ─── NPM Install & Build ────────────────────────────

build_project() {
    cd "$INSTALL_DIR"

    send_info "$(t npm_installing)"
    npm install --omit=dev > /dev/null 2>&1
    send_success "$(t npm_installed)"

    send_info "$(t ts_compiling)"
    npm install --save-dev typescript > /dev/null 2>&1

    if npx tsc > /dev/null 2>&1; then
        send_success "$(t ts_compiled)"
    else
        send_error "$(t ts_compile_fail) ${BLUE}cd $INSTALL_DIR && npx tsc$NORMAL"
    fi

    npm prune --omit=dev > /dev/null 2>&1 || true
}

# ─── Permissions & Service ──────────────────────────

setup_service() {
    chown -R "$USER_NAME:$USER_NAME" "$INSTALL_DIR"
    chmod 600 "$INSTALL_DIR/config.json"
    send_success "$(t perms_set)"

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
    systemctl enable "$SERVICE_NAME" > /dev/null 2>&1
    systemctl start "$SERVICE_NAME" 2>/dev/null || true

    send_success "$(t service_installed)"
}

# ─── nginx ──────────────────────────────────────────

setup_nginx() {
    if ! command -v nginx &> /dev/null; then
        send_info "$(t nginx_not_found)"
        return
    fi

    send_ask "$(t nginx_ask)"
    read -r do_nginx

    if [[ ! "$do_nginx" =~ ^[yYjJ]$ ]]; then
        return
    fi

    send_ask "$(t nginx_domain) ${DIM}[banner.example.com]:${NORMAL} "
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
        send_success "$(t nginx_configured):$BLUE $NGINX_DOMAIN$NORMAL"
    else
        send_warn "$(t nginx_test_fail)"
    fi
}

# ─── Summary ────────────────────────────────────────

show_summary() {
    echo ""
    echo -e "    ${DIM}─────────────────────────────────────$NORMAL"
    echo ""
    send_success "$(t complete)"
    echo ""
    echo -e "    $(t installed_to):  $BLUE$INSTALL_DIR$NORMAL"
    echo -e "    $(t status):       $GREEN● active$NORMAL"
    echo -e "    $(t url):         $CYAN http://localhost:${BANNER_PORT}/banner.png$NORMAL"

    if [ -n "$NGINX_DOMAIN" ] && [ "$NGINX_DOMAIN" != "banner.example.com" ]; then
        echo -e "    nginx:            $CYAN http://${NGINX_DOMAIN}/banner.png$NORMAL"
    fi

    echo ""
    echo -e "    ${DIM}─────────────────────────────────────$NORMAL"
    echo ""
    echo -e "    ${BOLD}$(t commands):$NORMAL"
    echo -e "    ${DIM}systemctl status $SERVICE_NAME$NORMAL      – Status"
    echo -e "    ${DIM}journalctl -u $SERVICE_NAME -f$NORMAL      – Logs"
    echo -e "    ${DIM}systemctl restart $SERVICE_NAME$NORMAL     – Restart"
    echo -e "    ${DIM}nano $INSTALL_DIR/config.json$NORMAL  – Config"
    echo ""
    send_info "$(t update_hint)"
    echo ""
}

# ═════════════════════════════════════════════════════
#  MAIN
# ═════════════════════════════════════════════════════

clear
show_header
select_language

send_info "$(t welcome) ${DIM}v$VERSION$NORMAL"
echo ""

verify_root
check_system
install_git
install_nodejs
install_deps
create_user
clone_or_pull
echo ""
configure
echo ""
build_project
setup_service
setup_nginx
show_summary
