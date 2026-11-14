# Brandväggstest elev-12 – 2026-11-12

**Ansvarig:** Rrezart Binaku (elev-12), person 2
**Skript:** `scripts/test-firewall.sh` (körs på elev-12) och `scripts/test-firewall-in.sh` (körs från jump)
**Bakgrund:** Peter påpekade att det gamla skriptet testade SSH från jump som utgående trafik och använde fel adress till loggservern. Det är rättat. D5 (tcp 514) togs bort ur zon.nft samma dag, före testerna.

## Sammanfattning

| Körning | Var | Tid (UTC) | Godkända | Underkända |
|---|---|---|---|---|
| Utgående + regelkontroll | elev-12 | 11:11 | 14 | 0 |
| Inkommande | jump (172.20.1.2) | 11:14 | 4 | 0 |
| Inkommande | ctf (172.20.1.10) | – | ej körd | – |

**ctf:** testerna kördes inte från ctf eftersom jag saknar åtkomst (lärarens kontrollserver). F13a (SSH från ctf) är bevisad av U6.2: ctf nådde SSH på elev-12 12 gånger 2026-11-11 kl. 16:09 UTC (Wazuh, regel 5710/5712). F13b (HTTP från ctf) finns i zon.nft, se regelkontrollen nedan.

**Larm:** de blockerade testerna gav ZON-UT-DROP och ZON-IN-DROP. Larm från T1571/T1046 efter 11:11 UTC är alltså framkallade av testet.

## Körning 1 – på elev-12 (utgående + regler)

```
========================================
 BRANDVÄGGSTEST UT – elev-12
 Datum: Thu Nov 12 11:11:38 AM UTC 2026
========================================

1. TILLÅTET UT (ska vara OPEN)
----------------------------------------
[PASS] F7a - TLS-loggning till loggserver 6514 (OPEN)
[PASS] F11a-b - DNS-uppslagning (OPEN)
[PASS] F11c - NTP synkad (OPEN)
[PASS] F11d - HTTPS ut (443) (OPEN)

2. INTE TILLÅTET UT (ska vara BLOCKED)
----------------------------------------
[PASS] NEG-D5 - Gamla D5: tcp 514 till loggserver (borttagen 12/11) (BLOCKED)
[PASS] NEG-4444 - Okänd port ut, 1.1.1.1:4444 (T1571) (BLOCKED)
[PASS] NEG-80 - HTTP ut, 1.1.1.1:80 (bara 443 tillåtet) (BLOCKED)
[PASS] F6-ej-infört - SSH till teamets server (ingen regel än) (BLOCKED)
[PASS] F9-ej-infört - Databas 5432 (ingen regel än) (BLOCKED)

3. REGLERNA FINNS I zon.nft
----------------------------------------
[PASS] F3 - SSH in från jump (FINNS)
[PASS] F13a - SSH in från ctf (FINNS)
[PASS] F1 - HTTP in via eth0 (FINNS)
[PASS] F7a - TLS-loggning ut 6514 (FINNS)
[PASS] NEG-D5-regel - D5 (514) ska vara borta (BORTA)

========================================
Godkända:  14
Underkända: 0
Ej testade: 0
Logg: /home/student/scripts/testresultat/test-ut-20261112-111138.log
========================================
```

## Körning 2 – från jump (inkommande)

```
========================================
 BRANDVÄGGSTEST IN – från jump mot elev-12
 Datum: Thu Nov 12 11:14:44 AM UTC 2026
========================================
[PASS] F3 - SSH från jump (OPEN)
[PASS] F14 - Ping från jump (OPEN)
[PASS] NEG-80 - HTTP från jump (bara eth0/ctf) (BLOCKED)
[PASS] NEG-4444 - Okänd port 4444 (T1046) (BLOCKED)
========================================
Godkända:  4
Underkända: 0
Logg: /home/elev-12/testresultat/test-in-jump-20261112-111444.log
========================================
```

## Att notera

- **F6 och F9 (teamnätet):** reglerna är inte införda i zon.nft än, därför förväntas BLOCKED. Tas upp med teamet mån 16/11.
- **Central loggning efter D5:** kontrollerad 11:59 svensk tid med `logger "TEST efter D5 borttagen"`, som syntes i Wazuh (wazuh-archives-*, location elev-12). Loggarna går via 6514 (TLS).
- **AI-stöd:** skripten rättades med AI-stöd. Jag har kört dem själv och kontrollerat resultaten mot zon.nft.
