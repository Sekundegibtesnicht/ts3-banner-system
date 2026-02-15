#!/usr/bin/env bash

# ─────────────────────────────────────────────────────
#  TBS – TeamSpeak Banner System
#  by Greenbox Studio
#  https://github.com/Sekundegibtesnicht/ts3-banner-system
# ─────────────────────────────────────────────────────

set -e

# Colors
RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
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
TOTAL_STEPS=8
CURRENT_STEP=0

# ═══════════════════════════════════════════════════
#  i18n
# ═══════════════════════════════════════════════════

declare -A DE
DE[root_error]="Du hast nicht genügend Rechte. Bitte mit sudo ausführen."
DE[select_lang]="Sprache wählen / Select language"
DE[welcome]="Willkommen beim TeamSpeak Banner System"
DE[os_found]="System erkannt"
DE[os_not_found]="Kein unterstütztes System. Nur Ubuntu/Debian."
DE[node_found]="Node.js gefunden"
DE[node_installing]="Node.js wird installiert..."
DE[node_installed]="Node.js installiert"
DE[git_found]="Git gefunden"
DE[git_installing]="Git wird installiert..."
DE[git_installed]="Git installiert"
DE[deps_installing]="Build-Tools werden installiert..."
DE[deps_installed]="System-Abhängigkeiten installiert"
DE[user_exists]="Benutzer existiert bereits"
DE[user_created]="Benutzer erstellt"
DE[repo_exists]="Repository existiert. Update wird durchgeführt..."
DE[repo_updated]="Repository aktualisiert"
DE[repo_cloning]="Repository wird geklont..."
DE[repo_cloned]="Repository geklont"
DE[config_exists]="config.json existiert bereits."
DE[config_ask]="Jetzt konfigurieren?"
DE[config_saved]="Konfiguration gespeichert"
DE[config_later]="Config später anpassen:"
DE[ts_host]="TeamSpeak Server IP/Hostname"
DE[ts_query_port]="ServerQuery Port"
DE[ts_server_port]="TeamSpeak Server Port"
DE[ts_username]="ServerQuery Benutzername"
DE[ts_password]="ServerQuery Passwort"
DE[banner_port]="Banner-System Port"
DE[npm_installing]="NPM Pakete werden installiert..."
DE[npm_installed]="NPM Pakete installiert"
DE[ts_compiling]="TypeScript wird kompiliert..."
DE[ts_compiled]="Kompilierung erfolgreich"
DE[ts_compile_fail]="Kompilierung fehlgeschlagen!"
DE[perms_set]="Berechtigungen gesetzt"
DE[service_installed]="Service eingerichtet & gestartet"
DE[nginx_ask]="nginx einrichten?"
DE[nginx_not_found]="nginx nicht installiert – überspringe"
DE[nginx_domain]="Domain für das Banner"
DE[nginx_configured]="nginx konfiguriert"
DE[nginx_test_fail]="nginx Test fehlgeschlagen."
DE[complete]="Installation abgeschlossen!"
DE[installed_to]="Installiert in"
DE[status]="Service Status"
DE[url]="Banner URL"
DE[commands]="Nützliche Befehle"
DE[update_hint]="Zum Updaten einfach erneut ausführen."
DE[yes_no]="j/n"
DE[step_system]="System prüfen"
DE[step_git]="Git installieren"
DE[step_node]="Node.js installieren"
DE[step_deps]="Abhängigkeiten"
DE[step_repo]="Repository"
DE[step_config]="Konfiguration"
DE[step_build]="Kompilieren"
DE[step_service]="Service einrichten"

