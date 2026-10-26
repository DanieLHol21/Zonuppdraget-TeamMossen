# Molnbrandvägg – implementerade regler

**Underlag:** `docs/flodestabell.md`. Bara flöden som filtreras i molnplattformen har regler här. Privata flöden (F3–F10, F13, F14) filtreras bara på värden.

## Avvikelse mot flödestabellen

Inkommande trafik nekas inte som standard än. Kursens standardregler 1–4 ligger kvar och släpper in tcp 1–21 och 23–65535, all udp och icmp. Tabellen säger att allt utom F1 ska nekas inkommande. Vi har inte tagit bort regel 1–4 än, eftersom vi först vill veta att inloggningen via jump och ctf-kontrollerna inte påverkas.

## Regler

| Regel | Riktning | Protokoll | Port | Källa/mål | Flöde | Tillåt/neka |
|---|---|---|---|---|---|---|
| 1–4 | in | tcp, udp, icmp | se ovan | 0.0.0.0/0 | kursens standard | Tillåt (avviker från tabellen) |
| 5 | in | tcp | 80 | 0.0.0.0/0 | F1 | Tillåt |
| 6 | ut | udp | 53 | 185.12.64.1 | F11a | Tillåt |
| 7 | ut | udp | 53 | 185.12.64.2 | F11a | Tillåt |
| 8 | ut | tcp | 53 | 185.12.64.1 | F11b | Tillåt |
| 9 | ut | tcp | 53 | 185.12.64.2 | F11b | Tillåt |
| 10 | ut | tcp | 443 | 0.0.0.0/0 | F11d | Tillåt |
| 11 | ut | udp | 123 | 213.239.239.164 | F11c | Tillåt |
| 12 | ut | udp | 123 | 213.239.239.165 | F11c | Tillåt |
| 13 | ut | udp | 123 | 213.239.239.166 | F11c | Tillåt |

Utgående trafik som inte står i tabellen nekas (`moln brandvägg regel lista` visar "implicit neka").

## Verifiering (från teamets elevserver, 2026-10-26)

- **Utgående neka:** `curl -m 5 http://example.com` gav timeout, så tcp/80 ut är nekat.
- **F11d (tcp/443 ut):** `curl -sI https://example.com` gav HTTP/2 200.
- **F11a (DNS):** `getent ahostsv4 example.com` gav adresser.
- **F11c (NTP):** efter `chronyc burst` var LastRx 4 sekunder med ett nytt sample, så udp/123 når tidsservrarna.
- **Inte testat:** F11b (DNS över tcp) och F1 (inkommande tcp/80).

## Öppna frågor

- **Regel 1–4:** Kan vi ta bort dem utan att förlora SSH via jump eller ctf-kontrollerna? Frågan ska ställas till Peter. Tills vi har svar ligger de kvar.
- **F2 (SSH in):** gäller jump i Admin-zonen, inte elevservern, så den har ingen regel här.
- **F11d:** källan är 0.0.0.0/0 eftersom speglarna varierar (öppen fråga i flödestabellen).
- **NTP:** tabellen anger ntp.hetzner.com, men chrony använder just nu ntp2.hetzner.de. Båda pekar på 213.239.239.165, och reglerna täcker alla tre adresserna.
