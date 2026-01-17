#!/bin/bash
set -e

BASE_URL="https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails"

# List of all jails
JAILS=(
    "shellshock"
    "proftpd-tls-crash"
    "sshd-ddos"
)

for jail in "${JAILS[@]}"; do
    echo "Installing $jail..."
    wget --no-cache -qO- "$BASE_URL/$jail.sh" | /bin/bash
    echo ""
done

echo "All jails installed successfully"
