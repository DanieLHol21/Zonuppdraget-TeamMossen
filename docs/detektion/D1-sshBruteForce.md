
# D1 – SSH brute force 
 
## 1. Händelse och teknik
 
Detektionen larmar på upprepade misslyckade SSH inloggningar från samma källadress. Det motsvarar T1110 Brute Force. Wazuh själv märker händelserna med T1110
 
## 2. Loggkälla och fält
 
Loggkälla: autentiseringsloggen på elev-22 (sshd), vidarebefordrad över TLS (port 6514) till loggservern och inläst i Wazuh. Index: `wazuh-alerts-*`.
 
| Fält | Värde i data | Betydelse |
|---|---|---|
| `rule.id` | 5710, 5712 | 5710 = försök med ickeexisterande användare. 5712 = `sshd: brute force trying to get access to the system`, nivå 10. |
| `data.srcip` | t.ex. 172.20.1.10, 10.40.3.75 | Källadressen för försöken. |
| `predecoder.program_name` | `sshd` (normaltrafik), `sshd-session` (min egen ström) | Rocky Linux 9 loggar med `sshd-session`, så sökningen måste vara `sshd*`. |
| `location` | `/var/log/remote/inmatat/elev-22/normal.log` (normaltrafik), `/var/log/remote/elev-22/syslog.log` (egen ström) | Visar vems logg och vilken ström. |
  
## 3. Detektionslogik
 
Monitor i Wazuh Alerting: **`SSH brute force (5712 many attempts)`**
 
- Typ: per query monitor, extraction query, index `wazuh-alerts-*`
- Körs: varje minut
- Tidsfönster: senaste 5 minuterna
- Filter: `rule.id` = 5712 och `location` innehåller `elev-22`
- Gruppering: aggregation per `data.srcip` (en hink per källadress)
- Trigger: `ctx.results[0].aggregations.by_ip.buckets.size() > 0`, allvarlighet 2
```json
{
  "size": 0,
  "query": {
    "bool": {
      "filter": [
        { "range": { "timestamp": { "gte": "{{period_end}}||-5m", "lte": "{{period_end}}" } } },
        { "term": { "rule.id": "5712" } },
        { "wildcard": { "location": "*elev-22*" } }
      ]
    }
  },
  "aggs": {
    "by_ip": { "terms": { "field": "data.srcip", "min_doc_count": 1, "size": 20 } }
  }
}
```
 
**Varför 5712:** upprepningen är redan inbyggd i regeln. Wazuh höjer 5712 först när det sett flera misslyckade försök från samma adress. Monitorn behöver därför inte räkna enskilda inloggningsförsök, och en enstaka felinmatning ger inget larm
 
## 4. Vad ska och inte ska larma
 
| Händelse | Larmar ? | Motivering |
|---|---|---|
| Ett enstaka misslyckat försök | Nej | Monitorn räknar bara 5712 |
| Upprepade försök från samma adress som ger 5712 | Ja | Det är brute force mönstret |
| Jump servern 172.20.1.2 | Inte väntat | Mina egna inloggningar via jump gav enstaka fel (5760, 5503), inte 5712. Jag har inte sett 5712 från jump |
| CTF servern 172.20.1.10 | vid testet | CTF servern är källan till testet (`kontrollera U6.2 start`) och måste därför larma. I uppgiften nämns den som legitim trafik, men i det här testet är den angriparen |
 
## 5. Mätning av normaltrafik
 
Period: 2026-11-11 kl 08:05–08:37 strömmen `/var/log/remote/inmatat/elev-22/normal.log`.
 
- Verifierat fönster: 32 minuter ≈ 0,53 timmar
- Träffar (regel 5710 eller 5712): **48** (47 st 5710 och 1 st 5712)
- Snitt: 48 / 0,53 ≈ **90 per timme**
- Uppskattning per dygn: ≈ **2 160** 
Fem adresser stod för alla 48 träffar. Varje adress gav hela sin skur inom en enda minut:
 
| Källadress | Träffar | Minut (svensk tid) |
|---|---|---|
| 10.40.1.156 | 12 | 08:32 |
| 10.40.1.57 | 10 | 08:24 |
| 10.40.3.235 | 9 | 08:23 |
| 10.40.3.75 | 9 | 08:17 |
| 10.40.3.113 | 8 | 08:29 |
 
Observation: en tröskel på antal 5710/5712 träffar per adress hade larmat på alla fem normaladresserna. Testet skickar tolv försök, lika många som den största normala skuren (12), så enbart volym kan inte skilja test från normaltrafik. Regel 5712 gav bara en träff i normaltrafiken
 
## 6. Falsklarm och begränsningar
 
- **Ett falsklarm i normaltrafiken:** 10.40.3.75 gav ett 5712-larm kl 08:17:52 efter en skur med icke-existerande användare Monitorn hade larmat på det. Ett snabbt försök med flera okända användarnamn ser likadant ut som brute force
- **Volym skiljer inte:** normala skurar (8–12) och testet (12) är lika stora
- **Kort mätfönster:** 32 minuter. Dygnssiffran är en extrapolering och normaltrafiken kan variera över dygnet
- **Grova mätintervall:** skurarna är mätta i fasta intervall om en minut. De kan vara snabbare än så
- **Monitorn räknar inte försök:** en 5712 och hundra ser likadana ut
- **Omfattning:** filtret `*elev-22*` täcker både min egen ström och normaltrafikströmmen för elev-22
- **Regel 5712:** exakt frekvens och tidsfönster är inte kontrollerade (ingen behörighet till Rules)
- **Förbättring:** höj `min_doc_count`, eller undanta kända adresser, för att minska falsklarm. Det kräver ny mätning
