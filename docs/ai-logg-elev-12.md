# AI-logg – Rrezart Binaku (elev-12)

ITSX26 Kurs 2 · Team 6 "Mössen" · kursmål 9 · uppdaterad 2026-11-23

## Hur jag använder AI

Jag använder Claude som stöd när jag vill fråga något, få en förklaring eller få ett utkast. Allt kör jag själv, och jag kollar resultatet på min egen server. Det jag lämnar in skriver jag med egna ord.

- **Ett steg i taget.** Jag ber om ett kommando i taget och en kort förklaring, och går vidare först när jag förstår.
- **Servern bestämmer.** Kan jag inte visa något med ett kommando litar jag inte på det.
- **Egna ord.** AI får föreslå, men jag skriver om svaren så att jag kan förklara dem själv.
- **Inget känsligt.** Interna IP-adresser byter jag mot `IP-INTERN-BORTTAGEN`. Lösenord, nycklar, flaggor och kvitton ger jag aldrig till AI.

## Logg

| # | Vecka | Vad jag frågade | Vad AI svarade | Hur jag kollade | Vad jag lärde mig |
|---|---|---|---|---|---|
| 1 | 4 | Hur stänger jag två portar på olika sätt (U4.5)? | En reject-regel och en drop-regel | Testade från jump: returkod 1 och 124 | Reject eller drop väljer jag själv |
| 2 | 5 | Hur ser jag vilka tidsservrar som används? | `chronyc sources -n` | Den visade namn, inte IP | Rätt är `chronyc -n sources` |
| 3 | 5 | Vilken returkod får jag när trafik ut stoppas? | 1 | Jag fick 124, och loggen visade `ZON-UT-DROP` | Loggen visar vad som hände, inte returkoden |
| 4 | 5 | Hur får jag CA-filen till servern? | Öppna port 80 | Det bryter mot flödestabellen | Hämtade den via jump i stället |
| 5 | 6 | Ser jag bara mina egna loggar i Wazuh? | Filtrera på `location` | Jag såg andra elevers loggar också | Filtrera alltid på min server. Annars fick jag 49 i stället för 26 i U6.3 |
| 6 | 6 | Är min T1110-monitor rätt från början? | Nej, filter på server saknas | Den larmade på andras trafik | Lade till filter, sedan 0 falsklarm |
| 7 | 6 | Varför visar terminalen bara `>`? | Ett extra `'` i kommandot | Ctrl+C och körde om | Läs kommandot innan Enter |
| 8 | 6 | Kan jag ta bort D5 (tcp/514)? | Kolla först vad som använder den, gör backup och nödbroms | `ss` visade bara 6514. Allt fungerade efteråt | Ta inte bort en regel innan jag vet vad den gör |
| 9 | 6 | Vad är fel i mitt testskript? | Fel adress, och inkommande ska testas från jump | 14/14 på servern, 4/4 från jump | Servern kan inte testa sin egen inkommande trafik |
| 10 | 6 | Kan du göra ett utkast till playbook och triagelogg? | Ett utkast | Jag gick igenom stegen och tiderna mot Wazuh. Korstestet med teamet blev inte av | Utkastet är bara en start. Jag måste kolla allt själv |
| 11 | 6 | Hur hittar jag rätt händelse bland 201 (U6.1)? | Räkna nivåerna med jq först | Bara en händelse hade nivå 8 | Räkna först, läs sedan |
| 12 | 6 | Varför fungerar inte mitt jq-kommando (U6.4)? | Det är en händelse per rad, så `.[]` ska bort | Hittade kedjan från 10.40.2.155 | Kolla hur filen ser ut innan jag skriver kommandot |
| 13 | 6 | Hur hittar jag något som inga regler fångar (U6.5)? | Titta på programnamnen | `syncagent` skickade data var 10:e sekund. Min egen monitor larmade | Det som är tillåtet syns inte i brandväggsloggen |
| 14 | 6 | Hjälp med Ö1–Ö10 | Utkast utifrån mitt arbete | Jämförde med föreläsningen och skrev om | Svara på varje delfråga |
| 15 | 7 | Hur ser jag SELinux-läget nu och efter omstart (U7.1)? | `getenforce`, `sestatus` och config-filen | Allt visade enforcing | Nu och efter omstart är olika saker |
| 16 | 7 | Varför får jag 403 (U7.2)? | Läs felet först. Filen har fel typ, använd `semanage fcontext` | Felet visade `var_t`. Efter ändringen fungerade sidan | Läs felet innan jag ändrar något |
| 17 | 7 | Vilka SSH-inställningar borde jag ändra? | Lösenord och root-inloggning, men vänta | Jag loggar in med lösenord, och ctf loggar in som root | Ett vanligt råd kan låsa ute mig. Kolla först |
| 18 | 7 | Vilka regler från audit2allow ska in (U7.3)? | Gick igenom varje rad, och aldrig skrivrätt i /etc | `overtrad` nekades efteråt | audit2allow föreslår allt, även det som ska nekas |
| 19 | 7 | Varför kraschar zonvakt? | **Fel gissning:** att jag testade för snabbt | `journalctl` visade att den inte fick skicka svar | AI:s första svar kan vara fel. Loggen visade sanningen |
| 20 | 7 | Hur hittar jag samma fel i Wazuh? | Sök på `comm=zonvakt` och jämför numret | Samma nummer (2979) lokalt och i Wazuh | Samma nummer = samma händelse |
| 21 | 7 | Hur hittar jag den riktiga händelsen (U7.4)? | Filtrera på `permissive=0` | Bara en händelse matchade | permissive=1 betyder bara loggat, inte stoppat |
| 22 | 7 | Hjälp med ett skript som bara kollar (U7.5) | Skript med GÄLLER och GÄLLER INTE | Testade att det kan säga GÄLLER INTE. Efter omstart gällde allt | Ett test som alltid säger ja bevisar inget |
| 23 | 7 | Skriv varför jag ändrade socket-raden | AI skrev en orsak som om den var säker | Jag kunde inte visa den med något kommando | Ändrade till "troligen". Skriv bara det jag kan visa |
| 24 | 7 | Gör ett utkast till härdningsrapport (ny chatt, maskerat) | 63 påståenden | **2 var fel:** AI sa att allt gjordes under workshop 1, men datumen visade att brandväggen var från vecka 4 | Ett snyggt svar är inget bevis |
| 25 | 7 | Vad ska ändras i teamets filer för F13c? | Hittade gamla saker, till exempel D5 och en fel sökväg | Kollade i repot: filen fanns inte. Testade F13c → stängd från jump | AI ser inte repot. Jag kollar själv |
| 26 | 7 | Hur gör jag porten snävare (U7.6)? | En egen porttyp i stället för alla portar | `sesearch` visade bara min port. På port 7513 startade tjänsten inte | Tillåt så lite som möjligt, och testa att resten nekas |

