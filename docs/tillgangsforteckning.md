# Tillgångsförteckning

## Studentservrar

Varje student har en egen Linux-server i labbmiljön. Servrarna används för projektets konfiguration, nätverksarbete och säkerhetstester.

| Tillgång | Värdnamn | DNS-namn | Intern IP-adress | Ansvarig |
|---|---|---|---|---|
| Studentserver | `elev-22` | `elev-22.sec.chas-lab.dev` | `172.20.1.122` | Student 22 |
| Studentserver | `elev-XX` | `elev-XX.sec.chas-lab.dev` | `172.20.1.(100+XX)` | Student NN |

*Ersätt XX med respektive students nummer och fyll i de faktiska uppgifterna för varje server.*

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

Uppgifterna dokumenteras utifrån kommandoutdata och labbinstruktionerna. Ej verifierade uppgifter markeras som preliminära.
