#!/bin/bash
set -e

FILTER_DIR="/etc/fail2ban/filter.d"
JAIL_DIR="/etc/fail2ban/jail.d"

# Create filter
cat > "$FILTER_DIR/proftpd-tls-crash.conf" << 'EOF'
[Definition]
failregex = ^.* proftpd\[\d+\] \S+ \(<HOST>\[.*?\]\): ProFTPD terminating \(signal 11\)
            ^.* proftpd\[\d+\] \S+ \(<HOST>\[.*?\]\): -----BEGIN STACK TRACE-----
ignoreregex =
EOF

# Create jail
cat > "$JAIL_DIR/proftpd-tls-crash.local" << 'EOF'
[proftpd-tls-crash]
enabled  = true
port     = ftp,ftp-data,ftps,ftps-data
filter   = proftpd-tls-crash
logpath  = /var/log/proftpd/proftpd.log
maxretry = 1
findtime = 86400
bantime  = -1
action   = %(action_mwl)s
EOF

# Reload fail2ban
fail2ban-client reload
echo "ProFTPD TLS crash jail installed and active"
fail2ban-client status proftpd-tls-crash
