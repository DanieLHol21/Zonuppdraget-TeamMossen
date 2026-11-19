# Playbook D3 – Ny användare eller ändrad behörighet (T1136)

Detektion: `docs/detektion/D3-ny-anvandare.md`

| | |
|---|---|
| ATTCK | T1136 Create Account |
| Standardregel | `5902 – New user added to the system` |
| Monitor | Standardregel 5902 (se D3-dokumentationen) |
| Trigger | Ny användare registrerad genom regel 5902 |
| Index | `wazuh-alerts-*` |

*När används playbooken:** när ett larm om en ny användare eller misstänkt kontoändring upptäcks i Wazuh.

**Vad 5902 betyder:** Wazuhs regel för när en ny användare läggs till i systemet. Regeln är nivå 8 och kopplad till MITRE T1136.

Regel 5402 registrerar vanliga sudo-kommandon på nivå 3. Den ska inte ensam betraktas som bevis för att en användare har skapats eller ändrats.

## 1. Förberedelse

1. Kontrollera i Alerting → Monitors om relevant monitor är Enabled, om en separat monitor används
3. Kontrollera att loggkedjan fungerar genom att söka `location: *elev-22*` i `wazuh-archives-*`, senaste 15 minuterna
3. Ta reda på om det finns planerade kontoändringar eller administrativa tester på elev-22
4. Skriv ner vem som ska utföra ändringen, vilket konto som berörs och när den ska ske

## 2. Detektion och analys

**Vad har hänt **

1. Öppna larmet i Alerting → Alerts. Anteckna regel, starttid och severity.
2. Öppna Discover, index `wazuh-alerts-*`. Sätt tiden till larmets starttid minus 5 minuter → starttid plus 5 minuter.
3. Sök:

```text
rule.id: 5902 and location: *elev-22*
```

4.
5. Lägg till kolumnerna `data.dstuser`, `data.uid`, `data.gid`, `data.home`, `data.shell`, `rule.id`, `rule.level` och `location`.
7. Öppna en träff och kontrollera:
   - Vilket användarkonto skapades?
   - Vilket UID och GID tilldelades?
   - Vilken hemkatalog och vilket skal används?
   - Vilken loggkälla registrerade händelsen?

8. Kontrollera autentiseringsloggen på elev-22:

```bash
sudo grep -E 'useradd|usermod' /var/log/secure | tail -30
```

7. Kontrollera auditposterna:

```bash
sudo ausearch -k rootkommando -i -c useradd
```

För `usermod`:

```bash
sudo ausearch -k rootkommando -i -c usermod
```

Läs särskilt:
   - `proctitle`: vilket kommando som kördes.
   - `auid`: vem som ursprungligen loggade in.
   - `uid` och `euid`: vilket konto kommandot kördes som.
   - `success` och `exit`: om exekveringen lyckades.

8. Om det gäller `usermod`, sök i Wazuh:

```text
location: *elev-22* and full_log: *usermod*
```

Kontrollera om träffarna är regel 5402 eller en annan regel. Regel 5402 är vanlig sudo-aktivitet och räcker inte som bevis på en separat detektion av kontoändringar.

9. Kontrollera även om det finns andra relevanta kontoändringar under samma tidsintervall.

**Beslutspunkt – avfärda eller eskalera?**

| Observation | Beslut |
|---|---|
| Ny användare skapad under ett dokumenterat test | Avfärda. Dokumentera testet och tidpunkten. |
| Ny användare skapad utan känd eller godkänd anledning | Eskalera för vidare undersökning. |
| Oväntat UID, hemkatalog eller skal | Undersök vidare och eskalera vid misstanke. |
| Endast regel 5402 från ett vanligt sudo-kommando | Avfärda som bevis för kontoändring. |
| Regel 5901 och 5902 samtidigt | Undersök som en del av samma användarskapande händelse. |
| `usermod` ändrar kontoinformation eller gruppmedlemskap utan godkännande | Eskalera för vidare undersökning. |
| Händelsen kan kopplas till ett godkänt administrativt arbete | Dokumentera underlaget och avfärda om ändringen verifierats. |

**Eskalera till:** [KONTROLLERA: rollen för triage i teamet och den som äger servern].

Underlag: larmets starttid (UTC), regel, användarkonto, UID, GID, hemkatalog, skal, `auid` och relevanta auditposter.

## 3. Begränsning, utrotning och återställning (vid eskalering)

1. Kontrollera kontot:

```bash
getent passwd <konto>
```

2. Kontrollera gruppmedlemskap:

```bash
id <konto>
```

3. Kontrollera nyligen skapade konton:

```bash
getent passwd | tail -10
```

4. Kontrollera root-kommandon som har utförts:

```bash
sudo ausearch -k rootkommando -i | tail -30
```

5. Vid bekräftad obehörig kontoändring: diskutera med serverägaren om kontot ska låsas eller tas bort. Ändra inte konton innan det är säkerställt att de inte tillhör en legitim användare eller tjänst

6. Verifiera efteråt genom att söka efter nya regel 5902-larm och relevanta `usermod`-händelser

## 4. Efterarbete

1. Skriv en post i `docs/detektion/triagelogg.md`:
   - Tid (UTC).
   - Larm och regel.
   - ATT&CK-ID.
   - Observation (vad som faktiskt syntes i loggarna).
   - Slutsats (vad händelsen bedömdes innebära).
   - Beslut och motivering.

2. Stäng larmet genom Acknowledge i Alerting om det fortfarande är Active.
3. Om larmet var ett falsklarm, skriv vad som skulle ändras i `D3-ny-anvandare.md`.
4. Ändra inte regler eller monitorer utan att först mäta bruset igen.

## Regel 40112 – triageexempel

Regel 40112 har nivå 12 och beskriver flera misslyckade autentiseringsförsök följda av en lyckad inloggning.

Sök i `wazuh-alerts-*`:

```text
rule.id: 40112 and location: *elev-22*
```

I undersökningen hittades 6 träffar från `172.20.1.2`, användaren `student`, i normaltrafikströmmen.

Jump-servern är en känd legitim källa. Kontrollera därför alltid källadress, användare, tidpunkt och loggkälla innan eskalering

## Gränsfall (ska inte automatiskt leda till åtgärd)

- Ett vanligt sudo-kommando ger regel 5402 men innebär inte automatiskt en kontoändring.
- Diagnostiska kommandon som `grep useradd` kan matcha sökningar efter `useradd` i `full_log`.
- En ny användare kan ge flera auditposter från samma kommando.
- En ny grupp som skapas tillsammans med en användare ska bedömas tillsammans med regel 5902.
- Regel 40112 från den kända jump-servern kan förekomma i normaltrafik.

## Korstest

Kontrollera att personen kan:
- Identifiera vilket konto som skapades.
- Hitta relevanta fält i Wazuh.
- Förstå skillnaden mellan autentiseringsloggen och auditposterna.
- Skilja vanlig sudo-aktivitet från faktiska kontoändringar.
- Undersöka `usermod`.
- Bedöma och dokumentera en misstänkt händelse.
