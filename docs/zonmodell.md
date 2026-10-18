# Zonmodell – milstolpe 2

Underlag: `docs/adressplan.md`, tillgångsförteckningen (vecka 1). Skiss: `diagrams/zonskiss.png`.

## Förutsättningar

- Modellen visar **målbilden**. I dag är labbnätet platt och alla servrar når varandra.
- Subnäten är hämtade oförändrade från adressplanen (10.40.0.0/16, endast IPv4). Labbadresser (172.20.x.x) står bara i tillgångsförteckningen.
- All trafik mellan zoner går genom **brandväggen/routern**, som är ansluten via Transit-länkarna. Där tillämpas flödesreglerna.
- **Zero Trust:** allt som inte står i flödestabellen nekas.
- *Planerad* = zon utan tillgångar i labbet än. Klass och flöden där är teamets antagande.

## 1. Tillgångar

| Tillgång | Klass | Motivering | Zon (subnät) |
|---|---|---|---|
| jump | Hög | Den som tar över jump når alla servrar. | Admin (10.40.1.96/28) |
| log | Hög | Loggarna bevisar vem som gjort vad – uppdragsgivarens krav. | Logg (10.40.1.120/29) |
| wazuh | Hög | Manipuleras den syns inga angrepp. | Logg (10.40.1.120/29) |
| elevservrar (elev-NN) | Medel | Ingen känslig data, men tjänsterna stannar om de faller. Nås från internet, därför DMZ. | DMZ (10.40.1.128/29) |
| ctf | – | Kursens övningsserver, ingår inte i uppdragsgivarens miljö. | Utanför |

## 2. Zoner

| Zon | Subnät | Klass | Syfte | Får nås av |
|---|---|---|---|---|
| **DMZ** | 10.40.1.128/29 | Medel | Tjänster mot internet | Internet, Klient (HTTP), Admin (SSH) |
| **Admin** | 10.40.1.96/28 | Hög | Enda vägen in för administration | Internet (SSH till jump) |
| **Logg** | 10.40.1.120/29 | Hög | Central loggning och övervakning | Alla zoner utom Gäst (loggar), Admin (SSH, dashboard) |
| **Server** *(planerad)* | 10.40.1.64/27 | Medel | Interna tjänster | DMZ, Admin |
| **Data** *(planerad)* | 10.40.1.112/29 | Hög | Databaser | Server, Admin |
| **Klient** *(planerad)* | 10.40.0.0/24 | Låg | Arbetsplatser | Ingen |
| **Gäst** *(planerad)* | 10.40.1.0/26 | Låg | Besökare, bara internet | Ingen |
| **Transit** | 10.40.1.136–.147 (Länk 1–3) | – | Länkar mellan routrar/brandvägg | Endast routrarna |

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
