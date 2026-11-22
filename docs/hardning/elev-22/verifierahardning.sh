#!/bin/bash

# Verifierar serverns hardning utan att andra nagot.

rc=0

kontroll() {
    if bash -c "$2" >/dev/null 2>&1; then
        printf 'GÄLLER %s\n' "$1"
    else
        printf 'GÄLLER INTE %s\n' "$1"
        rc=1
    fi
}

# SELinux-kontroller
kontroll "SELinux ar i enforcing-lage" '[ "$(getenforce)" = "Enforcing" ]'

kontroll "SELinux ar enforcing efter omstart" 'grep -qx "SELINUX=enforcing" /etc/selinux/config'

# Zonvakt-kontroller
kontroll "Zonvakt kor i egen doman zonvakt_t" 'ps -eZ | grep -v grep | grep -q "zonvakt_t.*zonvakt"'

kontroll "Zonvakt-domanen ar inte permissiv" '! semanage permissive -l | grep -qw zonvakt_t'

# Brandvaggskontroller
kontroll "Brandvaggen har policy drop for inkommande trafik" 'nft list chain inet zon in | grep -q "policy drop"'

kontroll "Zonvakt port 7522 tillats fran CTF-adressen" 'nft list chain inet zon in | grep -q "ip saddr 172.20.1.10 tcp dport 7522 accept"'

exit $rc