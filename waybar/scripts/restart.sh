#!/usr/bin/env bash
# Restart waybar. Serialized with a lock so overlapping hotplug events can't
# leave more than one instance running. On NixOS the process is named
# ".waybar-wrapped", so match that as well as plain "waybar".

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-restart.lock"
flock 9

pkill -x '\.?waybar.*'
while pgrep -x '\.?waybar.*' >/dev/null; do sleep 0.1; done

# Let the new output layout settle before waybar enumerates monitors.
sleep 1
setsid waybar 9>&- >/dev/null 2>&1 &
