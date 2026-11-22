# Sammanställd härdningsrapport – Milstolpe 7 (Rocky Linux 9 & SELinux)

**Projekt / Miljö:** Infrastruktursäkerhet & Härdning med Mandatory Access Control (SELinux)  
**Plattform:** Rocky Linux 9 (`elev-25` m.fl.)  
**Sammanställd av:** Rrezart Binaku (Person 1)  

## 1. Syfte och målgrupp
Denna rapport sammanfattar de tekniska härdningsåtgärder som genomförts och verifierats på teamets Rocky Linux 9-servrar. Rapporten är skriven för drift- och förvaltningspersonal så att varje konfiguration kan spåras, förstås och återverifieras automatiskt efter systemuppdateringar eller omstarter.

## 2. Sammanfattande kontrollöversikt per teammedlem
* **Person 1 (SSH & Konton – Rrezart Binaku):** 4 verifierade rader (`P1-1` till `P1-4`) – alla 4 verifieras via `scripts/verifiera-hardning-p1.sh`.
* **Person 2 (Tjänster, portar & paketfilter):** *(Kompletteras från `docs/hardning/hardningslista-p2.md` när PR är mergad – krav: minst 2 rader med omkörbart skript).*
* **Person 3 (Loggning & granskning / audit):** *(Kompletteras från `docs/hardning/hardningslista-p3.md` när PR är mergad – krav: minst 2 rader med omkörbart skript).*
* **Person 4 (SELinux-policyer & filkontexter):** *(Kompletteras från `docs/hardning/hardningslista-p4.md` när PR är mergad – krav: minst 2 rader med omkörbart skript).*

## 3. Sammanställd härdningstabell

| Person | Rad-ID | Åtgärd | Motivering | Effekt | Hur den verifierades | Verifieringsskript |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Person 1** | **P1-1** | Aktivera SELinux i `Enforcing` (nu och i `/etc/selinux/config`) samt kör `zonvakt` under egen tvingande domän (`zonvakt_t`). | MAC begränsar skadan om en tjänst komprometteras, även om tjänsten kör som `root`. | Otillåtna fil- och portåtkomster blockeras och loggas som AVC-nekelser, beständigt över omstart. | `getenforce`, `sestatus`, `ps -eZ \| grep zonvakt` samt test med `overtrad`. | `scripts/verifiera-hardning-p1.sh` (P1-1) |
| **Person 1** | **P1-2** | Stäng av lösenordsinloggning och tomma lösenord i SSH (`PasswordAuthentication no`, `PermitEmptyPasswords no`) via `05-hardning-p1.conf`. | Förhindrar brute-force-attacker mot SSH utan att bryta ctf-serverns nyckelinloggning för `root`. | Endast SSH-nycklar accepteras vid autentisering. | `sshd -T` samt inloggningstest i separat SSH-session. | `scripts/verifiera-hardning-p1.sh` (P1-2) |
| **Person 1** | **P1-3** | Sätt `MaxAuthTries 3` och `X11Forwarding no` i SSH-konfigurationen (`05-hardning-p1.conf`). | Begränsar antalet gissningsförsök per anslutning och stänger av onödig X11-vidarebefordran. | Anslutningar bryts efter 3 felaktiga försök och X11-attackytan elimineras. | `sshd -T` samt omkörning av skript efter omstart. | `scripts/verifiera-hardning-p1.sh` (P1-3) |
| **Person 1** | **P1-4** | Säkerställ att endast `root` och `student` har interaktivt inloggningsskal och kontrollera `wheel`/`sudoers`. | Tjänstekonton ska inte kunna användas för interaktiv skalinloggning vid ett intrång. | Endast avsedda administratörskonton har interaktivt skal och `sudo`-rättigheter. | Granskning av `/etc/passwd`, `getent group wheel` och `/etc/sudoers.d/`. | `scripts/verifiera-hardning-p1.sh` (P1-4) |
| **Person 2** | **P2-1** | *(Klistra in rad 1 från Person 2)* | *(Motivering P2)* | *(Effekt P2)* | *(Verifiering P2)* | `scripts/verifiera-hardning-p2.sh` |
| **Person 2** | **P2-2** | *(Klistra in rad 2 från Person 2)* | *(Motivering P2)* | *(Effekt P2)* | *(Verifiering P2)* | `scripts/verifiera-hardning-p2.sh` |
| **Person 3** | **P3-1** | *(Klistra in rad 1 från Person 3)* | *(Motivering P3)* | *(Effekt P3)* | *(Verifiering P3)* | `scripts/verifiera-hardning-p3.sh` |
| **Person 3** | **P3-2** | *(Klistra in rad 2 från Person 3)* | *(Motivering P3)* | *(Effekt P3)* | *(Verifiering P3)* | `scripts/verifiera-hardning-p3.sh` |
| **Person 4** | **P4-1** | *(Klistra in rad 1 från Person 4)* | *(Motivering P4)* | *(Effekt P4)* | *(Verifiering P4)* | `scripts/verifiera-hardning-p4.sh` |
| **Person 4** | **P4-2** | *(Klistra in rad 2 från Person 4)* | *(Motivering P4)* | *(Effekt P4)* | *(Verifiering P4)* | `scripts/verifiera-hardning-p4.sh` |

## 4. Instruktion för driftpersonal (omkörning av verifiering)
Samtliga verifieringsskript i katalogen `scripts/` läser endast av systemets konfiguration och tillstånd utan att göra ändringar:

```bash
sudo bash scripts/verifiera-hardning-p1.sh
