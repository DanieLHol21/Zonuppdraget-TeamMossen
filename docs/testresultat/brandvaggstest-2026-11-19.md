# Brandväggstest 2026-11-19 – elev-12 (vecka 7, F13c)

Syfte: verifiera den nya regeln **F13c** (ctf → tcp/7512, zonvakt) och att resten av regelverket gäller efter ändringen.
Regelfil: `configs/nftables/zon.nft` (F13c tillagd 17/11, laddad med säkerhetskopia `.bak5`, `nft -c` och nödbroms).

## 1. Inkommande – `scripts/test-firewall-in.sh`, kört från jump

Tid: 2026-11-19 11:04:23 UTC · Logg: `~/testresultat/test-in-jump-20261119-110423.log` (på jump)

| Id | Test | Förväntat | Resultat |
|---|---|---|---|
| F3 | SSH från jump | OPEN | PASS |
| F14 | Ping från jump | OPEN | PASS |
| NEG-80 | HTTP från jump (bara eth0/ctf) | BLOCKED | PASS |
| NEG-4444 | Okänd port 4444 (T1046) | BLOCKED | PASS |
| **F13c-nek** | **zonvakt tcp/7512 från jump (bara ctf)** | **BLOCKED** | **PASS** |

**Godkända: 5 · Underkända: 0**

## 2. Utgående – `scripts/test-firewall.sh`, kört på elev-12

Tid: 2026-11-19 11:06:25 UTC · Logg: `~/scripts/testresultat/test-ut-20261119-110625.log` (på elev-12)

Utdrag (sista delen av utskriften):

| Id | Test | Förväntat | Resultat |
|---|---|---|---|
| F11d | HTTPS ut (443) | OPEN | PASS |
| NEG-D5 | Gamla D5: tcp 514 till loggserver (borttagen 12/11) | BLOCKED | PASS |
| NEG-4444 | Okänd port ut, 1.1.1.1:4444 (T1571) | BLOCKED | PASS |
| NEG-80 | HTTP ut, 1.1.1.1:80 | BLOCKED | PASS |
| F6-ej-infört | SSH till teamets server | BLOCKED | PASS |
| F9-ej-infört | Databas 5432 | BLOCKED | PASS |
| F3, F13a, F1, F7a | Reglerna finns i zon.nft | FINNS | PASS |
| NEG-D5-regel | D5 (514) ska vara borta | BORTA | PASS |

**Godkända: 14 · Underkända: 0 · Ej testade: 0**

## 3. Från ctf (kursens kontroller)

ctf kan vi inte köra skript på. Flödena F13a–c verifieras i stället med kursens kontroller:

| Rad | Kontroll | Datum | Resultat |
|---|---|---|---|
| F13b (tcp/80) | `kontrollera U7.2` – ctf hämtar /zon/kvitto.txt | 17/11 | Godkänd |
| F13c (tcp/7512) | `kontrollera U7.3` – ctf ansluter till zonvakt och skickar overtrad | 17/11 | Godkänd |

## Slutsats

F13c släpper in ctf på tcp/7512 men inte jump – precis det flödestabellen säger. Övriga regler gäller oförändrat efter ändringen. Totalt 19/19 godkända + U7.2 och U7.3.

**Obs:** de blockerade testerna ger ZON-IN-DROP / ZON-UT-DROP och kan larma T1046 och T1571 (D2). Det är framkallade tester och triageras som sant positiva tester.
