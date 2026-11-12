# Playbook D2 – Zonöverträdelse: brandväggen nekar trafik

Rrezart Binaku (elev-12) · Team 6 "Mössen" · vecka 6 · person 2
Detektion: `docs/detektion/D2-brandvagg-drops.md`

| | 2a Inkommande | 2b Utgående |
|---|---|---|
| ATT&CK | T1046 Network Service Discovery | T1571 Non-Standard Port |
| Monitor | `T1046 skanning mot min server (ZON-IN-DROP)` | `T1571 otillåten anslutning ut från min server (ZON-UT-DROP)` |
| Trigger | minst 3 `ZON-IN-DROP` på 5 min, severity 3 | minst 1 `ZON-UT-DROP` med SYN på 5 min, severity 2 |
| Index | `wazuh-archives-*` | `wazuh-archives-*` |

**När används playbooken:** när någon av monitorerna ovan har ett larm i Alerting → Alerts.

**Tider:** Wazuh lagrar i UTC. Discover visar svensk tid (UTC+1 i november). Skriv tider i triageloggen i UTC.

---

## 1. Förberedelse (görs före passet)

1. **Kontrollera** i Alerting → Monitors att båda monitorerna är *Enabled*.
2. **Kontrollera** att loggkedjan fungerar: sök `location: *elev-12*` i `wazuh-archives-*`, de senaste 15 minuterna. Det ska finnas poster.
3. **Ta reda på** om någon i teamet ska köra planerade tester mot elev-12 under passet, och skriv ner tid och källa.

---

## 2. Detektion och analys

### Steg som gäller båda larmen

4. **Öppna larmet** i Alerting → Alerts. Anteckna monitor, trigger, starttid och severity.
5. **Öppna Discover** med `wazuh-archives-*`. Sätt tiden till **larmets starttid minus 5 minuter → starttid plus 2 minuter**.
6. **Sök** (2a): `data.action: ZON-IN-DROP and location: *elev-12*`
   **Sök** (2b): `data.action: ZON-UT-DROP and full_log: SYN and location: *elev-12*`
7. **Lägg till kolumnerna** `data.srcip`, `data.dstip`, `data.dstport`, `data.protocol`. Anteckna antal träffar och de värden som förekommer.

### 2a Inkommande – vad har hänt?

8. **Räkna** träffarna per `data.srcip` (klicka på fältet i listan). En källa eller flera?
9. **Räkna** olika `data.dstport` för den källan. Många olika portar på kort tid = skanning. En eller två portar = enstaka försök.
10. **Jämför källan** med kända adresser:
    - 172.20.1.2 = jump · 172.20.1.10 = ctf · 10.40.6.x = teamets servrar
    - Okänd extern adress = internet
11. **Kontrollera** i flödestabellen att porten verkligen inte ska vara öppen.

### 2b Utgående – vad har hänt?

12. **Anteckna** `data.dstip` och `data.dstport`. Är porten ovanlig (t.ex. 4444) eller en vanlig port till en adress som inte står i flödestabellen?
13. **Kontrollera** att raden har `SYN`. Utan SYN är det ett sent svar och inget nytt försök (se gränsfall).
14. **Logga in på elev-12** (fönster B) och ta reda på vilket program som försökte ansluta:
    - `sudo ss -tnp` (pågående anslutningar och program)
    - `sudo journalctl --since "10 min ago" | tail -50` (vad som hände runt tiden)

### Vad har berörts? (båda)

15. **Sök utan värdfilter**, samma tidsfönster: `data.srcip: <källan>` (2a) eller `data.dstip: <målet>` (2b). Syns samma källa eller mål mot andra servrar i teamet?
16. **Sök** i `wazuh-alerts-*`, samma källa och fönster: kom källan in, till exempel med en lyckad inloggning (5715, 40112)?

### Beslutspunkt – avfärda eller eskalera?

| Observation | Beslut |
|---|---|
| Källan är jump eller ctf, och tiden stämmer med ett planerat test (steg 3) eller en CTF-kontroll | **Avfärda.** Skriv in testet (vem, kommando, tid) som skäl. |
| 2b: raden saknar SYN (sent svar, ACK/PSH/FIN) | **Avfärda.** Skäl: inget nytt försök. |
| 2a: okänd extern källa, många portar, inga lyckade inloggningar | **Låg risk.** Notera i triageloggen och fortsätt följa källan. |
| 2a: källan finns även mot andra servrar, eller kom in (steg 16) | **Eskalera.** |
| 2b: okänt program eller okänt mål, särskilt ovanlig port | **Eskalera direkt.** Kan vara reverse shell eller exfiltrering. |

**Eskalera till:** teamets person 5 (triage) och den som äger servern. **Underlag:** larmets starttid (UTC), sökningen, antal träffar, `srcip`/`dstip`/`dstport` och vad steg 14–16 visade.

---

## 3. Begränsning, utrotning och återställning (vid eskalering)

17. **2b:** stoppa programmet som försökte ansluta ut (`sudo kill <pid>` från steg 14) och kontrollera med `sudo ss -tnp` att det är borta.
18. **2a:** brandväggen stoppar redan trafiken (policy drop). Kontrollera att ingen regel släpper igenom källan: `sudo nft list table inet zon`.
19. **Ändra inga regler** utan att flödestabellen ändras först.
20. **Verifiera** efteråt: kör samma sökning (steg 6) igen 10 minuter senare. Inga nya träffar = begränsat.

---

## 4. Efterarbete

21. **Skriv en post** i `docs/detektion/triagelogg.md`: tid (UTC), larm, monitor, ATT&CK-id, **observation** (det du såg, med fält och värden), **slutsats** (vad du tror att det betyder), beslut och skäl.
22. **Stäng larmet:** Acknowledge i Alerting om det fortfarande är Active.
23. **Justera vid behov:** gav larmet ett falsklarm, skriv vad som skulle ändras (tröskel, undantag) i D2-dokumentet. Ändra inte monitorn utan att mäta bruset igen.

---

## Gränsfall (ska inte leda till åtgärd)

- **2a:** ett enstaka blockerat försök ger 2 SYN (omsändning efter ~1 s) och når inte tröskeln 3.
- **2b:** sena svar från webbservern (SPT=80, ACK/PSH/FIN) till externa skannrar. Räknas inte, eftersom monitorn kräver SYN. Sedan 9/11 stoppas de av `ct state invalid drop` och loggas inte.
- Planerade tester från jump eller ctf (CTF-kontroller, teamets framkallade tester).
