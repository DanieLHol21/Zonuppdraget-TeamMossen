# Flödestabell – avsnitt 3 i zonmodellen

Flödestabellen följer mallen i studieguiden för vecka 3. Varje rad är **ett** protokoll och **en** port mellan ett bestämt mål och en eller flera namngivna källor – en rad blir en regel i vecka 4. Står flera zoner i samma rad gäller samma regel på var och en av dem. Radnumren hör ihop med pilarna i skissen (F1–F14); a, b, c … är delflöden av samma pil.

- **Riktning** = vem som öppnar anslutningen (skickar första paketet). Svaren släpps som etablerad trafik, även för UDP.
- **Filtreras var:** molnbrandväggen ser bara publik trafik. Flöden inom det privata nätet filtreras **bara på värden**.
- **Status:** Är verifierat i labbet · Men stäms av (Person 3 = baslinjen, teamet = beslut) · *planerad* = zonen finns inte i labbet än.

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering (verksamhetsfunktion) | Filtreras var | Status / belägg |
|---|---|---|---|---|---|---|---|---|
| F1 | Internet | DMZ (elevservrar) | TCP | 80 | Internet → DMZ | Besökare når webbplatsen. | Molnplattform + värden | `curl` 200 OK |
| F2 | Internet | Admin (jump) | TCP | 22 | Internet → jump | Administratörer når miljön – enda vägen in, bara nyckelinloggning. | Molnplattform + värden | jump är vägen in |
| F3 | Admin (jump) | DMZ (elevservrar) | TCP | 22 | jump → DMZ | Förvaltning och uppdatering av elevservrarna. | Värden | `tcpdump`, `Last login from jump` |
| F4a | Admin (jump) | Logg (log) | TCP | 22 | jump → log | Förvaltning av loggservern. | Värden | bara öppen port (`nmap`) – används det? |
| F4b | Admin (jump) | Logg (wazuh) | TCP | 22 | jump → wazuh | Förvaltning av övervakningsservern. | Värden | bara öppen port (`nmap`) – används det? |
| F5 | Admin (jump) | Logg (wazuh) | TCP | 443 | jump → wazuh | Driftpersonalen ser och hanterar intrångslarm – utan flödet syns inga larm. | Värden | `curl -kI` → `/app/login` – vem använder det? |
| F6a | Admin (jump) | Server | TCP | 22 | jump → Server | Förvaltning av applikations- och driftservrarna. | Värden | *planerad* |
| F6b | Admin (jump) | Data | TCP | 22 | jump → Data | Förvaltning av databasen. | Värden | *planerad* |
| F7a | DMZ (elevservrar) | Logg (log) | TCP (TLS) | 6514 | DMZ → log | Central loggning – vi måste kunna visa vem som gjort vad på de publika tjänsterna. | Värden | `nc -zv` → Connected · `openssl s_client` → TLSv1.2, cert CN=log.sec.chas-lab.dev från ITSX26 labb-CA, servern begär klientcertifikat |
| F7b | Admin (jump) | Logg (log) | TCP (TLS) | 6514 | jump → log | Central loggning av all administration. | Värden | `timeout 3 bash -c "</dev/tcp/172.20.1.58/6514"` på jump → öppen |
| F7c | Server | Logg (log) | TCP (TLS) | 6514 | Server → log | Central loggning av driftservrarna. | Värden | *planerad* |
| F7d | Data | Logg (log) | TCP (TLS) | 6514 | Data → log | Central loggning av åtkomst till affärsdata. | Värden | *planerad* |
| F7e | Klient | Logg (log) | TCP (TLS) | 6514 | Klient → log | Central loggning av inloggningar på klienterna. | Värden | *planerad* |
| F8 | DMZ | Server | TCP | 8080 | DMZ → Server | Portalen hämtar orderdata för att visa kundens ordrar. | Värden | *planerad* (port antagen) |
| F9 | Server | Data | TCP | 5432 | Server → Data | Appen läser och skriver kunddata åt portalen. | Värden | *planerad* (port antagen) |
| F10 | Klient | DMZ | TCP | 80 | Klient → DMZ | Personalen använder webbtjänsten. | Värden | *planerad* |
| F11a | DMZ, Admin, Logg, Server, Data | Internet: DNS-resolvrar 185.12.64.1, 185.12.64.2 | UDP | 53 | Server → resolver | Namnuppslag – utan det fungerar inga uppdateringar. | Molnplattform (utgående) + värden | `/etc/resolv.conf` |
| F11b | DMZ, Admin, Logg, Server, Data | Internet: DNS-resolvrar 185.12.64.1, 185.12.64.2 | TCP | 53 | Server → resolver | Namnuppslag med stora svar. | Molnplattform (utgående) + värden | `/etc/resolv.conf` |
| F11c | DMZ, Admin, Logg, Server, Data | Internet: ntp.hetzner.com | UDP | 123 | Server → tidsserver | Rätt tid – loggarnas tidsstämplar måste gå att lita på. | Molnplattform (utgående) + värden | `/etc/chrony.conf`, `chronyc sources` |
| F11d | DMZ, Admin, Logg, Server | Internet: mirrors.rockylinux.org och speglarna den anvisar | TCP | 443 | Server → paketförråd | Säkerhetsuppdateringar av systemen. Data uppdateras inte direkt mot internet (se öppna frågor). | Molnplattform (utgående) + värden | `/etc/yum.repos.d/*.repo` – bara https |
| F12a | Klient | Internet | TCP | 443 | Klient → Internet | Personalen använder webbtjänster i arbetet. | Molnplattform + värden | *planerad* |
| F12b | Klient | Internet | TCP | 80 | Klient → Internet | Personalen når webbplatser utan kryptering. | Molnplattform + värden | *planerad* |
| F12c | Klient | Internet: DNS-resolvrar (bestäms) | UDP | 53 | Klient → resolver | Namnuppslag för klienterna. | Molnplattform + värden | *planerad* |
| F12d | Gäst | Internet | TCP | 443 | Gäst → Internet | Besökare surfar. | Molnplattform + värden | *planerad* |
| F12e | Gäst | Internet | TCP | 80 | Gäst → Internet | Besökare når webbplatser utan kryptering. | Molnplattform + värden | *planerad* |
| F12f | Gäst | Internet: DNS-resolvrar (bestäms) | UDP | 53 | Gäst → resolver | Namnuppslag för besökare. | Molnplattform + värden | *planerad* |
| F13a | ctf 172.20.1.10 (utanför) | DMZ (elevservrar) | TCP | 22 | ctf → DMZ | Kursens labbkontroller av inloggningen. | Värden | lärarens exempel (föreläsning 8); ingen session i `last` – kontrollen öppnar bara anslutningen |
| F13b | ctf 172.20.1.10 (utanför) | DMZ (elevservrar) | TCP | 80 | ctf → DMZ | Kursens labbkontroll av webbservern över det interna nätet (U3.4). | Värden | krav i U3.4 |
| F14 | Admin (jump) | DMZ, Logg, Server, Data | ICMP | echo (typ 8) | jump → zon | Felsökning – kontrollera att en server svarar. Bara från jump. | Värden | beslutat – föreläsning 8: ICMP för felsökning |

**Sist i tabellen:** ”Allt som inte står ovan är nekat, inkommande och utgående.”

**Exempel på nekat:**
- **DMZ → Data** – ett intrång på en elevserver når inte databasen.
- **Data → Internet, utom DNS och NTP (F11a–c)** – databasen med hög klass får ingen väg ut på tcp/443 eller andra portar (skydd mot exfiltrering).
- **DMZ → Admin** – en elevserver kan inte nå jump.
- **elev → elev** – ingen verksamhetsfunktion kräver det.
- **Gäst → interna zoner** – gäster når bara internet. Gäst skickar inte heller loggar till log.
- **Logg → andra zoner** – loggservern tar emot men ansluter aldrig tillbaka.
- **TCP 514 och 80 på log** – ersätts av TLS på 6514.
- **TCP 9200 (wazuh)** – nekas från andra zoner (ej verifierat vad som körs på porten).
- **Övrig utgående trafik** – t.ex. reverse shell eller exfiltrering stoppas.
