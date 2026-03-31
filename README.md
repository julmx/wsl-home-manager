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

### Installation automatique

Le script `install.sh` gère tout automatiquement (installation de Nix, activation des flakes, clonage, configuration du username, application) :

```bash
bash <(curl -sL https://raw.githubusercontent.com/julmx/wsl-home-manager/main/install.sh)
```

Le script demandera le nom d'utilisateur, le nom git et l'email git.

### Installation manuelle

<details>
<summary>Étapes détaillées</summary>

1. **Installer Nix** (multi-user) :

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

2. **Activer les flakes** dans `~/.config/nix/nix.conf` :

```
experimental-features = nix-command flakes
```

3. **Cloner le dépôt** :

```bash
git clone https://github.com/julmx/wsl-home-manager.git ~/.config/home-manager
```

4. **Créer `local.nix`** à partir du template :

```bash
cp ~/.config/home-manager/local.nix.example ~/.config/home-manager/local.nix
nvim ~/.config/home-manager/local.nix  # adapter les valeurs
```

5. **Appliquer la configuration** :

```bash
nix run home-manager -- switch --flake ~/.config/home-manager --impure
```

</details>

La première exécution peut prendre un moment (téléchargement de tous les paquets).

## Commandes

Les tâches courantes sont disponibles via [`just`](https://github.com/casey/just). Lancer `just` sans argument affiche les commandes disponibles.

| Commande | Description |
|---|---|
| `just switch` | Appliquer la configuration |
| `just switch-debug` | Appliquer avec trace complète (debug) |
| `just update` | Mettre à jour les inputs du flake (nixpkgs, home-manager, nixvim) |
| `just upgrade` | Mettre à jour + appliquer |
| `just generations` | Lister les générations (historique) |
| `just packages` | Lister les paquets installés |
| `just check` | Vérifier la config sans l'appliquer |
| `just news` | Afficher les news Home Manager |
| `just clean` | Supprimer les générations de plus de 7 jours |
| `just gc` | Lancer le ramasse-miettes Nix |
| `just purge` | Nettoyage complet (clean + gc) |

## Workflow typique

```bash
# 1. Modifier la config (ex: ajouter un paquet dans home.nix)
nvim ~/.config/home-manager/home.nix

# 2. Appliquer les changements
just switch

# 3. Versionner
git add -A && git commit -m "feat: ajout de ..."
git push
```

## Mettre à jour les paquets

```bash
# Mettre à jour et appliquer en une commande
just upgrade

# Versionner le lock
git add flake.lock && git commit -m "chore: update flake inputs"
```

## Rollback

Pour revenir à une génération précédente :

```bash
# Lister les générations
just generations

# Activer une génération spécifique (copier le chemin depuis la sortie ci-dessus)
/nix/store/...-home-manager-generation/activate
```

## Structure du projet

```
~/.config/home-manager/
├── flake.nix          # Point d'entrée, définition des inputs (nixpkgs, home-manager, nixvim)
├── flake.lock         # Versions verrouillées des inputs
├── home.nix           # Configuration principale (paquets, imports des modules)
├── local.nix          # Config locale spécifique à la machine (gitignored)
├── local.nix.example  # Template pour local.nix
├── justfile           # Commandes de gestion (just switch, just update, etc.)
├── install.sh         # Script d'installation automatique
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
