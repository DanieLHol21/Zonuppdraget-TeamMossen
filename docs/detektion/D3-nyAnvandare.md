
# D3 – Ny användare eller ändrad behörighet (T1136)

## 1. Händelse och teknik

Detektionen gäller skapande av nya användarkonton genom `useradd` och undersökning av ändringar i befintliga konton genom `usermod`.

Skapandet av nya konton motsvarar T1136 Create Account. Wazuhs standardregel 5902 är redan märkt med T1136

## 2. Loggkälla och fält

Loggkälla: autentiseringsloggen `/var/log/secure` på elev-22, vidarebefordrad till loggservern och inläst i Wazuh. Auditregeln `rootkommando` registrerar även exekveringen av administrativa kommandon.

Index: `wazuh-alerts-*`.

| **Fält** | **Värde i data** | **Betydelse** |
|---|---|---|
| `rule.id` | 5902 | Ny användare tillagd i systemet. |
| `rule.level` | 8 | Severity för standardregeln. |
| `rule.description` | New user added to the system. | Beskrivning av händelsen. |
| `rule.mitre.id` | T1136 | Create Account. |
| `data.dstuser` | `testdetektion` | Namnet på det nya kontot. |
| `data.uid` | 1001 | Användarens UID. |
| `data.gid` | 1001 | Användarens primära GID. |
| `data.home` | `/home/testdetektion` | Kontots hemkatalog. |
| `data.shell` | `/bin/bash` | Kontots skal. |
| `location` | `/var/log/remote/elev-22/syslog.log` | Loggfilen som registrerade händelsen. |

**Auditposter för useradd och usermod:**

| **Fält** | **Testvärde** | **Betydelse** |
|---|---|---|
| `proctitle` | `usermod -s /bin/bash testmod` | Kommandot och argumenten. |
| `comm` | `usermod` | Programnamnet. |
| `exe` | `/usr/sbin/usermod` | Programmets sökväg. |
| `auid` | `student` | Ursprunglig inloggad användare. |
| `uid` | `root` | Användar-ID vid exekveringen. |
| `success` | `yes` | Kommandot lyckades. |
| `exit` | `0` | Lyckad exekvering. |
| `key` | `rootkommando` | Auditregelns nyckel. |

Autentiseringsloggen registrerar `useradd` som en separat programhändelse. För `usermod` registrerades sudo-kommandot, medan auditloggen visade själva programkörningen och dess argument

## 3. Detektionslogik

**Standardregel i Wazuh: `5902 – New user added to the system`**

- Typ: Wazuh standardregel.
- Regel-ID: 5902.
- Severity: 8.
- MITRE: T1136 Create Account.
- Loggkälla: autentiseringsloggen.
- Trigger: en ny användare registreras i systemet.

Regeln verifierades genom testet:

```bash
sudo useradd testdetektion
```

Wazuh genererade ett larm med:

```text
rule.id: 5902
rule.level: 8
rule.description: New user added to the system.
data.dstuser: testdetektion
data.uid: 1001
data.gid: 1001
data.home: /home/testdetektion
data.shell: /bin/bash
```

**Varför 5902:** standardregeln identifierar själva händelsen där en ny användare skapas. Den är betydligt smalare än att leta efter alla sudo-kommandon.

Regel 5402 (nivå 3) registrerar vanliga lyckade sudo-kommandon och är därför inte lämplig som ensam detektion för kontoändringar.

**usermod:**

Ett separat test utfördes:

```bash
sudo useradd testmod
sudo usermod -s /bin/bash testmod
```

Wazuh registrerade `usermod` genom regel 5402 eftersom kommandot kördes med sudo.

Auditloggen registrerade däremot själva kommandot med `comm=usermod`, `proctitle`, `auid=student` och `success=yes`.

Ingen separat standardregel för `usermod` verifierades.

**Detektionsbeslut:** regel 5902 används för nya användare. Ändringar genom `usermod` kan undersökas genom auditloggen. En separat, smal detektion kan behövas om sådana ändringar också ska generera egna larm. Ingen egen monitor har verifierats eller byggts i denna undersökning

