# Playbook D1 – SSH brute force (T1110)

Detektion: `docs/detektion/D1-ssh-brute-force.md`
 
| | |
|---|---|
| ATT&CK | T1110 Brute Force |
| Monitor | `T1110 SSH brute force D1 (5712 per srcip)` |
| Trigger | minst en källadress (`data.srcip`) med ett 5712-larm under de senaste 5 minuterna, severity 2 |
| Index | `wazuh-alerts-*` |
 
**När används playbooken:** när monitorn har ett larm i Alerting → Alerts.
 
**Vad 5712 betyder:** Wazuhs regel sshd: brute force trying to get access to the system. Den höjs först när Wazuh har sett flera misslyckade försök från samma address. Fältet previous_output i larmet listar de försök som regeln samlat

## 1. Förberedelse 
 
1. Kontrollera i Alerting → Monitors att monitorn är **Enabled**.
2. Kontrollera att loggkedjan fungerar: sök location: *elev-22* i wazuh-archives-*, senaste 15 minuterna. Det ska finnas poster.
3. Ta reda på om någon ska köra planerade tester mot elev-22 under passet (till exempel kontrollera U6.2 start). Skriv ner tid och källa.
## 2. Detektion och analys
 
**Vad har hänt?**
 
1. Öppna larmet i Alerting → Alerts. Anteckna monitor, starttid och severity.
2. Öppna Discover, index `wazuh-alerts-*`. Sätt tiden till larmets starttid minus 10 minuter → starttid plus 2 minuter.
3. Sök:
```
rule.id: 5712 and location: *elev-22*
```
4. Lägg till kolumnerna `data.srcip`, `data.srcuser`, `rule.id`, `location`. Anteckna antal träffar och vilka `data.srcip` som förekommer.
5. Öppna en träff och läs `previous_output`. Vilka användarnamn försöktes? Är de påhittade (till exempel admin, git, oracle) eller riktiga konton?
**Vem och varifrån?**
 
6. Jämför `data.srcip` med kända adresser:
   - 172.20.1.2 = jump-servern
   - 172.20.1.10 = CTF-servern (källan för `kontrollera U6.2 start`)
   - 10.40.x.x i strömmen `inmatat/elev-22/normal.log` = den genererade normaltrafiken 
   - annan adress = okänd
7. Notera `location`. `/var/log/remote/elev-22/syslog.log` är min egen server. `/var/log/remote/inmatat/elev-22/normal.log` är den genererade normaltrafiken.
**Vad har berörts?**
 
8. Gick försöken vidare till en lyckad inloggning? Sök i wazuh-alerts-*, samma källa och tidsfönster (utvidga till plus 30 minuter):
```
data.srcip: <källan> and rule.id: (5715 or 40112 or 5902)
```
   - 5715 = lyckad sshd-inloggning
   - 40112 = flera misslyckanden följda av en lyckad inloggning
   - 5902 = ny användare tillagd
9. Syns samma källa mot andra servrar? Sök utan värdfilter: data.srcip: <källan>

**Beslutspunkt – avfärda eller eskalera?**
 
| Observation | Beslut |
|---|---|
| Källan är 172.20.1.10 eller 172.20.1.2 och tiden stämmer med ett planerat test (steg 3 i förberedelsen) | Avfärda. Skriv in testet (vem, kommando, tid) som skäl. |
| Källan finns i normaltrafikströmmen, bara ett 5712, påhittade användarnamn, ingen lyckad inloggning efteråt | Troligen brus. Notera i triageloggen. Bedömningen bygger på min mätning, där 10.40.3.75 gav ett sådant larm. |
| Okänd källa, 5712 och ingen lyckad inloggning | Låg risk. Notera i triageloggen och följ källan. |
| Okänd källa och en lyckad inloggning (5715 eller 40112) | **Eskalera direkt.** Brute force kan ha lyckats. |
| Ny användare tillagd (5902) från samma källa | **Eskalera direkt.** Möjlig persistens. |
 
**Eskalera till:** [KONTROLLERA: rollen för triage i teamet och den som äger servern]. Underlag: larmets starttid (UTC), sökningen, antal träffar, `data.srcip`, `data.srcuser` och vad steg 8–9 visade.
 
## 3. Begränsning, utrotning och återställning (vid eskalering)
 
Ha en andra SSH-session öppen när du ändrar något som rör inloggning.
 
1. **Se vem som loggat in.** På elev-22:
```bash
last -n 20
sudo grep 'Accepted' /var/log/secure | tail -20
```
2. **Se vilka root-kommandon som kördes.** Auditregeln har nyckeln `rootkommando`:
```bash
sudo ausearch -k rootkommando -i | tail -30
```
3. **Kontrollera nya konton:** `getent passwd | tail -5`. Jämför med vad som ska finnas.
4. **Brandväggen:** SSH släpps bara in från 172.20.1.2 och 172.20.1.10. En extern källa borde därför aldrig nå sshd. Om en okänd källa ändå gjorde det, kontrollera reglerna med `sudo nft list chain inet zon in` och molnbrandväggen. Ändra inga regler utan att flödestabellen ändras först.
5. **Vid bekräftat intrång:** lås det berörda kontot (`sudo passwd -l <konto>`) bara efter att en andra session är öppen och efter samråd i teamet. [KONTROLLERA: teamets rutin för detta]
6. **Verifiera efteråt:** kör sökningen i steg 3 igen 10 minuter senare. Inga nya 5712 från källan = begränsat.
## 4. Efterarbete
 
1. Skriv en post i `docs/detektion/triagelogg.md`: tid (UTC), larm, monitor, ATT&CK-id, **observation** (vad du såg, med fält och värden), **slutsats** (vad du tror att det betyder), beslut och skäl. Håll observation och slutsats i skilda fält.
2. Stäng larmet: Acknowledge i Alerting om det fortfarande är Active.
3. Gav larmet ett falsklarm: skriv vad som skulle ändras (tröskel, undantag) i `D1-ssh-brute-force.md`. Ändra inte monitorn utan att mäta bruset igen.
## Gränsfall (ska inte leda till åtgärd)
 
- Ett enstaka misslyckat försök ger 5760, 5710 eller 5503, men inget 5712. Monitorn larmar inte.
- Planerade tester från CTF-servern (`kontrollera U6.2 start`) larmar och ska avfärdas med ett granskbart skäl.
- En normal adress som provar flera okända användarnamn snabbt kan ge ett 5712 (10.40.3.75 gjorde det en gång i mätningen).
## Korstest
 
Låt en teamkamrat följa playbooken på ett nytt larm (kör `kontrollera U6.2 start` och låt dem arbeta utifrån larmet). Anteckna var de fastnade och rätta playbooken. Namn och datum: [FYLL I]
 