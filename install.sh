#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/julmx/wsl-home-manager.git"
CONFIG_DIR="$HOME/.config/home-manager"
NIX_CONF="$HOME/.config/nix/nix.conf"

# --- Couleurs ---
green='\033[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
reset='\033[0m'

info()  { echo -e "${green}[+]${reset} $1"; }
warn()  { echo -e "${yellow}[!]${reset} $1"; }
error() { echo -e "${red}[x]${reset} $1"; exit 1; }

# --- Lecture des valeurs précédentes (si local.nix existe) ---
PREV_USERNAME="" PREV_HOME="" PREV_GIT_NAME="" PREV_GIT_EMAIL=""
if [[ -f "$CONFIG_DIR/local.nix" ]]; then
    PREV_USERNAME=$(grep 'username' "$CONFIG_DIR/local.nix" | sed 's/.*"\(.*\)".*/\1/')
    PREV_HOME=$(grep 'homeDirectory' "$CONFIG_DIR/local.nix" | sed 's/.*"\(.*\)".*/\1/')
    PREV_GIT_NAME=$(grep 'gitName' "$CONFIG_DIR/local.nix" | sed 's/.*"\(.*\)".*/\1/')
    PREV_GIT_EMAIL=$(grep 'gitEmail' "$CONFIG_DIR/local.nix" | sed 's/.*"\(.*\)".*/\1/')
fi

# --- Informations utilisateur ---
DEFAULT_USER="${PREV_USERNAME:-$(whoami)}"
read -rp "Nom d'utilisateur système [$DEFAULT_USER]: " USERNAME
USERNAME="${USERNAME:-$DEFAULT_USER}"

HOME_DIR="/home/$USERNAME"
[[ ! -d "$HOME_DIR" ]] && error "Le répertoire $HOME_DIR n'existe pas."

DEFAULT_GIT_NAME="${PREV_GIT_NAME:-$USERNAME}"
read -rp "Nom pour git [$DEFAULT_GIT_NAME]: " GIT_NAME
GIT_NAME="${GIT_NAME:-$DEFAULT_GIT_NAME}"

DEFAULT_GIT_EMAIL="${PREV_GIT_EMAIL:-}"
if [[ -n "$DEFAULT_GIT_EMAIL" ]]; then
    read -rp "Email pour git [$DEFAULT_GIT_EMAIL]: " GIT_EMAIL
    GIT_EMAIL="${GIT_EMAIL:-$DEFAULT_GIT_EMAIL}"
else
    read -rp "Email pour git: " GIT_EMAIL
    [[ -z "$GIT_EMAIL" ]] && error "L'email git ne peut pas être vide."
fi

info "Configuration pour: $USERNAME ($HOME_DIR)"
info "Git: $GIT_NAME <$GIT_EMAIL>"

# --- Nix ---
if command -v nix &>/dev/null; then
    info "Nix est déjà installé."
else
    info "Installation de Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    # Charger nix dans le shell courant
    if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

# --- Flakes ---
mkdir -p "$(dirname "$NIX_CONF")"
if grep -q "experimental-features.*flakes" "$NIX_CONF" 2>/dev/null; then
    info "Les flakes sont déjà activés."
else
    info "Activation des flakes..."
    echo "experimental-features = nix-command flakes" >> "$NIX_CONF"
    info "Flakes activés dans $NIX_CONF"
fi

# --- Git (nécessaire pour cloner) ---
if ! command -v git &>/dev/null; then
    info "Installation de git via nix..."
    nix profile install nixpkgs#git
fi

# --- Clone ou mise à jour ---
if [[ -d "$CONFIG_DIR/.git" ]]; then
    info "Mise à jour du dépôt existant..."
    git -C "$CONFIG_DIR" pull --rebase
else
    info "Clonage du dépôt..."
    rm -rf "$CONFIG_DIR"
    mkdir -p "$(dirname "$CONFIG_DIR")"
    git clone "$REPO" "$CONFIG_DIR"
fi

