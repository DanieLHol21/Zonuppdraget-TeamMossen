# Tillgångsförteckning

## Studentservrar

Varje student har en egen Linux-server i labbmiljön. Servrarna används för projektets konfiguration, nätverksarbete och säkerhetstester.

| Tillgång | Värdnamn | DNS-namn | Intern IP-adress | Ansvarig |
|---|---|---|---|---|
| Studentserver | `elev-22` | `elev-22.sec.chas-lab.dev` | `172.20.1.122` | Student 22 |
| Studentserver | `elev-XX` | `elev-XX.sec.chas-lab.dev` | `172.20.1.(100+XX)` | Student XX |

## Gemensamma servrar

| Tillgång | Värdnamn | DNS-namn | Intern IP-adress | Funktion |
|---|---|---|---|---|
| Jump-server | `jump` | `jump.sec.chas-lab.dev` | `172.20.1.2` | SSH-åtkomst till studentservrarna |
| Loggserver | `log` | `log.sec.chas-lab.dev` | `172.20.1.58` | Central logginsamling |
| CTF-server | `ctf` | `ctf.sec.chas-lab.dev` | `172.20.1.10` | Mottagning av flaggor |

## Verifiering

Varje student verifierar sin egen server med följande kommandon:

```bash
hostname
ip -br addr
ip route
sudo ss -tulpn
```

Uppgifterna dokumenteras utifrån kommandoutdata och labbinstruktionerna. 

# Tjänsteinventering

Tabllene visar identifierade tjänster och portar på studetn servern. 

| Server | Tjänst | Protokoll/port | Funktion | Status |
|---|---|---|---|---|
|elev-xx | sshd | TCP/22 | åtkomst via ssh | verifierad |
|elev-xx | Apache (httpd) | TCP/80 | webbserver | verifierad |
|elev-xx | chronyd | UDP/323 | Tid sync. | verifierad |
|elev-xx | rsyslog | / | logghantering | Tjänsten körs, loggning ej verifierad |
|log | HTTP testtjänst | ej fastställd | test av anslutning | enligt labbinstruktioner  |
|log |  |  |  |  |

# Server Info
| Server | Roll | 
|---|---|---|
| elev-xx | student server för projektets tester 
| jump | ingångpunkt för ssh till studetn servern |
| log | logginsamling |
| ctf | mottagning av ctf falggor |

# Verifiering

Uppgifterna hämtas från labbinstruktionerna och kommandoutdata från respektive server. Följande kommandon används för att kontrollera studentservrarna:
```bash
hostname
ip -br addr
ip route
sudo ss -tulpn
sudo systemctl --type=service --state=running```