# Home Manager — commandes de gestion

# Chemin du flake
flake := env("HOME") / ".config/home-manager"

# Initialiser après clonage (empêche git de tracker les modifs de local.nix)
init:
    git update-index --skip-worktree {{ flake }}/local.nix

# Appliquer la configuration
switch:
    home-manager switch --flake {{ flake }}

# Appliquer avec trace complète (debug)
switch-debug:
    home-manager switch --flake {{ flake }} --show-trace

# Mettre à jour les inputs (nixpkgs, home-manager, nixvim)
update:
    nix flake update --flake {{ flake }}

# Mettre à jour et appliquer
upgrade: update switch

# Lister les générations
generations:
    home-manager generations

# Supprimer les générations de plus de 7 jours
clean:
    home-manager expire-generations "-7 days"

# Lancer le ramasse-miettes Nix
gc:
    nix-collect-garbage -d

# Nettoyage complet (générations + gc)
purge: clean gc

# Afficher les news Home Manager
news:
    home-manager news

# Vérifier la config sans l'appliquer
check:
    nix flake check {{ flake }}

# Afficher les paquets installés
packages:
    home-manager packages

# Installer les Nerd Fonts côté Windows (dossier utilisateur, pas besoin d'admin)
fonts:
    #!/usr/bin/env bash
    FONT_DIR="$HOME/.nix-profile/share/fonts/truetype"
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
    [[ -z "$WIN_USER" ]] && { echo "Erreur: impossible de détecter l'utilisateur Windows"; exit 1; }
    WIN_FONTS="/mnt/c/Users/$WIN_USER/AppData/Local/Microsoft/Windows/Fonts"
    mkdir -p "$WIN_FONTS"
    find -L "$FONT_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -exec cp --update=none {} "$WIN_FONTS/" \;
    WIN_FONTS_WIN="C:\\Users\\$WIN_USER\\AppData\\Local\\Microsoft\\Windows\\Fonts"
    powershell.exe -NoProfile -Command "
        Get-ChildItem '$WIN_FONTS_WIN' -Filter '*.ttf' | ForEach-Object {
            \$regPath = 'HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts'
            \$name = \$_.BaseName + ' (TrueType)'
            if (-not (Get-ItemProperty -Path \$regPath -Name \$name -ErrorAction SilentlyContinue)) {
                New-ItemProperty -Path \$regPath -Name \$name -Value \$_.FullName -PropertyType String -Force | Out-Null
            }
        }
    " 2>/dev/null
    echo "Fonts installées et enregistrées dans Windows."

# Appliquer le thème Catppuccin Macchiato à Windows Terminal
theme:
    #!/usr/bin/env bash
    set -euo pipefail
    WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
    WT_SETTINGS=$(find "/mnt/c/Users/$WIN_USER/AppData/Local/Packages/" -path "*/Microsoft.WindowsTerminal*/LocalState/settings.json" 2>/dev/null | head -1)
    [[ -z "$WT_SETTINGS" ]] && { echo "Erreur: Windows Terminal non trouvé"; exit 1; }
    WT_THEME="{{ flake }}/windows-terminal.json"
    SCHEME=$(jq '.scheme' "$WT_THEME")
    THEME=$(jq '.theme' "$WT_THEME")
    if ! jq -e '.schemes[] | select(.name == "Catppuccin Macchiato")' "$WT_SETTINGS" &>/dev/null; then
        jq ".schemes += [$SCHEME]" "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
    fi
    if ! jq -e '.themes[] | select(.name == "Catppuccin Macchiato")' "$WT_SETTINGS" &>/dev/null; then
        jq ".themes += [$THEME]" "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
    fi
    jq '.theme = "Catppuccin Macchiato" | .profiles.defaults.colorScheme = "Catppuccin Macchiato"' "$WT_SETTINGS" > "${WT_SETTINGS}.tmp" && mv "${WT_SETTINGS}.tmp" "$WT_SETTINGS"
    echo "Thème Catppuccin Macchiato appliqué à Windows Terminal."