declare -A EN
EN[root_error]="Insufficient permissions. Please run with sudo."
EN[select_lang]="Sprache wählen / Select language"
EN[welcome]="Welcome to the TeamSpeak Banner System"
EN[os_found]="System detected"
EN[os_not_found]="No supported system. Ubuntu/Debian only."
EN[node_found]="Node.js found"
EN[node_installing]="Installing Node.js..."
EN[node_installed]="Node.js installed"
EN[git_found]="Git found"
EN[git_installing]="Installing Git..."
EN[git_installed]="Git installed"
EN[deps_installing]="Installing build tools..."
EN[deps_installed]="System dependencies installed"
EN[user_exists]="User already exists"
EN[user_created]="User created"
EN[repo_exists]="Repository exists. Updating..."
EN[repo_updated]="Repository updated"
EN[repo_cloning]="Cloning repository..."
EN[repo_cloned]="Repository cloned"
EN[config_exists]="config.json already exists."
EN[config_ask]="Configure now?"
EN[config_saved]="Configuration saved"
EN[config_later]="Edit config later:"
EN[ts_host]="TeamSpeak Server IP/Hostname"
EN[ts_query_port]="ServerQuery Port"
EN[ts_server_port]="TeamSpeak Server Port"
EN[ts_username]="ServerQuery Username"
EN[ts_password]="ServerQuery Password"
EN[banner_port]="Banner system port"
EN[npm_installing]="Installing NPM packages..."
EN[npm_installed]="NPM packages installed"
EN[ts_compiling]="Compiling TypeScript..."
EN[ts_compiled]="Compilation successful"
EN[ts_compile_fail]="Compilation failed!"
EN[perms_set]="Permissions set"
EN[service_installed]="Service set up & started"
EN[nginx_ask]="Set up nginx?"
EN[nginx_not_found]="nginx not installed – skipping"
EN[nginx_domain]="Domain for the banner"
EN[nginx_configured]="nginx configured"
EN[nginx_test_fail]="nginx test failed."
EN[complete]="Installation complete!"
EN[installed_to]="Installed to"
EN[status]="Service status"
EN[url]="Banner URL"
EN[commands]="Useful commands"
EN[update_hint]="To update, simply run this script again."
EN[yes_no]="y/n"
EN[step_system]="Check system"
EN[step_git]="Install Git"
EN[step_node]="Install Node.js"
EN[step_deps]="Dependencies"
EN[step_repo]="Repository"
EN[step_config]="Configuration"
EN[step_build]="Compile"
EN[step_service]="Setup service"

t() {
    if [ "$LANG_CODE" = "de" ]; then echo "${DE[$1]}"; else echo "${EN[$1]}"; fi
}

# ═══════════════════════════════════════════════════
#  TUI COMPONENTS
# ═══════════════════════════════════════════════════

send_success() { echo -e "  $GREEN✓$NORMAL $1"; }
send_info()    { echo -e "  ${BLUE}ℹ$NORMAL  $1"; }
send_warn()    { echo -e "  $YELLOW⚠$NORMAL $1"; }
send_error()   { echo -e "  $RED✗$NORMAL $1"; exit 1; }

send_ask() {
    echo -en "  $MAGENTA?$NORMAL $1 "
}

# ── Progress Bar ──

progress_bar() {
    local current=$1
    local total=$2
    local width=30
    local pct=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo -e "  ${DIM}[$NORMAL${CYAN}${bar}${NORMAL}${DIM}]$NORMAL ${BOLD}${pct}%%$NORMAL"
}

# ── Spinner ──

