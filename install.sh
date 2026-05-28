#!/usr/bin/env sh
set -eu

project_name="bot-pr"
default_repo="shravangoswami-bot/bot-lab"

repo="${BOT_PR_REPO:-$default_repo}"
version="${BOT_PR_VERSION:-latest}"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"

err() {
    printf '%s\n' "error: $*" >&2
    exit 1
}

has() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<USAGE
bot-pr installer

Downloads bot-pr from GitHub Releases.
Re-run this script later to update.

Usage:
  install.sh [options]

Options:
      --repo OWNER/REPO       GitHub repository [default: $repo]
      --version VERSION       Release version, for example v0.1.0 [default: latest]
  -b, --bin-dir DIR           Install directory [default: $bin_dir]
  -h, --help                  Print help

Environment:
  BOT_PR_REPO       Default GitHub repository
  BOT_PR_VERSION    Default release version
  BIN_DIR           Default install directory
USAGE
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --repo)
            [ "$#" -ge 2 ] || err "--repo requires OWNER/REPO"
            repo="$2"
            shift 2
            ;;
        --repo=*)
            repo="${1#*=}"
            shift
            ;;
        --version)
            [ "$#" -ge 2 ] || err "--version requires a release version"
            version="$2"
            shift 2
            ;;
        --version=*)
            version="${1#*=}"
            shift
            ;;
        -b|--bin-dir)
            [ "$#" -ge 2 ] || err "--bin-dir requires a directory"
            bin_dir="$2"
            shift 2
            ;;
        --bin-dir=*)
            bin_dir="${1#*=}"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            err "unknown option: $1"
            ;;
    esac
done

download() {
    file="$1"
    url="$2"

    if has curl; then
        curl --fail --silent --show-error --location --output "$file" "$url"
    elif has wget; then
        wget --quiet --output-document="$file" "$url"
    else
        err "need curl or wget to download release assets"
    fi
}

release_url() {
    asset="$1"
    case "$version" in
        latest)
            printf 'https://github.com/%s/releases/latest/download/%s' "$repo" "$asset"
            ;;
        v*)
            printf 'https://github.com/%s/releases/download/%s/%s' "$repo" "$version" "$asset"
            ;;
        *)
            printf 'https://github.com/%s/releases/download/v%s/%s' "$repo" "$version" "$asset"
            ;;
    esac
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

printf '%s\n' "Installing bot-pr from $repo ($version)"
download "$tmp" "$(release_url "$project_name")"

mkdir -p "$bin_dir"
cp "$tmp" "$bin_dir/$project_name"
chmod +x "$bin_dir/$project_name"

printf '\n'
printf '%s\n' "bot-pr installed at $bin_dir/$project_name"
printf '%s\n' "Make sure this is in your PATH: $bin_dir"
printf '\n'
printf '%s\n' "Try:"
printf '%s\n' "  bot-pr auth status"
printf '\n'
