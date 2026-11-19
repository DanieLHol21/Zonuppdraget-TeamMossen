# Härdningsrapport – elev-12

Rrezart Binaku · Vecka 7, workshop 2 · 18/11 2026 · Rocky Linux 9, SELinux targeted

Rapporten bygger på ett AI-utkast (råsvaret finns i `metodbilaga-elev-12/rasvar.txt`). Varje numrerat påstående i utkastet har fått en dom – **stämmer**, **fel** eller **ogrundat** – med kommandot och utdatan från min server som avgjorde. Belägg är tagna 17–18/11, efter omstarten 17/11 13:22 UTC. Interna IP-adresser är maskerade.

---

## Del 1 – Rättad rapport

### Sammanfattning
elev-12 har fem härdningsåtgärder. Tre gjordes eller verifierades under workshop 1 den 17/11 (SELinux enforcing, fcontext för /srv/zonwebb, zonvakt i egen domän). Två fanns sedan tidigare i kursen: paketfiltret med policy drop (vecka 4) och auditd-regeln för root-kommandon (vecka 5). Verifieringsskriptet ger GÄLLER på alla 8 kontroller och slutkod 0 efter omstart.

### SELinux-läge
SELinux är enforcing både nu och efter omstart (`sestatus`: Current mode och Mode from config file = enforcing), med targeted-policyn.

### Härdningsåtgärder
| Nr | Åtgärd | Motivering | Verifiering |
|---|---|---|---|
| 1 | SELinux enforcing nu och efter omstart | En tjänst som tas över får annars göra allt som dess användare får, även som root | `getenforce` = Enforcing, `SELINUX=enforcing` i config |
| 2 | Paketfilter `inet zon` med policy drop in och ut (vecka 4) | Bara flödena i flödestabellen ska vara öppna | `nft list chain inet zon in/ut` innehåller policy drop. Port 7512 är bara öppen för ctf-servern (F13c). |
| 3 | auditd loggar root-kommandon (vecka 5) | Den som använder sudo ska lämna spår | `auditctl -l`: execve med euid=0 och auid≥1000, nyckel `rootkommando`. Auditd-händelser når Wazuh via audisp-syslog. |
| 4 | Bestående fcontext för `/srv/zonwebb` | httpd ska bara läsa webbinnehåll, och typen ska tåla en relabel | `semanage fcontext -l -C` visar regeln, `curl` mot /zon/kvitto.txt ger 200 |
| 5 | zonvakt i egen tvingande domän `zonvakt_t` | zonvakt kör som root. Utan egen domän kan den skriva i /etc. | `ps -eZ` visar `zonvakt_t` för användaren root. `overtrad` nekas, AVC med permissive=0. |

### zonvakt under egen policy
Modulen `zonvakt` är laddad och inte permissiv. Den ger zonvakt rätt att lyssna på TCP, läsa i /etc och skriva i sin egen logg (`zonvakt_log_t`), men inte skriva i /etc. Den generiska portregeln (`corenet_tcp_bind_generic_port`) är för bred och kan snävas in med en egen porttyp. Motiveringen för varje regel finns i rättelseloggen för policyn.

### Kvarstående risker
- SSH: root-inloggning med nyckel, lösenordsinloggning och X11 är påslagna (sshd -T 18/11). X11 kan stängas av med låg risk. Root- och lösenordsinloggning ändras först när jag vet att inget behöver dem, och med en andra SSH-session öppen.
- zonvakt får binda alla oreserverade portar (generisk porttyp).
- Skriptet kontrollerar att inställningarna finns, inte att funktionen fungerar. Funktionen testades separat med `overtrad` och `curl`.

---

## Del 2 – Dom för varje påstående i AI-utkastet

