# Wisp Shell

A Quickshell-based Wayland shell with wallpaper, dynamic colors, settings, polkit, and greetd greeter support.

## Install

Run the installer as your normal user. It uses `sudo` for system changes:

```bash
./scripts/install.sh
```

For a fresh installation, bootstrap the project and run the installer directly from GitHub:

```bash
curl -fsSL https://raw.githubusercontent.com/physteorts/wisp-shell/main/scripts/install.sh | bash
```

When run this way, the installer clones the project into `~/.config/quickshell/wisp-shell` if it is not already present.

The installer supports Fedora, Arch Linux, and Debian-based systems. It installs or checks the required runtime tools, including:

- Quickshell
- greetd and Niri
- Python 3
- Matugen
- polkit and GLib utilities
- ACL and fontconfig support

It also:

- Installs `/usr/local/bin/wisp-greeter`
- Configures greetd to use this greeter
- Configures the Niri greeter session
- Grants the `greeter` user access to the shell source and `~/.config/wisp-shell`
- Adds inherited permissions for future configuration files

## Run the Desktop Shell

Start the desktop shell from this directory with:

```bash
quickshell -p ./shell.qml
```

For an autostart setup, add the command to your compositor or session startup configuration.

## Run the Greeter

The installer configures greetd to launch the greeter. Restart greetd after installation:

```bash
sudo systemctl restart greetd
```

The greeter loads `./greeter.qml` and shares wallpaper and configuration data with the desktop shell.

## Configuration

Runtime files are stored in:

```text
~/.config/wisp-shell/
```

The wallpaper, settings, and generated color files are managed automatically by the shell.

## Troubleshooting

Check the greetd service and recent logs with:

```bash
systemctl status greetd
journalctl -u greetd -b
```

Ensure the following commands are available after installation:

```bash
command -v quickshell matugen niri python3 setfacl
```
