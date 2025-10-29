#!/bin/bash

TARGET_DIR="$1"
USERNAME="$2"
CONFIGS_DIR="$3"

echo "Setting up Hyprland configuration..."

mkdir -p "$TARGET_DIR/home/$USERNAME/.config/hypr"
mkdir -p "$TARGET_DIR/home/$USERNAME/.config/waybar"
mkdir -p "$TARGET_DIR/home/$USERNAME/.config/rofi/themes"
mkdir -p "$TARGET_DIR/home/$USERNAME/.config/gtk-3.0"
mkdir -p "$TARGET_DIR/home/$USERNAME/.config/qt5ct"

if [ -d "$CONFIGS_DIR" ]; then
    cp -r "$CONFIGS_DIR/hypr/"* "$TARGET_DIR/home/$USERNAME/.config/hypr/" 2>/dev/null || true
    cp -r "$CONFIGS_DIR/waybar/"* "$TARGET_DIR/home/$USERNAME/.config/waybar/" 2>/dev/null || true
    cp -r "$CONFIGS_DIR/rofi/"* "$TARGET_DIR/home/$USERNAME/.config/rofi/" 2>/dev/null || true
    cp -r "$CONFIGS_DIR/gtk/"* "$TARGET_DIR/home/$USERNAME/.config/gtk-3.0/" 2>/dev/null || true
    cp -r "$CONFIGS_DIR/qt5ct/"* "$TARGET_DIR/home/$USERNAME/.config/qt5ct/" 2>/dev/null || true
fi

arch-chroot "$TARGET_DIR" bash << EOF
cd /home/$USERNAME/.config/hypr
if [ ! -f config.conf ]; then
    cat > config.conf << 'HYPRCONF'
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

device:epic-mouse-v1 {
    sensitivity = -0.5
}

bind = SUPER, Q, exec, ghostty
bind = SUPER, C, killactive,
bind = SUPER, M, exit,
bind = SUPER, E, exec, nautilus
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
fi

cd /home/$USERNAME/.config/rofi
if [ ! -f config.rasi ]; then
    cat > config.rasi << 'ROFICONF'
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
ROFICONF
fi

cd /home/$USERNAME/.config/waybar
if [ ! -f config.json ]; then
    cat > config.json << 'WAYBARJSON'
{
    "layer": "top",
    "position": "top",
    "height": 28,
    "spacing": 4,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": [],
    "modules-right": ["idle_inhibitor", "pulseaudio", "network", "cpu", "memory", "temperature", "battery", "clock", "tray"],
    "hyprland/window": {
        "format": "{class}",
        "separate-outputs": true
    },
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{name}: {icon}",
        "format-icons": {
            "1": "一",
            "2": "二",
            "3": "三",
            "4": "四",
            "5": "五",
            "6": "六",
            "7": "七",
            "8": "八",
            "9": "九",
            "10": "十"
        },
        "persistent_workspaces": {
            "*": 5
        }
    },
    "idle_inhibitor": {
        "format": "{icon}",
        "format-icons": {
            "activated": "",
            "deactivated": ""
        }
    },
    "tray": {
        "icon-size": 16,
        "spacing": 8
    },
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d %H:%M:%S}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>"
    },
    "cpu": {
        "format": "CPU: {usage}%",
        "tooltip": false
    },
    "memory": {
        "format": "RAM: {}%"
    },
    "temperature": {
        "critical-threshold": 80,
        "format": "{temperatureC}°C",
        "format-icons": ["", "", ""]
    },
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% 󰂄",
        "format-plugged": "{capacity}% 󰚥",
        "format-alt": "{time} {icon}",
        "format-icons": ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) 󰤨",
        "format-ethernet": "{ipaddr}/{cidr} 󰈀",
        "tooltip-format": "{ifname} via {gwaddr} 󰤨",
        "format-linked": "{ifname} (No IP) 󰈀",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon} 󰂯",
        "format-bluetooth-muted": "󰂲",
        "format-muted": "󰝟",
        "format-source": "{volume}% 󰍬",
        "format-source-muted": "󰍭",
        "format-icons": {
            "headphone": "󰋋",
            "hands-free": "󰋎",
            "headset": "󰋎",
            "phone": "󰄜",
            "portable": "󰦧",
            "car": "󰄋",
            "default": ["󰕿", "󰖀", "󰕾"]
        },
        "on-click": "pavucontrol"
    }
}
WAYBARJSON
fi

if [ ! -f style.css ]; then
    cat > style.css << 'WAYBARCSS'
* {
    border: none;
    border-radius: 0;
    font-family: "Space Grotesk", "Font Awesome 6 Free";
    font-size: 13px;
    min-height: 0;
    color: #e0e0e0;
}

window#waybar {
    background-color: rgba(20, 20, 20, 0.85);
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    color: #e0e0e0;
    transition-property: background-color;
    transition-duration: .5s;
    border-radius: 0;
}

window#waybar.hidden {
    opacity: 0.2;
}

#workspaces button {
    padding: 0 10px;
    background-color: transparent;
    color: #888888;
    border-bottom: 3px solid transparent;
    transition: all 0.3s ease;
}

#workspaces button:hover {
    background: rgba(255, 255, 255, 0.1);
    color: #e0e0e0;
}

#workspaces button.active {
    color: #ffffff;
    border-bottom: 3px solid #007AFF;
    background-color: rgba(0, 122, 255, 0.1);
}

#workspaces button.urgent {
    background-color: #eb4d4b;
    color: #ffffff;
}

#window {
    padding: 0 15px;
    font-weight: 500;
    color: #e0e0e0;
}

tooltip {
    background: rgba(20, 20, 20, 0.95);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 8px;
    padding: 5px 10px;
}

tooltip label {
    color: #e0e0e0;
}

#clock,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#network,
#pulseaudio,
#idle_inhibitor,
#tray,
#mode {
    padding: 0 8px;
    margin: 0 2px;
    color: #e0e0e0;
    background-color: transparent;
}

#clock {
    font-weight: 600;
}

#battery.charging {
    color: #52D017;
}

#battery.warning:not(.charging) {
    color: #FDB813;
}

#battery.critical:not(.charging) {
    color: #FF0000;
}

#network.disconnected {
    color: #888888;
}

#pulseaudio.muted {
    color: #888888;
}

#temperature.critical {
    color: #FF0000;
}

#idle_inhibitor.activated {
    color: #52D017;
}

#tray > .passive {
    -gtk-icon-effect: dim;
}

#tray > .needs-attention {
    -gtk-icon-effect: highlight;
    background-color: #eb4d4b;
}

#cpu,
#memory,
#temperature {
    font-weight: 400;
}

#battery {
    font-weight: 500;
}

#network {
    font-weight: 500;
}

#pulseaudio {
    font-weight: 500;
}

#clock {
    font-weight: 600;
}
WAYBARCSS
fi

chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
EOF

echo "Hyprland configured"
