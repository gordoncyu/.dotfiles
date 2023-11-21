#!/bin/bash

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPLACED_DIR="$DOTFILES_DIR/replaced"

# Function to create symlinks
create_symlink() {
    local src=$1
    local dst=$2
    local replaced=$3

    # Check if the destination file exists
    if [ -e "$dst" ] || [ -h "$dst" ]; then
        # Prompt user for action
        read -p "Replace $dst? (y/n): " -n 1 -r
        echo    # Move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Backup and replace
            mkdir -p "$(dirname $replaced)"
            mv "$dst" "$replaced"
            ln -snf "$src" "$dst"
            echo "Replaced $dst"
        else
            echo "Skipped $dst"
        fi
    else
        # Directly create symlink if no conflict
        ln -snf "$src" "$dst"
        echo "Linked $dst"
    fi
}

# Notify about .bashrc
echo "Please integrate .bashrc case-by-case."

# Symlink .clang-format, .fonts, .local/scripts, tmux, nvim, and .ssh
create_symlink "$DOTFILES_DIR/.clang-format" "$HOME/.clang-format" "$REPLACED_DIR/.clang-format"
create_symlink "$DOTFILES_DIR/.fonts" "$HOME/.fonts" "$REPLACED_DIR/.fonts"
create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim" "$REPLACED_DIR/.config/nvim"
create_symlink "$DOTFILES_DIR/.config/tmux" "$HOME/.config/tmux" "$REPLACED_DIR/.config/tmux"
create_symlink "$DOTFILES_DIR/.local/scripts" "$HOME/.local/scripts" "$REPLACED_DIR/.local/scripts"
create_symlink "$DOTFILES_DIR/.ssh" "$HOME/.ssh" "$REPLACED_DIR/.ssh"

if grep -q WSL /proc/version; then
    echo "WSL environment detected, keeping specific scripts"
else
    rm "$DOTFILES_DIR/.local/scripts/ospc"
    rm "$DOTFILES_DIR/.local/scripts/psr"
fi

install_nvim_appimage() {
    read -p "Install Neovim (AppImage)? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Downloading Neovim AppImage..."
        mkdir -p "$HOME/.local/bin"
        curl -L https://github.com/neovim/neovim/releases/download/stable/nvim.appimage -o "$HOME/.local/bin/nvim"
        chmod +x "$HOME/.local/bin/nvim.appimage"
        ln -s "$HOME/.local/bin/nvim" "$HOME/.local/bin/vim"
        echo "Neovim AppImage installed (linked to vim)"
    else
        echo "Skipping Neovim AppImage installation."
    fi
}

# Install Neovim AppImage
install_nvim_appimage

# Reminders
echo "Please fill out .local/scripts/cfg wloc.txt and floc.txt."
echo "Please install 'fzf' for certain .local/scripts and nvim functionality."
echo "Also consider installing 'ripgrep' for enhanced nvim search capabilities."

echo "Dotfiles installation complete."

