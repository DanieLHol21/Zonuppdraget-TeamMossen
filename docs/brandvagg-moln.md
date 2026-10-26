# Molnbrandvägg – implementerade regler

**Underlag:** `docs/flodestabell.md`. Bara flöden som filtreras i molnplattformen har regler här. Privata flöden (F3–F10, F13, F14) filtreras bara på värden, eftersom de går över det privata nätet och inte passerar molnbrandväggen.

## Standardregler

Kursens standardregler (tidigare regel 1–4) släppte in tcp 1–21 och 23–65535, all udp och icmp. De avviker från flödestabellen och tas bort efter bekräftelse från Peter. När de är borttagna nekas all inkommande trafik utom F1.

## Regler

| Regel | Riktning | Protokoll | Port | Källa/mål | Flöde | Tillåt/neka |
|---|---|---|---|---|---|---|
| 1 | in | tcp | 80 | 0.0.0.0/0 | F1 | Tillåt |
| 2 | ut | udp | 53 | 185.12.64.1 | F11a | Tillåt |
| 3 | ut | udp | 53 | 185.12.64.2 | F11a | Tillåt |
| 4 | ut | tcp | 53 | 185.12.64.1 | F11b | Tillåt |
| 5 | ut | tcp | 53 | 185.12.64.2 | F11b | Tillåt |
| 6 | ut | tcp | 443 | 0.0.0.0/0 | F11d | Tillåt |
| 7 | ut | udp | 123 | 213.239.239.164 | F11c | Tillåt |
| 8 | ut | udp | 123 | 213.239.239.165 | F11c | Tillåt |
| 9 | ut | udp | 123 | 213.239.239.166 | F11c | Tillåt |

Numren är de som gäller efter att standardreglerna tagits bort (gamla 5–13 blir 1–9). Utgående trafik som inte står i tabellen nekas (`moln brandvägg regel lista` visar "implicit neka"). ICMP inkommande nekas eftersom det inte står i flödestabellen.

## Verifiering (från teamets elevserver, 2026-10-26)

- **Utgående neka:** `curl -m 5 http://example.com` gav timeout, så tcp/80 ut är nekat.
- **F11d (tcp/443 ut):** `curl -sI https://example.com` gav HTTP/2 200.
- **F11a (DNS):** `getent ahostsv4 example.com` gav adresser.
- **F11c (NTP):** efter `chronyc burst` var LastRx 4 sekunder med ett nytt sample, så udp/123 når tidsservrarna.
- **Inte testat:** F11b (DNS över tcp) och F1 (inkommande tcp/80).
- **Efter borttagning av standardregler:** SSH via jump fungerar (fyll i bara om du testat).

## Beslut och öppna frågor

- **Regel 1–4 (standard):** Peter har bekräftat att de ska tas bort. SSH från jump och ctf-kontrollerna går över det privata nätet 172.20.1.0/24 och påverkas inte, men måste filtreras på servern med nftables (Person 3).
- **F2 (SSH in):** gäller jump i Admin-zonen, inte elevservern, så den har ingen regel här.
- **F11d:** källan är 0.0.0.0/0 eftersom speglarna varierar (öppen fråga i flödestabellen).
- **NTP:** tabellen anger ntp.hetzner.com, men chrony använder just nu ntp2.hetzner.de. Båda pekar på 213.239.239.165, och reglerna täcker alla tre adresserna.
