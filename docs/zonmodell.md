# Zonmodell – milstolpe 3

Underlag: `docs/adressplan.md`, tillgångsförteckningen (vecka 1), teamets klassificering, trafikbaslinjen (`docs/Trafiksbaslinje.md`) och markeringstabellen (`docs/markeringstabell.md`). Skiss: `diagrams/zonskiss.png`. Flödestabell: `docs/flodestabell.md`.

## Förutsättningar

- Modellen visar **målbilden**. I dag är labbnätet platt och alla servrar når varandra.
- Subnäten är hämtade oförändrade från adressplanen (10.40.0.0/16, endast IPv4). Labbadresser (172.20.x.x) står bara i tillgångsförteckningen.
- All trafik mellan zoner går genom **brandväggen/routern** (ansluten via Transit), där flödesreglerna tillämpas.
- **Zero Trust:** allt som inte står i flödestabellen nekas – **inkommande och utgående, både i molnbrandväggen och på värden**. Plats i nätet ger ingen tillit.
- **Klass:** varje zon bedöms på **K**onfidentialitet (obehöriga ser), **R**iktighet (data ändras) och **T**illgänglighet (går inte att nå). Skyddsklassen är det högsta av de tre.
- *Planerad* = zon utan tillgångar i labbet än. Flöden där är teamets antagande.

## 1. Tillgångar

| Tillgång | Klass | Motivering | Zon (subnät) |
|---|---|---|---|
| jump | Hög | Omfattande behörigheter – den som tar över jump når alla servrar. | Admin (10.40.1.96/28) |
| log | Hög | Loggarna bevisar vem som gjort vad och måste gå att lita på. | Logg (10.40.1.120/29) |
| wazuh | Hög | Manipuleras den syns inga angrepp. | Logg (10.40.1.120/29) |
| elevservrar (elev-NN) | Hög | Exponerade mot internet – driftstopp eller manipulation syns direkt. | DMZ (10.40.1.128/29) |
| ctf | – | Kursens labbserver, ingår inte i uppdragsgivarens miljö. Får bara köra labbkontroller (F13a–b). | Utanför |

## 2. Zoner

| Zon | Subnät | K / R / T | Klass | Syfte | Får nås av |
|---|---|---|---|---|---|
| **DMZ** | 10.40.1.128/29 | M / H / H | Hög | Publika tjänster | Internet (HTTP), Klient (HTTP), jump (SSH, ICMP), ctf (SSH, HTTP) |
| **Admin** | 10.40.1.96/28 | H / H / H | Hög | Adminkonton och verktyg, enda vägen in | Internet (SSH till jump) |
| **Logg** | 10.40.1.120/29 | H / H / M | Hög | Central loggning och övervakning | Alla zoner utom Gäst (loggar över TLS), jump (SSH, HTTPS, ICMP) |
| **Server** *(planerad)* | 10.40.1.64/27 | M / H / H | Hög | Applikations- och driftservrar | DMZ (app-port 8080), jump (SSH, ICMP) |
| **Data** *(planerad)* | 10.40.1.112/29 | H / H / H | Hög | Företagsdatabas och affärsdata | Server (5432), jump (SSH, ICMP) |
| **Klient** *(planerad)* | 10.40.0.0/24 | M / M / M | Medel | Klientdatorer och användarkonton | Ingen |
| **Gäst** *(planerad)* | 10.40.1.0/26 | L / L / M | Medel | Besökare, isolerat, bara internet | Ingen |
| **Transit** | 10.40.1.136–.147 (Länk 1–3) | M / H / H | Hög | Routerlänkar och säkerhetsregler | Endast routrarna (konfigureras från Admin) |

H = hög, M = medel, L = låg.

**Admin och Logg är separata zoner:** loggarna ska vara bevis även mot administratörer, och DB-nätet ligger mellan dem i adressplanen så de kan inte slås ihop till ett prefix. Loggservern förvaltas därför av ett separat loggadmin-konto.

## 3. Flöden

Den fullständiga flödestabellen – med källzon, målzon, protokoll, port, riktning, motivering, var flödet filtreras och belägg – finns i **[flodestabell.md](flodestabell.md)**. Översikt per pil i skissen:

| Pil | Från → Till | Vad |
|---|---|---|
| F1 | Internet → DMZ | Webbplatsen, tcp/80 |
| F2 | Internet → jump | Enda vägen in, tcp/22 med nyckel |
| F3 | jump → DMZ | Förvaltning, tcp/22 |
| F4a–b | jump → log, wazuh | Förvaltning, tcp/22, bara loggadmin-kontot |
| F5 | jump → wazuh | Larm i dashboarden, tcp/443 |
| F6a–b | jump → Server, Data | Förvaltning, tcp/22 |
| F7a–e | Alla zoner utom Gäst → log | Central loggning, tcp/6514 med TLS |
| F8 | DMZ → Server | Portalen hämtar orderdata, tcp/8080 |
| F9 | Server → Data | Appen läser och skriver kunddata, tcp/5432 |
| F10 | Klient → DMZ | Personalen använder webben, tcp/80 |
| F11a–d | Serverzonerna → Internet | DNS (udp/tcp 53), NTP (udp/123), uppdateringar (tcp/443) |
| F12a–f | Klient, Gäst → Internet | Surfa: tcp/80, tcp/443, udp/53 |
| F13a–b | ctf → DMZ | Kursens labbkontroller, tcp/22 och tcp/80 |
| F14 | jump → DMZ, Logg, Server, Data | Felsökning, ICMP echo |

**Nekanderegel:** ”Allt som inte står i flödestabellen är nekat – inkommande och utgående, både i molnbrandväggen och på värden.” Viktigast: DMZ → Data, DMZ → Admin, elev → elev, Data → Internet (utom DNS och NTP), Gäst → interna zoner och Logg → andra zoner.

## 4. Öppna frågor

- Vad körs på TCP 9200 (wazuh)? Troligen Wazuh-indexeraren – ej verifierat.
- Portarna 8080 och 5432 (F8, F9) är antaganden tills Server och Data finns.
- Hur uppdateras Data utan direkt väg till internet – via en intern spegel?
- F11d går till `mirrors.rockylinux.org`, som anvisar varierande speglar. Hur skrivs regeln exakt i vecka 4?
- Klient och Gäst (F12c, F12f) använder Hetzners resolvrar 185.12.64.1–.2, som bara fungerar för servrar i Hetzners nät ([källa](https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers)). Flyttar zonerna till ett kontor behövs en annan resolver.
- Baslinjen FL-01: öppnar elevservern SSH till jump, eller är det jump som öppnar? Bekräftas med `tshark` (SYN utan ACK).
- Vilka zoner representeras av teamets servrar i vecka 4, och vilka finns bara på papper? Labbnätet blir 10.40.T.0/24 enligt teamnumret.