| Nr | Påstående (kort) | Dom | Kommando | Utfall |
|---|---|---|---|---|
| 1 | Rrezart härdade servern under workshop 1, 17/11 | **fel** | `sudo ls -l --time-style=+%F /etc/nftables/zon.nft.bak /etc/audit/rules.d/` | zon.nft.bak 2026-11-02, rootkommando.rules 2026-11-04 – två åtgärder är äldre |
| 2 | Fem åtgärder genomfördes (under workshop 1) | **fel** | samma | Tre gjordes eller verifierades 17/11, två fanns sedan vecka 4–5 |
| 3 | Skriptet gav GÄLLER 8/8, slutkod 0 efter omstart | stämmer | `uptime -s`; `sudo verifiera-hardning` | Uppstart 17/11 13:22. 8 GÄLLER, slutkod 0 (18/11) |
| 4 | Tre SSH-inställningar står kvar som risker | stämmer | `sudo sshd -T` | without-password, yes, yes |
| 5 | Rocky 9, targeted, workshop 1 17/11 | stämmer | `sestatus` | targeted |
| 6 | Current och config mode enforcing | stämmer | `sestatus` | enforcing / enforcing |
| 7 | MLS enabled, deny_unknown allowed, memory actual | stämmer | `sestatus` | samma |
| 8 | Okänt om sestatus kördes efter omstart | ogrundat → avgjort | `uptime -s` | Omstart 17/11 13:22. sestatus kördes 18/11, alltså efter |
| 9 | Åtgärd 1: enforcing nu och efter omstart | stämmer | `sestatus` | enforcing / enforcing |
| 10 | Motivering: MAC begränsar skadan även som root | stämmer | `ps -o user= -C zonvakt`; `echo overtrad \| nc …` | root, men nekad |
| 11 | Effekt: getenforce Enforcing, config enforcing | stämmer | `sestatus` | Current och Mode from config file = enforcing |
| 12 | Kontrollerna för SELinux gav GÄLLER | stämmer | `sudo verifiera-hardning` | GÄLLER, GÄLLER |
| 13 | inet zon har in och ut med policy drop | stämmer | `sudo verifiera-hardning` | GÄLLER, GÄLLER |
| 14 | Motivering: bara flödestabellens flöden öppna | stämmer | `sudo nft list chain inet zon in \| grep 7512` | Bara ett specifikt accept för ctf, resten drop |
| 15 | Effekt: policy drop i in och ut | stämmer | `sudo verifiera-hardning` | GÄLLER |
| 16 | Kontrollerna för paketfilter gav GÄLLER | stämmer | samma | GÄLLER |
| 17 | Okänt om 7512 är öppen | ogrundat → avgjort | `sudo nft list chain inet zon in \| grep 7512` | `ip saddr IP-INTERN-BORTTAGEN tcp dport 7512 accept comment "F13c …"` |
| 18 | auditd-regel med nyckeln rootkommando | stämmer | `sudo auditctl -l` | key=rootkommando |
| 19 | Motivering: sudo ska lämna spår | stämmer | `sudo auditctl -l` | euid=0, auid>=1000 |
| 20 | Effekt: regeln finns | stämmer | `sudo auditctl -l` | finns |
| 21 | Kontrollen gav GÄLLER efter omstart | stämmer | `sudo verifiera-hardning` | GÄLLER |
| 22 | Regelns exakta innehåll visas inte | ogrundat → avgjort | `sudo auditctl -l` | `-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -F key=rootkommando` |
| 23 | Att loggen når loggservern är inte visat | ogrundat → avgjort | Wazuh Discover (`metodbilaga-elev-12/wazuh-avc-2979.png`), `wazuh-archives-*`, `full_log:"type=AVC" AND full_log:"comm=zonvakt" AND location:*elev-12*` | 17/11: auditd-händelse (löpnr 2979) kom fram via audisp-syslog, regel 100200 |
| 24 | Lokal fcontext-regel för /srv/zonwebb | stämmer | `sudo semanage fcontext -l -C` | `/srv/zonwebb(/.*)? … httpd_sys_content_t` |
| 25 | Motivering: chcon försvinner vid relabel | stämmer | `sudo semanage fcontext -l -C` | Regeln finns i policyn (inte bara på filen) |
| 26 | kvitto.txt har httpd_sys_content_t | stämmer | `ls -Z /srv/zonwebb` | httpd_sys_content_t |
| 27 | httpd kör i httpd_t | stämmer | `ps -eZ \| grep httpd` | httpd_t |
| 28 | Alias /zon/ → /srv/zonwebb/, Require all granted | stämmer | `cat /etc/httpd/conf.d/zonwebb.conf` | samma |
| 29 | Skriptet kollar bara att regeln finns | stämmer | `cat /usr/local/bin/verifiera-hardning` | `semanage fcontext -l -C \| grep -q` |
| 30 | Inget test att httpd levererar | ogrundat → avgjort | `curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/zon/kvitto.txt` | 200 |
| 31 | zonvakt i egen tvingande domän | stämmer | `ps -eZ`; `semanage permissive -l` | zonvakt_t, ingen permissiv |
| 32 | Motivering: kör som root, kan annars skriva i /etc | stämmer | `ps -o user= -C zonvakt` | root |
| 33 | Att zonvakt kör som root visas inte | ogrundat → avgjort | `ps -o user=,label=,comm= -C zonvakt`; `systemctl cat zonvakt` | root, zonvakt_t. Ingen User= i enheten |
| 34 | ps visar zonvakt_t, permissive tomt | stämmer | `ps -eZ`; `semanage permissive -l \| grep zonvakt` | zonvakt_t, inget svar |
| 35 | Kontrollerna för zonvakt gav GÄLLER | stämmer | `sudo verifiera-hardning` | GÄLLER, GÄLLER |
| 36 | Inget test att overtrad nekas | ogrundat → avgjort | `echo overtrad \| nc -w2 127.0.0.1 7512`; `sudo ausearch -m avc -c zonvakt -ts today -i` | "nekad: Permission denied". AVC löpnr 367: denied write, etc_t, permissive=0 |
| 37 | Modulen zonvakt laddad, version 1.0.0 | stämmer | `sudo semodule -l \| grep -x zonvakt`; zonvakt.te | zonvakt, 1.0.0 |
| 38 | Deklarerar zonvakt_t, exec_t, log_t | stämmer | zonvakt.te | samma |
| 39 | Filkontexter för binär och logg | stämmer | zonvakt.fc | samma |
| 40 | ls -Z visar exec_t och log_t | stämmer | `ls -Z` | samma |
| 41 | Grundreglerna (fifo, unix_stream, logg, läsa etc …) | stämmer | zonvakt.te | samma |
| 42 | /etc bara som läsrätt | stämmer | zonvakt.te | bara files_read_etc_files |
| 43 | Tillagda regler efter audit2allow | stämmer (förtydligat) | zonvakt.te | tcp_socket-raden är `create_stream_socket_perms`, ändrad från audit2allows förslag |
| 44 | audit2allow-utdata och motivering saknas | stämmer (i underlaget) | – | Finns i rättelseloggen för policyn |
| 45 | Ingen egen porttyp, generic_port | stämmer | zonvakt.te | corenet_tcp_bind_generic_port |
| 46 | Ingen permissive-sats | stämmer | zonvakt.te; `semanage permissive -l` | ingen |
| 47 | zonvakt lyssnar på 0.0.0.0:7512 | stämmer | `sudo ss -tlnp` | 0.0.0.0:7512 |
| 48 | Inventeringen 13.00 saknade zonvakt, okänt varför | stämmer → förklarat | Härdningslistan (tider) | Inventeringen gjordes före installationen (13.15) |
| 49 | systemd-enheten visas inte | ogrundat → avgjort | `systemctl cat zonvakt` | ExecStart=/usr/local/bin/zonvakt, ingen User= (root) |
| 50 | Skriptet efter omstart: 8/8, slutkod 0 | stämmer | `sudo verifiera-hardning` | samma |
| 51 | Skriptet läser bara av, slutkod 1 vid fel | stämmer | skriptet; test med `setenforce 0` 17/11 | GÄLLER INTE, slutkod 1 |
| 52 | Fördelning 2+2+1+1+2 | stämmer | skriptet | samma |
| 53 | Kontrollerna testar inställningar, inte funktion | stämmer | skriptet | Funktion testad separat (30, 36) |
| 54 | Okänt vilka utdata som togs efter omstart | ogrundat → avgjort | `uptime -s` | Alla utdata från 18/11, efter omstarten 17/11 |
| 55 | permitrootlogin without-password | stämmer | `sudo sshd -T` | samma |
| 56 | passwordauthentication yes | stämmer | `sudo sshd -T` | samma |
| 57 | x11forwarding yes | stämmer | `sudo sshd -T` | samma |
| 58 | Planen: först X11, sedan root/lösenord | **ogrundat** | Härdningslistan | Listan anger ingen ordning – omformulerat |
| 59 | Ingen senare sshd -T | ogrundat → avgjort | `sudo sshd -T` (18/11) | Samma värden |
| 60 | Okänt om filtret begränsar 7512 | ogrundat → avgjort | `sudo nft list chain inet zon in \| grep 7512` | Bara ctf-servern släpps in (F13c), resten policy drop |
| 61 | zonvakt_t binder generiska portar | stämmer | zonvakt.te | samma |
| 62 | Ingen AVC-genomgång, okänt om overtrad nekas | ogrundat → avgjort | `sudo ausearch -m avc -c zonvakt -ts today -i` | AVC 367, permissive=0 |
| 63 | Att audit-loggen når loggservern är inte verifierat | ogrundat → avgjort | Wazuh (se 23) | Löpnr 2979 syntes i Wazuh 17/11 |

