# Linux-brandväggen på studentservern (nftables)

Ansvarig: Person 3 (Rrezart, elev-12). Regelfilen finns i repot som [`configs/nftables/zon.nft`](../configs/nftables/zon.nft).

## 1. Sammanfattning

- Regelverket bygger på teamets flödestabell (`docs/flodestabell.md`). Varje regel har radens id som kommentar, så att regel och tabellrad hör ihop.
- **Default deny i båda riktningarna:** kedjorna `in` och `ut` har `policy drop`. Bara det som står i flödestabellen släpps igenom.
- **Stateful:** svar på tillåtna anslutningar släpps av `ct state established,related accept`. Därför behövs bara en regel per flöde, i den riktning där anslutningen öppnas.
- **Beständigt:** regelverket laddas automatiskt vid omstart. Det har verifierats med en riktig omstart.
- **Samma fil på alla elevservrar:** filen innehåller ingen egen IP-adress, så den kan användas oförändrad på teamets alla elevservrar.

## 2. Varför filtrering på värden?

Molnbrandväggen (Person 2, `docs/brandvagg-moln.md`) ser bara trafik på den publika adressen (eth0). Trafik i labbnätet (172.20.1.0/24, eth1) och teamnätet (10.40.6.0/24, eth2) passerar aldrig molnbrandväggen. Den kan därför **bara** filtreras med nftables på servern.

| Nätkort | Nät | Filtreras av |
|---|---|---|
| eth0 | internet (publik adress) | molnbrandväggen **och** nftables |
| eth1 | labbnätet 172.20.1.0/24 | bara nftables |
| eth2 | teamnätet 10.40.6.0/24 | bara nftables |

## 3. Reglerna

Reglerna prövas uppifrån och ned, och den första regeln som fattar ett beslut gäller. Därför ligger `established,related` först och loggregeln sist.

### Kedjan `in` (trafik till servern)

| Ordning | Regel (villkor → beslut) | Rad i flödestabellen | Varför |
|---|---|---|---|
| 1 | `ct state established,related` → accept | – | Svar på tillåtna anslutningar och pågående sessioner. |
| 2 | `ct state invalid` → drop | – | Paket som inte hör till någon giltig anslutning. |
| 3 | `iif "lo"` → accept | – | Serverns trafik till sig själv (loopback). |
| 4 | `ip saddr 172.20.1.2 tcp dport 22` → accept | F3 (D1) | SSH från jump – den enda vägen in för administration. |
| 5 | `ip saddr 172.20.1.10 tcp dport 22` → accept | F13a (D2) | Kursens kontrolltjänst (ctf) loggar in. |
| 6 | `iif "eth0" tcp dport 80` → accept | F1 | Webbplatsen från internet. Bara via eth0, så att andra servrar i labb- och teamnätet inte når port 80. |
| 7 | `ip saddr 172.20.1.10 tcp dport 80` → accept | F13b | ctf kontrollerar webbservern över labbnätet. |
| 8 | `ip saddr 172.20.1.2 icmp type echo-request` → accept | F14 | Ping för felsökning, bara från jump. |
| 9 | `limit rate 10/minute log prefix "ZON-IN-DROP "` | – (loggning, Person 4) | Loggar det som ingen regel släppt, högst 10 rader per minut. |
| – | `policy drop` | Nekanderegeln | Allt annat kastas tyst. |

### Kedjan `ut` (trafik från servern)

| Ordning | Regel (villkor → beslut) | Rad i flödestabellen | Varför |
|---|---|---|---|
| 1 | `ct state established,related` → accept | – | Svar till dem som anslutit till servern (t.ex. SSH, webb). |
| 2 | `oif "lo"` → accept | – | Loopback. |
| 3 | `ip daddr { 185.12.64.1, 185.12.64.2 } tcp/udp dport 53` → accept | F11a–b (D3) | Namnuppslag mot Hetzners resolvrar. |
| 4 | `oif "eth0" udp dport 123` → accept | F11c (D4) | Tidssynkronisering (chrony). |
| 5 | `oif "eth0" tcp dport 443` → accept | F11d (D7) | Paketuppdateringar (dnf) över https. |
| 6 | `ip daddr 172.20.1.58 tcp dport 514` → accept | D5 | Brandväggsloggen till loggservern (rsyslog, klartext vecka 4). |
| 7 | `ip daddr 172.20.1.58 tcp dport 6514` → accept | F7a | Loggar till loggservern över TLS (används från vecka 5). |
| 8 | `udp sport 68 udp dport 67` → accept | D6 | Förnyelse av serverns DHCP-adresser. |
| 9 | `limit rate 10/minute log prefix "ZON-UT-DROP "` | – (loggning, Person 4) | Loggar stoppad utgående trafik. |
| – | `policy drop` | Nekanderegeln | Allt annat utgående stoppas, t.ex. reverse shell eller exfiltrering. |

**F11c och F11d** skrivs mot internet (alla adresser) eftersom ntp.hetzner.com och Rocky Linux-speglarna saknar fasta IP-adresser. Reglerna är ändå begränsade till en port och till eth0 (beslut i flödestabellen).

### Exempel på vad som nekas

| Trafik | Varför den nekas | Förväntat utfall |
|---|---|---|
| SSH från en annan labbadress än jump och ctf | Bara F3 och F13a tillåter SSH | tyst |
| Elevserver → elevserver (labbnätet och teamnätet) | "elev → elev" – ingen verksamhetsfunktion | tyst |
| Port 80 från labb- eller teamnätet, utom ctf | F1 gäller bara eth0 | tyst |
| Servern → ctf (t.ex. tcp/8081) | Baslinjen FL-03 stängs | tyst (`ZON-UT-DROP`) |
| Servern → log tcp/80 | Ingen rad i flödestabellen | tyst (`ZON-UT-DROP`) |

