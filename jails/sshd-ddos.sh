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

# Detect logging backend (prefer log files if they have sshd entries)
LOGPATHS=""
[ -f /var/log/auth.log ] && grep -q sshd /var/log/auth.log 2>/dev/null && LOGPATHS="/var/log/auth.log"
[ -f /var/log/secure ] && grep -q sshd /var/log/secure 2>/dev/null && LOGPATHS="$LOGPATHS${LOGPATHS:+
           }/var/log/secure"

if [ -n "$LOGPATHS" ]; then
    BACKEND="logpath  = $LOGPATHS"
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

# Create jail (remove old config first)
rm -f "$JAIL_DIR/sshd-ddos.local"
cat > "$JAIL_DIR/sshd-ddos.local" << EOF
[sshd-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
$BACKEND
maxretry = 3
findtime = 60
bantime  = -1
EOF

# Reload fail2ban
fail2ban-client reload
echo "SSHD DDoS jail installed and active"
fail2ban-client status sshd-ddos
