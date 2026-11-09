# Central loggning – rsyslog över TLS

Ansvarig vecka 5: Rrezart (person 3). Verifierad på elev-12 den 4–5 november 2026.

## Loggkedjan

```
program → journald → rsyslog (elevserver) ── TLS, tcp/6514 ──▶ log 172.20.1.58 → /var/log/remote/elev-NN/ → loggsök på jump
                       auditd → audisp-syslog ─┘   kö på disk om log inte svarar
```

- Loggservern: `log.sec.chas-lab.dev`, intern adress **172.20.1.58** (labbnätet, eth1). Den sorterar raderna efter **källadress**, inte efter värdnamnet i meddelandet.
- Flödet i flödestabellen och brandväggen: **F7a**, `ip daddr 172.20.1.58 tcp dport 6514 accept`. Det går på eth1, så bara värdbrandväggen (nftables) filtrerar det. Molnbrandväggen ser inte labbnätet.
- Vecka 4 skickades `kern.*` i **klartext på tcp/514** (`60-brandvagg.conf`, D5). Den filen är ersatt av `60-central-loggning.conf`.

## Brandväggens logg (nftables)

Trafik som stoppas loggas av loggregler sist i kedjorna, före policy drop: `log prefix "ZON-IN-DROP "` i kedjan `in` och `log prefix "ZON-UT-DROP "` i kedjan `ut` (`configs/nftables/zon.nft`). Kärnan skriver raderna (facility `kern`), rsyslog läser dem från journalen och skickar dem vidare med regeln nedan.

## Vecka 4 → vecka 5

| | Vecka 4 | Vecka 5 |
|---|---|---|
| Fil | `60-brandvagg.conf` | `60-central-loggning.conf` |
| Urval | `kern.*` (kärnan, bland annat brandväggen) | system, autentisering, brandvägg och audit |
| Port | tcp/514, klartext (D5) | tcp/6514, TLS (F7a) |
| Format | traditionellt (RFC 3164) | RFC 5424 (`RSYSLOG_SyslogProtocol23Format`) |
| Kö | diskstödd, `fwd_kern`, saveOnShutdown | diskstödd, `fwd_tls`, saveOnShutdown (verifierad med U5.2) |

## Konfigurationen

Fil i repot: `configs/rsyslog/60-central-loggning.conf` → på servern `/etc/rsyslog.d/60-central-loggning.conf`.

| Rad | Betyder |
|---|---|
| `global(DefaultNetstreamDriverCAFile="/etc/pki/rsyslog/ca.pem")` | CA:n vi litar på (ITSX26 labb-CA) |
| `*.info;mail.none;cron.none` | urvalet: info och allvarligare, utom mail och cron |
| `target="172.20.1.58" port="6514" protocol="tcp"` | loggservern, TLS-porten (RFC 5425), TLS kräver TCP |
| `template="RSYSLOG_SyslogProtocol23Format"` | RFC 5424: år, delsekunder och tidszon i tidsstämpeln |
| `StreamDriver="gtls" StreamDriverMode="1"` | TLS på (`0` = klartext) |
| `StreamDriverAuthMode="x509/name"` | kontrollera certifikat och namn |
| `StreamDriverPermittedPeers="log.sec.chas-lab.dev"` | enda tillåtna namn på loggservern |
| `queue.type="LinkedList" queue.filename="fwd_tls"` | diskstödd kö i `/var/lib/rsyslog/` |
| `queue.saveOnShutdown="on"` | kön sparas vid omstart |
| `action.resumeRetryCount="-1"` | ge aldrig upp |

**Urval:** just nu används studieguidens minimiurval: system, autentisering (authpriv) och brandväggen (kern). Auditposter från auditd kommer med via `audisp-syslog` (user.info). Urvalet justeras när `docs/logging/loggurval.md` (person 1 och 2) är klart.

## Så sätter du upp det på din server

Ordning: **tid → flöde → vidarebefordran → testhändelse**. Alla kommandon körs på din server om inget annat står.

