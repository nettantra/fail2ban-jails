#!/bin/bash
set -e

FILTER_DIR="/etc/fail2ban/filter.d"
JAIL_DIR="/etc/fail2ban/jail.d"

# Create filter
cat > "$FILTER_DIR/shellshock.conf" << 'EOF'
[Definition]
failregex = ^<HOST> -.*"\(\)\s*\{\s*:;\s*\};\s*/bin/bash
            ^<HOST> -.*"\(\)\s*\{\s*[^}]*\};\s*
ignoreregex =
EOF

# Create jail
cat > "$JAIL_DIR/shellshock.local" << 'EOF'
[shellshock]
enabled  = true
port     = http,https
filter   = shellshock
logpath  = /var/log/nginx/access.log
           /var/log/apache2/access.log
           /var/log/virtualmin/*_access_log
           /var/log/virtualmin/*_error_log
maxretry = 1
findtime = 86400
bantime  = -1
action   = %(action_mwl)s
EOF

# Reload fail2ban
fail2ban-client reload
echo "Shellshock jail installed and active"
fail2ban-client status shellshock