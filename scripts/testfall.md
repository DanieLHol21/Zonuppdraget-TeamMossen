# Testfallslista – elev-12

Testfallen i `testfall.csv` är skrivna **innan** testerna körs (workshop 2, 29/10). Id:t pekar på raden i `docs/flodestabell.md`: `-till` ska släppas igenom, `-nek` ska stoppas.

- **Riktning:** in eller ut, sett från servern vars regel testas (elev-12).
- **Källa:** där testet körs. `jump` körs på jump, `elev-12` på elev-12, `kamrat` på en teamkamrats server i teamnätet och `egen-dator` med `curl` från internet.
- **Förväntat:** *oppen* = handskakningen blir klar · *avvisad* = snabbt svar med RST eller ICMP-fel · *tyst* = inget svar före timeout (3 s).

## Varför vi förväntar oss det vi gör

| Testfall | Förväntat | Varför |
|---|---|---|
| F3-till, F14-till | oppen | Regel F3 (SSH) och F14 (ping) släpper in från jump 172.20.1.2 |
| F3-nek, F1-nek, Nek-in | tyst | Ingen regel för porten från jump på eth1 → `policy drop` i kedjan in, utan svar |
| F1-till | oppen | Webb från internet in på eth0 – passerar molnet (regel F1) och värden (`iif "eth0"`) |
| F11b-till, F11d-till, D5-till, F7a-till | oppen | Utgående regler finns; mottagaren lyssnar |
| F11b-nek | tyst | DNS bara till Hetzners resolvrar – 8.8.8.8 stoppas i kedjan ut |
| F11d-nek | tyst | Bara tcp/443 ut mot internet – tcp/80 stoppas |
| D5-nek, F7a-nek | tyst | Mot log släpps bara 514 och 6514 – 80 och 22 stoppas i kedjan ut |
| FL03-nek | tyst | Baslinjens FL-03 (elev → ctf) är stängd |
| Team-nek-ut | tyst | Elev → elev i teamnätet nekas – stoppas i kedjan ut på elev-12 |
| Team-nek-in, F14-nek | tyst | Elev → elev nekas – stoppas i kedjan in på elev-12 (ping bara från jump) |

**Krav från läraren:** minst ett testfall mellan två servrar i teamnätet 10.40.6.0/24 – Team-nek-ut, Team-nek-in och F14-nek.

## Rader som inte testas med skriptet

| Rad | Varför | Hur den kontrolleras i stället |
|---|---|---|
| F11a (DNS udp), F11c (NTP udp) | Skriptet provar TCP-anslutningar; UDP har ingen handskakning | `getent hosts mirrors.rockylinux.org` och `chronyc burst 1/1; chronyc sources` |
| D6 (DHCP) | UDP, och syns först när lånet förnyas | `ip -br addr` efter omstart – alla nätkort har adress |
| F13a, F13b | Källan är ctf, som vi inte kan köra skript på | Kursens kontroll (`kontrollera U4.1`) loggar in från ctf |
| F2, F4a, F4b, F5, F7b | Reglerna ligger på kursens servrar (jump, log, wazuh), inte på elev-12 | – (ej vår server) |
| F6a, F6b, F7c–e, F8, F9, F10, F12a–f | Zonerna finns inte i labbet | – (planerad) |
