# Zonmodell – milstolpe 2 (uppdaterad inför milstolpe 3)

Underlag: `docs/adressplan.md`, tillgångsförteckningen (vecka 1) och teamets klassificering. Skiss: `diagrams/zonskiss.png`.

## Förutsättningar

- Modellen visar **målbilden**. I dag är labbnätet platt och alla servrar når varandra.
- Subnäten är hämtade oförändrade från adressplanen (10.40.0.0/16, endast IPv4). Labbadresser (172.20.x.x) står bara i tillgångsförteckningen.
- All trafik mellan zoner går genom **brandväggen/routern** (ansluten via Transit), där flödesreglerna tillämpas.
- **Zero Trust:** allt som inte står i flödestabellen nekas – **inkommande och utgående**. Plats i nätet ger ingen tillit.
- **Klass:** varje zon bedöms på **K**onfidentialitet (obehöriga ser), **R**iktighet (data ändras) och **T**illgänglighet (går inte att nå). Skyddsklassen är det högsta av de tre.
- *Planerad* = zon utan tillgångar i labbet än. Flöden där är teamets antagande.

## 1. Tillgångar

| Tillgång | Klass | Motivering | Zon (subnät) |
|---|---|---|---|
| jump | Hög | Omfattande behörigheter – den som tar över jump når alla servrar. | Admin (10.40.1.96/28) |
| log | Hög | Loggarna bevisar vem som gjort vad och måste gå att lita på. | Logg (10.40.1.120/29) |
| wazuh | Hög | Manipuleras den syns inga angrepp. | Logg (10.40.1.120/29) |
| elevservrar (elev-NN) | Hög | Exponerade mot internet – driftstopp eller manipulation syns direkt. | DMZ (10.40.1.128/29) |
| ctf | – | Kursens labbserver, ingår inte i uppdragsgivarens miljö. Får bara köra labbkontroller (F13). | Utanför |

## 2. Zoner

| Zon | Subnät | K / R / T | Klass | Syfte | Får nås av |
|---|---|---|---|---|---|
| **DMZ** | 10.40.1.128/29 | M / H / H | Hög | Publika tjänster | Internet, Klient (HTTP), jump (SSH), ctf (SSH) |
| **Admin** | 10.40.1.96/28 | H / H / H | Hög | Adminkonton och verktyg, enda vägen in | Internet (SSH till jump) |
| **Logg** | 10.40.1.120/29 | H / H / M | Hög | Central loggning och övervakning | Alla zoner utom Gäst (loggar), jump |
| **Server** *(planerad)* | 10.40.1.64/27 | M / H / H | Hög | Applikations- och driftservrar | DMZ, jump |
| **Data** *(planerad)* | 10.40.1.112/29 | H / H / H | Hög | Företagsdatabas och affärsdata | Server, jump |
| **Klient** *(planerad)* | 10.40.0.0/24 | M / M / M | Medel | Klientdatorer och användarkonton | Ingen |
| **Gäst** *(planerad)* | 10.40.1.0/26 | L / L / M | Medel | Besökare, isolerat, bara internet | Ingen |
| **Transit** | 10.40.1.136–.147 (Länk 1–3) | M / H / H | Hög | Routerlänkar och säkerhetsregler | Endast routrarna (konfigureras från Admin) |

H = hög, M = medel, L = låg.

**Admin och Logg är separata zoner:** loggarna ska vara bevis även mot administratörer, och DB-nätet ligger mellan dem i adressplanen så de kan inte slås ihop till ett prefix.

## 3. Flöden

Flödestabellen följer mallen i studieguiden för vecka 3. Radnumren (F1–F13) är desamma som i skissen; ett flöde med flera portar har en rad per port (a, b, c).