## När AI hade fel

| Fall | Vad AI sa | Typ av fel | Hur jag märkte det |
|---|---|---|---|
| 2 | Fel ordning i kommandot | Uppfunnet | Utskriften såg fel ut |
| 3 | Fel returkod | Ogrundat | Jag körde testet |
| 4 | Öppna port 80 | Bröt mot vår design | Jämförde med flödestabellen |
| 19 | Fel orsak till kraschen | Ogrundat | `journalctl` |
| 23 | En orsak som fakta | Ogrundat | Inget kommando kunde visa den |
| 24 | Allt gjort under workshop 1 | Faktafel | Filernas datum |
| 25 | Fel sökväg i repot | Inaktuellt | Kollade i repot |

## Hur jag har blivit bättre

- **Vecka 4–5:** jag märkte att det ofta är små detaljer som blir fel. Därför började jag testa allt själv.
- **Vecka 6:** jag lärde mig att alltid filtrera på min egen server, och att en nolla också måste kontrolleras.
- **Vecka 7:** jag gick igenom ett helt AI-utkast, påstående för påstående, och satte ett kommando bredvid varje. Jag dolde känsliga uppgifter och använde en ny chatt, så att AI bara hade mitt eget material.

**Viktigaste lärdomen:** att något låter rätt betyder inte att det är rätt. Jag frågar mig alltid: hur kan jag kolla det här på servern?
