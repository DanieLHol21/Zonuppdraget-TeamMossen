#!/usr/bin/env bash

# =====================================================
# Brandväggstest – elev-12 (körs PÅ elev-12)
# Testar UTGÅENDE trafik + att reglerna finns i zon.nft.
# Inkommande trafik testas med test-firewall-in.sh
# FRÅN jump och ctf (en server kan inte testa sin
# egen inkommande trafik inifrån).
#
# OBS: de blockerade testerna ger ZON-UT-DROP med SYN
# och larmar alltså T1571 (2b). Det är förväntat –
# triagera som framkallat test.
# =====================================================

set -u

# Adresser
LOG="172.20.1.58"        # loggserver (rättat, var 10.40.6.58)
SERVER="10.40.6.3"       # teamets interna server
DB="10.40.6.50"          # teamets databas

# Loggfil
LOGDIR="$HOME/scripts/testresultat"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/test-ut-$(date +%Y%m%d-%H%M%S).log"

PASS=0
FAIL=0
SKIP=0

exec > >(tee -a "$LOGFILE") 2>&1

echo "========================================"
echo " BRANDVÄGGSTEST UT – $(hostname)"
echo " Datum: $(date)"
echo "========================================"

result() {
    local id="$1" description="$2" expected="$3" actual="$4"
    if [[ "$expected" == "$actual" ]]; then
        echo "[PASS] $id - $description ($actual)"
        ((PASS+=1))
    else
        echo "[FAIL] $id - $description"
        echo "       Förväntat: $expected"
        echo "       Faktiskt:  $actual"
        ((FAIL+=1))
    fi
}

skip() {
    echo "[SKIP] $1 - $2"
    ((SKIP+=1))
}

tcp_test() {
    local id="$1" description="$2" host="$3" port="$4" expected="$5"
    if timeout 4 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        actual="OPEN"
    else
        actual="BLOCKED"
    fi
    result "$id" "$description" "$expected" "$actual"
}

nft_has() {
    # Kollar att en regel finns i laddade regler
    local id="$1" description="$2" chain="$3" pattern="$4"
    if sudo nft list chain inet zon "$chain" | grep -q "$pattern"; then
        result "$id" "$description" "FINNS" "FINNS"
    else
        result "$id" "$description" "FINNS" "SAKNAS"
    fi
}

echo
echo "1. TILLÅTET UT (ska vara OPEN)"
echo "----------------------------------------"

tcp_test "F7a" "TLS-loggning till loggserver 6514" "$LOG" 6514 "OPEN"

if getent hosts example.com >/dev/null 2>&1; then
    result "F11a-b" "DNS-uppslagning" "OPEN" "OPEN"
else
    result "F11a-b" "DNS-uppslagning" "OPEN" "BLOCKED"
fi

if timedatectl show -p NTPSynchronized --value 2>/dev/null | grep -q '^yes$'; then
    result "F11c" "NTP synkad" "OPEN" "OPEN"
else
    result "F11c" "NTP synkad" "OPEN" "BLOCKED"
fi

if curl -sSI --connect-timeout 5 https://example.com >/dev/null 2>&1; then
    result "F11d" "HTTPS ut (443)" "OPEN" "OPEN"
else
    result "F11d" "HTTPS ut (443)" "OPEN" "BLOCKED"
fi

echo
echo "2. INTE TILLÅTET UT (ska vara BLOCKED)"
echo "----------------------------------------"

tcp_test "NEG-D5"  "Gamla D5: tcp 514 till loggserver (borttagen 12/11)" "$LOG" 514 "BLOCKED"
tcp_test "NEG-4444" "Okänd port ut, 1.1.1.1:4444 (T1571)" "1.1.1.1" 4444 "BLOCKED"
tcp_test "NEG-80"  "HTTP ut, 1.1.1.1:80 (bara 443 tillåtet)" "1.1.1.1" 80 "BLOCKED"

# Teamnätet: reglerna F6/F9 är inte införda i zon.nft än
# (tas upp med teamet mån 16/11). Därför BLOCKED just nu.
tcp_test "F6-ej-infört" "SSH till teamets server (ingen regel än)" "$SERVER" 22 "BLOCKED"
tcp_test "F9-ej-infört" "Databas 5432 (ingen regel än)" "$DB" 5432 "BLOCKED"

echo
echo "3. REGLERNA FINNS I zon.nft"
echo "----------------------------------------"

nft_has "F3"   "SSH in från jump"        in  'ip saddr 172.20.1.2 tcp dport 22 accept'
nft_has "F13a" "SSH in från ctf"         in  'ip saddr 172.20.1.10 tcp dport 22 accept'
nft_has "F1"   "HTTP in via eth0"        in  'tcp dport 80 accept'
nft_has "F7a"  "TLS-loggning ut 6514"    ut  'tcp dport 6514 accept'

if sudo nft list chain inet zon ut | grep -q 'dport 514 accept'; then
    result "NEG-D5-regel" "D5 (514) ska vara borta" "BORTA" "FINNS"
else
    result "NEG-D5-regel" "D5 (514) ska vara borta" "BORTA" "BORTA"
fi

echo
echo "========================================"
echo "Godkända:  $PASS"
echo "Underkända: $FAIL"
echo "Ej testade: $SKIP"
echo "Inkommande: kör test-firewall-in.sh från jump och ctf"
echo "Logg: $LOGFILE"
echo "========================================"

(( FAIL > 0 )) && exit 1 || exit 0
