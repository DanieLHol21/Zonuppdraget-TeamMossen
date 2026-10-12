Adressplan
-----
**Interna nätverket och adressområden**

Det interna nätverket är uppdelat i zoner för att roller ska vara separerade och minska attackytan.
| Zon | Nätadress | Syfte |
|----|----|----|
| Studentzon | 10.0.10.0/24 | Studentservrar |
| Gemensam zon | 10.0.20.0/24 | DNS, DHCP, AD, gemensamma tjänster |
| Säkerhetszon | 10.0.30.0/24 | Brandvägg, IDS/IPS |
| Backupzon | 10.0.40.0/24 | Backup och lagring |
------

**IP-adresser och DNS-namn för servrar**

Här dokumenteras både studentservrar och gemensamma servrar.

**Gemensamma servrar**
| Server | IP-adress | DNS-namn | Roll |
|----|----|----|----|
| dns-01 | 10.0.20.10 | dns.team.local | Namnupplösning |
| dhcp-01 | 10.0.20.11 | dhcp.team.local | IP-tilldelning |
| ad-01 | 10.0.20.12 | ad.team.local | Directory Services |
| firewall-01 | 10.0.30.1 | fw.team.local | Brandvägg/routing |
-----

**Studentservrar** 
| Server | IP-adress | DNS-namn | Roll |
|----|----|----|----|
| elev01 | 10.0.10.101 | elev01.student.local | Studentserver |
| elev02 | 10.0.10.102 | elev02.student.local | Studentserver |
| elev03 | 10.0.10.103 | elev03.student.local | Studentserver |
-----

**Hur studentservrarnas IP-adresser tilldelas**
Studentservrarna får sina IP-adresser via DHCP-servern (dhcp-01).

Tilldelningen sker genom:
- Statisk DHCP-reservation baserat på MAC-adress
- Varje studentserver får en fast IP inom 10.0.10.0/24
- DHCP-servern hanterar även gateway och DNS-inställningar
- Exempel:

MAC: 00:16:3e:ab:cd:01
Tilldelad IP: 10.0.10.101
DNS: 10.0.20.10
Gateway: 10.0.10.1


**Hur DNS och IP-adresser hänger ihop**

DNS-servern (dns-01) hanterar zonerna:
- team.local (gemensamma server)
- student.local (studentservrar)

Varje server har: 
- A-post > DNS-namn > IP-adress
- PTR-post > IP-adress > DNS-namn (omvänd)
- Exempel:

A-post: web01.student.local → 10.0.10.5
PTR-post: 10.0.10.5 → web01.student.local

DNS används för:
- Namnuppslagning mellan servrar
- Loggning och spårbarhet
- Automatisering och konfigurationshantering
----




