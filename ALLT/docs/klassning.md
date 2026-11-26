# Klassning och CIA
-----------------------------------------------
### Namn (DMZ, 10.40.1.128/29)

**Funktion:** DMZ är publika tjänsten, webbplatnse och portalen som besökarna och kunder når från internet (F1) den också visar kundernas ordrar (F8)

| | Nivå | Motivering |
|---|---|---|
| **K** | Medel | Webbplatsen är publik och ska synas men servern har saker som inte är publikt: konfiguration, loggar, konton, och portalen visar kunders ordrar |
| **R** | Hög | En förändrad webbplats syns omedelbart för varje besökare: felaktig information eller skadlig kod som angriper besökarna samtlig påverkar reputationen av webbplats ägaren |
| **T** | Hög | Webbplatsen är det första intrycket av företaget om den inte fungerar det får företaget att se dåligt ut |

**Skyddsklass:** Hög

**Varför zonen finns:** den ända zonen som får nå internet är DMZ (F1). Alla andra zoner är interna och år inte nås utifrån därför behöver DMZ vara i sin egen zon bort från alla de andra. DMZ är typ en "buffer zon" så at en övertagen server inne kan inte gå vidare. Bara F8 och F3 (ssh och server) kan interagera med DMZ

-----------------------------------------------
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**

-----------------------------------------------
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**

-----------------------------------------------
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**

-----------------------------------------------
### Företagsdatabas (Data, 10.40.1.112/29)

**Funktion:** Företagets databas. Den lagrar kunddata och privata uppgifter,
t.ex kundinformation och orderdata. Applikationsservern läser och skriver i den
(F9), och portalen i DMZ visar kundens ordrar via applikationsservern (F8 <> F9).

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
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**

-----------------------------------------------
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**

-----------------------------------------------
### Namn (Zon, subnät)

**Funktion:** 

| | Nivå | Motivering |
|---|---|---|
| **K** |  |  |
| **R** |  |  |
| **T** |  |  |

**Skyddsklass:** 

**Varför zonen finns:**