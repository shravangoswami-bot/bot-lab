#!/usr/bin/env sh
set -eu

project_name="botlab"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"
binary="$bin_dir/$project_name"

remove_block() {
    profile="$1"
    [ -f "$profile" ] || return 0
    if ! grep -q "# >>> botlab >>>" "$profile" && ! grep -q "# >>> bot-pr >>>" "$profile"; then
        return 0
    fi
    tmp="$(mktemp)"
    awk '
        /# >>> botlab >>>/{skip=1}
        /# >>> bot-pr >>>/{skip=1}
        skip{if(/# <<< botlab <<</ || /# <<< bot-pr <<</){skip=0; next}; next}
        {print}
    ' "$profile" > "$tmp"
    cp "$tmp" "$profile"
    rm -f "$tmp"
    printf '%s\n' "removed botlab block from $profile"
}

if [ -f "$binary" ]; then
    rm -f "$binary"
    printf '%s\n' "removed $binary"
else
    printf '%s\n' "botlab is not installed at $binary"
fi

old_binary="$bin_dir/bot-pr"
if [ -f "$old_binary" ]; then
    rm -f "$old_binary"
    printf '%s\n' "removed old $old_binary"
fi

remove_block "$HOME/.bashrc"
remove_block "$HOME/.zshrc"

printf '%s\n' "bot gh config is still kept at ~/.config/botlab/gh"
printf '%s\n' "Remove it manually if you want to forget bot auth."