## 4. Vad ska och inte ska larma

| **Händelse** | **Larmar?** | **Motivering** |
|---|---|---|
| Ny användare skapas med `useradd` | Ja | Standardregel 5902 upptäcker händelsen. |
| Ny grupp skapas i samband med användarskapandet | Ja, regel 5901 kan triggas | Gruppen skapas i samband med den nya användaren |
| Vanligt sudo-kommando | Inte med 5902 | Regel 5402 registrerar vanlig sudo-aktivite |
| Ändring med `usermod` | Inte verifierat med separat regel | Testet gav regel 5402 och en auditpost |
| Diagnostisk sökning efter `useradd` | Inte ett riktigt användarskapande | En sökning i `full_log` efter ordet kan ge falska träffar |
| Flera auditposter från ett `useradd`-kommando | Ska bedömas som samma händelse | Hjälpprogram kan skapa flera auditposter |

## 5. Mätning av normaltrafik

Mätning utförd i Wazuh Discover, index `wazuh-alerts-*`

**Period 1: senaste 30 dagarna**

Sökning:

```text
rule.id: 5902 and location: *elev-22*
```

- Träffar: **1**
- Händelsen inträffade den 18 november 2026 kl. 15:43:19.
- Träffen var det egna testet med `sudo useradd testdetektion`

**Period 2: normaltrafik**

Period: 2026-11-11 kl. 08:05–08:37, strömmen `/var/log/remote/inmatat/elev-22/normal.log`.

Sökning:

```text
rule.id: 5902 and location: *inmatat*
```

- Träffar: **0**

**Sammanfattning:**

| **Mätning** | **Resultat** |
|---|---:|
| Regel 5902, senaste 30 dagarna | 1 |
| Verifierat test | 1 |
| Normaltrafik | 0 |
| Oväntade träffar | 0 |

Den enda träffen under 30-dagarsperioden var det kontrollerade testet. Ingen träff registrerades under den undersökta normaltrafikperioden

Det fullständiga verifierade övervakningsfönstret i timmar har inte fastställts. Därför beräknas ingen träffmängd per timme eller dygn

## 6. Falsklarm och begränsningar

- **Vanliga sudo-kommandon:** regel 5402 genererar larm för lyckade sudo-kommandon. Dessa ska inte automatiskt betraktas som misstänkta kontoändringar.
- **Sökningar kan ge falska träffar:** en sökning efter `useradd` i `full_log` kan även matcha exempelvis `sudo grep useradd`.
- **usermod saknar verifierad separat regel:** testet genererade regel 5402 och en auditpost, men ingen separat Wazuh-standardregel för kontoändringen verifierades.
- **Flera auditposter:** ett enda `useradd`-kommando kan skapa flera auditposter genom hjälpprogram. Dessa ska inte räknas som flera användarskapanden.
- **Auditfel:** `success=no` och `exit=ENOENT` kan avse saknade hjälpprogram och innebär inte automatiskt att själva användarskapandet misslyckades.
- **Kort normaltrafikmätning:** normaltrafiken undersöktes under 32 minuter. Noll träffar under denna period bevisar inte att falsklarm aldrig kan förekomma.
- **Begränsad mätning:** den enda träffen under 30 dagar var det egna testet. Den fullständiga övervakningsperioden har inte verifierats.
- **Regel 40112:** sex träffar hittades från jump-servern `172.20.1.2` i normaltrafikströmmen. Dessa visar att hög severity inte automatiskt innebär ett intrång.
- **Förbättring:** en separat, smal detektion för `usermod` kan byggas baserad på auditposter. Den måste först testas mot vanlig administrativ aktivitet för att mäta falsklarmrisken

Regel 40112 har nivå 12 och beskriver flera misslyckade autentiseringsförsök följda av en lyckad inloggning. Den används som triageexempel och är inte en del av själva T1136 detektionen
