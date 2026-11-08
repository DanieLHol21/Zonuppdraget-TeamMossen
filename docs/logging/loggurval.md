# Loggurval och Undersökningsfrågor

## Syfte

Syftet med detta dokument är att identifiera vilka frågor ett företag ska kunna besvara genom att undersöka loggarna på sina servrar.

Utifrån loggkällekartan har fem undersökningsfrågor tagits fram. Varje fråga innehåller ett tidsspann, ett subjekt och vad som ska fastställas. Till varje fråga kopplas de loggkällor som behövs för att kunna genomföra undersökningen.

Målet är att välja ut relevanta loggkällor utan att samla in onödig information.

## Undersökningsfrågor

### Fråga 1 - Har någon obehörig försökt logga in på servern?

    Tidsspann: 5 november 2026 kl. 00:00–23:59.
    Subjekt: Användarkontot student och andra användarkonton på servern.
    Vad ska fastställas? Om det har förekommit misslyckade eller misstänkta inloggningsförsök, vilka IP-adresser som använts och om någon okänd användare har fått tillgång till servern.
    Loggkällor:
        /var/log/secure – visar SSH-inloggningar, användarkonton och autentiseringsförsök.
        journalctl – kan komplettera med händelser från SSH-tjänsten.

### Fråga 2 – Har brandväggen blockerat misstänkt nätverkstrafik?

    Tidsspann: 5 november 2026 kl. 12:00–13:00.
    Subjekt: Serverns nätverksgränssnitt och inkommande eller utgående nätverkstrafik.
    Vad ska fastställas? Vilka anslutningsförsök som har blockerats, vilka IP-adresser som kommunicerat och vilka portar som trafiken försökt nå.
    Loggkällor:
        /var/log/messages – innehåller brandväggshändelser med information om käll-IP, destinations-IP och portar.
        journalctl – kan användas för att undersöka relaterade system- och nätverkshändelser.

### Fråga 3 – Har någon kört misstänkta kommandon på servern?

    Tidsspann: 5 november 2026 kl. 00:00–23:59.
    Subjekt: Användarkontot student och användaren root.
    Vad ska fastställas? Vilka kommandon som har körts, vilken användare som utfört dem och om det förekommit kommandon som kan tyda på obehörig aktivitet.
    Loggkällor:
        /var/log/audit/audit.log – visar registrerade kommandokörningar och processinformation.
        /var/log/secure – kan användas för att koppla aktiviteter till autentiserade användarsessioner.

### Fråga 4 – Har serverns schemalagda jobb körts som planerat?

    Tidsspann: 4 november 2026 kl. 00:00–23:59.
    Subjekt: Serverns schemalagda jobb och användarkontot root.
    Vad ska fastställas? Om schemalagda jobb har startat och avslutats som förväntat eller om något jobb har misslyckats eller inte körts.
    Loggkällor:
        /var/log/cron – visar när schemalagda jobb startas och vilka kommandon som körs.
        journalctl – kan komplettera med systemrelaterade felmeddelanden.

### Fråga 5 – Har någon programuppdatering eller pakethantering orsakat problem?

    Tidsspann: 5 november 2026 kl. 00:00–23:59.
    Subjekt: DNF-pakethanteraren och serverns installerade paket.
    Vad ska fastställas? Om programvaruuppdateringar eller andra paketoperationer har genomförts, vilka åtgärder som utförts och om det förekommit fel.
    Loggkällor:
        /var/log/dnf.log – visar aktivitet från DNF och information om pakethantering.
        journalctl – kan visa systemfel eller tjänsteproblem som uppstått i samband med uppdateringar.

## Slutligt urval av loggkällor

| Loggkälla | Varför behövs den? |
|---|---|
| `/var/log/secure` | Undersöka inloggningar och användarsessioner. |
| `journalctl` | Komplettera med system- och tjänstehändelser. |
| `/var/log/messages` | Undersöka systemmeddelanden och blockerad nätverkstrafik. |
| `/var/log/audit/audit.log` | Undersöka kommandokörningar och processinformation. |
| `/var/log/cron` | Kontrollera schemalagda jobb. |
| `/var/log/dnf.log` | Undersöka programinstallationer och uppdateringar. |

Dessa sex loggkällor täcker de fem undersökningsfrågorna och ger möjlighet att undersöka både säkerhetsrelaterade händelser och driftproblem.

## Loggkällor som inte behöver ingå

Ingen av de identifierade loggkällorna behöver användas för alla undersökningsfrågor. Däremot är vissa loggkällor inte nödvändiga för specifika typer av undersökningar.

Exempel:

    Cron-loggen: Behövs inte vid undersökning av SSH-inloggningar eller brandväggstrafik eftersom den endast visar information om schemalagda jobb.
    DNF-loggen: Behövs inte vid undersökning av användarinloggningar eller blockerad nätverkstrafik eftersom den fokuserar på pakethantering.
    Audit-loggen: Behövs inte vid en vanlig kontroll av schemalagda jobb om det endast är viktigt att fastställa om jobben har körts. Cron-loggen räcker då normalt.
    Brandväggshändelser i messages: Behövs inte vid undersökning av programuppdateringar eller vanliga användarsessioner.

