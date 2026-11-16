# Detektion 4: Loggkedjan tystnar (T1562.001)

**Ansvarig:** elev-25  
**MITRE ATT&CK:** T1562.001 – Impair Defenses: Disable or Modify Tools  

## 1. Nedbrytning av händelsen
Om någon med root-rättigheter stoppar `rsyslog` för att dölja sina spår händer två saker:
1. Systemd/journald loggar lokalt på maskinen att tjänsten avslutas (`Stopping System Logging Service...` och `rsyslogd: exiting on signal 15`). Eftersom loggkedjan bryts precis då hinner den posten inte alltid skickas vidare till Wazuh.
2. Det slutar helt komma in loggar från `elev-25` till `wazuh-alerts-*`. Detektionen bygger därför på att larma när antalet träffar från värden är `0` under ett visst tidsfönster.

## 2. Brusmätning och tröskelvärde
- **Köfördröjning (`saveOnShutdown`):** Enligt `loggning.md` kan diskbuffrade köer fördröja leveransen med upp till 461 sekunder (ca 7 min 41 sek). Tystnad måste därför vara längre än så.
- **Längsta normala tysta period:** Jag kollade normaltrafiken för `elev-25` i Discover (`wazuh-alerts-*`) den 11 nov kl. 08:05–08:37 (347 träffar totalt). Den längsta luckan utan loggar under den perioden var 1 minut (60 sekunder).
- **Vald tröskel:** 10 minuter (600 sekunder) med 0 träffar (`IS BELOW 1`).
- **Motivering:** 600 sekunder ligger med god marginal över både köfördröjningen på 461 sekunder och den längsta normala tysta perioden på 60 sekunder, vilket minskar risken för falsklarm.

## 3. Monitor-konfiguration
- **Namn:** `D4 - Loggkedjan tystnar (elev-25)`
- **Typ:** Per query monitor (`wazuh-alerts-*`, tidsfält `@timestamp`)
- **Filter:** `location` innehåller `elev-25` under tidsfönstret `last 10 minutes`
- **Schema:** Körs varje minut (`Every 1 minute`)
- **Trigger:** `IS BELOW 1` (Severity 1)

## 4. Test och verifiering
Monitorn fick gå mot normaltrafik först och gav inga falsklarm. Efter att ha stämt av med gruppen körde jag `sudo systemctl stop rsyslog` på `elev-25` kl. 10:12 (09:12 UTC) utan att ändra någon konfiguration. Exakt 10 minuter senare, kl. 10:22, löste triggern ut under *Alerting -> Alerts* i Wazuh. Kl. 10:30 startade jag tjänsten igen med `sudo systemctl start rsyslog`, verifierade att den var `active (running)` och kl. 10:31 återgick larmet till 0 aktiva alerts.

## 5. Koppling till vecka 5 och falsklarmrisk
I vecka 5 säkrade vi loggkedjan med rättigheter, köhantering (`saveOnShutdown`) och vidarebefordran till central server så att loggar inte kan raderas i efterhand. Den här detektionen fångar upp om någon istället försöker stänga av själva loggtjänsten helt.

**Falsklarmrisker:**
- **Planerade omstarter eller underhåll:** Om `elev-25` startas om eller underhålls i mer än 10 minuter kommer larmet att gå.
- **Nätverksproblem:** Om kontakten mellan klienten och loggservern bryts buffras loggarna lokalt på disk och slutar komma in i Wazuh, vilket ser likadant ut som att `rsyslog` stoppats.
- **Låg aktivitet nattetid:** Under nätter och helger när väldigt lite händer på maskinen kan tysta perioder bli längre än under dagtid.
