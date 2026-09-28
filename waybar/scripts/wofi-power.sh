#!/usr/bin/env bash

# Power menu entries with nerd font icons — terminal style
entries=" Lock\n󰍃 Logout\n󰒲 Suspend\n󰑐 Reboot\n⏻ Shutdown"

selected=$(echo -e "$entries" | wofi \
    --dmenu \
    --prompt "  power" \
    --width 220 \
    --height 270 \
    --insensitive \
    --style /home/jason/.config/wofi/power.css \
    --cache-file /dev/null)

case "$selected" in
    # Goes through swayidle's `lock` handler, so it uses the same locker as idle/lid
    *"Lock"*)     loginctl lock-session ;;
    *"Logout"*)
        case "${XDG_CURRENT_DESKTOP:-}" in
            *Hyprland*) hyprctl dispatch 'hl.dsp.exit()' ;;
            *niri*)     niri msg action quit --skip-confirmation ;;
            *)          false ;;
        esac || loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
    *"Suspend"*)  systemctl suspend ;;
    *"Reboot"*)   systemctl reboot ;;
    *"Shutdown"*) systemctl poweroff ;;
esac
