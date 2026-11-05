# Loggkallekarta - Elev Server

Dokumentet beskriver loggkällor som finns på vara studentservrar. Syftet är att identifiera vilekn ifno som loggas, vart loggarna lagras och hur länge dem sparas. 
Inventeringen bygger på faktiska loggutdrag från vår Elev server. Loggarnas grundläggande struktur förväntas vara likartad på övriga studentservrar, men individuella skillnader kan förekomma.

## Identifierade loggkällor
### Systemd journal (journalctl)

- Loggplats: `run/log/journal/`
- Verktyg: journalctl
- Innehåll: Systemhändelser felmeddelande från systemets tjänster osv.
- Exempel på en logghändelse

 ```text
Nov 05 12:31:13 elev-22 systemd[1]: Starting Hostname Service...
Nov 05 12:31:13 elev-22 systemd[1]: Started Hostname Service.
Nov 05 12:31:14 elev-22 rsyslogd[81566]: cannot connect to 172.20.1.58:514 (took 129.71 seconds): Connection timed out
 ```
 - Vad används den för?: Se om tjänster startar korrekt eller för att felsöka problem med t.ex rsyslog
 - Lagring och retention: Vid undersökningen tog journlen ~ 47MB. Loggarna lagras i `run/log/journal`. Detta försvinner vid omstart
 - Rotation: Hanteras automatiskt av journald.

 ### Autentiseringslogg 

- Loggplats: `var/log/secure`
- Innehåll: användar sessioner och SSH inloggs
- Exempel på en logghändelse:
```text
Nov  5 12:31:13 elev-22 sshd-session[94780]: Accepted publickey for student from 172.20.1.2 port 33796 ssh2
Nov  5 12:31:13 elev-22 sshd-session[94780]: pam_unix(sshd:session): session opened for user student(uid=1000)
```
- Vad används den för?: För att se vem som har loggats in och när
- Lagring och retention: Fyra roterade loggar sparas 
- Rotation: Veckovis

####System och kärnlogg 

- Loggplats: `var/log/messages`
- Innehåll: Systemmeddelande
- Exempel på en logghändelse
```text
Nov  5 12:34:54 elev-22 kernel: ZON-UT-DROPIN= OUT=eth1 SRC=172.20.1.122 DST=172.20.1.58 LEN=60 PROTO=TCP SPT=50102 DPT=514
```

- Vad används den för?: Identifiera nätverkstrafik eller att se vad som har blockerats av brandväggen
- Lagring och retention: Fyra roterade loggar sparas 
- Rotation: Veckovis

### Cron logg

- Loggplats: `var/log/cron`
- Innehåll: Info om schemalagda jobb som körs av cron
- Exempel på en logghändelse
```text
Nov  4 12:01:01 elev-22 CROND[94766]: (root) CMD (run-parts /etc/cron.hourly)
Nov  4 12:01:01 elev-22 run-parts[94769]: (/etc/cron.hourly) starting 0anacron
Nov  4 12:01:01 elev-22 run-parts[94775]: (/etc/cron.hourly) finished 0anacron
```

- Vad används den för?: För att se om schemalagda jobb har körts 
- Lagring och retention: Fyra roterade loggar sparas 
- Rotation: Veckovis

### DNG logs

- Loggplats: `var/log/dng.log`
- Innehåll: Aktivitet från DNF packet manager
- Exempel på en logghändelse
```text
2026-11-05T12:45:00+0000 DDEBUG Extra commands: ['makecache', '--timer']
2026-11-05T12:45:00+0000 DEBUG Making cache files for all metadata files.
2026-11-05T12:45:00+0000 INFO Metadata cache refreshed recently.
```

- Vad används den för?: Se när packet managern har kört och vad den gjorde 
- Retention och Rotation: konfigurationen specifika retention och rotationsinstälningar kunde inte fastställas

### Audit logs

- Loggplats: `var/log/audit/audit.log`
- Innehåll: Kommandokörningar, processinfo och säkerhetsrelaterade händelser
- Exempel på en logghändelse
```text
type=EXECVE msg=audit(1793883315.006:6509): argc=4 a0="tail" a1="-n" a2="5" a3="/var/log/audit/audit.log"
type=CWD msg=audit(1793883315.006:6509): cwd="/home/student"
```

- Vad används den för?: Se vilak kommando har körts
- Lagring och retention: numlogs = 5 som betyder 5 roterande loggfiler behöls
- Rotationstyp: `max_log_file_action = ROTATE`
- Storlekgräns: `max_log_file = 8` (max 8mb)

## Sammanfattning av loggraotation och retention
Den globala config funns i `etc/loggrotate.conf`

Följande regler gäller som standard för loggarna som använder den globala konfigen
| Inställning | Värde | Betydelse |
|---|---|---|
| `weekly` | Veckovis | Loggar roteras en gång i veckan. |
| `rotate` | 4 | Fyra äldre loggfiler sparas. |
| `create` | Aktiverad | En ny tom loggfil skapas efter rotation. |
| `dateext` | Aktiverad | Datum används som suffix på roterade loggfiler. |
| `compress` | Avstängd | Äldre loggfiler komprimeras inte genom denna globala inställning. |



