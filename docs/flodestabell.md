# Flödestabell – avsnitt 3 i zonmodellen

Flödestabellen följer mallen i studieguiden för vecka 3. Varje rad är **ett** protokoll och **en** port mellan ett bestämt mål och en eller flera namngivna källor – en rad blir en regel i vecka 4. Står flera zoner i samma rad gäller samma regel på var och en av dem. Radnumren hör ihop med pilarna i skissen (F1–F14); a, b, c … är delflöden av samma pil.

- **Riktning** = vem som öppnar anslutningen (skickar första paketet). Svaren släpps som etablerad trafik, även för UDP.
- **Filtreras var – och varför:** molnbrandväggen ser bara trafik som passerar den publika adressen. Flöden inom det privata nätet filtreras **bara på värden**, eftersom de aldrig passerar molnbrandväggen.
- **Port:** portnummer med tjänstnamn enligt IANA-registret (RFC 6335).
- **Status:** **Verifierat** = testat i labbet · **Stäms av** = porten är öppen men användningen ska bekräftas mot trafikbaslinjen · *Planerad* = zonen finns inte i labbet än.

| Rad | Källzon | Målzon | Protokoll | Port | Riktning | Motivering (verksamhetsfunktion) | Filtreras var | Status / belägg |
|---|---|---|---|---|---|---|---|---|
| F1 | Internet | DMZ (elevservrar) | TCP | 80 (http) | Internet → DMZ | Besökare når webbplatsen. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: `curl` 200 OK |
| F2 | Internet | Admin (jump) | TCP | 22 (ssh) | Internet → jump | Administratörer når miljön – enda vägen in, bara nyckelinloggning. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: jump är vägen in |
| F3 | Admin (jump) | DMZ (elevservrar) | TCP | 22 (ssh) | jump → DMZ | Förvaltning och uppdatering av elevservrarna. Bara driftens personliga konton, med nyckel. | Värden – privat nät, molnbrandväggen ser inte trafiken | Verifierat: `tcpdump`, `Last login from jump` |
| F4a | Admin (jump) | Logg (log) | TCP | 22 (ssh) | jump → log | Förvaltning av loggservern. Bara ett separat loggadmin-konto, med nyckel – drift når inte loggarna. | Värden – privat nät, molnbrandväggen ser inte trafiken | Stäms av: bara öppen port (`nmap`) – används det? |
| F4b | Admin (jump) | Logg (wazuh) | TCP | 22 (ssh) | jump → wazuh | Förvaltning av övervakningsservern. Bara loggadmin-kontot, med nyckel. | Värden – privat nät, molnbrandväggen ser inte trafiken | Stäms av: bara öppen port (`nmap`) – används det? |
| F5 | Admin (jump) | Logg (wazuh) | TCP | 443 (https) | jump → wazuh | Driftpersonalen ser och hanterar intrångslarm – utan flödet syns inga larm. | Värden – privat nät, molnbrandväggen ser inte trafiken | Stäms av: `curl -kI` → `/app/login` – vem använder det? |
| F6a | Admin (jump) | Server | TCP | 22 (ssh) | jump → Server | Förvaltning av applikations- och driftservrarna. Bara driftens personliga konton, med nyckel. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F6b | Admin (jump) | Data | TCP | 22 (ssh) | jump → Data | Förvaltning av databasen. Bara databasadministratörens konto, med nyckel. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F7a | DMZ (elevservrar) | Logg (log) | TCP (TLS) | 6514 (syslog-tls) | DMZ → log | Central loggning – vi måste kunna visa vem som gjort vad på de publika tjänsterna. | Värden – privat nät, molnbrandväggen ser inte trafiken | Verifierat: `nc -zv` → Connected · `openssl s_client` → TLSv1.2, cert CN=log.sec.chas-lab.dev från ITSX26 labb-CA, servern begär klientcertifikat |
| F7b | Admin (jump) | Logg (log) | TCP (TLS) | 6514 (syslog-tls) | jump → log | Central loggning av all administration. | Värden – privat nät, molnbrandväggen ser inte trafiken | Verifierat: `timeout 3 bash -c "</dev/tcp/172.20.1.58/6514"` på jump → öppen |
| F7c | Server | Logg (log) | TCP (TLS) | 6514 (syslog-tls) | Server → log | Central loggning av driftservrarna. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F7d | Data | Logg (log) | TCP (TLS) | 6514 (syslog-tls) | Data → log | Central loggning av åtkomst till affärsdata. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F7e | Klient | Logg (log) | TCP (TLS) | 6514 (syslog-tls) | Klient → log | Central loggning av inloggningar på klienterna. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F8 | DMZ | Server | TCP | 8080 (http-alt) | DMZ → Server | Portalen hämtar orderdata för att visa kundens ordrar. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* (port antagen) |
| F9 | Server | Data | TCP | 5432 (postgresql) | Server → Data | Appen läser och skriver kunddata åt portalen. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* (port antagen) |
| F10 | Klient | DMZ | TCP | 80 (http) | Klient → DMZ | Personalen använder webbtjänsten. | Värden – privat nät, molnbrandväggen ser inte trafiken | *Planerad* |
| F11a | DMZ, Admin, Logg, Server, Data | Internet: DNS-resolvrar 185.12.64.1, 185.12.64.2 | UDP | 53 (domain) | Server → resolver | Namnuppslag – utan det fungerar inga uppdateringar. | Molnplattform (utgående) + värden – går ut via den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: `/etc/resolv.conf` |
| F11b | DMZ, Admin, Logg, Server, Data | Internet: DNS-resolvrar 185.12.64.1, 185.12.64.2 | TCP | 53 (domain) | Server → resolver | Namnuppslag med stora svar. | Molnplattform (utgående) + värden – går ut via den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: `/etc/resolv.conf` |
| F11c | DMZ, Admin, Logg, Server, Data | Internet: ntp.hetzner.com | UDP | 123 (ntp) | Server → tidsserver | Rätt tid – loggarnas tidsstämplar måste gå att lita på. | Molnplattform (utgående) + värden – går ut via den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: `/etc/chrony.conf`, `chronyc sources` |
| F11d | DMZ, Admin, Logg, Server | Internet: mirrors.rockylinux.org och speglarna den anvisar | TCP | 443 (https) | Server → paketförråd | Säkerhetsuppdateringar av systemen. Data uppdateras inte direkt mot internet (se öppna frågor). | Molnplattform (utgående) + värden – går ut via den publika adressen, så molnet kan filtrera; värden som andra lager | Verifierat: `/etc/yum.repos.d/*.repo` – bara https |
| F12a | Klient | Internet | TCP | 443 (https) | Klient → Internet | Personalen använder webbtjänster i arbetet. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F12b | Klient | Internet | TCP | 80 (http) | Klient → Internet | Personalen når webbplatser utan kryptering. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F12c | Klient | Internet: DNS-resolvrar (bestäms) | UDP | 53 (domain) | Klient → resolver | Namnuppslag för klienterna. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F12d | Gäst | Internet | TCP | 443 (https) | Gäst → Internet | Besökare surfar. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F12e | Gäst | Internet | TCP | 80 (http) | Gäst → Internet | Besökare når webbplatser utan kryptering. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F12f | Gäst | Internet: DNS-resolvrar (bestäms) | UDP | 53 (domain) | Gäst → resolver | Namnuppslag för besökare. | Molnplattform + värden – passerar den publika adressen, så molnet kan filtrera; värden som andra lager | *Planerad* |
| F13a | ctf 172.20.1.10 (utanför) | DMZ (elevservrar) | TCP | 22 (ssh) | ctf → DMZ | Kursens labbkontroller av inloggningen. | Värden – privat nät, molnbrandväggen ser inte trafiken | Verifierat: lärarens exempel (föreläsning 8); ingen session i `last` – kontrollen öppnar bara anslutningen |
| F13b | ctf 172.20.1.10 (utanför) | DMZ (elevservrar) | TCP | 80 (http) | ctf → DMZ | Kursens labbkontroll av webbservern över det interna nätet (U3.4). | Värden – privat nät, molnbrandväggen ser inte trafiken | Verifierat: krav i U3.4 |
| F14 | Admin (jump) | DMZ, Logg, Server, Data | ICMP | echo (typ 8) | jump → zon | Felsökning – kontrollera att en server svarar. Bara från jump. | Värden – privat nät, molnbrandväggen ser inte trafiken | Beslutat: föreläsning 8, ICMP för felsökning |

**Nekanderegel (sist i tabellen):** ”Allt som inte står ovan är nekat – inkommande och utgående, både i molnbrandväggen och på värden.”

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
