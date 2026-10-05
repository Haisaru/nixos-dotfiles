#!/usr/bin/env bash
#
# Connect to a Wi-Fi network, including WPA2/WPA3-Enterprise (eduroam)
#
# Dependencies:
#   - fzf
#   - libnotify (notify-send)
#   - networkmanager (nmcli)
#   - networkmanagerapplet (nm-connection-editor)
#   - geteduroam-cli (optional, for institution eduroam profiles)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 11, 2025
# License: MIT

TIMEOUT=10

RESET=$'\e[0m'
DIM=$'\e[2m'
BOLD=$'\e[1m'

EDIT="__edit__"
OFF="__off__"

usage() {
	cat <<-EOF
		USAGE: ${0##*/} [option]

		Connect to a Wi-Fi network

		OPTIONS:
		  off       Turn Wi-Fi off
		  toggle    Turn Wi-Fi on or off
		  edit      Open the connection editor
		  <none>    Turn Wi-Fi on and launch the CLI
	EOF
}

debug() { printf "%b" "$*" >&2; }

hide_cursor() { debug $'\e[?25l'; }
show_cursor() { debug $'\e[?25h'; }

fzf_menu() {
	local label=$1
	shift
	fzf --border=sharp --border-label=" $label " --cycle --height=~100% \
		--highlight-line --info=inline-right --pointer= --reverse "$@"
}

edit_connections() {
	setsid -f nm-connection-editor >/dev/null 2>&1
}

turn_off() {
	nmcli radio wifi off
	notify-send "Wi-Fi Off" -i "network-wireless-off" \
		-h string:x-canonical-private-synchronous:network
}

turn_on() {
	local init
	init=$(nmcli radio wifi)

	if [[ $init == enabled ]]; then
		return 0
	fi

	nmcli radio wifi on

	local state
	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rTurning on Wi-Fi... ($s/$TIMEOUT)"

		state=$(nmcli radio wifi)

		if [[ $state == enabled ]]; then
			break
		fi

		sleep 1
	done

	if [[ $state != enabled ]]; then
		notify-send "Wi-Fi" "Failed to turn on" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi On" -i "network-wireless-on" \
		-h string:x-canonical-private-synchronous:network
}

toggle() {
	if [[ $(nmcli radio wifi) == enabled ]]; then
		turn_off
	else
		nmcli radio wifi on
		notify-send "Wi-Fi On" -i "network-wireless-on" \
			-h string:x-canonical-private-synchronous:network
	fi
}

# SSID -> UUID of every saved Wi-Fi profile
load_saved() {
	declare -gA SAVED=()

	local uuid type ssid
	while IFS=: read -r uuid type; do
		[[ $type == 802-11-wireless ]] || continue
		ssid=$(nmcli -g 802-11-wireless.ssid connection show "$uuid")
		[[ -n $ssid ]] && SAVED[$ssid]=$uuid
	done < <(nmcli -t -f UUID,TYPE connection show)
}

signal_icon() {
	local s=$1
	if ((s >= 75)); then
		printf "󰤨"
	elif ((s >= 50)); then
		printf "󰤥"
	elif ((s >= 25)); then
		printf "󰤢"
	else
		printf "󰤟"
	fi
}

get_networks() {
	nmcli device wifi rescan 2>/dev/null

	local raw
	local s
	for ((s = 1; s <= TIMEOUT; s++)); do
		debug "\rScanning for networks... ($s/$TIMEOUT)"

		# SSID last, since it is the only field that can contain ':'
		raw=$(nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID device wifi list)

		if grep -qv ':$' <<<"$raw"; then
			break
		fi

		sleep 1
	done

	debug "\n\n"

	load_saved

	# One row per SSID, strongest access point wins
	declare -gA SECURITY=()
	local -A signal=() active=()
	local in_use sig sec ssid
	while IFS=: read -r in_use sig sec ssid; do
		ssid=${ssid//\\:/:}
		ssid=${ssid//\\\\/\\}
		[[ -z $ssid ]] && continue

		[[ $in_use == '*' ]] && active[$ssid]=1
		if [[ -z ${signal[$ssid]} ]] || ((sig > signal[$ssid])); then
			signal[$ssid]=$sig
			SECURITY[$ssid]=${sec:-open}
		fi
	done <<<"$raw"

	if ((${#signal[@]} == 0)); then
		notify-send "Wi-Fi" "No networks found" -i "package-broken"
		exit 1
	fi

	NETWORKS=$(
		for ssid in "${!signal[@]}"; do
			local tag=""
			if [[ -n ${active[$ssid]} ]]; then
				tag="${BOLD}connected${RESET}"
			elif [[ -n ${SAVED[$ssid]} ]]; then
				tag="${DIM}saved${RESET}"
			fi
			printf "%s\t%s\t%s %3s%%  %-32s %-16s %s\n" \
				"${signal[$ssid]}" "$ssid" "$(signal_icon "${signal[$ssid]}")" \
				"${signal[$ssid]}" "$ssid" "${SECURITY[$ssid]}" "$tag"
		done | sort -t $'\t' -k1,1nr | cut -f2-
	)

	CONNECTED=$(for ssid in "${!active[@]}"; do printf "%s" "$ssid"; done)
}

select_network() {
	local actions
	printf -v actions "%s\t%s\n%s\t%s" \
		"$EDIT" "󰒓  Edit saved connections…" \
		"$OFF" "󰤮  Turn Wi-Fi off"

	SSID=$(printf "%s\n%s\n" "$NETWORKS" "$actions" |
		fzf_menu "Wi-Fi Networks" --ansi --delimiter=$'\t' --with-nth=2 \
			--ghost=Search | cut -f1)

	if [[ -z $SSID ]]; then
		exit 1
	fi
}

connect_enterprise() {
	local ssid=$1

	local methods=(
		"PEAP / MSCHAPv2 (eduroam and most universities)"
		"TTLS / PAP"
	)
	if [[ $ssid == eduroam ]] && command -v geteduroam-cli >/dev/null; then
		methods=("geteduroam (download your institution's profile)" "${methods[@]}")
	fi
	methods+=("Open the connection editor")

	local method
	method=$(printf "%s\n" "${methods[@]}" |
		fzf_menu "$ssid: sign-in method" --no-input) || exit 1

	local eap phase2
	case $method in
		geteduroam*)
			geteduroam-cli || {
				notify-send "Wi-Fi" "geteduroam failed" -i "package-purge"
				exit 1
			}
			notify-send "Wi-Fi" "eduroam profile installed" -i "package-install"
			return 0
			;;
		PEAP*) eap=peap phase2=mschapv2 ;;
		TTLS*) eap=ttls phase2=pap ;;
		*)
			edit_connections
			exit 0
			;;
	esac

	local identity password anon domain
	read -rp "Username (e.g. you@school.edu): " identity
	[[ -z $identity ]] && exit 1
	read -rsp "Password: " password
	debug "\n"
	read -rp "Anonymous identity ${DIM}(optional, e.g. anonymous@school.edu)${RESET}: " anon
	read -rp "Server domain to verify ${DIM}(optional, e.g. radius.school.edu)${RESET}: " domain

	local args=(
		type wifi con-name "$ssid" ssid "$ssid"
		wifi-sec.key-mgmt wpa-eap
		802-1x.eap "$eap" 802-1x.phase2-auth "$phase2"
		802-1x.identity "$identity" 802-1x.password "$password"
	)
	[[ -n $anon ]] && args+=(802-1x.anonymous-identity "$anon")
	# Without a domain the server certificate is not checked
	[[ -n $domain ]] && args+=(
		802-1x.ca-cert /etc/ssl/certs/ca-certificates.crt
		802-1x.domain-suffix-match "$domain"
	)

	local uuid
	uuid=$(nmcli -t connection add "${args[@]}" | grep -oE '[0-9a-f-]{36}')
	if [[ -z $uuid ]]; then
		notify-send "Wi-Fi" "Failed to create connection" -i "package-purge"
		exit 1
	fi

	debug "Connecting...\n"

	if ! nmcli connection up "$uuid"; then
		# Don't leave a broken profile behind; the next attempt starts clean
		nmcli connection delete "$uuid" >/dev/null
		notify-send "Wi-Fi" "Failed to connect to $ssid" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi" "Connected to $ssid" -i "package-install"
}

connect_network() {
	case $SSID in
		"$EDIT")
			edit_connections
			exit 0
			;;
		"$OFF")
			turn_off
			exit 0
			;;
	esac

	if [[ $SSID == "$CONNECTED" ]]; then
		local choice
		choice=$(printf "%s\n" "Disconnect" "Edit connections…" "Cancel" |
			fzf_menu "$SSID" --no-input)
		case $choice in
			Disconnect) nmcli connection down id "$SSID" >/dev/null ;;
			Edit*) edit_connections ;;
		esac
		exit 0
	fi

	debug "Connecting to $SSID...\n"

	if [[ -n ${SAVED[$SSID]} ]]; then
		# --ask prompts for the password if the saved one is missing/wrong
		if nmcli -a connection up "${SAVED[$SSID]}"; then
			notify-send "Wi-Fi" "Connected to $SSID" -i "package-install"
			exit 0
		fi
		notify-send "Wi-Fi" "Failed to connect to $SSID" -i "package-purge"
		exit 1
	fi

	if [[ ${SECURITY[$SSID]} == *802.1X* ]]; then
		connect_enterprise "$SSID"
		return
	fi

	if ! nmcli -a device wifi connect "$SSID"; then
		notify-send "Wi-Fi" "Failed to connect to $SSID" -i "package-purge"
		exit 1
	fi

	notify-send "Wi-Fi" "Connected to $SSID" -i "package-install"
}

main() {
	local option=$1

	case $option in
		off)
			turn_off
			return 0
			;;
		toggle)
			toggle
			return 0
			;;
		edit)
			edit_connections
			return 0
			;;
		'')
			hide_cursor
			trap 'show_cursor' EXIT

			turn_on
			get_networks

			show_cursor
			trap - EXIT

			select_network
			connect_network
			;;
		*)
			usage >&2
			return 1
			;;
	esac
}

main "$@"
