# Playbook: D2 Zonöverträdelse – brandväggen nekar trafik (2a T1046 inkommande, 2b T1571 utgående)

Författare: Rrezart Binaku (elev-12) | Testad av: | Datum: 2026-11-16
Detektion (regel-ID): 2a monitor `T1046 skanning mot min server (ZON-IN-DROP)` (id `bq-yyaEB0V6KK2aYE4zR`) · 2b monitor `T1571 otillåten anslutning ut från min server (ZON-UT-DROP)` (id `_6-4yaEB0V6KK2aYtp6m`) | Allvarlighet: 2a = 3 · 2b = 2

Varje steg placeras i exakt en fas.

## 1. Förberedelse

* **Vilka loggkällor och fält krävs?** Brandväggens loggrader `ZON-IN-DROP` och `ZON-UT-DROP` från elev-12 i `wazuh-archives-*`. Fält: `data.action`, `data.srcip`, `data.dstip`, `data.dstport`, `full_log`, `location`. Kontrollera före passet att båda monitorerna är *Enabled* och att `location: *elev-12*` ger poster de senaste 15 minuterna.
* **Vilka verktyg och behörigheter behövs?** Wazuh-konto (Discover och Alerting). SSH till elev-12 via jump med sudo (för 2b).
* **Vad är normalnivån (mätt brus, mätfönster)?** 0 träffar i normaltrafiken (mätfönster ca 0,5 h). Över tid: 2a ca 221 träffar på 369 h (skannrar från internet), 2b 2 träffar på 168 h (bara egna tester). Se `docs/detektion/D2-brandvagg-drops.md`.

## 2. Detektion och analys

* **Vilken sökning och vilket fält larmar? Vilken tröskel?** 2a: `data.action: ZON-IN-DROP`, minst 3 på 5 min. 2b: `data.action: ZON-UT-DROP` och `full_log: SYN`, minst 1 på 5 min. Båda med `location: *elev-12*`.
* **Vad tittar man på först? Vad skiljer ett äkta larm från ett falsklarm?**
    1. Öppna larmet i Alerting → Alerts och anteckna starttid (UTC).
    2. Öppna Discover med tiden starttid −5 min → +2 min och kolumnerna `data.srcip`, `data.dstip`, `data.dstport`.
    3. Titta på källan: 172.20.1.2 = jump, 172.20.1.10 = ctf, 10.40.6.x = teamet, annat = internet. Stämmer tiden med ett planerat test är det ett sant positivt test → avfärda.
    4. 2a: många portar från samma okända källa = skanning. Sök samma källa utan värdfilter och efter lyckad inloggning (5715, 40112). Syns den mot fler servrar eller kom in → eskalera.
    5. 2b: kontrollera att raden har SYN (utan SYN = sent svar, avfärda). Kör `sudo ss -tnp` på elev-12. Okänt program eller okänt mål → eskalera direkt till person 5 och serverns ägare.
* **Känd falsklarmsrisk:** 2a låg–medel: teamets egna tester från jump eller ctf kan nå tröskeln, och ett enstaka försök (2 SYN) når den inte. 2b låg: sena svar (ACK/PSH/FIN) räknas inte eftersom monitorn kräver SYN.
* **Hur dokumenteras det i triageloggen?** En rad i `docs/detektion/triagelogg.md`: tid (UTC), larm med ATT&CK-id, observation med fält och värden, slutsats, åtgärd och skäl till avfärdande.

## 3. Begränsning, utrotning och återställning

* **Begränsning (stoppa spridning):** 2a: brandväggen stoppar redan trafiken (policy drop). Kontrollera med `sudo nft list table inet zon` att ingen regel släpper igenom källan. 2b: stoppa programmet med `sudo kill <pid>`.
* **Utrotning (ta bort orsaken):** 2b: ta reda på hur programmet startades (tjänst, cron eller användare) och ta bort det. Ändra inga brandväggsregler utan att flödestabellen ändras först.
* **Återställning (tillbaka till drift, hur verifieras det):** kör samma sökning igen efter 10 minuter. Inga nya träffar och inget program i `sudo ss -tnp` = verifierat.

## 4. Efterarbete

* **Vad lärde vi oss?** Skriv kort i triageposten vad som orsakade larmet och om det gick att se snabbt. Kvittera larmet (Acknowledge) och stäng ärendet.
* **Vilken regel, tröskel eller dokumentation ändras?** Vid falsklarm: skriv förslaget (tröskel eller undantag) i `docs/detektion/D2-brandvagg-drops.md`. Ändra inte monitorn utan att mäta bruset igen.
