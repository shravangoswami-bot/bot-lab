#!/usr/bin/env sh
set -eu

project_name="botlab"
default_repo="shravangoswami-bot/bot-lab"

repo="${BOTLAB_REPO:-$default_repo}"
version="${BOTLAB_VERSION:-latest}"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"
shell_name="auto"
profile_path=""
modify_profile="1"
profile_updated=""
is_update=""

err() {
    printf '%s\n' "error: $*" >&2
    exit 1
}

has() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    cat <<USAGE
botlab installer

Downloads botlab from GitHub Releases.
Re-run this script later to update.

Usage:
  install.sh [options]

Options:
      --repo OWNER/REPO       GitHub repository [default: $repo]
      --version VERSION       Release version, for example v0.1.0 [default: latest]
  -b, --bin-dir DIR           Install directory [default: $bin_dir]
      --shell bash|zsh|none   Shell profile integration [default: auto]
      --profile PATH          Shell profile to update
      --no-modify-profile     Install only the binary
  -h, --help                  Print help

Environment:
  BOTLAB_REPO       Default GitHub repository
  BOTLAB_VERSION    Default release version
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
        --shell)
            [ "$#" -ge 2 ] || err "--shell requires bash, zsh, or none"
            shell_name="$2"
            shift 2
            ;;
        --shell=*)
            shell_name="${1#*=}"
            shift
            ;;
        --profile)
            [ "$#" -ge 2 ] || err "--profile requires a path"
            profile_path="$2"
            shift 2
            ;;
        --profile=*)
            profile_path="${1#*=}"
            shift
            ;;
        --no-modify-profile)
            modify_profile="0"
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

detect_shell() {
    case "$shell_name" in
        bash|zsh|none) printf '%s' "$shell_name" ;;
        auto)
            current_shell="$(basename "${SHELL:-}")"
            case "$current_shell" in
                bash|zsh) printf '%s' "$current_shell" ;;
                *) printf '%s' "none" ;;
            esac
            ;;
        *) err "unsupported shell: $shell_name" ;;
    esac
}

default_profile_for_shell() {
    case "$1" in
        bash) printf '%s/.bashrc' "$HOME" ;;
        zsh) printf '%s/.zshrc' "$HOME" ;;
        none) printf '%s' "" ;;
    esac
}

profile_dirname() {
    path="$1"
    case "$path" in
        */*) printf '%s' "${path%/*}" ;;
        *) printf '%s' "." ;;
    esac
}

escape_double_quotes() {
    printf '%s' "$1" | sed 's/["\\$`]/\\&/g'
}

path_has_bin_dir() {
    case ":$PATH:" in
        *":$bin_dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

update_profile() {
    selected_shell="$1"
    [ "$modify_profile" = "1" ] || return 0
    [ "$selected_shell" != "none" ] || return 0
    path_has_bin_dir && return 0

    profile="$profile_path"
    if [ -z "$profile" ]; then
        profile="$(default_profile_for_shell "$selected_shell")"
    fi
    [ -n "$profile" ] || return 0

    mkdir -p "$(profile_dirname "$profile")"
    if [ -f "$profile" ] && grep -q "# >>> botlab >>>" "$profile"; then
        profile_updated="$profile"
        return 0
    fi

    escaped_bin_dir="$(escape_double_quotes "$bin_dir")"
    {
        printf '\n'
        printf '%s\n' '# >>> botlab >>>'
        printf '%s\n' '# Added by the botlab installer. Remove with: uninstall.sh'
        printf 'export PATH="%s:$PATH"\n' "$escaped_bin_dir"
        printf '%s\n' '# <<< botlab <<<'
    } >> "$profile"

    profile_updated="$profile"
}

print_summary() {
    printf '\n'
    if [ -n "$is_update" ]; then
        printf '%s\n' "botlab is updated."
    else
        printf '%s\n' "botlab is installed."
    fi
    printf '\n'
    printf '  Binary:  %s\n' "$bin_dir/$project_name"

    if path_has_bin_dir; then
        printf '  PATH:    already active\n'
    elif [ -n "$profile_updated" ]; then
        printf '  Profile: %s\n' "$profile_updated"
        printf '\n'
        printf '%s\n' "Reload your shell to activate it:"
        printf '\n'
        printf '  source %s\n' "$profile_updated"
        printf '\n'
        printf '%s\n' "Or start a fresh shell session:"
        printf '\n'
        printf '%s\n' "  exec \$SHELL"
    else
        printf '\n'
        printf '%s\n' "Shell profile was not modified. To activate manually:"
        printf '\n'
        printf '  export PATH="%s:$PATH"\n' "$bin_dir"
    fi

    printf '\n'
    printf '%s\n' "Verify:"
    printf '\n'
    printf '%s\n' "  botlab gh auth status"
    printf '%s\n' "  botlab --version"
    printf '\n'
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

printf '%s\n' "Installing botlab from $repo ($version)"
download "$tmp" "$(release_url "$project_name")"

mkdir -p "$bin_dir"
if [ -f "$bin_dir/$project_name" ]; then
    is_update="1"
fi
cp "$tmp" "$bin_dir/$project_name"
chmod +x "$bin_dir/$project_name"

if [ -f "$bin_dir/bot-pr" ]; then
    rm -f "$bin_dir/bot-pr"
fi

selected_shell="$(detect_shell)"
update_profile "$selected_shell"
print_summary
