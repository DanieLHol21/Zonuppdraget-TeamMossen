# Klassning och CIA
-----------------------------------------------
### Elevservrar (DMZ, 10.40.1.128/29)

**Funktion:** DMZ är publika tjänsten, webbplatnse och portalen som besökarna och kunder når från internet (F1) den också visar kundernas ordrar (F8)

| | Nivå | Motivering |
|---|---|---|
| **K** | Medel | Webbplatsen är publik och ska synas men servern har saker som inte är publikt: konfiguration, loggar, konton, och portalen visar kunders ordrar |
| **R** | Hög | En förändrad webbplats syns omedelbart för varje besökare: felaktig information eller skadlig kod som angriper besökarna samtlig påverkar reputationen av webbplats ägaren |
| **T** | Hög | Webbplatsen är det första intrycket av företaget om den inte fungerar det får företaget att se dåligt ut |

**Skyddsklass:** Hög

**Varför zonen finns:** den ända zonen som får nå internet är DMZ (F1). Alla andra zoner är interna och år inte nås utifrån därför behöver DMZ vara i sin egen zon bort från alla de andra. DMZ är typ en "buffer zon" så at en övertagen server inne kan inte gå vidare. Bara F8 och F3 (ssh och server) kan interagera med DMZ

-----------------------------------------------
### Jump (Admin, 10.40.1.96/28)

**Funktion:** Admin (jump) är centrala zonen som får nå fläst zoner och har flest regler (F3-F7 samt F11abc) och får nås av inernet (F2). Admin kan skapa nay behörigheter och påverka andra system

| | Nivå | Motivering |
|---|---|---|
| **K** | Hög | Eftersom admin får se alla zoner samt känslig info so loggar och DB har den hösta nivå på konfidentialitet |
| **R** | Hög | Att bevara informationens integritet inom loggzonen och databasen är det viktigaste, det är därför det får hög |
| **T** | Medel | Om admin är nere fortsätter tjänsterna att fungera webbplatsen, databasen och loggningen påverkas inte. Men ingen kan administrera servrarna eller åtgärda en incident förrän admin blir tillgänglig igen |

**Skyddsklass:**Hög

**Varför zonen finns:** Jump har nycklarna till alla servrar och är samtidigt den enda vägen in utifrån (F2). Den blir därför den mest värdefulla målet för angripare, den som tar över admin får tillgång till allt därför ligger den i sin egen zon och ahr bara flöden som behövs för administartion. Speciellt DMZ får aldrig nå admin och Admin och logg är också i separata zoner så att loggarna förblir bevis även mot administratörerna

-----------------------------------------------
### Log (LOgg, 10.40.1.120/29)

**Funktion:** Central loggning används av alla zoner utom gäst och alla zoner skicakr sina loggar hit över TLS (F7) dem används för olika saker såsom att hålla koll på flödet och upptäcka när och var något gick fel, och eftersom de sparas kan vi också gå tillbaka och titta på dem, nästan som ett kvitto.  Adminis förvaltar servrarna från jump (F4) och hanterar larmen i Wazuh(F5)

| | Nivå | Motivering |
|---|---|---|
| **K** | HGög | Eftersom det finns loggar från överallt i loggsystemet det finns loggar som som inte är konfidenteilla och även loggar som ör konfidentiella därför fick den Medel |
| **R** | Hög | Loggar måste litas på, om en logg ändras det blir nästan värdelöst, hela poängen med loggar är att ha en kvitto av allt som pågår i servrar därför fick den Hög |
| **T** | Medel | Om loggservern är nere fortsätter tjänsterna att fungera, och loggarna köas eftersom varje server har en queue. Men under tiden larmar inte Wazuh, så ett angrepp kan passera obemärkt. Vid ett långt avbrott blir köerna fulla och loggar kan bli förlorad |

**Skyddsklass:** Hög

**Varför zonen finns:** Loggar är en bevis på vad händer i systemet och måste gå att lita på. Logg tar bara emotloggar på 6514 TCP, med TLS (F7) och förvaltning från jump (F4 F5). Logg ansluter alrig till nån annan zon

-----------------------------------------------
### Applikations och driftservrar (Server, 10.40.1.64/27)

**Funktion:** Server är mellan lagret mellan portalen och DBn. Portalen frågar appen om kundens ordrar (F8) och appen skriver data i DBn (F9). Servrarna förvaltas från jump (F6)

| | Nivå | Motivering |
|---|---|---|
| **K** | H | Eftersom appen har formodligen lösenorder till DBn för att kunna logga in (F9) om nån skulle läsa appserverns config får nyckeln till all kunddata|
| **R** | H | Om appen skulle ändras, den kan då skriva fel data i DBn eller visa kunderna fel ordrar |
| **T** | H | Ligger appen nere kan portalen inte visa några ordrar och inget sparas, kundtjänsten stannar också |

**Skyddsklass:** Hög

