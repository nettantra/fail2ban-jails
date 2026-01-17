#!/bin/bash
set -e

FILTER_DIR="/etc/fail2ban/filter.d"
JAIL_DIR="/etc/fail2ban/jail.d"

# Create filter
cat > "$FILTER_DIR/sshd-ddos.conf" << 'EOF'
[Definition]
failregex = sshd\[\d+\]: Did not receive identification string from <HOST>
            sshd\[\d+\]: Connection closed by <HOST> port \d+ \[preauth\]
            sshd\[\d+\]: Connection reset by <HOST> port \d+ \[preauth\]
            sshd\[\d+\]: Bad protocol version identification .* from <HOST>
            sshd\[\d+\]: SSH: Server;Ltype: Version;Remote: <HOST>-\d+;Protocol: 1\.99;Client:
ignoreregex =
EOF

# Detect logging backend
if [ -f /var/log/auth.log ]; then
    BACKEND="logpath  = /var/log/auth.log"
elif [ -f /var/log/secure ]; then
    BACKEND="logpath  = /var/log/secure"
elif command -v journalctl &> /dev/null && journalctl -u sshd.service -n 1 &> /dev/null; then
    BACKEND="backend  = systemd
journalmatch = _SYSTEMD_UNIT=sshd.service + _COMM=sshd"
elif command -v journalctl &> /dev/null && journalctl -u ssh.service -n 1 &> /dev/null; then
    BACKEND="backend  = systemd
journalmatch = _SYSTEMD_UNIT=ssh.service + _COMM=sshd"
else
    echo "Error: Could not detect SSH log source"
    exit 1
fi

# Create jail
cat > "$JAIL_DIR/sshd-ddos.local" << EOF
[sshd-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
$BACKEND
maxretry = 3
findtime = 60
bantime  = -1
action   = %(action_mwl)s
EOF

# Reload fail2ban
fail2ban-client reload
echo "SSHD DDoS jail installed and active"
fail2ban-client status sshd-ddos
