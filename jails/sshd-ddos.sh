#!/bin/bash
set -e

FILTER_DIR="/etc/fail2ban/filter.d"
JAIL_DIR="/etc/fail2ban/jail.d"

# Create filter
cat > "$FILTER_DIR/sshd-ddos.conf" << 'EOF'
[Definition]
failregex = ^.* sshd\[\d+\]: Did not receive identification string from <HOST>
            ^.* sshd\[\d+\]: Connection closed by <HOST> port \d+ \[preauth\]
            ^.* sshd\[\d+\]: Connection reset by <HOST> port \d+ \[preauth\]
            ^.* sshd\[\d+\]: Bad protocol version identification .* from <HOST>
            ^.* sshd\[\d+\]: SSH: Server;Ltype: Version;Remote: <HOST>-\d+;Protocol: 1\.99;Client:
ignoreregex =
EOF

# Create jail
cat > "$JAIL_DIR/sshd-ddos.local" << 'EOF'
[sshd-ddos]
enabled  = true
port     = ssh
filter   = sshd-ddos
logpath  = /var/log/auth.log
           /var/log/secure
maxretry = 3
findtime = 60
bantime  = -1
action   = %(action_mwl)s
EOF

# Reload fail2ban
fail2ban-client reload
echo "SSHD DDoS jail installed and active"
fail2ban-client status sshd-ddos