1. **Tid:** `chronyc tracking` → `Leap status: Normal`.
2. **Flöde:** `sudo nft list ruleset | grep 6514` → regeln F7a ska finnas.
3. **TLS-stöd:** `sudo dnf install -y rsyslog-gnutls` (går ut via F11d, tcp/443).
4. **CA-filen:** hämtas över http (port 80), som är stängd i vår brandvägg. Hämta den därför på jump och kopiera den via din egen dator:
   ```
   # jump
   curl -o ~/ca.pem http://log.sec.chas-lab.dev/ca.pem
   openssl x509 -in ~/ca.pem -noout -subject -enddate -fingerprint -sha256
   # egen dator
   scp elev-NN@jump.sec.chas-lab.dev:ca.pem .
   scp ca.pem lab:
   # din server
   sudo install -o root -g root -m 644 ~/ca.pem /etc/pki/rsyslog/ca.pem
   sudo openssl x509 -in /etc/pki/rsyslog/ca.pem -noout -fingerprint -sha256   # samma som på jump
   ```
   Förväntat: `subject=CN=ITSX26 labb-CA`, giltig till 1 nov 2027, fingeravtryck `2A:B7:EE:ED:…:3B:A6:0C:53`.
5. **Testa TLS före rsyslog:**
   ```
   sudo openssl s_client -connect 172.20.1.58:6514 -CAfile /etc/pki/rsyslog/ca.pem -verify_hostname log.sec.chas-lab.dev </dev/null 2>&1 | grep -E 'subject=|issuer=|Protocol|Verify'
   ```
   Förväntat: `Verify return code: 0 (ok)`.
6. **Byt konfiguration:** flytta undan den gamla klartextfilen, annars skickas brandväggsloggen två gånger:
   ```
   sudo mv /etc/rsyslog.d/60-brandvagg.conf /root/60-brandvagg.conf.v4
   ```
   Lägg sedan `60-central-loggning.conf` i `/etc/rsyslog.d/`.
7. **Kontrollera och starta om:**
   ```
   sudo rsyslogd -N1
   sudo systemctl restart rsyslog
   sudo journalctl -u rsyslog --since "2 min ago" --no-pager
   ```
   Varningarna `certificate file is not set` och `key file is not set` är väntade. Servern har inget eget certifikat, eftersom det är loggserverns certifikat som kontrolleras (RFC 5425 §5.3).
8. **Testhändelse:** `logger -p user.notice -t sparbarhet "U5.1 <identifierare>"` och sedan `loggsök <identifierare>` på jump. Raden ska börja med `mottaget … TLS |`.

## Verifierat på elev-12

| Kontroll | Resultat |
|---|---|
| `rsyslogd -N1` | inga fel |
| `openssl s_client` | CN=log.sec.chas-lab.dev, issuer CN=ITSX26 labb-CA, TLSv1.2, Verify 0 (ok) |
| `tcpdump -i eth1 host 172.20.1.58 and port 6514` | data ut och ACK tillbaka, inga upprepade SYN |
| System (U5.1) | `TLS | … elev-12 sparbarhet[12375] U5.1 spar8ae6168c` (53 ms från tidsstämpel till mottagning) |
| Autentisering | `TLS | … elev-12 sudo[25413] student : … COMMAND=/usr/bin/touch …` |
| Audit (U5.3) | `TLS | … elev-12 audisp-syslog[25384] type=EXECVE …` |
| Brandvägg | `TLS | … elev-12 kernel ZON-IN-DROP IN=eth1 … SRC=172.20.1.2 … DPT=4444 … SYN` |
| Kön (U5.2) | händelse under blockering + två omstarter kom fram 461 s senare |

Detaljer och belägg: `docs/logging/verifiering-loggning.md` och `docs/logging/loggskydd.md` (person 4).

## Kvar och öppna frågor

- **Flödestabellen:** D5 (tcp/514 till log) behövs inte längre när alla servrar skickar över TLS. Ändra tabellen först och ta sedan bort regeln i `zon.nft`.
- **CA-hämtningen** görs via jump, så vi behöver inget nytt flöde för port 80. Det ska noteras i flödestabellen som ett beslut.
- **Kön** har ingen egen diskgräns (`queue.maxDiskSpace`), utan delar disk med `/`. Förslag: sätt en gräns, till exempel `1g`.
- **Urvalet** justeras när `docs/logging/loggurval.md` är klart.
- Person 5 kontrollerar att alla servrar har samma konfiguration, till exempel med `sudo md5sum /etc/rsyslog.d/60-central-loggning.conf`.
