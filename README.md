# Zonuppdraget-TeamMössen

Detta är vårt gemensamma GitHub-repo för **Zonuppdraget – Kurs 2: Infrastruktur och nätverksgrunder**.

Här samlar vi projektets dokumentation, konfigurationer, skript, detektioner, playbooks och annat material som hör till projektet.

## Klona repot

Första gången du ska arbeta med projektet behöver du klona repot till din dator.

### 1. Öppna Git Bash

Gå till den mapp där du vill ha projektet.

### 2. Klona repot

Kopiera repo-länken från GitHub och kör:

git clone <REPO-URL>

Exempel:

git clone https://github.com/username/zonuppdraget.git

Gå sedan in i projektmappen:

cd zonuppdraget


## Skapa en egen branch

**Arbeta ALRDIG direkt på `main`.**

Skapa istället en egen branch för det du arbetar med:

git switch -c ditt-namn/uppgift

Du kan kontrollera vilken branch du är på med:

git branch

Branchen med `*` framför är den du arbetar på.


## Spara ditt arbete

När du är klar med dina ändringar:

### 1. Kontrollera vad som ändrats

git status

### 2. Lägg till ändringarna

git add .

### 3. Skapa en commit

git commit -m "Lägg till IP-adressplan"

### 4. Pusha till GitHub

Första gången du pushar din branch:

git push -u origin ditt-namn/uppgift

Exempel:

git push -u origin alex/adressplan


## Pull Request

När din uppgift är klar skapar du en **Pull Request (PR)** på GitHub.

Arbetsflödet är:

Egen branch
     ↓
Gör ändringar
     ↓
Commit
     ↓
Push
     ↓
Pull Request
     ↓
Minst 1 annan student granskar och godkänner
     ↓
Merge till main

Ändringar ska inte göras direkt i `main`.


# Bra att tänka på

### Skriv tydliga commit-meddelanden

Undvik:

test
fix
stuff
ändringar
asdf

Skriv istället vad du faktiskt gjorde:

Lägg till IP-adressplan
Uppdatera zonmodell
Lägg till verifieringsskript
Fixa brandväggsregler
Uppdatera loggstrategi


### Håll en branch till en uppgift

Försök att inte blanda flera helt olika saker i samma branch.

Exempel:

alex/adressplan

bör främst innehålla arbete med adressplanen.


### Pusha ditt arbete regelbundet

Gör commits under arbetets gång istället för att vänta tills allt är färdigt.


### Kontrollera alltid innan du committar

Kör:

git status

så att du vet vilka filer som kommer att committas.


### Lägg aldrig upp hemligheter

Lägg aldrig upp:

- lösenord
- privata SSH-nycklar
- API-nycklar
- access tokens
- molnuppgifter
- andra hemliga uppgifter


### Var försiktig med kommandon du inte känner till

Kör inte kommandon som kan ta bort eller skriva över arbete om du inte vet vad de gör.

Om du är osäker, fråga först.


## De viktigaste kommandona

git clone <repo-url>

git switch -c <branch>

git status

git add .

git commit -m "Beskriv ändringen"

git push -u origin <branch>
