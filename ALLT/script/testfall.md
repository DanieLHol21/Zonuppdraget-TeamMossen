# Testfall och testprotokoll – elev-22
 
Testfallen i `testfall.csv` skrevs innan testerna kördes. Varje rad är ett riktigt
TCP anslutnings försök. 
 
## Så körs testet
 
Skriptet bygger på förövningen i studieguiden för vecka 4.
Saker som jag har löagt till.
 
- har="$2 och if [ "$kalla" != "$har" ]; then continue; fi – varje maskin kör bara sina egna rader.
- PASS/FAIL per rad och räknare. Loopen matas med done < <(tail -n +2 "$fil") i stället för
  tail … | while, annars körs loopen i ett subshell och räknarna försvinner.
| Var | Kommando | Testar |
|---|---|---|
| elev-22 | ./test.sh testfall.csv elev-22 | kedjam ut |
| jump | ./test.sh testfall.csv jump` | kedjan in |
| egen dator | curl -I http://<publik-ip> | F1-till från internet |
 
Inkommande testas från jump. Ett test från servern mot sig själv går via lo, som alltid
släpps, och bevisar då ingenting.
 
- **Riktning:** in eller ut, sett från elev-22.
- **Källa:** maskinen testet körs på.
- **Utfall:** *oppen* = handskakningen blir klar · *avvisad* = snabbt nej (RST eller ICMP-fel) ·
  *tyst* = inget svar före timeout (3 s). I en fångst syns *tyst* som upprepade SYN utan svar.
## Testfall och varför
 
| Testfall | Förväntat | Varför |
|---|---|---|
| F3-till | oppen | F3 (D1) släpper in jump 172.20.1.2 på tcp/22. |
| F3-nek | tyst | Ingen regel för tcp/2222 → `policy drop` i kedjan in, inget svar. |
| F1-nek | tyst | F1 gäller bara eth0 (internet). Jump kommer in på eth1, och port 80 i labbnätet är bara öppen för ctf (F13b) → `policy drop`. |
| F13c-nek | tyst | F13c släpper bara in ctf 172.20.1.10 på tcp/7522. Jump är fel källa → `policy drop`. |
| F1-till | oppen | Webb från internet in på eth0. Molnbrandväggen släpper port 80 (regel F1) och värden har regeln F1. |
| F7-till | oppen | F7 (D5) släpper ut loggar till log 172.20.1.58 på tcp/6514 (TLS). |
| F7-nek | tyst | Ingen regel för tcp/514 → `policy drop` i kedjan ut. Därför har den gamla klartextkön vuxit sedan 4/11. |
| F11a-till | oppen | F11a (D3) släpper DNS till Hetzners resolvrar 185.12.64.1 och .2. |
| F11a-nek | tyst | 8.8.8.8 finns inte i regelns adresslista → `policy drop`. |
| F11c-till | oppen | F11c (D7) släpper ut tcp/443 för uppdateringar. |
| F11c-nek | tyst | Bara 443 är tillåtet ut mot internet, inte tcp/80 → `policy drop`. |
| Team-nek | tyst | Elev → elev nekas enligt zonmodellen. Ingen regel släpper något till 10.40.6.0/24 → `policy drop` på eth2. |
 
**Krav från läraren – testfall inom teamnätet:** Team-nek (elev-22 → 10.40.6.3, tcp/22).
 
## Rader som inte testas med skriptet
 
| Flöde | Varför | Hur det kontrolleras i stället |
|---|---|---|
| F13a, F13b, F13c (tillåtet) | Källan är ctf, där jag inte kan köra skript | `kontrollera U4.1`, |
| F11b (NTP) | UDP – ingen handskakning att mäta | / |
| D6 (DHCP) | UDP, syns först när lånet förnyas | `ip -br addr`: eth0–eth2 har adress |
 
## Resultat 2026-11-26
 
| Körning | Tid (svensk tid) | Resultat | Fil |
|---|---|---|---|
| elev-22 (ut) | ca 12:01 | 7 av 7 som förväntat | resultat-elev-22.csv |
| jump (in) | ca 12:29 | 4 av 4 som förväntat | resultat-jump.csv |
| egen dator (F1-till) | – | körs efter att F1 lagts till | – |
 
oppen tog 8–16 ms (handskakningen klar direkt), tyst tog ca 3000 ms (timeout utan svar).
 
## Bevis: det var min brandvägg som stoppade
 
Varje `tyst` har en loggrad i journalctl -k på elev-22 (tid i UTC), sparat i bevis-zon-drops.tx`.
 
| Testfall | Loggrad |
|---|---|
| F7-nek | `ZON-UT-DROP … OUT=eth1 DST=172.20.1.58 … DPT=514 … SYN` |
| F11a-nek | `ZON-UT-DROP … OUT=eth0 DST=8.8.8.8 … DPT=53 … SYN` |
| F11c-nek | `ZON-UT-DROP … OUT=eth0 DST=1.1.1.1 … DPT=80 … SYN` |
| F1-nek | `ZON-IN-DROP IN=eth1 … SRC=172.20.1.2 … DPT=80 … SYN` |
| F3-nek | `ZON-IN-DROP IN=eth1 … SRC=172.20.1.2 … DPT=2222 … SYN` |
| F13c-nek | `ZON-IN-DROP IN=eth1 … SRC=172.20.1.2 … DPT=7522 … SYN` |
| Team-nek | `ZON-UT-DROP … OUT=eth2 SRC=10.40.6.2 DST=10.40.6.3 … DPT=22 … SYN` |
 
Alla rader är `SYN` – anslutningen stoppades redan vid första paketet. Två rader med en sekunds
mellanrum per test = avsändaren skickade SYN igen när inget svar kom.
 