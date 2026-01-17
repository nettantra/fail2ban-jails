# fail2ban-jails

Collection of fail2ban jails for common attack patterns.

## Installation

Run as root:

```bash
# Shellshock
wget -qO- https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails/shellshock.sh | /bin/bash

# ProFTPD TLS Crash
wget -qO- https://raw.githubusercontent.com/nettantra/fail2ban-jails/main/jails/proftpd-tls-crash.sh | /bin/bash
```

## Available Jails

| Jail | Description |
|------|-------------|
| shellshock | Blocks Shellshock (CVE-2014-6271) exploit attempts |
| proftpd-tls-crash | Blocks IPs causing ProFTPD TLS module crashes (signal 11) |
