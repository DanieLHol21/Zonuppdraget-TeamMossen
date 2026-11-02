# Tillgångsförteckning (Asset Inventory)

## 1. Syfte och Omfång
Denna tillgångsförteckning identifierar och dokumenterar servrar, nätverksenheter, IP-adresser och aktiva tjänster inom projektets miljö. 

*Obs! Dokumentet skiljer på den befintliga labbmiljön (`172.20.1.0/24`) och den planerade målarkitekturen/adressplanen (`10.40.0.0/16`).*

---

## 2. Tillgångar i Labbmiljön (`172.20.1.0/24`)

| Hostnamn / Enhet | IP-adress (Labb) | Tjänst / Roll | Protokoll & Portar | Beskrivning / Anmärkning |
| :--- | :--- | :--- | :--- | :--- |
| **Jump-server** | `172.20.1.2` | Bastion Host / SSH Jump | TCP 22 | Central inloggnings- och administrationspunkt för labbmiljön. |
| **CTF-server / Inlämning** | `172.20.1.10` | Kontroll- & CTF-tjänst | TCP 80, TCP 22 | Server för kontroll och inlämning av flaggor/uppgifter. |
| **Student-server (Elev-25)** | `172.20.1.137` | Klient / Webbservis-node | TCP 22, TCP 80 | Elevinstans som kör lokala tjänster och kommunicerar med jump-servern. |
| **Labbnätverk (Subnät)** | `172.20.1.0/24` | Labbgruppsnätverk | Blandat | Internt delat nätverk för laboratorium. |

---

## 3. Mappning mot Ny Adressplan (`10.40.0.0/16`)

Inför zonmodellering och mikrosegmentering mappas systemens roll över till det nya valda adressutrymmet enligt casedirektivet:

| Roll / Zontillhörighet | Nytt Adressutrymme (Exempel) | Tillåtna Tjänster / Portar | Klassificering |
| :--- | :--- | :--- | :--- |
| **Management / Jump** | `10.40.10.0/24` | SSH (TCP 22) | Hög / Kritiskt adminstöd |
| **Webb / Tjänster** | `10.40.20.0/24` | HTTP (TCP 80), HTTPS (TCP 443) | Medel / Publik/Intern tjänst |
| **Internt / Kontroll** | `10.40.30.0/24` | Specifika kontrollportar | Hög / Intern styrning |

---

## 4. Ägandeskap och Underhåll
- **Ansvarig:** Person 4 (Tillgångsförteckning & Trafikbaslinje)
- **Status:** Verifierad mot trafikfångster och uppdragsbeskrivning.
- **Senast uppdaterad:** Oktober 2026