spinner() {
    local pid=$1
    local msg=$2
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    tput civis 2>/dev/null || true  # hide cursor
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${frames[i++ % ${#frames[@]}]}$NORMAL %s" "$msg"
        sleep 0.08
    done
    printf "\r  \033[2K"
    tput cnorm 2>/dev/null || true  # show cursor
}

# ── Step Header ──

step_header() {
    CURRENT_STEP=$1
    local title=$2
    echo ""
    echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NORMAL"
    echo -e "  ${WHITE}[$CURRENT_STEP/$TOTAL_STEPS]$NORMAL  ${BOLD}$title$NORMAL"
    echo -e "  ${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$NORMAL"
}

# ── Separator ──

separator() {
    echo -e "  ${DIM}──────────────────────────────────────────────$NORMAL"
}

# ── Header ──

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
    separator
    echo ""
}

# ═══════════════════════════════════════════════════
#  INSTALLER STEPS
# ═══════════════════════════════════════════════════

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
    send_info "$(t welcome) ${DIM}v$VERSION$NORMAL"
}

verify_root() {
    if [ "$EUID" -ne 0 ]; then
        send_error "$(t root_error)"
    fi
}

# ── Step 1: System ──

check_system() {
    step_header 1 "$(t step_system)"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        send_success "$(t os_found): ${BLUE}$PRETTY_NAME$NORMAL"
    else
        send_error "$(t os_not_found)"
    fi
    progress_bar 1 $TOTAL_STEPS
}

# ── Step 2: Git ──

install_git() {
    step_header 2 "$(t step_git)"
    if command -v git &> /dev/null; then
        send_success "$(t git_found): ${BLUE}$(git --version | cut -d' ' -f3)$NORMAL"
    else
        send_info "$(t git_installing)"
        apt-get install -y git > /dev/null 2>&1 &
        spinner $! "$(t git_installing)"
        wait $!
        send_success "$(t git_installed)"
    fi
    progress_bar 2 $TOTAL_STEPS
}

# ── Step 3: Node.js ──

install_nodejs() {
    step_header 3 "$(t step_node)"
    if command -v node &> /dev/null; then
        send_success "$(t node_found): ${BLUE}$(node -v)$NORMAL"
    else
        send_info "$(t node_installing)"
        (curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1 && \
         apt-get install -y nodejs > /dev/null 2>&1) &
        spinner $! "$(t node_installing)"
        wait $!
        send_success "$(t node_installed): ${BLUE}$(node -v)$NORMAL"
    fi
    progress_bar 3 $TOTAL_STEPS
}

# ── Step 4: Dependencies ──

install_deps() {
    step_header 4 "$(t step_deps)"
    send_info "$(t deps_installing)"
    (apt-get update -qq > /dev/null 2>&1 && \
     apt-get install -y build-essential libcairo2-dev libjpeg-dev libpango1.0-dev \
        libgif-dev librsvg2-dev pkg-config python3 > /dev/null 2>&1) &
    spinner $! "$(t deps_installing)"
    wait $! || true
    send_success "$(t deps_installed)"
    progress_bar 4 $TOTAL_STEPS
}

# ── Step 5: Repository ──

clone_or_pull() {
    step_header 5 "$(t step_repo)"

    # Create user
    if id "$USER_NAME" &>/dev/null; then
        send_success "$(t user_exists): ${BLUE}$USER_NAME$NORMAL"
    else
        useradd --system --no-create-home --shell /usr/sbin/nologin "$USER_NAME"
        send_success "$(t user_created): ${BLUE}$USER_NAME$NORMAL"
    fi

    # Clone or pull
    if [ -d "$INSTALL_DIR/.git" ]; then
        send_info "$(t repo_exists)"
        cd "$INSTALL_DIR"
        git stash > /dev/null 2>&1 || true
        git pull origin main > /dev/null 2>&1 &
        spinner $! "git pull..."
        wait $!
        git stash pop > /dev/null 2>&1 || true
        send_success "$(t repo_updated)"
    else
        send_info "$(t repo_cloning)"
        git clone "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1 &
        spinner $! "git clone..."
        wait $!
        send_success "$(t repo_cloned): ${BLUE}$INSTALL_DIR$NORMAL"
    fi
    progress_bar 5 $TOTAL_STEPS
}

# ── Step 6: Configuration ──

configure() {
    step_header 6 "$(t step_config)"

    if [ -f "$INSTALL_DIR/config.json" ]; then
        send_warn "$(t config_exists)"
        progress_bar 6 $TOTAL_STEPS
        return
    fi

    send_ask "$(t config_ask) ${DIM}($(t yes_no))$NORMAL"
    read -r do_config

    if [[ "$do_config" =~ ^[yYjJ]$ ]]; then
        echo ""

        send_ask "$(t ts_host) ${DIM}[127.0.0.1]:$NORMAL "
        read -r TS_HOST; TS_HOST=${TS_HOST:-127.0.0.1}

        send_ask "$(t ts_query_port) ${DIM}[10011]:$NORMAL "
        read -r TS_QPORT; TS_QPORT=${TS_QPORT:-10011}

        send_ask "$(t ts_server_port) ${DIM}[9987]:$NORMAL "
        read -r TS_SPORT; TS_SPORT=${TS_SPORT:-9987}

        send_ask "$(t ts_username) ${DIM}[serveradmin]:$NORMAL "
        read -r TS_USER; TS_USER=${TS_USER:-serveradmin}

        send_ask "$(t ts_password): "
        read -rs TS_PASS; echo ""

        send_ask "$(t banner_port) ${DIM}[3200]:$NORMAL "
        read -r BP_INPUT; BANNER_PORT=${BP_INPUT:-3200}

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
        send_warn "$(t config_later) ${DIM}nano $INSTALL_DIR/config.json$NORMAL"
    fi
    progress_bar 6 $TOTAL_STEPS
}

# ── Step 7: Build ──

build_project() {
    step_header 7 "$(t step_build)"
    cd "$INSTALL_DIR"

    send_info "$(t npm_installing)"
    npm install --omit=dev > /dev/null 2>&1 &
    spinner $! "npm install..."
    wait $!
    send_success "$(t npm_installed)"

    send_info "$(t ts_compiling)"
    npm install --save-dev typescript > /dev/null 2>&1

    if npx tsc > /dev/null 2>&1; then
        send_success "$(t ts_compiled)"
    else
        send_error "$(t ts_compile_fail) ${BLUE}cd $INSTALL_DIR && npx tsc$NORMAL"
    fi

    npm prune --omit=dev > /dev/null 2>&1 || true
    progress_bar 7 $TOTAL_STEPS
}

# ── Step 8: Service & nginx ──

setup_service() {
    step_header 8 "$(t step_service)"

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

    # nginx (optional)
    echo ""
    if command -v nginx &> /dev/null; then
        send_ask "$(t nginx_ask) ${DIM}($(t yes_no))$NORMAL"
        read -r do_nginx

        if [[ "$do_nginx" =~ ^[yYjJ]$ ]]; then
            send_ask "$(t nginx_domain) ${DIM}[banner.example.com]:$NORMAL "
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
    }

    location /api/ {
        proxy_pass http://127.0.0.1:$BANNER_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location /health { proxy_pass http://127.0.0.1:$BANNER_PORT; }

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
                send_success "$(t nginx_configured): ${BLUE}$NGINX_DOMAIN$NORMAL"
            else
                send_warn "$(t nginx_test_fail)"
            fi
        fi
    else
        send_info "$(t nginx_not_found)"
    fi

    progress_bar 8 $TOTAL_STEPS
}

# ═══════════════════════════════════════════════════
#  SUMMARY
# ═══════════════════════════════════════════════════

show_summary() {
    echo ""
    echo ""
    echo -e "  ${GREEN}╔══════════════════════════════════════════════╗$NORMAL"
    echo -e "  ${GREEN}║                                              ║$NORMAL"
    echo -e "  ${GREEN}║   ${WHITE}✓  $(t complete)${GREEN}                    ║$NORMAL"
    echo -e "  ${GREEN}║      ${DIM}Greenbox Studio – TBS v$VERSION${GREEN}        ║$NORMAL"
    echo -e "  ${GREEN}║                                              ║$NORMAL"
    echo -e "  ${GREEN}╚══════════════════════════════════════════════╝$NORMAL"
    echo ""

    echo -e "  $(t installed_to):  ${BLUE}$INSTALL_DIR$NORMAL"
    echo -e "  $(t status):       ${GREEN}● active$NORMAL"
    echo -e "  $(t url):         ${CYAN}http://localhost:${BANNER_PORT}/banner.png$NORMAL"

    if [ -n "$NGINX_DOMAIN" ] && [ "$NGINX_DOMAIN" != "banner.example.com" ]; then
        echo -e "  nginx:            ${CYAN}http://${NGINX_DOMAIN}/banner.png$NORMAL"
    fi

    echo ""
    separator
    echo ""
    echo -e "  ${BOLD}$(t commands):$NORMAL"
    echo ""
    echo -e "  ${DIM}systemctl status $SERVICE_NAME$NORMAL       Status"
    echo -e "  ${DIM}journalctl -u $SERVICE_NAME -f$NORMAL       Logs"
    echo -e "  ${DIM}systemctl restart $SERVICE_NAME$NORMAL      Restart"
    echo -e "  ${DIM}nano $INSTALL_DIR/config.json$NORMAL   Config"
    echo ""
    separator
    echo ""
    send_info "$(t update_hint)"
    echo -e "  ${DIM}bash <(curl -s https://raw.githubusercontent.com/Sekundegibtesnicht/ts3-banner-system/main/install.sh)$NORMAL"
    echo ""
}

# ═══════════════════════════════════════════════════
#  MAIN
# ═══════════════════════════════════════════════════

clear
show_header
select_language
verify_root
check_system
install_git
install_nodejs
install_deps
clone_or_pull
configure
build_project
setup_service
show_summary
