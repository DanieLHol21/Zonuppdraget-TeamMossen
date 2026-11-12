#!/usr/bin/env bash

# =====================================================
# Brandväggstest IN mot elev-12
# Körs FRÅN jump (172.20.1.2) eller ctf (172.20.1.10).
# Skriptet känner av var det körs och väljer
# förväntat resultat efter zon.nft.
#
# OBS: blockerade försök ger ZON-IN-DROP. Tre stycken
# på 5 min larmar T1046 (2a) – förväntat, triagera
# som framkallat test.
# =====================================================

set -u

TARGET="172.20.1.112"   # elev-12

LOGDIR="$HOME/testresultat"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/test-in-$(hostname)-$(date +%Y%m%d-%H%M%S).log"

PASS=0
FAIL=0

exec > >(tee -a "$LOGFILE") 2>&1

echo "========================================"
echo " BRANDVÄGGSTEST IN – från $(hostname) mot elev-12"
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

tcp_test() {
    local id="$1" description="$2" port="$3" expected="$4"
    if timeout 4 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null; then
        actual="OPEN"
    else
        actual="BLOCKED"
    fi
    result "$id" "$description" "$expected" "$actual"
}

ping_test() {
    local id="$1" description="$2" expected="$3"
    if ping -c 2 -W 2 "$TARGET" >/dev/null 2>&1; then
        actual="OPEN"
    else
        actual="BLOCKED"
    fi
    result "$id" "$description" "$expected" "$actual"
}

case "$(hostname)" in
  *jump*)
    tcp_test  "F3"      "SSH från jump"                    22   "OPEN"
    ping_test "F14"     "Ping från jump"                        "OPEN"
    tcp_test  "NEG-80"  "HTTP från jump (bara eth0/ctf)"   80   "BLOCKED"
    tcp_test  "NEG-4444" "Okänd port 4444 (T1046)"         4444 "BLOCKED"
    ;;
  *ctf*)
    tcp_test  "F13a"    "SSH från ctf"                     22   "OPEN"
    tcp_test  "F13b"    "HTTP från ctf"                    80   "OPEN"
    ping_test "NEG-ping" "Ping från ctf (bara jump)"            "BLOCKED"
    tcp_test  "NEG-4444" "Okänd port 4444 (T1046)"         4444 "BLOCKED"
    ;;
  *)
    echo "Kör skriptet från jump eller ctf."
    exit 2
    ;;
esac

echo "========================================"
echo "Godkända:  $PASS"
echo "Underkända: $FAIL"
echo "Logg: $LOGFILE"
echo "========================================"

(( FAIL > 0 )) && exit 1 || exit 0
