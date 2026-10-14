# Adressplan och tillgångsförteckning

Labbmiljön undersökt i min studentserver. Alla uppgifter kommer från kommandon som jag körde själv, och beläggen står i tabellerna. Detta är en tydlig beskrivning av min labbmiljö.

## 1. Nätverk och adressområde

- Internt nät: 172.20.0.0/16 via gateway 172.20.0.1 på eth1. Gatewayen svarar på ping. Belägg: `ip route`, `ping`.
- Servrarna ligger i 172.20.1.x. Adresserna är /32, så hur nätet är uppdelat i subnät har jag inte verifierat.
- eth0: 2.28.98.110/32 med default gateway 172.31.1.1. Belägg: `ip a`, `ip route`.

## 2. Servrar

| Namn | Roll | Adress | Tjänster | Belägg |
|---|---|---|---|---|
| elev-12 | Studentserver | 172.20.1.112 (eth1), 2.28.98.110 (eth0) | SSH (22), webbserver (80) | `ss -tuln` visar port 22 och 80, `curl -I http://localhost` ger 200 OK |
| jump | Jump-server | 172.20.1.2 | SSH (22) | `nmap -sV` visar bara port 22 öppen |
| ctf | Övningsserver | 172.20.1.10 | SSH (22), webbtjänst (8081) | `nmap -sV` visar port 22 och 8081 öppna, 8081 svarar med HTTP |
| (namn saknas) | Okänd, kanske övervakning? | 172.20.1.21 | SSH (22), HTTPS (443), HTTPS (9200) | `nmap -sV` visar portarna öppna |
| log | Loggserver | 172.20.1.58 | SSH (22), webbserver (80), TCP 514 (okänd tjänst) | `nmap -sV` visar port 22, 80 och 514 öppna, UDP 514 är stängd (`nmap -sU`) |

- Alla servrar svarade på `ping`.
- Brandvägg på elev-12: ingen aktiv (`nft list ruleset` är tomt och `iptables -L` visar inga regler).
- Jump tar emot SSH-inloggning, men jag fick `Permission denied` eftersom elev-12 saknar SSH-nyckel.
- elev-00 till elev-46 finns i `/etc/hosts`, men har bara kontrollerat mig själv (elev-12).

## 3. Hur IP-adresserna tilldelas

- Båda adresserna på elev-12 är markerade `dynamic` i `ip a`, så de tilldelas via DHCP.
- Jag vet inte vilken DHCP-server som tilldelar dem.

## 4. Hur DNS och IP-adresser hänger ihop

- DNS-servrarna är 185.12.64.1 och 185.12.64.2 (`/etc/resolv.conf`). De gav NXDOMAIN för jump, ctf och log, både för namn och omvända uppslag (`nslookup`).
- Namnen fungerar ändå via `/etc/hosts` (`getent hosts jump ctf log`). Adressen 172.20.1.21 saknar namn.

## 5. Begränsningar och det som återstår att verifiera

Begränsningar: kontrollerna är gjorda från elev-12. Jag skannade de 1000 vanligaste TCP-portarna och UDP bara på port 514.

| Att verifiera | Hur |
|---|---|
| Vad 172.20.1.21 är | Ej verifierat |
| Vad som körs på TCP 514 på log | Ej verifierat |
| DNS-zonens domännamn | Ej verifierat |
| DHCP-server | `nmcli device show eth1` |
| Internet via eth0 | `ping -c 2 1.1.1.1` |
