# Dotfiles

Personal dotfiles managed with [Ansible](https://www.ansible.com/).

## Features

- **Cross-platform**: macOS (primary), Linux (Debian/Ubuntu, Fedora, Arch)
- **Idempotent**: Safe to run multiple times
- **Modular**: Each tool is a separate Ansible role
- **Flexible**: Per-host and work/personal customization via variables
- **Hostname validation**: Prevents running on wrong machine
- **Symlinks where it matters**: Configs you edit frequently (Starship, Ghostty) are symlinked for live editing

## Quick Start

```bash

# Run the setup/update script
./run.sh

# Run the script for a particular tag
./run.sh --tags zsh     # For updating zsh configs only

```

### New Machine

```bash
# 1. Clone the repository
git clone https://github.com/YOURUSERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the setup script
./run.sh
```

On first run, if your hostname isn't in `inventory.yaml`, you'll see:

```
ERROR: Host 'MyMacbook' not found in inventory.yaml

Add the following to inventory.yaml under 'darwin':

    MyMacbook:
      ansible_host: localhost
      ansible_connection: local

Then rerun: ./run.sh
```

Add your host to the inventory and run again.

### Existing Machine

```bash
cd ~/.dotfiles
git pull
./run.sh
```

## What Gets Installed

### Packages

| Category | macOS (Homebrew) | Linux (apt/dnf/pacman) |
|----------|------------------|------------------------|
| Shell | zsh | zsh |
| Editor | neovim | neovim |
| Prompt | starship | starship |
| Terminal | ghostty | - |
| Multiplexer | tmux | tmux |
| Search | fzf, ripgrep, fd | fzf, ripgrep, fd |
| Utils | jq, bat, eza, tree, htop | jq, bat, tree, htop |
| Git | git, delta | git |

### Configurations

| Config | Method | Location |
|--------|--------|----------|
| `.zshrc` | Template | `~/.zshrc` |
| `.tmux.conf` | Template | `~/.tmux.conf` |
| `.gitconfig` | Template | `~/.gitconfig` |
| `starship.toml` | **Symlink** | `~/.config/starship.toml` |
| `ghostty/config` | **Symlink** | Platform-specific |

**Symlinked configs**: Edit directly in the app; changes are automatically tracked in git.

## Directory Structure

```
.dotfiles/
├── run.sh                   # Main entry point (bootstrap + run)
├── ansible.cfg              # Ansible configuration
├── inventory.yaml           # Host inventory
├── site.yaml                # Main playbook
│
├── group_vars/
│   ├── all.yaml             # Shared variables
│   ├── darwin.yaml          # macOS variables
│   ├── linux.yaml           # Linux variables
│   └── work.yaml            # Work machine variables
│
├── host_vars/               # Per-host overrides
│   └── .gitkeep
│
├── roles/
│   ├── core/                # Base setup + hostname validation
│   ├── packages/            # Package installation
│   ├── ohmyzsh/             # Oh My Zsh + plugins
│   ├── zsh/                 # Zsh configuration
│   ├── tmux/                # Tmux configuration
│   ├── starship/            # Starship prompt (symlinked)
│   ├── ghostty/             # Ghostty terminal (symlinked)
│   ├── git/                 # Git configuration
│   └── fonts/               # Font installation
│
├── README.md
└── LICENSE
```

## Customization

### Variables

Edit `group_vars/all.yaml` for shared settings:

```yaml
git_user_name: "Your Name"
git_user_email: "you@example.com"
git_editor: nvim
```

### Adding a New Machine

1. Get your hostname: `hostname -s`
2. Add to `inventory.yaml` under the appropriate OS group:

```yaml
darwin:
  hosts:
    YourHostname:                 # Must match output of hostname -s
      ansible_host: localhost
      ansible_connection: local
```

3. Optionally add to `work` or `personal` group for additional settings.

### Work vs Personal

Add your machine's hostname to the `work` group:

```yaml
work:
  hosts:
    YourWorkMachine: {}
```

Work machines get:
- `~/.aliases.work` with work-specific aliases
- Different git settings (SSH URLs instead of HTTPS)

### Per-Host Customization

Create `host_vars/<your-hostname>.yaml`:

```yaml
---
git_user_email: "different-email@example.com"
install_gui_apps: false  # For servers
```

### Local Overrides

For machine-specific settings not tracked in git:
- `~/.zshrc.local` - Sourced at end of `.zshrc`
- `~/.gitconfig.local` - Included by `.gitconfig`

## Usage

### Run Full Setup

```bash
./run.sh
```

### Run Specific Roles

```bash
# Only zsh configuration
./run.sh --tags zsh

# Only packages
./run.sh --tags packages

# Multiple tags
./run.sh --tags "zsh,tmux,git"
```

### Dry Run

```bash
./run.sh --check --diff
```

### Update Dotfiles

```bash
cd ~/.dotfiles
git pull
./run.sh
```

## Adding New Configurations

### Adding a New Tool

1. Create the role structure:
   ```bash
   mkdir -p roles/newtool/{tasks,files,templates}
   ```

2. Create `roles/newtool/tasks/main.yaml`

3. Add to `site.yaml`:
   ```yaml
   - role: newtool
     tags: [newtool]
   ```

### Symlink vs Template

- **Symlink** (`file: state=link`): For configs you edit frequently in the app
- **Template** (`.j2`): For configs that need OS-specific or machine-specific values

## How It Works

The `run.sh` script:

1. **Detects OS** (macOS or Linux distro)
2. **Installs Ansible** if not present (via Homebrew, apt, dnf, or pacman)
3. **Checks hostname** against `inventory.yaml`
4. **Runs playbook** with `--limit $(hostname -s)`

The playbook then:

1. **Validates hostname** matches inventory entry (prevents running on wrong machine)
2. **Installs packages** via native package manager
3. **Deploys configs** (templates for dynamic, symlinks for static)
4. **Installs fonts** for terminal

## Troubleshooting

### Host Not Found in Inventory

```
ERROR: Host 'MyHost' not found in inventory.yaml
```

Add your hostname to `inventory.yaml` under the correct OS group (darwin/linux).

### Hostname Mismatch

```
Hostname mismatch!
Inventory host: WrongHost
Actual hostname: RightHost
```

Either rename the inventory entry or run on the correct machine.

### Permission Denied on Linux

Run with sudo password prompt:
```bash
./run.sh --ask-become-pass
```

### Check What Would Change

```bash
./run.sh --check --diff
```

## License

MIT