- **Riktning** = vem som öppnar anslutningen (skickar första paketet). Svaren släpps som etablerad trafik.
- **Filtreras var:** molnbrandväggen ser bara publik trafik – flöden inom det privata nätet filtreras bara på värden.

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering (verksamhetsfunktion) | Filtreras var | Belägg |
|---|---|---|---|---|---|---|---|---|
| F1 | Internet | DMZ (elevservrar) | TCP | 80 | Internet → DMZ | Besökare når webbplatsen. | Molnplattform + värden | `curl` 200 OK |
| F2 | Internet | Admin (jump) | TCP | 22 | Internet → jump | Administratörer når miljön – enda vägen in, bara nyckelinloggning. | Molnplattform + värden | jump är vägen in |
| F3 | Admin (jump) | DMZ (elevservrar) | TCP | 22 | jump → DMZ | Administrativ förvaltning av tilldelade elevservrar via SSH från jump. | Värden | `tcpdump`, `Last login from jump` |
| F4 | Admin (jump) | Logg (log, wazuh) | TCP | 22 | jump → Logg | Förvaltning av logg- och övervakningsservrar via SSH för utsedda administratörer. | Värden | `nmap -sV` |
| F5 | Admin (jump) | Logg (wazuh) | TCP | 443 | jump → wazuh | Granska och hantera larm i Wazuh-dashboarden. | Värden | `curl -kI` → `/app/login` |
| F6 | Admin (jump) | Server, Data | TCP | 22 | jump → Server, Data | Förvaltning av specificerade interna servrar och databasservrar via SSH för administratörer med motsvarande behörighet. | Värden | *planerad* |
| F7 | Alla zoner utom Gäst | Logg (log) | TCP (TLS) | 6514 | Källa → log | Central loggning – utan den kan vi inte visa vem som gjort vad. | Värden | 6514 öppen på log – verifieras med `nc` |
| F8 | DMZ | Server | TCP | 8080 | DMZ → Server | Portalen hämtar orderdata för att visa kundens ordrar. | Värden | *planerad* |
| F9 | Server | Data | TCP | 5432 | Server → Data | Appen läser och skriver kunddata åt portalen. | Värden | *planerad* |
| F10 | Klient | DMZ | TCP | 80 | Klient → DMZ | Personalen använder webbtjänsten. | Värden | *planerad* |
| F11a | DMZ, Admin, Logg, Server, Data | Internet (DNS) | UDP | 53 | Server → Internet | Namnuppslag – utan det fungerar inga uppdateringar. | Molnplattform (utgående) + värden | DNS i `/etc/resolv.conf` |
| F11b | DMZ, Admin, Logg, Server, Data | Internet (NTP) | UDP | 123 | Server → Internet | Rätt tid – loggarnas tidsstämplar måste gå att lita på. | Molnplattform (utgående) + värden | – |
| F11c | DMZ, Admin, Logg, Server, Data | Internet | TCP | 443 | Server → Internet | Säkerhetsuppdateringar av systemen. | Molnplattform (utgående) + värden | – |
| F12a | Klient, Gäst | Internet | TCP | 80, 443 | Klient/Gäst → Internet | Personal och besökare surfar. | Molnplattform + värden | *planerad* |
| F12b | Klient, Gäst | Internet (DNS) | UDP | 53 | Klient/Gäst → Internet | Namnuppslag för surfning. | Molnplattform + värden | *planerad* |
| F13 | ctf (utanför) | DMZ (elevservrar) | TCP | 22 | ctf → DMZ | Kursens labbkontroller av elevservrarna. | Värden | labbmiljöns krav – teamet bekräftar |

**Sist i tabellen:** ”Allt som inte står ovan är nekat, inkommande och utgående.”

**Exempel på nekat:**
- **DMZ → Data** – ett intrång på en elevserver når inte databasen.
- **DMZ → Admin** – en elevserver kan inte nå jump.
- **elev → elev** – ingen verksamhetsfunktion kräver det.
- **Gäst → interna zoner** – gäster når bara internet.
- **Logg → andra zoner** – loggservern tar emot men ansluter aldrig tillbaka.
- **TCP 514 och 80 på log** – ersätts av TLS på 6514.
- **TCP 9200 (wazuh)** – nås bara inom Logg-zonen.
- **Övrig utgående trafik** – t.ex. reverse shell eller exfiltrering stoppas.

### Begränsning av administrativ SSH-åtkomsten

SSH-åtkomst sker via jump-servern i Admin-zonen och begränsas enligt principen om minsta privilegium.

- Systemadministratörer får endast SSH-åtkomst till de elevservrar och interna servrar som de ansvarar för.
- Logg- och säkerhetsadministratörer får SSH-åtkomst till logg- och övervakningsservrarna när det behövs för deras arbetsuppgifter.
- Åtkomst till databasservrar begränsas till administratörer med ett dokumenterat behov.
- Administratörer använder individuella konton och nyckelbaserad autentisering. Behörigheter tilldelas utifrån arbetsuppgifter.
- SSH-regler begränsas till specifika målservrar där det är möjligt. Att en server kan nås från jump innebär inte automatiskt att alla administratörer har behörighet att logga in.

Rollerna ovan är designantaganden som behöver bekräftas vid implementation. De faktiska behörigheterna ska dokumenteras och konfigureras innan miljön tas i drift.

## 4. Öppna frågor

- Är TCP 6514 med TLS i drift på log, och kan 514 och 80 stängas? Verifieras med `nc` och `tshark`.
- Vad körs på TCP 9200 (wazuh)? Troligen Wazuh-indexeraren.
- Portarna 8080 och 5432 (F8, F9) är antaganden tills Server och Data finns.
- Jump har SSH till alla serverzoner (F3, F4, F6) – kan åtkomsten begränsas till de konton som behöver den?
- Ska F13 (ctf → elev) stå kvar? Bekräftas med teamet.
