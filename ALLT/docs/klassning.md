# Klassning och CIA
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
t.ex. kundinformation och orderdata. Applikationsservern läser och skriver i den
(F9), och portalen i DMZ visar kundens ordrar via applikationsservern (F8 → F9).

| | Nivå | Motivering |
|---|---|---|
| **K** | Hög | Kunddata och privata uppgifter som läcker skadar kunderna direkt och kan inte "tas tillbaka". Kunderna kan dessutom utsättas för bedrägeri eller nätfiske med sina egna uppgifter. |
| **R** | Hög | Om data ändras blir den opålitlig eller rent felaktig, och företaget kan inte lita på någon uppgift i databasen. En ändring är ofta svår att upptäcka – en ändrad order eller ett ändrat pris kan gå obemärkt länge. |
| **T** | Hög | Utan databasen fungerar nästan ingenting. Portalen kan inte visa ordrar, kunderna kan inte se eller lägga ordrar, och företaget kan inte sälja. |

**Skyddsklass:** Hög (högsta av K, R och T).

**Varför zonen Data finns:** Databasen har högst skyddsvärde och ska ligga så långt
från internet som möjligt. DMZ är den mest exponerade zonen – den nås direkt från
internet (F1). Tas en server i DMZ över får angriparen inte nå databasen direkt
(DMZ → Data är nekat), utan måste först ta sig igenom Server-zonen, som blir en
buffert mellan internet och data. Bara applikationsservern (F9, tcp/5432) och jump
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