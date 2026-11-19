#!/bin/bash
# Verifierar härdningen på elev-12. Läser bara av, ändrar ingenting. Slutkod 0 = allt gäller.
rc=0
kontroll() {
  if bash -c "$2" >/dev/null 2>&1; then printf 'GÄLLER %s\n' "$1"; else printf 'GÄLLER INTE %s\n' "$1"; rc=1; fi
}
kontroll "SELinux i tvingande läge nu" '[ "$(getenforce)" = Enforcing ]'
kontroll "SELinux enforcing efter omstart" 'grep -qx "SELINUX=enforcing" /etc/selinux/config'
kontroll "paketfiltret: policy drop in" 'nft list chain inet zon in | grep -q "policy drop"'
kontroll "paketfiltret: policy drop ut" 'nft list chain inet zon ut | grep -q "policy drop"'
kontroll "auditd loggar root-kommandon" 'auditctl -l | grep -q rootkommando'
kontroll "/srv/zonwebb har bestående fcontext-regel" 'semanage fcontext -l -C | grep -q "^/srv/zonwebb"'
kontroll "zonvakt kör i egen domän zonvakt_t" 'ps -eZ | grep -v grep | grep -q "zonvakt_t.*zonvakt"'
kontroll "zonvakt-domänen är inte permissiv" '! semanage permissive -l | grep -qw zonvakt_t'
exit $rc
