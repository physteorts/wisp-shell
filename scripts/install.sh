#!/usr/bin/env bash
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$HOME/.config/wisp-shell"
readonly GREETER_USER="greeter"
readonly REPOSITORY_URL="https://github.com/physteorts/wisp-shell.git"
PROJECT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

log() {
    printf '[wisp-shell] %s\n' "$*"
}

fail() {
    printf '[wisp-shell] error: %s\n' "$*" >&2
    exit 1
}

need_command() {
    command -v "$1" >/dev/null 2>&1 || fail "Required command is missing: $1"
}

run_root() {
    if [[ $EUID -eq 0 ]]; then
        "$@"
    else
        sudo "$@"
    fi
}

install_packages() {
    local package_manager=""
    local -a packages=()

    if command -v dnf >/dev/null 2>&1; then
        package_manager=dnf
        packages=(quickshell greetd niri python3 acl polkit glib2 fontconfig)
    elif command -v pacman >/dev/null 2>&1; then
        package_manager=pacman
        packages=(quickshell greetd niri python python-pip acl polkit glib2 fontconfig)
    elif command -v apt-get >/dev/null 2>&1; then
        package_manager=apt-get
        packages=(python3 acl policykit-1 libglib2.0-bin fontconfig)
        log "Quickshell, greetd, Niri, and Matugen may require third-party repositories on Debian-based systems."
    else
        fail "Unsupported distribution: install Quickshell, greetd, Niri, Python 3, acl, polkit, glib2, and fontconfig manually."
    fi

    log "Installing system packages with $package_manager"
    case "$package_manager" in
        dnf)
            run_root dnf install -y "${packages[@]}"
            ;;
        pacman)
            run_root pacman -Sy --needed --noconfirm "${packages[@]}"
            ;;
        apt-get)
            run_root apt-get update
            run_root apt-get install -y "${packages[@]}"
            ;;
    esac
}

prepare_project() {
    if [[ -f "$PROJECT_DIR/greeter.qml" ]]; then
        return
    fi

    PROJECT_DIR="$HOME/.config/quickshell/wisp-shell"
    if [[ ! -f "$PROJECT_DIR/greeter.qml" ]]; then
        need_command git
        log "Cloning Wisp Shell into $PROJECT_DIR"
        mkdir -p "$(dirname -- "$PROJECT_DIR")"
        git clone "$REPOSITORY_URL" "$PROJECT_DIR"
    fi
}

install_matugen() {
    if command -v matugen >/dev/null 2>&1; then
        return
    fi

    if ! command -v cargo >/dev/null 2>&1; then
        log "Installing Rust tooling for Matugen"
        if command -v dnf >/dev/null 2>&1; then
            run_root dnf install -y cargo
        elif command -v pacman >/dev/null 2>&1; then
            run_root pacman -Sy --needed --noconfirm rust
        elif command -v apt-get >/dev/null 2>&1; then
            run_root apt-get install -y cargo
        else
            fail "Cargo is required to install Matugen on this system."
        fi
    fi

    log "Installing Matugen"
    cargo install matugen
}

install_greeter_files() {
    [[ -d /etc/greetd ]] || fail "/etc/greetd does not exist; greetd was not installed correctly"

    local launcher
    launcher="$(mktemp)"
    cat > "$launcher" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail
unset DISPLAY WAYLAND_DISPLAY WAYLAND_SOCKET
export XDG_RUNTIME_DIR="/tmp/greetd-runtime-\$(id -u)"
mkdir -p "\$XDG_RUNTIME_DIR"
chmod 0700 "\$XDG_RUNTIME_DIR"
export XDG_SESSION_TYPE=wayland
export QT_QPA_PLATFORM=wayland
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
exec niri --config /etc/greetd/niri-greeter.kdl
EOF
    chmod 0755 "$launcher"
    run_root install -o root -g root -m 0755 "$launcher" /usr/local/bin/wisp-greeter
    rm -f "$launcher"

    local greeter_config
    greeter_config="$(mktemp)"
    cat > "$greeter_config" <<EOF
spawn-at-startup "quickshell" "-p" "$PROJECT_DIR/greeter.qml"

prefer-no-csd
screenshot-path null

layout {
    focus-ring {
        off
    }
    border {
        off
    }
}

hotkey-overlay {
    skip-at-startup
}
EOF
    run_root install -o root -g root -m 0644 "$greeter_config" /etc/greetd/niri-greeter.kdl
    rm -f "$greeter_config"

    if [[ -f /etc/greetd/config.toml ]]; then
        local greetd_config
        greetd_config="$(mktemp)"
        awk '
            BEGIN { in_default = 0; seen_command = 0; seen_user = 0 }
            /^\[default_session\]/ { in_default = 1 }
            /^\[/ && !/^\[default_session\]/ { in_default = 0 }
            in_default && /^command[[:space:]]*=/ { print "command = \"/usr/local/bin/wisp-greeter\""; seen_command = 1; next }
            in_default && /^user[[:space:]]*=/ { print "user = \"greeter\""; seen_user = 1; next }
            { print }
            END {
                if (!in_default) {
                    print ""
                    print "[default_session]"
                }
                if (!seen_command) print "command = \"/usr/local/bin/wisp-greeter\""
                if (!seen_user) print "user = \"greeter\""
            }
        ' /etc/greetd/config.toml > "$greetd_config"
        run_root install -o root -g root -m 0644 "$greetd_config" /etc/greetd/config.toml
        rm -f "$greetd_config"
    fi
}

setup_access() {
    [[ $(id -u "$GREETER_USER" 2>/dev/null || true) ]] || fail "The $GREETER_USER user does not exist"
    need_command setfacl

    mkdir -p "$CONFIG_DIR"
    setfacl -R -m "u:$GREETER_USER:rwX" "$PROJECT_DIR" "$CONFIG_DIR"
    find "$PROJECT_DIR" "$CONFIG_DIR" -type d -exec setfacl -m "d:u:$GREETER_USER:rwx" {} +
}

main() {
    [[ $EUID -ne 0 ]] || fail "Run this installer as your normal user; it will request sudo when needed."

    prepare_project
    install_packages
    install_matugen
    setup_access
    install_greeter_files

    need_command quickshell
    need_command niri
    need_command python3
    need_command matugen
    log "Installation complete. Restart greetd to launch the greeter."
}

main "$@"