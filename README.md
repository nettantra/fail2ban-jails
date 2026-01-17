# fail2ban-jails

Collection of fail2ban jails for common attack patterns.

## Installation

Run as root:

```bash
# Install all jails
curl -fsSL https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/install-all.sh | /bin/bash

# Or install individually:

# Shellshock
curl -fsSL https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails/shellshock.sh | /bin/bash

# ProFTPD TLS Crash
curl -fsSL https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails/proftpd-tls-crash.sh | /bin/bash

# SSHD DDoS
curl -fsSL https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails/sshd-ddos.sh | /bin/bash
```

## Available Jails

| Jail | Description |
|------|-------------|
| shellshock | Blocks Shellshock (CVE-2014-6271) exploit attempts |
| proftpd-tls-crash | Blocks IPs causing ProFTPD TLS module crashes (signal 11) |
| sshd-ddos | Blocks SSH DDoS attempts (connection floods, protocol abuse) |
