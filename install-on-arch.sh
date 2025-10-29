#!/bin/bash

set -euo pipefail

# Simple one-shot installer for CURRENT Arch Linux system.
# It will install Hyprland, apps, fonts, themes, GPU drivers, and configs.

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "Please run as root (sudo ./install-on-arch.sh)"
    exit 1
  fi
}

prompt_user() {
  local default_user
  default_user=${SUDO_USER:-$(logname 2>/dev/null || echo "")}
  read -rp "Target username [${default_user}]: " TARGET_USER
  TARGET_USER=${TARGET_USER:-$default_user}
  if [[ -z "$TARGET_USER" ]]; then
    echo "Could not determine target username."; exit 1
  fi
  TARGET_HOME=$(eval echo ~"$TARGET_USER")
}

ensure_base_packages() {
  pacman -Syu --noconfirm || true
  pacman -Sy --noconfirm --needed \
    base base-devel git curl wget unzip \
    networkmanager openssh sudo \
    hyprland waybar rofi \
    gtk3 gtk4 qt5ct qt6ct polkit-gnome \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils \
    thunar thunar-archive-plugin file-roller \
    noto-fonts ttf-font-awesome ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono noto-fonts-emoji

  systemctl enable --now NetworkManager || true
  systemctl enable --now sshd || true
}

install_yay() {
  if command -v yay >/dev/null 2>&1; then return; fi
  sudo -u "$TARGET_USER" bash -c '
    set -e
    cd /tmp
    if [[ ! -d yay ]]; then git clone https://aur.archlinux.org/yay.git yay; fi
    cd yay
    makepkg -si --noconfirm
  '
}

