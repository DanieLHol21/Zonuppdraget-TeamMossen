Tillgångsförteckning
--------

Denna tillgångsförteckning beskriver labbmiljön som den är i dag.
Alla servrar, adresser, tjänster och belägg är baserade på faktisk verifiering i labben.


**Studentservrar**
| Namn | Roll |	Adress |	Tjänster |	Belägg |
|----|----|----|----|----|
| elev-12 |	Studentserver |	172.20.1.112 |	SSH (22), HTTP (80)	| ss -tuln visar port 22 och 80 öppna. curl localhost ger HTTP‑svar. IP är dynamic via DHCP. |


**Gemensamma servrar**
| Namn |	Roll |	Adress |	Tjänster |	Belägg |
|---|---|---|---|---|
| jump |	Bastion/jump-server |	172.20.1.2 |	SSH (22) |	nmap -sV visar port 22 öppen. nslookup ger NXDOMAIN. |
| ctf |	Övningsserver	| 172.20.1.10	| Inga öppna portar	| nmap -sV visar inga tjänster. nslookup ger NXDOMAIN. |
| 172.20.1.21	| Okänd server	| 172.20.1.21	| Inga öppna portar	| nmap -sV visar inga tjänster. nslookup ger NXDOMAIN. |
| log	| Loggserver	| 172.20.1.58	| Inga öppna portar |	nmap -sV visar inga tjänster. nslookup ger NXDOMAIN. |
-------

**DNS och IP-adresser**
- nslookup på samtliga gemensamma servrar gav NXDOMAIN.
- DNS-servern saknar A‑poster för dessa IP‑adresser.
- Detta är en faktisk observation i labbmiljön.
------

**DHCP-tilldelning**
- Studentservern elev-12 har en dynamisk IP-adress enligt ip a.
- Detta visar att DHCP används i studentnätet.
------

**Adressplan (verklig labbmiljö)**
| Zon |	Nätadress |	Syfte |
|---|---|---|
| Studentzon |	172.20.1.0/24	| Studentservrar (elev‑00 → elev‑46) |
| Gemensam zon |	172.20.1.0/24 |	Jump, CTF, Loggserver, okänd server |
| Extern/NAT | 2.x.x.x (eth0)	| Utgående trafik från studentservrar |


**Att verifiera i labben**
| Kontrollpunkt | Kommando |	Förväntat resultat |
|----|----|----|
| DNS‑uppslag	| nslookup "server" | DNS‑post (saknas idag) |
| DHCP‑tilldelning |	ip a |	Adress markerad som dynamic |
| Jump‑server SSH	| ssh 172.20.1.2 |	Inloggningsprompt |
| Loggserver | telnet 172.20.1.58 514	| Eventuellt syslog‑svar |
| Brandväggsregler | sudo iptables -L	| Tillåter SSH/HTTP |
