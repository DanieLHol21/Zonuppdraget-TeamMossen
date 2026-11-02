# Spårbarhetslista – från flödestabell till regel

Listan visar vilken regel som hör till vilken rad i flödestabellen (`docs/flodestabell.md`), i vilket lager den ligger och om den är testad. Mallen kommer från studieguiden för vecka 4.

- **Riktning** = in eller ut, sett från servern där regeln ligger.
- **Lager:** *värd* = nftables på elevservern (`configs/nftables/zon.nft`) · *moln* = Hetzners molnbrandvägg (`moln brandvägg regel lista`).
- **Regelns identifierare:** kommentaren i nftables, eller beskrivningen i molnregeln. Båda börjar med radens id.
- **Status:** *planerad* = inte byggd · *implementerad* = regeln finns · *verifierad* = ett test visar att den fungerar.
- **Server:** elev-12 (eth0 2.28.98.110, eth1 172.20.1.112, eth2 10.40.6.4). Regelfilen är densamma på teamets alla elevservrar.

Senast uppdaterad: 28 oktober 2026.

## 1. Regler som är byggda

### Värden – kedjan `in`

| Rad-id | Riktning | Källa | Mål | Proto/port | Lager | Regelns identifierare | Loggar? | Status |
|---|---|---|---|---|---|---|---|---|
| F3 (D1) | in | jump 172.20.1.2 | elevservern (eth1) | tcp/22 | värd | `"F3 SSH från jump (D1)"` | nej | verifierad – ny inloggning via jump efter laddning och efter omstart |
| F13a (D2) | in | ctf 172.20.1.10 | elevservern (eth1) | tcp/22 | värd | `"F13a kontroll från ctf (D2)"` | nej | verifierad – `kontrollera U4.1` loggar in från ctf |
| F1 | in | internet (eth0) | elevservern, publik adress | tcp/80 | värd | `"F1 webb från internet"` | nej | verifierad – `curl -I http://2.28.98.110` från egen dator via internet → HTTP/1.1 200 OK |
| F13b | in | ctf 172.20.1.10 | elevservern (eth1) | tcp/80 | värd | `"F13b webbkontroll från ctf"` | nej | implementerad |
| F14 | in | jump 172.20.1.2 | elevservern (eth1) | icmp echo-request | värd | `"F14 ping från jump"` | nej | verifierad – `ping -c2 172.20.1.112` från jump → 0 % packet loss |
| Nekanderegel | in | alla övriga | elevservern | alla | värd | `"ZON-IN-DROP "` (loggregel) + `policy drop` | **ja** | verifierad – SSH från 172.20.1.203 → tyst (`kontrollera U4.1`); nekad rad framme på log (`kontrollera U4.2`) |

### Värden – kedjan `ut`

| Rad-id | Riktning | Källa | Mål | Proto/port | Lager | Regelns identifierare | Loggar? | Status |
|---|---|---|---|---|---|---|---|---|
| F11a–b (D3) | ut | elevservern | 185.12.64.1, 185.12.64.2 | udp/53, tcp/53 | värd | `"F11a-b DNS (D3)"` | nej | verifierad – `getent hosts mirrors.rockylinux.org` svarar |
| F11c (D4) | ut | elevservern | internet via eth0 | udp/123 | värd | `"F11c NTP (D4)"` | nej | verifierad – `chronyc burst` → LastRx 5 s |
| F11d (D7) | ut | elevservern | internet via eth0 | tcp/443 | värd | `"F11d uppdateringar (D7)"` | nej | verifierad – `curl -sI https://mirrors.rockylinux.org` → HTTP/2 302 |
| D5 | ut | elevservern | log 172.20.1.58 | tcp/514 | värd | `"D5 brandväggslogg till log"` | nej | verifierad – `ss -tn` → ESTAB :514; `kontrollera U4.2` |
| F7a | ut | elevservern | log 172.20.1.58 | tcp/6514 | värd | `"F7a loggar till log TLS"` | nej | implementerad – TLS används från vecka 5 |
| D6 | ut | elevservern | DHCP-servern: 172.31.1.1 (eth0), 172.20.0.1 (eth1), 10.40.6.1 (eth2) | udp 68 → 67 | värd | `"D6 DHCP"` | nej | implementerad – syns först när lånet (24 h) förnyas |
| Nekanderegel | ut | elevservern | alla övriga | alla | värd | `"ZON-UT-DROP "` (loggregel) + `policy drop` | **ja** | verifierad – ut till ctf 172.20.1.10:8081 → tyst (124); ping till teamkamrat 10.40.6.3 → stoppad; `kontrollera U4.1` |

### Molnet

| Rad-id | Riktning | Källa | Mål | Proto/port | Lager | Regelns identifierare | Loggar? | Status |
|---|---|---|---|---|---|---|---|---|
| F1 | in | 0.0.0.0/0 | elevservern | tcp/80 | moln | `"F1 webb från internet"` | nej | verifierad – samma test: trafiken passerar molnet och värden; regeln granskad av `kontrollera U4.4` |
| F11a | ut | elevservern | 185.12.64.1/32, 185.12.64.2/32 | udp/53 | moln | `"F11a DNS"` (två regler) | nej | verifierad – DNS svarar efter U4.4 |
| F11b | ut | elevservern | 185.12.64.1/32, 185.12.64.2/32 | tcp/53 | moln | `"F11b DNS tcp"` (två regler) | nej | implementerad |
| F11c | ut | elevservern | 0.0.0.0/0 | udp/123 | moln | `"F11c NTP"` | nej | verifierad – `chronyc burst` efter U4.4 |
| F11d | ut | elevservern | 0.0.0.0/0 | tcp/443 | moln | `"F11d uppdateringar"` | nej | verifierad – `curl` efter U4.4 |
| Nekanderegel | in + ut | övrigt | övrigt | alla | moln | inbyggt: bara det som står i reglerna släpps | nej (molnet loggar inte) | implementerad – kursens startregler borttagna; "Utgående: bara det som står i ut-reglerna" |

Molnet filtrerar bara eth0 (internet). Rader i labbnätet och teamnätet finns därför bara i värdlagret.

## 2. Rader som inte är regler på elevservern

| Rad-id | Varför ingen regel på elevservern | Status |
|---|---|---|
| F2 | Internet → jump. Filtreras på jump, som är kursens server. | ej vår server |
| F4a, F4b, F5 | jump → log/wazuh. Filtreras på log och wazuh, kursens servrar. | ej vår server |
| F7b | jump → log. Filtreras på jump och log. | ej vår server |
| F6a, F6b | jump → Server, Data. Zonerna finns inte i labbet. | planerad |
| F7c, F7d, F7e | Server, Data, Klient → log. Zonerna finns inte i labbet. | planerad |
| F8 | DMZ → Server tcp/8080. Teamet väljer vilka servrar som spelar DMZ och Server. | planerad |
| F9 | Server → Data tcp/5432. Zonerna finns inte i labbet. | planerad |
| F10 | Klient → DMZ. Zonen finns inte i labbet. | planerad |
| F12a–f | Klient, Gäst → internet. Zonerna finns inte i labbet. | planerad |
