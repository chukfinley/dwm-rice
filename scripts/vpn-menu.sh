#!/bin/bash
#
# dmenu wrapper for eddie-cli VPN
# Supports connect, disconnect, server selection, and network lock
#

CACHE_DIR="$HOME/.cache/dwm-colors"
SERVER_FILE="$CACHE_DIR/vpn-server"
LOCK_FILE="$CACHE_DIR/vpn-lock-enabled"

# Ensure cache dir exists
mkdir -p "$CACHE_DIR"

# Get saved server or default
get_saved_server() {
    if [[ -f "$SERVER_FILE" ]]; then
        cat "$SERVER_FILE"
    else
        echo ""
    fi
}

# Check if VPN is connected (tunnel up) or connecting (eddie-cli running)
is_connected() {
    ip link show 2>/dev/null | grep -qE "tun|tap"
}

is_running() {
    pgrep -f "eddie-cli.*(connect|--connect)" >/dev/null 2>&1
}

get_vpn_state() {
    if is_connected; then
        echo "connected"
    elif is_running; then
        echo "connecting"
    else
        echo "disconnected"
    fi
}

# Check if network lock is enabled
is_lock_enabled() {
    [[ -f "$LOCK_FILE" ]]
}

# Get list of servers from AirVPN API (format: Country - Server - Location - Load)
get_servers() {
    curl -s "https://airvpn.org/api/status/" 2>/dev/null | \
        jq -r '.servers[] | "\(.country_name) | \(.public_name) | \(.location) | \(.currentload)%"' | \
        sort
}

# Connect to VPN
do_connect() {
    local server="$1"
    local lock_opt=""
    if is_lock_enabled; then
        lock_opt="--netlock"
    fi

    if [[ -n "$server" ]]; then
        notify-send "VPN" "Connecting to $server..."
        eddie-cli --server="$server" --connect $lock_opt &
    else
        notify-send "VPN" "Connecting..."
        eddie-cli --connect $lock_opt &
    fi
}

# Disconnect from VPN
do_disconnect() {
    notify-send "VPN" "Disconnecting..."
    pkill -f eddie-cli
}

# Toggle network lock
toggle_lock() {
    if is_lock_enabled; then
        rm -f "$LOCK_FILE"
        notify-send "VPN" "Network lock disabled (takes effect on next connect)"
    else
        touch "$LOCK_FILE"
        notify-send "VPN" "Network lock enabled (takes effect on next connect)"
    fi
}

# Build menu options based on current state
build_menu() {
    local saved_server=$(get_saved_server)
    local state=$(get_vpn_state)

    case "$state" in
        "connected")
            echo "Disconnect (Connected)"
            ;;
        "connecting")
            echo "Disconnect (Connecting...)"
            ;;
        *)
            if [[ -n "$saved_server" ]]; then
                echo "Connect ($saved_server)"
            fi
            echo "Connect (Auto)"
            ;;
    esac

    echo "Select Server"

    if is_lock_enabled; then
        echo "Network Lock: ON"
    else
        echo "Network Lock: OFF"
    fi

    echo "Status"
}

# Server selection submenu
select_server() {
    notify-send "VPN" "Fetching server list..."
    local servers=$(get_servers)
    local saved_server=$(get_saved_server)

    if [[ -z "$servers" ]]; then
        notify-send "VPN" "Could not fetch server list"
        return 1
    fi

    # Mark saved server if exists (server name is second field)
    if [[ -n "$saved_server" ]]; then
        servers=$(echo "$servers" | sed "s/| ${saved_server} |/* ${saved_server} |/")
    fi

    local selected=$(echo "$servers" | dmenu -i -l 20 -p "Server (search country/city):")

    if [[ -n "$selected" ]]; then
        # Extract server name (second field, between first and second |)
        local server_name=$(echo "$selected" | awk -F'|' '{gsub(/^[ *]+|[ ]+$/, "", $2); print $2}')
        echo "$server_name" > "$SERVER_FILE"
        notify-send "VPN" "Server saved: $server_name"

        # Ask if user wants to connect now
        local connect_now=$(echo -e "Yes\nNo" | dmenu -i -p "Connect to $server_name now?")
        if [[ "$connect_now" == "Yes" ]]; then
            do_connect "$server_name"
        fi
    fi
}

# Show VPN status
show_status() {
    local state=$(get_vpn_state)
    local lock_status="OFF"
    is_lock_enabled && lock_status="ON"
    local saved=$(get_saved_server)
    [[ -z "$saved" ]] && saved="(none)"

    notify-send "VPN Status" "State: $state\nNetwork Lock: $lock_status\nSaved Server: $saved"
}

# Main menu
main() {
    local choice=$(build_menu | dmenu -i -p "VPN:")

    case "$choice" in
        "Connect ("*")")
            # Connect with saved server
            local server=$(get_saved_server)
            do_connect "$server"
            ;;
        "Connect (Auto)")
            # Connect to default/auto server
            do_connect
            ;;
        "Disconnect"*)
            do_disconnect
            ;;
        "Select Server")
            select_server
            ;;
        "Network Lock: ON"|"Network Lock: OFF")
            toggle_lock
            ;;
        "Status")
            show_status
            ;;
    esac
}

main
