# WSL Home Manager

Configuration Home Manager (Nix) pour environnement WSL, gérée via un flake.

## Contenu

- **Shell** : Zsh
- **Editeur** : Neovim (NixVim)
- **Terminal multiplexer** : Tmux
- **CLI tools** : bat, fzf, git, lazygit, htop, btop, bottom, gh
- **Utilitaires** : eza, zoxide, tealdeer, fastfetch, ripgrep, fd, jq, ncdu, duf, yazi
- **Dev** : Node.js 22, pnpm, pyright
- **Fonts** : JetBrains Mono NF, Fira Code NF, Maple Mono NF

## Installation sur une nouvelle machine

### Prérequis

1. **Installer Nix** (multi-user) :

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

2. **Activer les flakes** en ajoutant dans `~/.config/nix/nix.conf` :

```
experimental-features = nix-command flakes
```

Puis relancer le shell ou `source` le profil.

### Déployer la configuration

1. **Cloner le dépôt** :

```bash
git clone git@github.com:julmx/wsl-home-manager.git ~/.config/home-manager
```

2. **Adapter le nom d'utilisateur** si nécessaire dans `flake.nix` et `home.nix` :
   - `flake.nix` : remplacer `"julmx"` dans `homeConfigurations."julmx"` par votre username
   - `home.nix` : modifier `home.username` et `home.homeDirectory`

3. **Appliquer la configuration** :

```bash
home-manager switch --flake ~/.config/home-manager
```

La première exécution peut prendre un moment (téléchargement de tous les paquets).

## Commandes de base

| Commande | Description |
|---|---|
| `home-manager switch --flake ~/.config/home-manager` | Appliquer la configuration (après modification) |
| `home-manager generations` | Lister les générations (historique des activations) |
| `home-manager expire-generations "-7 days"` | Supprimer les générations de plus de 7 jours |
| `nix flake update --flake ~/.config/home-manager` | Mettre à jour les inputs du flake (nixpkgs, home-manager, nixvim) |
| `home-manager switch --flake ~/.config/home-manager --show-trace` | Appliquer avec trace complète en cas d'erreur |

## Workflow typique

```bash
# 1. Modifier la config (ex: ajouter un paquet dans home.nix)
nvim ~/.config/home-manager/home.nix

# 2. Appliquer les changements
home-manager switch --flake ~/.config/home-manager

# 3. Versionner
cd ~/.config/home-manager
git add -A && git commit -m "feat: ajout de ..."
git push
```

## Mettre à jour les paquets

```bash
# Mettre à jour le flake.lock (nouvelles versions de nixpkgs, home-manager, nixvim)
nix flake update --flake ~/.config/home-manager

# Reconstruire avec les mises à jour
home-manager switch --flake ~/.config/home-manager

# Versionner le lock
cd ~/.config/home-manager
git add flake.lock && git commit -m "chore: update flake inputs"
```

## Rollback

Pour revenir à une génération précédente :

```bash
# Lister les générations
home-manager generations

# Activer une génération spécifique (copier le chemin depuis la sortie ci-dessus)
/nix/store/...-home-manager-generation/activate
```

## Structure du projet

```
~/.config/home-manager/
├── flake.nix          # Point d'entrée, définition des inputs (nixpkgs, home-manager, nixvim)
├── flake.lock         # Versions verrouillées des inputs
├── home.nix           # Configuration principale (paquets, imports des modules)
└── modules/
    ├── cli/           # bat, fzf, git, lazygit, htop, btop, bottom, gh
    ├── editors/       # neovim (nixvim)
    ├── shell/         # zsh
    ├── yazi/          # gestionnaire de fichiers
    ├── eza.nix        # remplacement de ls
    ├── fastfetch.nix  # info système
    ├── tealdeer.nix   # tldr pages
    ├── tmux.nix       # multiplexeur terminal
    └── zoxide.nix     # cd intelligent
```
