# Zero Trust Checklista

## Syfte 
Checklistan används för att granska zonmodellen mot Zero Trust principerna i NIST SP 800-207, avsnitt 2.1. Syftet med checklistan är att identifiera brister, implicit tillit och områden där ytterligare verifiering behövs

| NIST Princip | Kontrollfråga | Vilket underlag räknas som bevis? | Var kan bevis hittas? |
|---|---|---|---|
| Alla datakälor/tjänster betraktas som resurser | Är alla tjänster identifierade som resurser i zonmodellen | Dokumenterad förteckning över tjänster och deras zoner | `docs/tillgangsforteckning.md`, `docs/zonmodellen.md` |
| ALl kommunikation skyddas oavsett nätverkplats | Skyddas kommunikationen oavsett vilken zon de befinner sig i | En flödestabell med källzon, målzon, protokol, port, riktning etc. | `docs/zonmodellen.md` |
| Åtkomst till enskilda resurser beviljas i "per session basis" | Är åtkomsten till varje resurs begränsad till bara dem som behöver den | Dokumenterade åtkomstflöden och begränskningar mellan zoner Det framgår inte tillräckligt tydligt vilka användare som får åtkomst till respektive resurs | `docs/zonmodellen.md`  |
| Åtkomst till resurser styrs av dynamiska regler | baseras åtkomstbeslut på relevanta regler (identitet, behörighet) | Dokumenterade åtkomstregler baserade på identitet, enhetens säkerhetstillstånd eller andra relevanta faktorer. | `docs/zonmodellen.md`, `docs/klassicifiering.md` |
| Organisationen övervakar och mäter alla tillgångars integritet  | Finns det rutiner eller lösningar till övervakningen | Dokumentation om central loggning och övervakning samt flöden till loggservern | `docs/zonmodellen.md` |
| Autentisering och behörighetskontroll för alla resurser tillämpas dynamiskt, innan aåkomst tillåts | Är identitet och behörighet kontrollerad innan åtkomst till resurser tillåts | Dokumenterade autentiseringskrav och åtkomstkontroller | `docs/zonmodellen.md` |
| Organisation samlar in information (loggar) om tillgångar, nätverksinfrastruktur och kommunikation |  Samlas loggar om tillgångar, nätverksinfrastruktur och kommunikation | En trafikbaslinje med verifierade flöden från egna trafikfångster, inklusive källor, destinationer, portar etc. | ``docs/trafikbaslinje.md, `docs/zonmodellen.md` |

