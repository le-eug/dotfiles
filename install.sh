#!/usr/bin/env bash
# Set up a Mac from this repo. Safe to run again: existing files are backed up, not deleted.
#
#   ./install.sh               install everything + link configs
#   ./install.sh --links-only  only (re)create the symlinks

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
LINKS_ONLY=false
[[ "${1:-}" == "--links-only" ]] && LINKS_ONLY=true

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# Move a real file/folder out of the way so a symlink can go there.
# Leaves symlinks alone (stow/ln replace or reuse them).
backup() {
  local path="$1"
  if [[ -e "$path" && ! -L "$path" ]]; then
    mv "$path" "$path.bak.$STAMP"
    echo "    backed up $path -> $path.bak.$STAMP"
  fi
}

# Symlink $2 -> $1, replacing an existing symlink and backing up a real file
link() {
  local target="$1" path="$2"
  backup "$path"
  ln -sfn "$target" "$path"
  echo "    $path -> $target"
}

install_tools() {
  # Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"

  info "Installing Brewfile packages (this takes a while)"
  # Keep going if one package fails; brew prints which ones did
  brew bundle --file="$DOTFILES/Brewfile" || echo "    some Brewfile packages failed, see above"

  # oh-my-zsh (KEEP_ZSHRC so it doesn't replace our .zshrc)
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
  local zsh_custom="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  if [[ ! -d "$zsh_custom" ]]; then
    info "Installing zsh-autosuggestions"
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$zsh_custom"
  fi

  # nvm (PROFILE=/dev/null so it doesn't edit .zshrc; ours already loads it)
  if [[ ! -d "$HOME/.nvm" ]]; then
    info "Installing nvm"
    PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh)"
  fi
}

link_configs() {
  command -v stow >/dev/null 2>&1 || { echo "stow not found. Run ./install.sh without --links-only first."; exit 1; }

  info "Linking configs into ~/.config"
  mkdir -p "$HOME/.config"
  cd "$DOTFILES"
  for pkg in */; do
    pkg="${pkg%/}"
    # Back up anything stow would collide with
    for item in "$pkg"/.config/*; do
      [[ -e "$item" ]] && backup "$HOME/.config/$(basename "$item")"
    done
    stow --restow --target="$HOME" "$pkg"
    echo "    $pkg"
  done

  info "Linking home folder files"
  link "$HOME/.config/zsh/.zshrc" "$HOME/.zshrc"
  link "$HOME/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"
  link "$HOME/.config/aerospace/.aerospace.toml" "$HOME/.aerospace.toml"
}

install_nvim_plugins() {
  if command -v nvim >/dev/null 2>&1; then
    info "Installing Neovim plugins (versions from lazy-lock.json)"
    nvim --headless "+Lazy! restore" +qa || true
    echo "    LSP servers install the first time you open nvim (see :Mason)"
  fi
}

if ! $LINKS_ONLY; then
  install_tools
fi
link_configs
if ! $LINKS_ONLY; then
  install_nvim_plugins
fi

info "Done. Open a new terminal to load the new shell config."
