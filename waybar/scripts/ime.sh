#!/usr/bin/env bash
# fcitx5 input method indicator for waybar
#   (no arg)  print module JSON
#   next      cycle to the next input method
#   prev      cycle to the previous input method
#   config    open fcitx5-configtool

ims=(keyboard-us rime mozc)

if ! pgrep -x fcitx5 >/dev/null; then
	[ -n "$1" ] && exit 0
	jq -cn '{text: "--", tooltip: "fcitx5 not running", class: ["off"]}'
	exit 0
fi

current=$(fcitx5-remote -n 2>/dev/null)

case "$1" in
	next | prev)
		idx=0
		for i in "${!ims[@]}"; do
			[ "${ims[$i]}" = "$current" ] && idx=$i
		done
		step=1
		[ "$1" = prev ] && step=$((${#ims[@]} - 1))
		fcitx5-remote -s "${ims[$(((idx + step) % ${#ims[@]}))]}"
		pkill -RTMIN+10 waybar
		exit 0
		;;
	config)
		fcitx5-configtool &
		exit 0
		;;
esac

case "$current" in
	rime) text="中" name="Chinese (Rime)" ;;
	mozc) text="あ" name="Japanese (Mozc)" ;;
	keyboard-us) text="EN" name="English (US)" ;;
	*) text="${current:0:2}" name="$current" ;;
esac

jq -cn --arg text "$text" --arg tooltip "$name"$'\n'"Click: next · Right-click: previous · Middle: settings" --arg class "$current" \
	'{text: $text, tooltip: $tooltip, class: [$class]}'
