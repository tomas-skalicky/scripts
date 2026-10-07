#!/usr/bin/env bash
# install-claude-desktop.sh
# Installs the official Claude Desktop (beta) on Linux Mint and makes sure it
# appears in the application menu in the list of installed apps.
#
# Usage:
#   sudo bash install-claude-desktop.sh                 # install + menu entry
#   sudo bash install-claude-desktop.sh --desktop-icon  # also put an icon on the desktop
#
# Requirements: Linux Mint 21.x/22.x (Ubuntu 22.04/24.04 base), amd64 or arm64.

set -euo pipefail

PKG="claude-desktop"
KEYRING="/usr/share/keyrings/claude-desktop-archive-keyring.asc"
KEY_URL="https://downloads.claude.ai/claude-desktop/key.asc"
REPO_LIST="/etc/apt/sources.list.d/claude-desktop.list"
REPO_LINE="deb [arch=amd64,arm64 signed-by=${KEYRING}] https://downloads.claude.ai/claude-desktop/apt/stable stable main"
FALLBACK_DESKTOP="/usr/share/applications/claude-desktop.desktop"

ADD_DESKTOP_ICON=0
for arg in "$@"; do
  case "$arg" in
    --desktop-icon) ADD_DESKTOP_ICON=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

info() { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
warn() { printf '\e[1;33m[!]\e[0m %s\n' "$*" >&2; }
die()  { printf '\e[1;31m[x]\e[0m %s\n' "$*" >&2; exit 1; }

# --- 1. Pre-flight checks ----------------------------------------------------
[[ $EUID -eq 0 ]] || die "Run this script with sudo:  sudo bash $0"

. /etc/os-release
info "Detected: ${PRETTY_NAME:-unknown}"

case "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}" in
  jammy|noble) ;;   # Ubuntu 22.04/24.04
  focal|bionic) die "Your base (${UBUNTU_CODENAME}) is too old. Claude Desktop needs Mint 21+ (Ubuntu 22.04+)." ;;
  *) warn "Unrecognised base '${UBUNTU_CODENAME:-${VERSION_CODENAME:-?}}' – continuing anyway." ;;
esac

ARCH="$(dpkg --print-architecture)"
[[ "$ARCH" == "amd64" || "$ARCH" == "arm64" ]] || die "Unsupported architecture: $ARCH (need amd64 or arm64)."

# --- 2. Prerequisites --------------------------------------------------------
info "Installing prerequisites..."
apt-get update -qq
apt-get install -y -qq curl ca-certificates desktop-file-utils xdg-utils >/dev/null

# --- 3. Anthropic signing key + apt repository -------------------------------
info "Adding Anthropic's signing key..."
curl -fsSLo "$KEYRING" "$KEY_URL"
chmod 644 "$KEYRING"

info "Adding the Claude Desktop apt repository..."
echo "$REPO_LINE" > "$REPO_LIST"

# --- 4. Install the package --------------------------------------------------
info "Installing ${PKG}..."
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y "$PKG"

# --- 5. Make sure there's a menu entry --------------------------------------
DESKTOP_FILE="$(dpkg -L "$PKG" 2>/dev/null | grep -E '/applications/.*\.desktop$' | head -n1 || true)"

if [[ -n "$DESKTOP_FILE" && -f "$DESKTOP_FILE" ]]; then
  info "Package provides menu entry: $DESKTOP_FILE"
else
  warn "No .desktop file shipped by the package – creating one."
  BIN="$(command -v claude-desktop || echo /usr/bin/claude-desktop)"

  # Pick the largest icon the package ships, else fall back to a generic name.
  ICON="$(dpkg -L "$PKG" 2>/dev/null | grep -E '\.(png|svg)$' | grep -i claude \
          | awk '{print length, $0}' | sort -rn | head -n1 | cut -d' ' -f2- || true)"
  ICON="${ICON:-claude-desktop}"

  cat > "$FALLBACK_DESKTOP" <<EOF
[Desktop Entry]
Type=Application
Name=Claude
GenericName=AI Assistant
Comment=Claude Desktop by Anthropic – Chat, Cowork and Code
Exec=${BIN} %U
Icon=${ICON}
Terminal=false
Categories=Network;Office;Utility;Development;
Keywords=AI;Claude;Anthropic;Chat;Assistant;
StartupNotify=true
StartupWMClass=Claude
MimeType=x-scheme-handler/claude;
EOF
  chmod 644 "$FALLBACK_DESKTOP"
  DESKTOP_FILE="$FALLBACK_DESKTOP"
fi

desktop-file-validate "$DESKTOP_FILE" || warn "desktop-file-validate reported issues (usually harmless)."

# --- 6. Refresh menu / icon caches ------------------------------------------
info "Refreshing application menu and icon caches..."
update-desktop-database -q /usr/share/applications || true
if command -v gtk-update-icon-cache >/dev/null; then
  gtk-update-icon-cache -q -f /usr/share/icons/hicolor || true
fi
xdg-desktop-menu forceupdate --mode system 2>/dev/null || true

# --- 7. Done ----------------------------------------------------------------
VERSION="$(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null || echo '?')"
cat <<EOF

$(printf '\e[1;32m')Claude Desktop ${VERSION} installed.$(printf '\e[0m')

  • Menu:      Menu → Internet (or Office/Accessories) → Claude, or just type "Claude" in the menu search
  • Terminal:  claude-desktop
  • Updates:   arrive via Update Manager / 'sudo apt upgrade' (repo has been added)
  • Uninstall: sudo apt remove ${PKG} && sudo rm ${REPO_LIST} ${KEYRING}

If the entry doesn't show up immediately, log out and back in
(or right-click the panel → Troubleshoot → Restart Cinnamon).
EOF
