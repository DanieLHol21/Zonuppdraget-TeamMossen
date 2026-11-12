# D2 – Zonöverträdelse: brandväggen nekar trafik

Rrezart Binaku (elev-12) · Team 6 "Mössen" · vecka 6 · person 2

Paketfiltret (`zon.nft`) loggar trafik som flödestabellen stoppar. Jag delar upp händelsen i två detektioner, eftersom riktningen betyder olika saker.

## 2a. Inkommande – skanning (T1046 Network Service Discovery)

- **Händelse:** någon försöker nå portar på servern som flödestabellen inte släpper in.
- **Loggkälla:** kärnans brandväggslogg (kern) → rsyslog över TLS → `wazuh-archives-*`. Ingen standardregel larmar, därför används archives.
- **Fält:** `data.action: ZON-IN-DROP`, `data.srcip`, `data.dstport`, `data.protocol`, `location: *elev-12*`
- **Faktiska värden:** 2026-11-05 07:21 UTC, `srcip 172.20.1.2` (jump) → `dstip 172.20.1.112`, `dstport 4444`, TCP SYN, IN=eth1 (mitt test).
- **Gränsfall som inte ska träffa:** ett enstaka försök eller mitt planerade test från jump. Skanning = flera försök från samma `srcip` på kort tid.
- **Notering:** inkommande drops är ovanliga (2 på 7 dagar), eftersom molnbrandväggen bara släpper in tcp/80 på eth0. Internetskannrar når aldrig nftables.

## 2b. Utgående – otillåten anslutning ut (T1571 Non-Standard Port)

- **Händelse:** servern försöker ansluta ut till något som flödestabellen stoppar, till exempel en reverse shell eller exfiltrering.
- **Loggkälla:** samma som 2a.
- **Fält:** `data.action: ZON-UT-DROP`, `data.dstip`, `data.dstport`, `full_log: SYN`, `location: *elev-12*`
- **Faktiska värden:** 2026-11-09 22:28 UTC, `srcip 2.28.98.110` → `dstip 1.1.1.1`, `dstport 80`, TCP SYN, OUT=eth0 (mitt test).
- **Gränsfall som inte ska träffa:** sena svar från webbservern (SPT=80, ACK/PSH/FIN) till externa skannrar. 12 av 14 ZON-UT-DROP de senaste 7 dagarna var sådana (71.6.155.70, 85.175.101.203, 216.180.246.34, mot höga slumpportar). Därför räknar detektionen bara SYN. Sedan 9/11 stoppas de redan av `ct state invalid drop` och loggas inte.
- **Kontroll:** `data.action: ZON-UT-DROP and full_log: SYN` → 2 träffar (bara testet).

## Brusmätning

**Normaltrafikperioden:** 2026-11-11 07:06–07:36 UTC (≈ 0,5 h), värdarna web01, app01 och db01.
- `data.action: ZON*` → **0 träffar**.
- Kontroll: `predecoder.program_name: kernel` gav också 0. Normaltrafiken har alltså inga paketfilterrader alls, så den kan inte användas för att mäta bruset för den här detektionen. Därför mäter jag mot mitt eget verifierade fönster.

**Mitt verifierade fönster (elev-12):** 2026-10-26 ca 23:20 UTC → 2026-11-11 08:00 UTC ≈ **369 h** (15,4 dygn), från att `zon.nft` med loggregeln laddades.

| | Träffar | Per timme | Per dygn |
|---|---|---|---|
| Alla `ZON-*` | 265 | 0,72 | ≈ 17 |
| `ZON-IN-DROP` | ≈ 221 | 0,60 | ≈ 14 |
| `ZON-UT-DROP` | ≈ 44 | 0,12 | ≈ 3 |
| `ZON-UT-DROP` + SYN (senaste 7 d, 168 h) | 2 | 0,01 | ≈ 0,3 (bara mitt test) |

**Toppen:** 213 av 265 träffar kom 2026-10-27 kl 00:20–00:50 svensk tid. Det var internetskannrar mot eth0 (bland andra 147.185.132.101, 69.5.169.81 och 194.180.49.53) på slumpade portar, innan molnbrandväggen (U4.4) stängde eth0. Den högsta 10-minutersstapeln hade ≈ 100 träffar, alltså **10 per minut = taket i loggregeln** (`limit rate 10/minute`). Den verkliga skanningen var troligen större. Efter U4.4 kommer bara enstaka träffar.

Snittet (0,7 per timme) säger lite. Det är toppen som avgör tröskeln.

## Trösklar

Tröskeln måste ligga **under 10 per minut** (max 50 per 5 min), annars kan loggregelns tak göra att detektionen aldrig larmar.

| Detektion | Villkor | Fönster | Tröskel | Motivering |
|---|---|---|---|---|
| 2a IN (T1046) | `data.action: ZON-IN-DROP` | 5 min | **≥ 3** | Ett blockerat försök ger 2 SYN (omsändning efter ~1 s) och ska inte larma. Skanning = upprepning. Skanningen 27/10 gav ≈ 50 på 5 min och hade larmat direkt. |
| 2b UT (T1571) | `data.action: ZON-UT-DROP` och `full_log: SYN` | 5 min | **≥ 1** | Bruset är 0 sedan `ct state invalid drop` (9/11). Händelsen är en enda post: varje riktigt försök ut kan vara en reverse shell eller exfiltrering. |

