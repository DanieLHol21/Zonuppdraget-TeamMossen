
#!/usr/bin/env bash

# =====================================================
# Firewall tester - Lab-server
# Testar nftables och molnbrandväggens trafikflöden
# =====================================================

set -u

# Målservrar
JUMP="172.20.1.2"
CTF="172.20.1.10"
LOG="10.40.6.58"
WAZUH="10.40.6.58"
SERVER="10.40.6.3"
DB="10.40.6.50"

# Loggfil
mkdir -p docs/testresultat
LOGFILE="docs/testresultat/test-$(date +%Y%m%d-%H%M%S).log"

PASS=0
FAIL=0
SKIP=0

# Testresultat
exec > >(tee -a "$LOGFILE") 2>&1

echo "========================================"
echo " BRANDVÄGGSTEST - LAB-SERVER"
echo " Datum: $(date)"
echo " Server: $(hostname)"
echo "========================================"

# -----------------------------------------------------
# Funktioner
# -----------------------------------------------------

result() {
    local id="$1"
    local description="$2"
    local expected="$3"
    local actual="$4"

    if [[ "$expected" == "$actual" ]]; then
        echo "[PASS] $id - $description"
        ((PASS+=1))
    else
        echo "[FAIL] $id - $description"
        echo "       Förväntat: $expected"
        echo "       Faktiskt: $actual"
        ((FAIL+=1))
    fi
}

skip() {
    echo "[SKIP] $1 - $2"
    ((SKIP+=1))
}

tcp_test() {
    local id="$1"
    local description="$2"
    local host="$3"
    local port="$4"
    local expected="$5"

    if timeout 4 bash -c \
        "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        actual="OPEN"
    else
        actual="BLOCKED"
    fi

    result "$id" "$description" "$expected" "$actual"
}

udp_test() {
    local id="$1"
    local description="$2"
    local host="$3"
    local port="$4"

    if ! command -v nc >/dev/null 2>&1; then
        skip "$id" "nc saknas"
        return
    fi

    # UDP utan svar kan inte säkert skilja
    # en öppen port från en filtrerad port.
    if nc -z -u -w 3 "$host" "$port" 2>/dev/null; then
        echo "[INFO] $id - UDP-probe skickad, resultat ej verifierat"
        ((SKIP+=1))
    else
        echo "[INFO] $id - UDP-probe gav inget bekräftat svar"
        ((SKIP+=1))
    fi
}

echo
echo "========================================"
echo "1. LOKALA NFTABLES-REGLER"
echo "========================================"

# F3 - SSH från jump
tcp_test "F3" "SSH från jump" "$JUMP" 22 "OPEN"

# F6 - SSH till intern server
tcp_test "F6" "SSH till intern server" "$SERVER" 22 "OPEN"

# F8 - DMZ till server, port 8080
# Kräver att testet körs från DMZ.
skip "F8" "Kräver test från DMZ-server"

# F9 - Server till databas
# Kräver separat DB-server.
tcp_test "F9" "Anslutning till databas" "$DB" 5432 "OPEN"

# F7 - TLS-loggning
tcp_test "F7" "TLS-loggning till loggserver" "$LOG" 6514 "OPEN"

echo
echo "========================================"
echo "2. UTGÅENDE TRAFIK"
echo "========================================"

# F11a - DNS
if getent hosts example.com >/dev/null 2>&1; then
    result "F11a" "DNS-uppslagning" "OPEN" "OPEN"
else
    result "F11a" "DNS-uppslagning" "OPEN" "BLOCKED"
fi

# F11b - NTP
if command -v timedatectl >/dev/null 2>&1; then
    if timedatectl show -p NTPSynchronized --value |
        grep -q '^yes$'; then
        result "F11b" "NTP-tidssynkronisering" "OPEN" "OPEN"
    else
        result "F11b" "NTP-tidssynkronisering" "OPEN" "BLOCKED"
    fi
else
    skip "F11b" "timedatectl saknas"
fi

# F11c - HTTPS
if curl -sSIL --connect-timeout 5 https://example.com \
    >/dev/null 2>&1; then
    result "F11c" "HTTPS utgående" "OPEN" "OPEN"
else
    result "F11c" "HTTPS utgående" "OPEN" "BLOCKED"
fi

echo
echo "========================================"
echo "3. INKOMMANDE TRAFIK"
echo "========================================"

# Kontrollera lokal SSH-tjänst
if systemctl is-active --quiet sshd; then
    echo "[INFO] SSH-tjänsten är aktiv"
else
    echo "[INFO] SSH-tjänsten är inte aktiv"
fi

# Kontrollera att endast tillåtna källor finns
# i nftables-reglerna för SSH.
if sudo nft list chain inet zon in |
    grep -q 'ip saddr 172.20.1.2 tcp dport 22 accept'; then
    result "F3-LOCAL" "Jump tillåten i INPUT-regeln" "OPEN" "OPEN"
else
    result "F3-LOCAL" "Jump tillåten i INPUT-regeln" "OPEN" "BLOCKED"
fi

if sudo nft list chain inet zon in |
    grep -q 'ip saddr 172.20.1.10 tcp dport 22 accept'; then
    result "F13" "CTF tillåten i INPUT-regeln" "OPEN" "OPEN"
else
    result "F13" "CTF tillåten i INPUT-regeln" "OPEN" "BLOCKED"
fi

echo
echo "========================================"
echo "4. SAMMANFATTNING"
echo "========================================"

echo "Godkända tester: $PASS"
echo "Underkända tester: $FAIL"
echo "Ej verifierade tester: $SKIP"
echo
echo "Logg sparad i: $LOGFILE"

echo "========================================"

if (( FAIL > 0 )); then
    exit 1
else
    exit 0
fi
