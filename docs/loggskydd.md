# Skydd och hantering av loggkedjan

## 1. Behörigheter och raderingsskydd

### Lokalt på klienten (`elev-25`)
- **Filsystemsrättigheter:** Loggfiler under `/var/log/` (t.ex. `messages`, `secure`, `audit/audit.log`) ägs av `root:root` eller `root:wheel` med rättigheter som `0600` eller `0640`. Vanliga användare saknar läs- och skrivrättigheter.
- **Processer:** Loggtjänsterna `rsyslogd` och `auditd` körs som `root`. En användare utan root-privilegier kan inte modifiera, stoppa eller radera loggar.
- **Begränsning:** Om en attackerare erhåller `root`-behörighet kan lokala loggar ändras eller raderas. Därför vidarebefordras loggar i realtid till den centrala loggservern.

### Centralt på loggservern
- Loggar skickas över krypterad TLS (port 6514) i RFC 5424-format med tidsstämplar som innehåller delsekunder och tidszon.
- Klienter (`elev-25`) har enbart rättighet att vidarebefordra loggar, inte läsa eller radera loggar som lagrats på den centrala servern.

---

## 2. Loggrotation och lagringstid

### Logrotate
- `/etc/logrotate.conf` och konfigurationer i `/etc/logrotate.d/` styr rotationen av filer i `/var/log/`.
- Loggar roteras schemalagt (t.ex. veckovis) och komprimeras. Gamla loggar gallras automatiskt ut efter inställd retentionsperiod (t.ex. 4 veckor).

### Systemd Journal (`journald`)
- Hanteras via `/etc/systemd/journald.conf`.
- `journalctl --disk-usage` visar aktuell utrymmesförbrukning. Maxgränser (`SystemMaxUse`) förhindrar att loggar fyller hårddisken fullständigt.

---

## 3. Beteende vid avbrott mot loggservern (Köhantering)

I `/etc/rsyslog.d/90-logg.conf` är köhantering aktiverad för vidarebefordran:

- **Minneskö (`LinkedList`):** Logghändelser buffras i RAM om loggservern tillfälligt inte kan nås.
- **Diskbuffert (`queue.filename="fwd"`):** Om minneskön fylls upp eller om rsyslog-tjänsten stängs av (`queue.saveOnShutdown="on"`), skrivs kön ned till disk under `/var/lib/rsyslog/`.
- **Återanslutning (`action.resumeRetryCount="-1"`):** rsyslog försöker kontinuerli
