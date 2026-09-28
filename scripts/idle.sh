#!/usr/bin/env bash
# Idle handling for Hyprland and niri:
#   - screen off after 9 min idle, lock at 10 min
#   - screen off after 30 s idle while the lock screen is up
#   - lock before sleep (lid close) and on `loginctl lock-session`

export SWAYLOCK_FANCY_FALLBACK=/home/jason/dotfiles/assets/active.jpg
lock="/home/jason/.config/scripts/swaylock-fancy/swaylock-fancy --daemonize"

case "${XDG_CURRENT_DESKTOP:-}" in
    *Hyprland*)
        off="hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'"
        on="hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'"
        ;;
    *niri*)
        off="niri msg action power-off-monitors"
        on="niri msg action power-on-monitors"
        ;;
    *)
        off="true"
        on="true"
        ;;
esac

exec swayidle -w \
    timeout 540 "$off" resume "$on" \
    timeout 600 "$lock" \
    timeout 30 "pgrep -x swaylock >/dev/null && $off" resume "$on" \
    before-sleep "$lock" \
    lock "$lock"