# --- Configuration de local.nix ---
info "Configuration de local.nix..."
cat > "$CONFIG_DIR/local.nix" <<EOF
{
  username = "$USERNAME";
  homeDirectory = "$HOME_DIR";
  gitName = "$GIT_NAME";
  gitEmail = "$GIT_EMAIL";
}
EOF

# Empêcher git de tracker les modifications locales de local.nix
git -C "$CONFIG_DIR" update-index --skip-worktree local.nix

# --- Application ---
info "Application de la configuration Home Manager..."
nix run home-manager -- switch --flake "$CONFIG_DIR"

# --- Recharger le PATH après home-manager ---
export PATH="$HOME_DIR/.nix-profile/bin:$PATH"

# --- Installation des fonts côté Windows (dossier utilisateur, pas besoin d'admin) ---
WIN_USER_FONTS=$(find /mnt/c/Users -maxdepth 1 -mindepth 1 -type d ! -name "Public" ! -name "Default*" 2>/dev/null | head -1)
if [[ -n "$WIN_USER_FONTS" ]]; then
    WIN_USER_FONTS="$WIN_USER_FONTS/AppData/Local/Microsoft/Windows/Fonts"
    mkdir -p "$WIN_USER_FONTS"
    info "Installation des Nerd Fonts côté Windows..."
    FONT_DIR="$HOME_DIR/.nix-profile/share/fonts/truetype"
    find -L "$FONT_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp -n {} "$WIN_USER_FONTS/" \;
    info "Fonts installées dans $WIN_USER_FONTS"
else
    warn "/mnt/c non disponible — installation des fonts Windows ignorée."
fi

# --- Windows Terminal (thème Catppuccin Macchiato) ---
if [[ -d "/mnt/c" ]]; then
    WT_SETTINGS=$(find /mnt/c/Users/*/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json 2>/dev/null | head -1)
    if [[ -n "$WT_SETTINGS" ]]; then
        info "Configuration du thème Catppuccin Macchiato dans Windows Terminal..."
        WT_THEME="$CONFIG_DIR/windows-terminal.json"
        if command -v jq &>/dev/null && [[ -f "$WT_THEME" ]]; then
            SCHEME=$(jq '.scheme' "$WT_THEME")
            THEME=$(jq '.theme' "$WT_THEME")
            # Ajouter le scheme s'il n'existe pas
            if ! jq -e '.schemes[] | select(.name == "Catppuccin Macchiato")' "$WT_SETTINGS" &>/dev/null; then
                jq ".schemes += [$SCHEME]" "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
            fi
            # Ajouter le theme s'il n'existe pas
            if ! jq -e '.themes[] | select(.name == "Catppuccin Macchiato")' "$WT_SETTINGS" &>/dev/null; then
                jq ".themes += [$THEME]" "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
            fi
            # Appliquer le thème et le scheme par défaut
            jq '.theme = "Catppuccin Macchiato" | .profiles.defaults.colorScheme = "Catppuccin Macchiato"' "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
            info "Thème Catppuccin Macchiato appliqué à Windows Terminal."
        else
            warn "jq non disponible — configuration du thème Windows Terminal ignorée."
        fi
    else
        warn "Windows Terminal non trouvé."
    fi
fi

# --- Shell par défaut ---
ZSH_PATH="$HOME_DIR/.nix-profile/bin/zsh"
if [[ ! -x "$ZSH_PATH" ]]; then
    error "zsh introuvable dans $ZSH_PATH — home-manager switch a peut-être échoué."
fi

if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
    info "Ajout de zsh dans /etc/shells..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
fi

if [[ "$(getent passwd "$USERNAME" | cut -d: -f7)" != "$ZSH_PATH" ]]; then
    info "Configuration de zsh comme shell par défaut..."
    sudo chsh -s "$ZSH_PATH" "$USERNAME"
    info "Shell par défaut changé pour zsh."
else
    info "zsh est déjà le shell par défaut."
fi

info "Installation terminée ! Relancez votre terminal ou faites: exec zsh"
