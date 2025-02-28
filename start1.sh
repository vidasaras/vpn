#!/usr/bin/env bash

# Function to load profile
load_profile() {
    local profile_file="$1"
    while IFS=' = ' read -r key value; do
        case "$key" in
            HOST) export HOST="$value" ;;
            USERNAME) export USERNAME="$value" ;;
            PASSWORD) export PASSWORD="$value" ;;
        esac
    done < <(grep -E 'HOST|USERNAME|PASSWORD' "$profile_file")
}

# Check if profile file is passed as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <profile_file>"
    exit 1
fi

# Load the profile
load_profile "$1"

# Function to start the tunnel and monitor output
start_tunnel() {
    # Start the tunnel in the background and capture the PID
    python tunnel.py &
    TUNNEL_PID=$!

    # Monitor the output
    while true; do
        # Check if the application has produced output that contains "Client disconnected!"
        if ! wait $TUNNEL_PID; then
            echo "Client disconnected! Restarting the application..."
            # Restart the application
            python tunnel.py &
            TUNNEL_PID=$!
        fi
        sleep 1
    done
}

# Terminate any process using port 9092
test=$(netstat -tulpn | grep 9092 | awk '{print $7}' | cut -d "/" -f 1)
if [ -n "$test" ]; then
    kill -9 $test
fi

# Activate the virtual environment
source venv/bin/activate

# Start monitoring the tunnel
start_tunnel &

# Wait for the tunnel to establish
sleep 3

# Start SSH with ProxyCommand
sshpass -p "$PASSWORD" ssh -C -o "ProxyCommand=nc -X CONNECT -x 127.0.0.1:9092 %h %p" "$USERNAME"@"$HOST" -p 443 -v -CN -D 1080 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null &

# Optional: Start HTTP proxy
sleep 1
pproxy -l http://0.0.0.0:1090 -r socks5://127.0.0.1:1080 > /dev/null