**Summa:** 63 påståenden: 47 stämmer, 2 fel (1, 2) och 14 ogrundade. 13 av de ogrundade avgjordes med kommandon på servern, och 1 omformulerades (58).

---

## Del 3 – Rättelselogg

| Påst. nr | Påstående (kort) | Dom | Kommando som avgjorde | Faktiskt utfall | Feltyp | Ändrat till |
|---|---|---|---|---|---|---|
| 1 | Servern härdades under workshop 1 | fel | `sudo ls -l --time-style=+%F /etc/nftables/zon.nft.bak /etc/audit/rules.d/` | Paketfiltret 2026-11-02, auditd-regeln 2026-11-04 | Faktafel (slutsats utan stöd) | "Tre åtgärder gjordes eller verifierades 17/11, två fanns sedan vecka 4–5" |
| 2 | Fem åtgärder genomfördes | fel | samma | Två av fem är äldre | Faktafel | Som ovan |
| 17, 60 | Okänt om 7512 är öppen | ogrundat | `sudo nft list chain inet zon in \| grep 7512` | F13c: bara ctf-servern | Ogrundat | "Port 7512 är bara öppen för ctf-servern (F13c)" |
| 22 | Regelns innehåll visas inte | ogrundat | `sudo auditctl -l` | execve, euid=0, auid>=1000 | Ogrundat | Regeln beskriven |
| 23, 63 | Loggen når loggservern ej visat | ogrundat | Wazuh Discover | Löpnr 2979 via audisp-syslog | Ogrundat | "Auditd-händelser når Wazuh" |
| 30 | httpd levererar ej testat | ogrundat | `curl … /zon/kvitto.txt` | 200 | Ogrundat | Lagt till som verifiering |
| 33, 49 | Root och systemd-enhet visas inte | ogrundat | `ps -o user= -C zonvakt`; `systemctl cat zonvakt` | root, ingen User= | Ogrundat | "zonvakt kör som root" med belägg |
| 36, 62 | overtrad nekas ej testat | ogrundat | `echo overtrad \| nc …`; `ausearch -m avc` | Nekad, AVC 367 permissive=0 | Ogrundat | Lagt till som verifiering |
| 8, 54 | Okänt om utdata togs efter omstart | ogrundat | `uptime -s` | Omstart 17/11 13:22, utdata 18/11 | Ogrundat | "Belägg tagna efter omstarten" |
| 48 | Varför zonvakt saknas i inventeringen | ogrundat | Härdningslistans tider | Inventering 13.00, installation 13.15 | Inaktuellt | Förklaring tillagd |
| 58 | Plan: först X11, sedan root/lösenord | ogrundat | Härdningslistan | Ingen ordning angiven | Ogrundat | "X11 kan stängas av med låg risk; root/lösenord först när …" |
| 59 | Ingen senare sshd -T | ogrundat | `sudo sshd -T` | Samma värden 18/11 | Ogrundat | Datum tillagt |