detect_and_install_gpu() {
  local vendor
  vendor=$(lspci | grep -i vga | grep -oE 'NVIDIA|AMD|Intel' | head -n1 || true)

  # Ensure multilib is enabled if possible (for lib32- packages)
  local had_multilib
  if grep -q '^\[multilib\]' /etc/pacman.conf; then
    had_multilib=1
  else
    had_multilib=0
    sed -i 's/^#\s*\[multilib\]/[multilib]/' /etc/pacman.conf || true
    sed -i 's/^#\s*Include\s*=\s*\/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/' /etc/pacman.conf || true
    pacman -Sy || true
  fi

  local pkgs=(mesa)
  case "$vendor" in
    NVIDIA)
      pkgs=(nvidia nvidia-utils nvidia-settings);;
    AMD)
      pkgs=(mesa vulkan-radeon xf86-video-amdgpu)
      if grep -q '^\[multilib\]' /etc/pacman.conf; then
        pkgs+=(lib32-vulkan-radeon)
      fi
      ;;
    Intel)
      pkgs=(mesa vulkan-intel intel-media-driver)
      if grep -q '^\[multilib\]' /etc/pacman.conf; then
        pkgs+=(lib32-vulkan-intel)
      fi
      ;;
    *)
      pkgs=(mesa);;
  esac

  # Install available packages, skip missing ones to avoid failures
  local to_install=()
  for p in "${pkgs[@]}"; do
    if pacman -Si "$p" >/dev/null 2>&1; then
      to_install+=("$p")
    fi
  done
  if (( ${#to_install[@]} )); then
    pacman -Sy --noconfirm --needed "${to_install[@]}"
  fi
}

install_fonts() {
  # Space Grotesk
  sudo -u "$TARGET_USER" bash -c '
    set -e
    mkdir -p ~/.local/share/fonts
    cd /tmp
    if curl -L https://github.com/floriankarsten/space-grotesk/releases/download/2.0.0/SpaceGrotesk-2.0.0.zip -o space-grotesk.zip 2>/dev/null; then
      rm -rf space-grotesk && mkdir space-grotesk && unzip -q space-grotesk.zip -d space-grotesk || true
      find space-grotesk -iname "*.ttf" -exec cp {} ~/.local/share/fonts/ \; || true
    else
      git clone --depth 1 https://github.com/floriankarsten/space-grotesk.git /tmp/space-grotesk || true
      find /tmp/space-grotesk -iname "*.ttf" -exec cp {} ~/.local/share/fonts/ \; || true
    fi
  '

  # Instrument Serif
  sudo -u "$TARGET_USER" bash -c '
    set -e
    mkdir -p ~/.local/share/fonts
    cd /tmp
    if curl -L https://github.com/Instrument/instrument-serif/releases/latest/download/fonts.zip -o instrument-serif.zip 2>/dev/null; then
      rm -rf instrument-serif && mkdir instrument-serif && unzip -q instrument-serif.zip -d instrument-serif || true
      find instrument-serif -iname "*.ttf" -exec cp {} ~/.local/share/fonts/ \; || true
      find instrument-serif -iname "*.otf" -exec cp {} ~/.local/share/fonts/ \; || true
    else
      git clone --depth 1 https://github.com/Instrument/instrument-serif.git /tmp/instrument-serif || true
      find /tmp/instrument-serif -iname "*.ttf" -exec cp {} ~/.local/share/fonts/ \; || true
      find /tmp/instrument-serif -iname "*.otf" -exec cp {} ~/.local/share/fonts/ \; || true
    fi
    fc-cache -fv >/dev/null 2>&1 || true
  '
}

install_apps() {
  install_yay
  sudo -u "$TARGET_USER" yay -Syu --noconfirm || true
  sudo -u "$TARGET_USER" yay -S --noconfirm --needed ghostty-bin zen-browser-bin 1password-bin 1password-cli-bin || true
  pacman -Sy --noconfirm --needed discord fastfetch firefox htop vim nano git python python-pip nodejs npm rust cargo || true
}

write_configs() {
  local cfg
  cfg="$TARGET_HOME/.config"
  install -d -m 755 "$cfg/hypr" "$cfg/waybar" "$cfg/rofi/themes" "$cfg/gtk-3.0" "$cfg/qt5ct"

  # Hyprland
  cat > "$cfg/hypr/config.conf" << 'HYPRCONF'
monitor=,preferred,auto,1

exec-once = waybar
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

bind = SUPER, Q, exec, ghostty
bind = SUPER, C, killactive,
bind = SUPER, M, exit,
bind = SUPER, E, exec, thunar
bind = SUPER, V, togglefloating,
bind = SUPER, R, exec, rofi -show drun
bind = ALT, SPACE, exec, rofi -show drun
bind = SUPER, P, pseudo,
bind = SUPER, J, togglesplit,
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10
bind = SUPER, mouse_down, workspace, e+1
bind = SUPER, mouse_up, workspace, e-1
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
HYPRCONF

  # Waybar config
  cat > "$cfg/waybar/config.json" << 'WAYBARJSON'
{
  "layer": "top",
  "position": "top",
  "height": 28,
  "spacing": 4,
  "modules-left": ["hyprland/workspaces", "hyprland/window"],
  "modules-center": [],
  "modules-right": ["idle_inhibitor", "pulseaudio", "network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
  "hyprland/window": {"format": "{class}", "separate-outputs": true},
  "hyprland/workspaces": {
    "disable-scroll": true,
    "all-outputs": true,
    "format": "{name}: {icon}",
    "format-icons": {"1":"一","2":"二","3":"三","4":"四","5":"五","6":"六","7":"七","8":"八","9":"九","10":"十"},
    "persistent_workspaces": {"*": 5}
  },
  "idle_inhibitor": {"format": "{icon}", "format-icons": {"activated": "", "deactivated": ""}},
  "tray": {"icon-size": 16, "spacing": 8},
  "clock": {"format": "{:%H:%M}", "format-alt": "{:%Y-%m-%d %H:%M:%S}", "tooltip-format": "<tt><small>{calendar}</small></tt>"},
  "cpu": {"format": "CPU: {usage}%", "tooltip": false},
  "memory": {"format": "RAM: {}%"},
  "temperature": {"critical-threshold": 80, "format": "{temperatureC}°C", "format-icons": ["","",""]},
  "battery": {"states": {"warning": 30, "critical": 15}, "format": "{capacity}% {icon}", "format-charging": "{capacity}% 󰂄", "format-plugged": "{capacity}% 󰚥", "format-alt": "{time} {icon}", "format-icons": ["󰁺","󰁻","󰁼","󰁽","󰁾","󰁿","󰂀","󰂁","󰂂","󰁹"]},
  "network": {"format-wifi": "{essid} ({signalStrength}%) 󰤨", "format-ethernet": "{ipaddr}/{cidr} 󰈀", "tooltip-format": "{ifname} via {gwaddr} 󰤨", "format-linked": "{ifname} (No IP) 󰈀", "format-disconnected": "Disconnected ⚠", "format-alt": "{ifname}: {ipaddr}/{cidr}"},
  "pulseaudio": {"format": "{volume}% {icon}", "format-bluetooth": "{volume}% {icon} 󰂯", "format-bluetooth-muted": "󰂲", "format-muted": "󰝟", "format-source": "{volume}% 󰍬", "format-source-muted": "󰍭", "format-icons": {"headphone":"󰋋","hands-free":"󰋎","headset":"󰋎","phone":"󰄜","portable":"󰦧","car":"󰄋","default":["󰕿","󰖀","󰕾"]}, "on-click": "pavucontrol"}
}
WAYBARJSON

  # Waybar style
  cat > "$cfg/waybar/style.css" << 'WAYBARCSS'
* { border: none; border-radius: 0; font-family: "Space Grotesk", "Symbols Nerd Font", "Symbols Nerd Font Mono", "Font Awesome 6 Free"; font-size: 13px; min-height: 0; color: #e0e0e0; }
window#waybar { background-color: rgba(20,20,20,0.85); border-bottom: 1px solid rgba(255,255,255,0.1); color:#e0e0e0; transition-property: background-color; transition-duration:.5s; border-radius:0; }
window#waybar.hidden { opacity: .2; }
#workspaces button { padding: 0 10px; background: transparent; color:#888; border-bottom:3px solid transparent; transition: all .3s ease; }
#workspaces button:hover { background: rgba(255,255,255,.1); color:#e0e0e0; }
#workspaces button.active { color:#fff; border-bottom:3px solid #007AFF; background: rgba(0,122,255,.1); }
#workspaces button.urgent { background:#eb4d4b; color:#fff; }
#window { padding: 0 15px; font-weight:500; color:#e0e0e0; }
tooltip { background: rgba(20,20,20,.95); border:1px solid rgba(255,255,255,.1); border-radius:8px; padding:5px 10px; }
tooltip label { color:#e0e0e0; }
#clock,#battery,#cpu,#memory,#temperature,#backlight,#network,#pulseaudio,#idle_inhibitor,#tray,#mode { padding:0 8px; margin:0 2px; color:#e0e0e0; background:transparent; }
#clock { font-weight:600; }
#battery.charging { color:#52D017; }
#battery.warning:not(.charging) { color:#FDB813; }
#battery.critical:not(.charging) { color:#F00; }
#network.disconnected { color:#888; }
#pulseaudio.muted { color:#888; }
#temperature.critical { color:#F00; }
#idle_inhibitor.activated { color:#52D017; }
#tray > .needs-attention { -gtk-icon-effect: highlight; background:#eb4d4b; }
WAYBARCSS

  # Rofi theme/config
  cat > "$cfg/rofi/config.rasi" << 'ROFICONF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    terminal: "ghostty";
    drun-display-format: "{icon} {name}";
    location: 0;
    disable-history: false;
    hide-scrollbar: true;
    display-drun: "Applications";
    display-run: "Run";
    display-window: "Windows";
    sidebar-mode: true;
    font: "Space Grotesk 13";
    width: 50;
    lines: 10;
    columns: 1;
    fixed-num-lines: true;
}
@theme "~/.config/rofi/themes/dark.rasi"
ROFICONF

  cat > "$cfg/rofi/themes/dark.rasi" << 'ROFITHEME'
* { bg-col: #1a1a1a; bg-col-light: #252525; border-col: #333333; selected-col: #007AFF; fg-col: #e0e0e0; grey: #888888; font: "Space Grotesk 14"; }
window { height: 360px; border: 2px; border-color: @border-col; background-color: @bg-col; border-radius: 12px; padding: 5px; }
inputbar { children: [prompt,entry]; background-color: @bg-col; border-radius: 8px; padding: 5px; }
prompt { background-color: @selected-col; padding: 6px; text-color: #ffffff; border-radius: 8px; margin: 5px; }
entry { padding: 6px; margin: 5px; text-color: @fg-col; background-color: @bg-col-light; border-radius: 8px; }
listview { border: 2px 0 0; border-color: @border-col; border-radius: 8px; padding-top: 6px; columns:1; lines:5; spacing:5px; background: @bg-col; }
element { border: 0; padding: 8px; border-radius: 8px; }
element normal.normal { background-color: @bg-col-light; text-color: @fg-col; }
element selected.normal { background-color: @selected-col; text-color: #fff; }
ROFITHEME

  # GTK minimal theming hint
  cat > "$cfg/gtk-3.0/gtk.css" << 'GTKCSS'
* { font-family: "Space Grotesk", sans-serif; font-size: 13px; }
GTKCSS

  chown -R "$TARGET_USER:$TARGET_USER" "$cfg"
}

setup_waybar_service() {
  local sysd="$TARGET_HOME/.config/systemd/user"
  install -d -m 755 "$sysd"
  cat > "$sysd/waybar.service" << 'UNIT'
[Unit]
Description=Waybar status bar
PartOf=graphical-session.target

[Service]
ExecStart=/usr/bin/waybar
Restart=always
RestartSec=2

[Install]
WantedBy=graphical-session.target
UNIT

  chown -R "$TARGET_USER:$TARGET_USER" "$sysd"
  sudo -u "$TARGET_USER" systemctl --user daemon-reload || true
  sudo -u "$TARGET_USER" systemctl --user enable --now waybar.service || true
}

setup_autostart() {
  sudo -u "$TARGET_USER" bash -c 'cat > ~/.zprofile << "ZPROFILE" 
if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]; then
  exec Hyprland
fi
ZPROFILE'
}

environment_tweaks() {
  grep -q QT_QPA_PLATFORMTHEME /etc/environment 2>/dev/null || echo "QT_QPA_PLATFORMTHEME=gtk2" >> /etc/environment
  grep -q _JAVA_AWT_WM_NONREPARENTING /etc/environment 2>/dev/null || echo "_JAVA_AWT_WM_NONREPARENTING=1" >> /etc/environment
}

main() {
  require_root
  prompt_user
  ensure_base_packages
  detect_and_install_gpu
  install_yay
  install_apps
  install_fonts
  write_configs
  setup_waybar_service
  setup_autostart
  environment_tweaks

  echo "Done. Log out and log back in on TTY1, Hyprland will start."
}

main "$@"


