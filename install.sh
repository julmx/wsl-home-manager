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

# --- Informations utilisateur ---
read -rp "Nom d'utilisateur système: " USERNAME
[[ -z "$USERNAME" ]] && error "Le nom d'utilisateur ne peut pas être vide."

HOME_DIR="/home/$USERNAME"
[[ ! -d "$HOME_DIR" ]] && error "Le répertoire $HOME_DIR n'existe pas."

read -rp "Nom pour git (ex: Jean Dupont) [$USERNAME]: " GIT_NAME
GIT_NAME="${GIT_NAME:-$USERNAME}"

read -rp "Email pour git: " GIT_EMAIL
[[ -z "$GIT_EMAIL" ]] && error "L'email git ne peut pas être vide."

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
