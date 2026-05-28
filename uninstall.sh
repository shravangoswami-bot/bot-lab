#!/usr/bin/env sh
set -eu

project_name="bot-pr"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"
binary="$bin_dir/$project_name"

if [ -f "$binary" ]; then
    rm -f "$binary"
    printf '%s\n' "removed $binary"
else
    printf '%s\n' "bot-pr is not installed at $binary"
fi

printf '%s\n' "bot gh config is still kept at ~/.config/bot-pr/gh"
printf '%s\n' "Remove it manually if you want to forget bot auth."