---

## Del 4 – Metodbilaga

### 1. Underlag som matades in
- Härdningslistan (`hardningslista-elev-12.md`) – interna IP-adresser maskerade med `IP-INTERN-BORTTAGEN`
- `zonvakt.te`, `zonvakt.fc`
- `/etc/httpd/conf.d/zonwebb.conf`
- `/usr/local/bin/verifiera-hardning` (skriptets innehåll)
- Utdata 17–18/11: `sestatus`, `semodule -l | grep -x zonvakt`, `ps -eZ`, `ls -Z`, `semanage permissive -l`, `semanage fcontext -l -C`, `ss -tlnp`, verifieringsskriptets utskrift
- Maskering gjordes med `sed -E 's/(172\.20|10\.40)\.[0-9]+\.[0-9]+/IP-INTERN-BORTTAGEN/g'` utan att ändra filerna.

### 2. Prompt, ordagrant
Se `metodbilaga-elev-12/prompt.txt` (oförändrad). Den ber AI:n hålla sig till underlaget, numrera påståendena, markera det som saknas med [SAKNAS I UNDERLAGET] och anger systemet (Rocky Linux 9, SELinux targeted).

### 3. Råsvar, oredigerat
Se `metodbilaga-elev-12/rasvar.txt` (oförändrad, 63 numrerade påståenden). Utkastet togs fram i en ny chatt utan tidigare sammanhang.

### 4. Rättelselogg
Se del 3. Två fel rättades (1–2). 13 ogrundade påståenden avgjordes med kommandon på servern, och ett omformulerades (58).

### 5. Utelämningslista
| Utelämnat | Varför |
|---|---|
| Hela `zon.nft` och flödestabellen | Visar nätets uppbyggnad med interna adresser. Behövdes inte för rapporten. |
| AVC-loggar och Wazuh-utdrag | Innehåller interna adresser. Användes bara vid granskningen. |
| CTF-flaggor och kvittot | Personliga |
| Lösenord, SSH-nycklar, certifikat (rsyslog TLS) | Får aldrig matas in |
| Serverns publika IP | Behövs inte |

### Vad jag lärde mig
AI-utkastet var bra på att hålla sig till underlaget och markera luckor, men det drog en slutsats som lät rimlig och var fel: att allt gjordes under workshop 1. Det syntes först när jag kontrollerade filernas datum på servern. Ett påstående är inte sant för att det står i ett välskrivet utkast. Det krävs ett kommando bredvid.
