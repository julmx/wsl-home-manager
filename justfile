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