**Varför zonen finns:** Serevr zonen är en till buffer zon mellan internet och DB. DMZ får bara nå appen på enda port (F8) och bara appen får nå DBn (F9)

-----------------------------------------------
### Företagsdatabas (Data, 10.40.1.112/29)

**Funktion:** Företagets databas. Den lagrar kunddata och privata uppgifter, t.ex kundinformation och orderdata. Applikationsservern läser och skriver i den (F9), och portalen i DMZ visar kundens ordrar via applikationsservern (F8 <> F9).

| | Nivå | Motivering |
|---|---|---|
| **K** | Hög | Kunddata och privata uppgifter som läcker skadar kunderna direkt och kan inte "tas tillbaka". Kunderna kan dessutom utsättas för bedrägeri eller nätfiske med sina egna uppgifter. |
| **R** | Hög | Om data ändras blir den opålitlig eller rent felaktig, och företaget kan inte lita på någon uppgift i databasen. En ändring är ofta svår att upptäcka – en ändrad order eller ett ändrat pris kan gå obemärkt länge. |
| **T** | Hög | Utan databasen fungerar nästan ingenting. Portalen kan inte visa ordrar, kunderna kan inte se eller lägga ordrar, och företaget kan inte sälja. |

**Skyddsklass:** Hög 

**Varför zonen Data finns:** Databasen har högst skyddsvärde och ska ligga så långt
från internet som möjligt. DMZ är den mest exponerade zonen den nås direkt från
internet (F1). Tas en server i DMZ över får angriparen inte nå databasen direkt
(DMZ > Data är nekat), utan måste först ta sig igenom Server-zonen, som blir en
buffert mellan internet och data. Bara applikationsservern (F9) och jump
för administration (F6) får nå databasen.
-----------------------------------------------
### Klientdatorer  (Klient , 10.40.0.0/24)

**Funktion:** Klientzonen är för personalens datorer ingen annan zon får anlusta till klient. Personalen kan andvända webbtjänsten i DMZ (F!0) och websurfning (F12ab) och skickar loggar (F7)

| | Nivå | Motivering |
|---|---|---|
| **K** | Medel | I klient zonen finns personalens data som epost deras dokument etc som inte är publika men det viktigaste som är gäst data ligger i DB inte i klient zonen därför får den Medel |
| **R** | Medel | Om klient blir ändrad av en angripare t.ex, drabbar det oftast bara en av peronalens dator |
| **T** | Medel | Medel: Ligger en klient nere kan en anställd inte arbeta. Ligger många nere stannar personalens arbete, men kundernas tjänster – webbplatsen och portalen – fortsätter att fungera |

**Skyddsklass:** Medel

**Varför zonen finns:** Personalen surfar fritt på internet och det kan då bli den mest sannolika vägen in för en angripare därför ligger Klient i en egen zon. Klienter får nå DMZ och interent men servrar loggar. Ingen zon får ansluta till klienterna. En kapad klientdator når alltså inte de viktiga systemen

-----------------------------------------------
### Gästnät (Gäst, 10.40.1.0/26)

**Funktion:**  Zonen för besökarna att surfa på internet (F12ab) och den når ingen intern zon. Också den enda zonen som inte skickar loggar (-F7-) 

| | Nivå | Motivering |
|---|---|---|
| **K** | Låg | Gästnättet innehåller ingen av företagets info bara besökarnas egan enheter |
| **R** | Låg | Ändras något i gästnättet drabar det bara besökarens egen enhet. |
| **T** | Låg | Om gästnättet är nere drabbas bara gäster som inte kan surfa längre men det drabar inga interna zoner |

**Skyddsklass:** Låg

**Varför zonen finns:** Gästernas enheter är okända och opålitliga därför är gäst i en egen zon helt isolerad och är den ända zonen som inte skickar loggar. Skyddkslassen är låg från företagets perspektiv eftersom det viktigaste för företaget är de interna zoner

-----------------------------------------------
### Nätverkskonfiguration  (Transit, 10.40.1.136–.147 (Länk 1–3))

**Funktion:** Länkar mellan routrarna/brandväggen. All trafik mellan alla zoner går igenom Transit och det är där flödesregler tillämps

| | Nivå | Motivering |
|---|---|---|
| **K** | H | Nätverkskonfigurationen är som en karta över hela företags nätet om någon skulle se den kan dem enkelt  visualisera hur alla zoner ser ur och se adresser portar som finns den kan visa en angripare vägar in etc |
| **R** | H| Om nätverkskonfigurationens regler ändras kan hela zonindelningen kringgås bara en regeländring som DB får nå internet och hela skyddet run DBn försvinner |
| **T** | H | Utan transit ingen kan nå något annat |

**Skyddsklass:** Hög

**Varför zonen finns:** Regeler som skyddar och separerar zoner måste själva bli skyddade om vem som helst kan ändra regler som finns mellan zoner kan de kringgå alla regler som var där från början. Därför ligger routerlänkarna i en egen zon som bara routrarna når, och de konfigureras bara från Admin