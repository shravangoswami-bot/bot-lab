#!/usr/bin/env sh
set -eu

project_name="bot-pr"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"
binary="$bin_dir/$project_name"

remove_block() {
    profile="$1"
    [ -f "$profile" ] || return 0
    if ! grep -q "# >>> bot-pr >>>" "$profile"; then
        return 0
    fi
    tmp="$(mktemp)"
    awk '/# >>> bot-pr >>>/{skip=1} skip{if(/# <<< bot-pr <<</){skip=0; next}; next} {print}' "$profile" > "$tmp"
    cp "$tmp" "$profile"
    rm -f "$tmp"
    printf '%s\n' "removed bot-pr block from $profile"
}

if [ -f "$binary" ]; then
    rm -f "$binary"
    printf '%s\n' "removed $binary"
else
    printf '%s\n' "bot-pr is not installed at $binary"
fi

remove_block "$HOME/.bashrc"
remove_block "$HOME/.zshrc"

printf '%s\n' "bot gh config is still kept at ~/.config/bot-pr/gh"
printf '%s\n' "Remove it manually if you want to forget bot auth."
