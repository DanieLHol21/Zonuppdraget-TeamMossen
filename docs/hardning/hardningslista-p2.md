# Härdningslista – person 2: tjänster och portar (elev-12)

Rrezart Binaku · Vecka 7 · Rocky Linux 9, SELinux targeted · Verifieringsskript: `scripts/verifiera-hardning-p2.sh`

## Inventering (17/11)

| Port | Tjänst | Finns i flödestabellen? | Bedömning |
|---|---|---|---|
| tcp/22 | sshd | F3 (jump), F13a (ctf) | Behövs – enda vägen in för förvaltning |
| tcp/80 | httpd | F1 (internet), F13b (ctf) | Behövs – webbplatsen och kursens webbkontroll |
| tcp/7512 | zonvakt | F13c (ctf) – ny vecka 7 | Behövs – kursens tjänst under egen SELinux-policy |

Kommando: `sudo ss -tlnp`. Inga andra tjänster lyssnar. Varje lyssnande port har en rad i flödestabellen.

### Tjänster som körs (systemctl, 19/11)

`systemctl list-units --type=service --state=running` och `systemctl is-enabled sshd httpd zonvakt` (→ enabled, enabled, enabled):

| Tjänst | Varför den behövs |
|---|---|
| sshd, httpd, zonvakt | De tre som lyssnar (se ovan). Alla `enabled`, så de startar efter omstart. |
| auditd, rsyslog, systemd-journald | Loggning – root-kommandon och loggar till loggservern (F7a) |
| chronyd | Rätt tid via NTP (F11c) – tidsstämplarna i loggarna |
| NetworkManager, hc-net-ifup@eth1/eth2 | Nätkorten (labbnät och teamnät) |
| qemu-guest-agent | Molnplattformens agent för den virtuella servern |
| crond, dbus-broker, systemd-logind, systemd-udevd, irqbalance | Grundtjänster i Rocky Linux |
| getty@tty1, serial-getty@ttyS0, user@1000 | Konsolinloggning och min egen session |

Ingen av tjänsterna lyssnar på nätet utom sshd, httpd och zonvakt, och alla behövs. Därför stängde jag ingen tjänst.

## Härdningslista

| Nr | Åtgärd | Motivering – vilket hot | Förväntad effekt | Hur den verifierades | Skript? |
|---|---|---|---|---|---|
| P2-1 | SELinux enforcing nu och efter omstart (obligatorisk) | En tjänst som tas över får annars göra allt som dess användare får, även som root | `getenforce` = Enforcing och `SELINUX=enforcing` i config | `getenforce` → Enforcing; `sestatus` → Current mode och Mode from config file = enforcing | ☑ |
| P2-2 | Bara tjänster som finns i flödestabellen får lyssna | Varje öppen port är en möjlig väg in. En tjänst som ingen vet om övervakas inte. | `ss -tlnp` visar bara 22, 80 och 7512 | `sudo ss -tlnp` → sshd 22, httpd 80, zonvakt 7512 (18/11); `systemctl is-enabled sshd httpd zonvakt` → enabled (19/11) | ☑ |
| P2-3 | Paketfilter med policy drop inkommande | Även om en tjänst råkar starta ska den inte gå att nå utan en regel | Kedjan `in` har `policy drop` | `nft list chain inet zon in` → policy drop; testfall F3-nek, Nek-in → tyst | ☑ |
| P2-4 | zonvakt nås bara från ctf (F13c) | zonvakt lyssnar på 0.0.0.0. Utan regel per källa skulle alla i labbnätet nå den. | Bara 172.20.1.10 släpps in på tcp/7512 | `kontrollera U7.3` (ctf) godkänd 17/11; `test-firewall-in.sh` från jump → F13c-nek BLOCKED (19/11) | ☑ |
| P2-5 | zonvakt i egen tvingande domän | Tjänsten kör som root. Tas den över ska den inte kunna skriva i /etc. | `ps -eZ` → `zonvakt_t`; `overtrad` nekas | `ps -o user=,label= -C zonvakt` → root, zonvakt_t; `echo overtrad` → nekad (18/11) | ☑ |

## Kör skriptet

```
sudo bash scripts/verifiera-hardning-p2.sh; echo "slutkod $?"
```

Skriptet läser bara av och skriver GÄLLER eller GÄLLER INTE per rad. Slutkod 0 = allt gäller.

## Inte gjort

- Jag stängde inga tjänster, eftersom alla som körs behövs (se systemctl ovan) och de tre som lyssnar finns i flödestabellen.
- SSH-inställningarna (PermitRootLogin, lösenordsinloggning, X11) hör till person 1. ctf loggar in som root med nyckel, så PermitRootLogin ska inte ändras.
