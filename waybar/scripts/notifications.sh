#!/usr/bin/env bash
# Mako notification indicator for waybar
#   (no arg)  print module JSON
#   dnd       toggle do-not-disturb
#   restore   bring back the last dismissed notification
#   clear     dismiss all notifications

case "$1" in
	dnd) makoctl mode -t do-not-disturb >/dev/null ;;
	restore) makoctl restore ;;
	clear) makoctl dismiss --all ;;
esac

if [ -n "$1" ]; then
	pkill -RTMIN+9 waybar
	exit 0
fi

count=$(makoctl list -j 2>/dev/null | jq 'length' 2>/dev/null)
count=${count:-0}
classes=()

if [ "$count" -gt 0 ]; then
	icon="󱅫"
	tooltip="$count notification$([ "$count" -gt 1 ] && echo s)"
	classes+=(notification)
else
	icon="󰂚"
	tooltip="No notifications"
fi

if makoctl mode 2>/dev/null | grep -qx do-not-disturb; then
	icon="󰂛"
	tooltip="Do Not Disturb"$'\n'"$tooltip"
	classes+=(dnd)
fi

jq -cn --arg text "$icon" --arg tooltip "$tooltip" --arg class "${classes[*]}" \
	'{text: $text, tooltip: $tooltip, class: ($class | split(" ") | map(select(. != "")))}'
