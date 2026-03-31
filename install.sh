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
if nix flake --help &>/dev/null 2>&1; then
    info "Les flakes sont déjà activés."
else
    info "Activation des flakes..."
    mkdir -p "$(dirname "$NIX_CONF")"
    echo "experimental-features = nix-command flakes" >> "$NIX_CONF"
    info "Flakes activés dans $NIX_CONF"
fi

# --- Git (nécessaire pour cloner) ---
if ! command -v git &>/dev/null; then
    info "Installation de git via nix..."
    nix profile install nixpkgs#git
fi

# --- Clone ---
if [[ -d "$CONFIG_DIR" ]]; then
    warn "$CONFIG_DIR existe déjà, étape de clonage ignorée."
else
    info "Clonage du dépôt..."
    mkdir -p "$(dirname "$CONFIG_DIR")"
    git clone "$REPO" "$CONFIG_DIR"
fi

# --- Génération de local.nix ---
info "Génération de local.nix..."
cat > "$CONFIG_DIR/local.nix" <<EOF
{
  username = "$USERNAME";
  homeDirectory = "$HOME_DIR";
  gitName = "$GIT_NAME";
  gitEmail = "$GIT_EMAIL";
}
EOF

# --- Application ---
info "Application de la configuration Home Manager..."
nix run home-manager -- switch --flake "$CONFIG_DIR" --impure

info "Installation terminée ! Relancez votre shell ou faites: exec \$SHELL"
