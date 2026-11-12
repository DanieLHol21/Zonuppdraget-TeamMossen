# AI-logg – Rrezart Binaku (elev-12)

ITSX26 Kurs 2 · Team 6 "Mössen" · kursmål 9 · uppdaterad 2026-11-12

Jag har använt AI som stöd: för att fråga, få förklaringar och få utkast. Jag kör allt själv och kontrollerar resultatet. Texter jag lämnar in skriver jag med egna ord.

| # | Vecka | Fråga (prompt) | AI:s svar | Min kontroll | Rättelse / lärdom |
|---|---|---|---|---|---|
| 1 | 4 | Hur stänger jag två portar på olika sätt i U4.5? | En reject-regel och en drop-regel | Testade från jump: returkod 1 och 124 | Reject eller drop är mitt eget val |
| 2 | 5 | Hur ser jag vilka tidsservrar som används? | `chronyc sources -n` | Utskriften visade namn, inte IP | Rätt är `chronyc -n sources` |
| 3 | 5 | Vilken returkod får jag om trafik ut stoppas? | 1 | Jag fick 124, och loggen visade `ZON-UT-DROP` | Loggen visar vad som hände, inte returkoden |
| 4 | 5 | Hur får jag CA-filen till servern? | Öppna port 80 | Det bryter mot flödestabellen | Hämtade den via jump i stället |
| 5 | 6 | Ser jag bara mina egna loggar i Wazuh? | Filtrera på `location` | Jag såg elev-16, -22 och -37 också | Filtrerar alltid på min server. Samma fel gav fel svar i U6.3 (49 i stället för 26) |
| 6 | 6 | Har jag gjort rätt med min T1110-monitor från början? | Nej, den saknar filter på server | Den larmade på normaltrafiken | Lade till filter. Testkörning gav 0 |
| 7 | 6 | Vad händer här? (terminalen visade bara `>`) | Ett extra `'` i kommandot | Ctrl+C och körde om | Läs kommandot innan jag trycker Enter |
| 8 | 6 | Är det säkert att ta bort D5 (tcp/514)? | Kolla först vad som använder 514, gör backup och nödbroms | `ss` visade bara 6514. SSH och Wazuh fungerade efteråt | Ta inte bort en regel innan jag vet vad den används till |
| 9 | 6 | Peter sa att mitt testskript är fel. Vad ska ändras? | Rätt adress till loggservern, och kör inkommande tester från jump | Körde själv: 14/14 på servern, 4/4 från jump | En server kan inte testa sin egen inkommande trafik |
| 10 | 6 | Kan du hjälpa mig med ett utkast till playbook och triageposter? | Ett utkast | Gick igenom stegen och tiderna mot Wazuh | Korstestas av person 3 |

**Viktigaste lärdomen:** det är ofta i detaljerna det blir fel, till exempel fel flagga, fel adress eller fel server. Därför kontrollerar jag alltid själv innan jag litar på ett svar.

*Fylls på: korstestet och U6.4.*