Den första, den andra (utgående från elev-12) och den fjärde är verifierade (avsnitt 6). Övriga testas av Person 5 (`docs/testresultat.md`).

## 4. Installera och ladda regelverket utan att låsa ute sig

**Status:** installerat och verifierat på **elev-12**. Övriga elevservrar i teamet: fyll i när regelverket är installerat där.

Gör så här på en elevserver (fungerar på alla, eftersom filen inte innehåller någon egen adress):

1. Två SSH-sessioner öppna: en att arbeta i och en reserv.
2. Kontrollera om gamla regelverk finns och laddas vid omstart – kommentera i så fall bort deras include-rader:
   `sudo nft list ruleset` och `sudo grep -n include /etc/sysconfig/nftables.conf`
3. Kopiera innehållet i `configs/nftables/zon.nft` till `/etc/nftables/zon.nft` på servern (t.ex. `sudo tee /etc/nftables/zon.nft` och klistra in).
4. Syntaxkontroll: `sudo nft -c -f /etc/nftables/zon.nft`
5. Säkerhetsnät som rensar reglerna efter fem minuter: `sudo systemd-run --on-active=5min --unit=nodbroms nft flush ruleset`
6. Ladda regelverket (atomiskt – allt eller inget): `sudo nft -f /etc/nftables/zon.nft`
7. Testa en **ny** inloggning via jump.
8. Fungerar den: `sudo systemctl stop nodbroms.timer`
9. Gör det beständigt:
   `echo 'include "/etc/nftables/zon.nft"' | sudo tee -a /etc/sysconfig/nftables.conf` och `sudo systemctl enable --now nftables`
10. Nödläge om allt är låst: `moln återställ-ssh` på jump.

## 5. Beständighet

- Regelfilen ligger i `/etc/nftables/zon.nft` och börjar med `flush ruleset`, så den ersätter allt som fanns innan.
- `/etc/sysconfig/nftables.conf` innehåller raden `include "/etc/nftables/zon.nft"`.
- Det gamla regelverket från vecka 3 (`u34.nft`, labben U3.4) är bortkommenterat i samma fil. Dess funktion (port 80 bara från ctf på eth1) ingår nu i F1 och F13b.
- `systemctl enable --now nftables` → `enabled`.

## 6. Verifiering

| Test | Kommando | Förväntat | Resultat | Datum |
|---|---|---|---|---|
| Syntax | `sudo nft -c -f /etc/nftables/zon.nft` | inget fel | inget fel | 26/10 |
| SSH via jump efter laddning | ny session: `ssh lab` | inloggning | `Last login … from 172.20.1.2` | 26/10 |
| DNS (F11a–b) | `getent hosts mirrors.rockylinux.org` | en adress | adress returnerad | 26/10 |
| NTP (F11c) | `sudo chronyc burst 1/1; chronyc sources` | färskt svar | `LastRx 5` (sekunder) | 26/10 |
| Uppdateringar (F11d) | `curl -sI https://mirrors.rockylinux.org` | http-svar | `HTTP/2 302` | 26/10 |
| Utgående som inte står i tabellen | `timeout 3 bash -c "</dev/tcp/172.20.1.10/8081"; echo $?` | 124 (tyst) | 124 | 26/10 |
| Kursens kontroll | `kontrollera U4.1` på jump | godkänd | policy drop in och ut, startar vid omstart, SSH från 172.20.1.203 → tyst, ut till 172.20.1.10:4445 → stoppad | 26/10 |
| Omstart | `sudo reboot`, sedan `uptime` och `sudo nft list ruleset` | regelverket laddat | `up 2 min`, `table inet zon … policy drop` | 27/10 |
| Nätkort efter omstart (D6) | `ip -br addr` | eth0–eth2 har adresser | eth0 2.28.98.110, eth1 172.20.1.112, eth2 10.40.6.4 | 27/10 |
| Ping från jump (F14) | på jump: `ping -c2 172.20.1.112` | svar | 0 % packet loss | 28/10 |
| Webb från internet (F1) | från egen dator: `curl -I http://2.28.98.110` | HTTP 200 | `HTTP/1.1 200 OK` – passerar både molnet och värden | 28/10 |
| Elev → elev nekas (ut) | `ping -c2 10.40.6.3` (teamkamrat) | stoppad | 100 % packet loss; svar först med en tillfällig regel, som sedan togs bort | 28/10 |

Loggningen (loggreglerna, rsyslog och D5) beskrivs och verifieras av Person 4 i `docs/loggning.md`. Kursens kontroll `kontrollera U4.2` är godkänd på elev-12.

**Lärdom från testerna:** ett test från servern mot sin egen adress går via `lo` och träffar aldrig filtret. Det gav *avvisad* (RST från kärnan) i stället för *tyst*. Tester av inkommande regler måste därför köras från en annan server, t.ex. jump.

## 7. Öppna frågor och avvikelser

- **Inget flöde i teamnätet (eth2) är tillåtet än.** De planerade flödena mellan zonerna (F8 DMZ → Server, F9 Server → Data) finns bara på papper. Teamet behöver bestämma vilket flöde som ska implementeras för att testas i workshop 2.
- **Elevservrarnas adresser i teamnätet** (10.40.6.3–.6) ligger i Server-subnätet (10.40.6.0/27), men elevservrarna hör till DMZ (10.40.6.64/29) enligt labbimplementationen i adressplanen. Det påverkar inte reglerna i dag, men måste stämma när regler skrivs för teamnätet (Person 1).
- **F7a (tcp/6514)** är öppnad ut, men rsyslog använder D5 (tcp/514) den här veckan. TLS införs i vecka 5.
- **Ping mellan teamets servrar** nekas eftersom F14 bara tillåter jump.
