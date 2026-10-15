# Tillgångsförteckning

Jag har undersökt labbmiljön från min egen server, elev-12. Allt nedan har jag kontrollerat med kommandon. Det jag inte har kunnat bekräfta står som "ej verifierat".

## 1. Nätet

- Internt nät: 172.20.0.0/16 via gateway 172.20.0.1 på eth1. (`ip route`, `nmcli device show eth1`)
- Min server har adressen 172.20.1.112/32. Alla servrar har /32, så jag vet inte hur nätet delas i subnät.
- eth0 har adressen 2.28.98.110/32 och default gateway 172.31.1.1. (`ip a`, `ip route`)
- Internet fungerar via eth0. (`ping -c 2 1.1.1.1` gav svar)
- Uppdragsgivarens planerade adressutrymme är 10.40.0.0/16. IPv6 är avstängt på labbservrarna.

## 2. Tillgångar

| Namn | Roll | Adress | Tjänster | Klass (förslag) | Subnät | Varför den klassen |
|---|---|---|---|---|---|---|
| jump | Jump-server, vägen in till labbet | 172.20.1.2 | SSH (22) | Hög | (fylls i) | Den som tar över jump når alla servrar. |
| log | Loggserver | 172.20.1.58 | SSH (22), HTTP (80), TCP 514 | Hög | (fylls i) | Loggarna är beviset på vem som gjort vad. |
| wazuh | Säkerhetsövervakning (Wazuh-dashboard) | 172.20.1.21 | SSH (22), HTTPS (443), HTTPS (9200) | Hög | (fylls i) | Den larmar om intrång, så den får inte kunna manipuleras. |
| elev-12 | Min studentserver | 172.20.1.112 | SSH (22), HTTP (80) | Medel | (fylls i) | Nås från internet utan brandvägg, men har ingen känslig data. |
| ctf | Övningsserver | 172.20.1.10 | SSH (22), HTTP (8081) | Låg | (fylls i) | Bara en övningsmiljö utan riktig data. |

Klasserna är förslag som teamet ska bekräfta.

## 3. Belägg per tillgång

**jump**
- `ping` fick svar.
- `nmap -sV` visade bara port 22 öppen.
- `ssh` från min server fick `Permission denied` eftersom elev-12 saknar nyckel mot jump.

**log**
- `ping` fick svar.
- `nmap -sV` visade port 22, 80 och 514 öppna.
- `nmap -Pn -sT -p 514 --reason` visade att TCP 514 är öppen. Nmap kallar den "shell", men det är bara standardnamnet för portnumret.
- `nc -zv 172.20.1.58 514` gav `Connected`, men ingen text kom tillbaka.
- `nmap -sU -p 514` visade att UDP 514 är stängd.
- `getent hosts log.sec.chas-lab.dev` gav 46.224.108.117 (en publik adress via DNS).

**wazuh (172.20.1.21)**
- `ping` fick svar.
- `nmap -sV` visade port 22, 443 och 9200 öppna.
- `curl -kI https://172.20.1.21` gav `302 Found` till `/app/login` med headern `osd-name: wazuh`. Det är en Wazuh-dashboard.
- `curl -k https://172.20.1.21:9200` svarade `Unauthorized`, så porten kräver inloggning.

**elev-12**
- `ss -tuln` visade port 22 och 80.
- `curl -I http://localhost` gav 200 OK.
- `nft list ruleset` var tomt och `iptables -L` visade inga regler, så ingen brandvägg är aktiv.
- `Last login ... from 172.20.1.2` visade att en inloggning kom från jump.

**ctf**
- `ping` fick svar.
- `nmap -sV` visade port 22 och 8081 öppna, och 8081 svarade med HTTP.

## 4. Trafik jag har sett

| Från | Till | Port | Belägg |
|---|---|---|---|
| jump | elev-12 | TCP 22 | `tcpdump` visade SSH-paket mellan 172.20.1.2 och 172.20.1.112 i båda riktningarna. |
| elev-12 | jump, ctf, log, wazuh | ICMP | `ping` fick svar från alla. |
| elev-12 | ctf, log, wazuh | olika portar | `nmap` visade att portarna är öppna. |

Öppna portar visar bara att en tjänst lyssnar. Det är `tcpdump` som visar att trafiken faktiskt används.

## 5. Adresser och namn

- Båda adresserna på elev-12 är markerade `dynamic` i `ip a`, alltså DHCP. Jag vet inte vilken server som delar ut dem. `nmcli` hjälpte inte, eftersom eth1 är `unmanaged`.
- DNS-servrar: 185.12.64.1 och 185.12.64.2 (`/etc/resolv.conf`).
- `nslookup` gav NXDOMAIN för jump, ctf och log. Namnen fungerar ändå via `/etc/hosts` (`getent hosts jump ctf log`).
- DNS-zonen är sec.chas-lab.dev. Wazuh-servern saknar namn.

## 6. Ej verifierat

- Vilken tjänst som körs på TCP 514 på log.
- Vad som körs på port 9200 (troligen Wazuh-indexeraren).
- Vilken DHCP-server som delar ut adresserna.
- Hur nätet delas i subnät.
- Jag har bara skannat de 1000 vanligaste TCP-portarna, och bara UDP 514.

## 7. Kvar att göra

- Fylla i subnät för varje tillgång från `adressplan.md`.
-
