# Verifiering av loggkedjan och testflöde

## 1. Verifieringsmetod för testhändelser

För att kontrollera att händelser genereras lokalt, fångas av auditd/rsyslog och vidarebefordras till den centrala loggservern används två huvudsakliga testhändelser:

### Test 1: Manuell loggpost via syslog (`logger`)
Genererar en syslog-händelse med en unik identifierare i RFC 5424-format över TLS:
```bash
logger -t u55 spar713acc44
