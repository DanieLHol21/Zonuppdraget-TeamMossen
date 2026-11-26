# AVC-händelser i loggkedjan
## Rå AVC-händelse till Wazuh

Verifiering av SELinux-loggningen genomfördes i Wazuh med följande sökning:

text
full_log:"type=AVC" AND full_log:"comm=zonvakt"


Sökningen genomfördes inom de senaste sju dagarna och gav 48 träffar.

En av träffarna kom från klienten elev-37 och innehöll följande information:

Fält	Resultat
program_name	audisp-syslog
agent.name	log
agent.ip	172.20.1.58
location	/var/log/remote/elev-37/syslog.log
rule.id	100200
rule.level	5
rule.description	SELinux (AVC): åtkomst nekad

Detta visar att råa AVC-händelser från elev-37 vidarebefordras via audisp-syslog till den centrala loggservern och behandlas av Wazuh.

## Wazuh-regel för SELinux

Händelserna identifieras av kursens lokala Wazuh-regel:

Regel-ID: 100200
Nivå: 5
Beskrivning: SELinux (AVC): åtkomst nekad

Standardregeln för SELinux-nekanden har nivå 2, medan kursens egen regel ger nivå 5.

I den verifierade händelsen var rule.mail satt till false. Det innebär att ingen automatisk e-postavisering skickas från den aktuella regeln.

Händelserna kan däremot sökas fram och följas upp i Wazuh.

En separat Alerting-monitor kan skapas för att ge aviseringar vid SELinux-nekanden. Någon sådan monitor har inte verifierats som aktiv.

## Setroubleshoot

För att kontrollera om setroubleshoot-meddelanden vidarebefordras till loggservern genomfördes följande sökning:

text
full_log:"SELinux is preventing"


Sökningen inom de senaste sju dagarna gav inga träffar.

Det innebär att det inte har kunnat verifieras att setroubleshoot-meddelanden når Wazuh.

Den råa AVC-loggningen fungerar däremot och är verifierad för elev-37.

Det återstår att undersöka om setroubleshoot genererar meddelanden lokalt och om dessa skickas vidare via syslog.

## Jämförelse med lokal auditlogg

En AVC-händelse innehåller ett audit-serienummer i fältet:

text
msg=audit(tidsstämpel:serienummer)


Serienumret kan användas för att jämföra händelsen i Wazuh med motsvarande post i klientens lokala /var/log/audit/audit.log.

Exempel på lokal kontroll:

bash
sudo ausearch -m AVC -ts recent


En fullständig jämförelse mellan lokal auditlogg och Wazuh har inte kunnat genomföras för elev-37. Därför återstår denna kontroll.

## Begränsningar i verifieringen

Verifieringen genomfördes med tillgängliga loggar från elev-37. Direkt åtkomst till elev-12 saknas.

Dokumentationen baseras därför på de händelser som faktiskt har kunnat observeras i Wazuh från elev-37.

Råa AVC-händelser har verifierats centralt, men vidarebefordran av setroubleshoot-meddelanden och jämförelsen med den lokala auditloggen återstår.

## Slutsats

Den råa AVC-händelsen från elev-37 når loggservern via audisp-syslog och identifieras av Wazuh med kursens regel 100200 på nivå 5.

Det visar att den centrala loggningen kan användas för att upptäcka och följa upp SELinux-nekanden.

Setroubleshoot-meddelanden har däremot inte kunnat hittas i Wazuh. Den delen av loggkedjan återstår att undersöka.

Loggningen av råa AVC-händelser är därmed verifierad, medan hela loggkedjan ännu inte är fullständigt verifierad.