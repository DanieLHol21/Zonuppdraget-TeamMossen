# Zonmodell – milstolpe 2

Underlag: `docs/adressplan.md`, tillgångsförteckningen (vecka 1) och teamets klassificering. Skiss: `diagrams/zonskiss.png`.

## Förutsättningar

- Modellen visar **målbilden**. I dag är labbnätet platt och alla servrar når varandra.
- Subnäten är hämtade oförändrade från adressplanen (10.40.0.0/16, endast IPv4). Labbadresser (172.20.x.x) står bara i tillgångsförteckningen.
- All trafik mellan zoner går genom **brandväggen/routern** (ansluten via Transit), där flödesreglerna tillämpas.
- **Zero Trust:** allt som inte står i flödestabellen nekas.
- **Klass:** varje zon bedöms på **K**onfidentialitet (obehöriga ser), **R**iktighet (data ändras) och **T**illgänglighet (går inte att nå). Skyddsklassen är det högsta av de tre.
- *Planerad* = zon utan tillgångar i labbet än. Flöden där är teamets antagande.

## 1. Tillgångar

| Tillgång | Klass | Motivering | Zon (subnät) |
|---|---|---|---|
| jump | Hög | Omfattande behörigheter – den som tar över jump når alla servrar. | Admin (10.40.1.96/28) |
| log | Hög | Loggarna bevisar vem som gjort vad och måste gå att lita på. | Logg (10.40.1.120/29) |
| wazuh | Hög | Manipuleras den syns inga angrepp. | Logg (10.40.1.120/29) |
| elevservrar (elev-NN) | Hög | Exponerade mot internet – driftstopp eller manipulation syns direkt. | DMZ (10.40.1.128/29) |
| ctf | – | Kursens övningsserver, ingår inte i uppdragsgivarens miljö. | Utanför |

## 2. Zoner

| Zon | Subnät | K / R / T | Klass | Syfte | Får nås av |
|---|---|---|---|---|---|
| **DMZ** | 10.40.1.128/29 | M / H / H | Hög | Publika tjänster | Internet, Klient (HTTP), Admin (SSH) |
| **Admin** | 10.40.1.96/28 | H / H / H | Hög | Adminkonton och verktyg, enda vägen in | Internet (SSH till jump) |
| **Logg** | 10.40.1.120/29 | H / H / M | Hög | Central loggning och övervakning | Alla zoner utom Gäst (loggar), Admin |
| **Server** *(planerad)* | 10.40.1.64/27 | M / H / H | Hög | Applikations- och driftservrar | DMZ, Admin |
| **Data** *(planerad)* | 10.40.1.112/29 | H / H / H | Hög | Företagsdatabas och affärsdata | Server, Admin |
| **Klient** *(planerad)* | 10.40.0.0/24 | M / M / M | Medel | Klientdatorer och användarkonton | Ingen |
| **Gäst** *(planerad)* | 10.40.1.0/26 | L / L / M | Medel | Besökare, isolerat, bara internet | Ingen |
| **Transit** | 10.40.1.136–.147 (Länk 1–3) | M / H / H | Hög | Routerlänkar och säkerhetsregler | Endast routrarna (konfigureras från Admin) |

H = hög, M = medel, L = låg.

**Admin och Logg är separata zoner:** loggarna ska vara bevis även mot administratörer, och DB-nätet ligger mellan dem i adressplanen så de kan inte slås ihop till ett prefix.

## 3. Flöden

| # | Från → Till | Port | Syfte | Belägg |
|---|---|---|---|---|
| F1 | Internet → DMZ | TCP 80 | Webbtjänster | `curl` 200 OK |
| F2 | Internet → Admin (jump) | TCP 22, bara nyckel | Vägen in | jump är vägen in |
| F3 | Admin → DMZ | TCP 22 | Administration | `tcpdump` |
| F4 | Admin → Logg | TCP 22, 443 | Administration, Wazuh-dashboard | `nmap -sV` |
| F5 | Admin → Server, Data | TCP 22 | Administration | *planerad* |
| F6 | Alla zoner utom Gäst → log | TCP 514 | Central loggning | `nc` (tjänst ej verifierad) |
| F7 | DMZ → Server | app-port | Interna tjänster | *planerad* |
| F8 | Server → Data | db-port | Data | *planerad* |
| F9 | Klient → DMZ | TCP 80 | Webben | *planerad* |
| F10 | Klient, Gäst → Internet | – | Surfa ut | *planerad* |

**Nekas:** DMZ → Data (intrång på elevserver når inte databasen) · DMZ → Admin · Gäst → interna zoner · Logg → andra zoner (tar emot, ansluter aldrig tillbaka) · TCP 9200 nås bara inom Logg.

## 4. Öppna frågor

- Tjänsterna på TCP 514 (log) och 9200 (wazuh) är inte verifierade.
- Portar för Server och Data (F7, F8) bestäms senare.
- Trafik mellan elevservrar inom DMZ hanteras i vecka 3.
