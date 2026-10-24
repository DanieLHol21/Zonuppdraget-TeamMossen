# Markeringstabell för Zero Trust

## Syfte
Tabellen sammanfattar identifierade brister och oklarheter vid granskning av zonmodellen mot NIST SP 800-207. Fynden baseras på projektets dokumentation och skiljer mellan dokumenterade begränsningar och sådant som behöver verifieras.

| Plats i zonförslaget | Kontrollfråga som inte uppfylls | Var finns implicit tillit? | Föreslagen ändring | Operativ kostnad |
|---|---|---|---|---|
| `zonmodell.md`, F3, F4 och F6 | Är ssh åtkomsten begränsad till de som behöver den | Jump servern har ssh åtkomst till flera zoner, men det är inte tydligt vilka faktiskt behöver respektive åtkomst | SPecifiera vilka som behöver nå vilka mål | **Medel :** Behörigheter och regler behöver konfigureras |
| `zonmodell.md`, F7  | Modellen anger att TCP 6514 ska användas, men ställer själv frågan om TLS-loggningen är i drift och om de andra portarna kan stängas | Verifgiera TLS loggningen och kontrollera om TCP 514 och 80 kan stängas | **Låg :** Beror på befintlig konfiguration och eventuella ändringar |
| `zonmodell.md`, F6, F8 , F9 och F10 | Är de planerade trafikflödena verifierade och nödvändiga? | Flödena är markerade som planerade eller bygger på antaganden och är därför inte bevis på implementerade kontroller. | Verifiera behovet  | **Medel :** kräver dokumentation vid implementation |
|  |  |  |  |  |
