#!/bin/bash
# Verifierar person 2:s härdningsrader (tjänster och portar) på elev-12.
# Läser bara av, ändrar ingenting. Slutkod 0 = allt gäller.
# Körs med sudo: sudo bash scripts/verifiera-hardning-p2.sh
rc=0
kontroll() {
  if bash -c "$2" >/dev/null 2>&1; then printf 'GÄLLER %s\n' "$1"; else printf 'GÄLLER INTE %s\n' "$1"; rc=1; fi
}
kontroll "P2-1 SELinux i tvingande läge nu" '[ "$(getenforce)" = Enforcing ]'
kontroll "P2-1 SELinux enforcing efter omstart" 'grep -qx "SELINUX=enforcing" /etc/selinux/config'
kontroll "P2-2 bara portarna i flödestabellen lyssnar (22, 80, 7512)" '[ "$(ss -tlnH | awk "{print \$4}" | sed "s/.*://" | sort -un | tr "\n" " ")" = "22 80 7512 " ]'
kontroll "P2-3 paketfiltret: policy drop inkommande" 'nft list chain inet zon in | grep -q "policy drop"'
kontroll "P2-4 zonvakt nås bara från ctf (F13c)" 'nft list chain inet zon in | grep "dport 7512" | grep -q "saddr 172.20.1.10"'
kontroll "P2-5 zonvakt kör i egen domän zonvakt_t" 'ps -eZ | grep -v grep | grep -q "zonvakt_t.*zonvakt"'
exit $rc