## Monitorer (Alerting, tenant Private)

Båda är per query-monitorer med extraction query mot `wazuh-archives-*`, schema varje minut och fönster de senaste 5 minuterna. Frågorna provkördes med längre fönster innan de sparades, för att visa att de *kan* träffa: noll träffar får inte bero på fel fält.

### 2a – `T1046 skanning mot min server (ZON-IN-DROP)`
- Skapad 2026-11-11 09:20 CET, monitor-id `bq-yyaEB0V6KK2aYE4zR`
- Trigger: `T1046 minst 3 ZON-IN-DROP på 5 min`, severity 3 (medel)
- Villkor: `ctx.results[0].hits.total.value >= 3`
- Provkörning: `-30d` → 221 (samma som i Discover), `-5m` → 0

```json
{
  "size": 0,
  "query": { "bool": { "filter": [
    { "term": { "data.action": "ZON-IN-DROP" } },
    { "wildcard": { "location": "*elev-12*" } },
    { "range": { "timestamp": { "from": "{{period_end}}||-5m", "to": "{{period_end}}" } } }
  ] } }
}
```

### 2b – `T1571 otillåten anslutning ut från min server (ZON-UT-DROP)`
- Skapad 2026-11-11 09:28 CET, monitor-id `_6-4yaEB0V6KK2aYtp6m`
- Trigger: `T1571 minst 1 ZON-UT-DROP med SYN på 5 min`, severity 2 (hög)
- Villkor: `ctx.results[0].hits.total.value >= 1`
- Provkörning: `-7d` → 2 (bara mitt test, de 12 sena svaren utesluts), `-5m` → 0

```json
{
  "size": 0,
  "query": { "bool": { "filter": [
    { "term": { "data.action": "ZON-UT-DROP" } },
    { "wildcard": { "location": "*elev-12*" } },
    { "match_phrase": { "full_log": "SYN" } },
    { "range": { "timestamp": { "from": "{{period_end}}||-5m", "to": "{{period_end}}" } } }
  ] } }
}
```

## Framkallat test

| Detektion | Händelse | Tid händelse (sv tid) | Larm start | Larm slut | Fördröjning | Resultat |
|---|---|---|---|---|---|---|
| 2b UT | På elev-12: `timeout 3 bash -c '</dev/tcp/1.1.1.1/4444'` → returkod 124 | 2026-11-11 09:30 | 09:31 | 09:35 (Completed) | ≈ 1 min | ✅ larmade, severity 2 |

Larmet blev Completed av sig självt när händelsen hade lämnat 5-minutersfönstret.

## Falsklarmsrisk

### 2a Inkommande (T1046)
- **Planerade tester:** teamets framkallade tester och CTF-kontroller från jump (172.20.1.2) eller ctf (172.20.1.10) kan nå tröskeln. De avfärdas med ett skäl som går att kontrollera (vem, kommando, tid).
- **Internetskannrar:** de når bara nftables om molnbrandväggen öppnas mer. Före U4.4 gav de ≈ 10/min (taket). Med dagens molnregler är risken låg.
- **Bedömning:** låg. Normalt 0–2 träffar per dygn, och tröskeln ≥ 3 på 5 min kräver mer än ett enstaka försök.

### 2b Utgående (T1571)
- **Sena svar** (ACK/PSH/FIN) räknas inte, eftersom monitorn kräver SYN och `ct state invalid drop` stoppar dem innan loggen.
- **Legitima program** kan försöka nå något som inte står i flödestabellen, till exempel om Hetzner byter NTP-adress eller en paketkälla använder port 80. Då larmar det, och rätt åtgärd är att uppdatera flödestabellen först och sedan regeln.
- **Mina egna tester** från elev-12 larmar, och det är meningen.
- **Bedömning:** låg. 0 riktiga försök på 7 dagar utöver mina tester, och varje larm är värt att titta på.

### Risk för falskt negativt (missade händelser)
- Trafik som **är tillåten** (DNS, NTP, 443) loggas inte som drop. En angripare som ringer hem via 443 syns alltså inte här, utan behöver en annan detektion.
- Loggregeln har ett tak på **10 per minut**. Toppar kapas, men tröskeln ligger under taket, så larmet går ändå.
- Tystnar loggkedjan (rsyslog stoppas) kommer inga rader alls. Det fångas av teamets D4.

## Status

- [x] Nedbrytning (2a och 2b)
- [x] Brusmätning (normaltrafik och verifierat fönster)
- [x] Trösklar med motivering
- [x] Monitorer skapade och provkörda
- [x] Framkallat test 2b (09:30 → larm 09:31)
- [ ] Framkallat test 2a i par
- [x] Falsklarmsrisk
- [x] Playbook: `playbooks/D2-brandvagg-drops.md`
- [ ] Korstest av playbooken (person 3)
