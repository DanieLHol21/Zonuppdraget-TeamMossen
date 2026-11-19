# zonvakt under egen policy – rättelselogg (elev-12)

Vecka 7, workshop 1, 17/11 2026. Tjänst: zonvakt på tcp/7512. Modul: `zonvakt` (`~/policy/zonvakt.te`, `zonvakt.fc`).

## Arbetsgång
1. `sepolicy generate --init` skapade modulen med domänen `zonvakt_t` (permissiv).
2. Byggde, laddade, `restorecon` och omstart → `ps -eZ` visade `zonvakt_t`.
3. Använde tjänsten (`hej`) och framkallade överträdelsen (`overtrad`).
4. Läste förslagen: `ausearch -m avc -c zonvakt --raw | audit2allow -R`.
5. Granskade varje förslag (tabellen nedan), tog bort `permissive zonvakt_t;`, byggde och laddade om.
6. Test: `hej` → ok, `overtrad` → nekad, ingen fil i /etc.

## Rättelselogg – en rad per förslag

| Förslag från audit2allow | Beslut | Varför |
|---|---|---|
| `allow zonvakt_t self:tcp_socket { accept bind create getattr listen setopt };` | **Ändrad** till `create_stream_socket_perms` | Förslaget saknade read och write. Tjänsten kraschade i tvingande läge med `PermissionError` på `conn.sendall` (journalctl). Nekandet syntes inte i ausearch, troligen dolt av en dontaudit-regel. Makrot ger det en TCP-tjänst behöver för att ta emot och svara. |
| `corenet_tcp_bind_generic_node(zonvakt_t)` | Med | Tjänsten måste binda till en adress (0.0.0.0). |
| `corenet_tcp_bind_generic_port(zonvakt_t)` | Med (för bred) | Behövs för att lyssna på 7512, men tillåter alla oreserverade portar. Kan snävas in med en egen porttyp (U7.6). |
| `corecmd_mmap_bin_files(zonvakt_t)` | Med | Python-tolken måste kunna läsas och mappas. |
| `auth_read_passwd_file(zonvakt_t)` | Med | Läser användarnamn vid start. Bara läsning. |
| `sssd_read_public_files(zonvakt_t)` | Med | Uppslag av användare via sssd. Bara läsning. |
| `sssd_search_lib(zonvakt_t)` | Med | Samma som ovan. |
| `corecmd_exec_bin(zonvakt_t)` | Inte med | Överlappar mmap-raden och är bredare. Tjänsten startar inga andra program. |
| `files_manage_etc_files(zonvakt_t)` | **Aldrig** | Det är själva överträdelsen. En vakttjänst ska inte skriva i /etc. |
| `auth_etc_filetrans_shadow(zonvakt_t)` | **Aldrig** | Hör till att skapa filer i /etc. Inget tjänsten behöver. |
| `permissive zonvakt_t;` (genererad) | **Borttagen** | Permissiv domän stoppar inget. Bara för felsökning. |

## Brandväggen
- Ny regel **F13c** i `zon.nft`: `ip saddr 172.20.1.10 tcp dport 7512 accept` – ctf kontrollerar zonvakt (U7.3).
- Laddad säkert: `.bak5` → `nft -c` → nödbroms → restart → SSH testad i fönster C → nödbroms av.
- Finns i flödestabellen (`docs/network/zonmodell.md`), spårbarhetslistan och testfallen sedan 19/11.

## Bevis (U7.3)
- Lokalt: zonvakt.log `2026-11-17T12:53:59 172.20.1.10 'overtrad' -> nekad`. AVC löpnummer **2979**: `denied { write }` för `zonvakt_t` på `etc_t` (dir), `permissive=0`, `uid=root`.
- Centralt: Wazuh `wazuh-archives-*`, `full_log:"type=AVC" AND full_log:"comm=zonvakt" AND location:*elev-12*` → samma `msg=audit(1794920039.625:2979)`, via audisp-syslog, regel 100200 nivå 5.
- Slutsats: policyn gjorde rätt och står kvar. Tjänsten ska inte skriva i /etc.

## Verifiering (U7.5)
`/usr/local/bin/verifiera-hardning` – 8 kontroller, GÄLLER på alla, slutkod 0 efter omstart (skript 13:19:47, uppstart 13:22:09 UTC). Testad med `setenforce 0` → GÄLLER INTE, slutkod 1, sedan tillbaka till Enforcing.
