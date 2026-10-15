# Adressplan - Zonuppdraget

## Förutsätningar

Adressplanen ska beskriva hur adresser delas upp i subnät.

- Adressutrymme : 10.40.0.0/16
- Tillväxtmarignal på 25% används
- Ingen överlapp
- Bara ipv4 används Ipv6 är avstängd

## Adressplan

| Prefix | Syfte | Adressintervall | Ansvarig tjänst | Reserverat utrymme | Kommentar |
|---|---|---|---|---|---|
| 10.40.0.0/24 | Klienter | 10.40.0.1–10.40.0.254 | Klientnät | 104 | 120 * 1.25 = 150 adresser. /24 ger 254 användbara adresser |
| 10.40.1.0/26 | Gäst | 10.40.1.1–10.40.1.62 | Gästnät | 12 | 40 * 1.25 = 50 adresser. /26 ger 62 använbara adresser |
| 10.40.1.64/27 | Servrar | 10.40.1.65–10.40.1.94 | Drift av servrar | 12 | 14 * 1.25 = ~18 adresser. /27 ger 20 använbara adresser |
| 10.40.1.96/28 | Admin | 10.40.1.97–10.40.1.110 | Drift/ Adminnät | 6 | 6 * 1.25 = ~8 adreser. /28 ger 14 användbara adresser |
| 10.40.1.112/29 | DB | 10.40.1.113–10.40.1.118 | Databas tjänst | 1 | 4 × 1.25 = 5 adresser. /29 ger 6 användbara adresser |
| 10.40.1.120/29 | Logs | 10.40.1.121–10.40.1.126 | övervakningtjänst/ loggar | 1 | 4 × 1.25 = 5 adresser. /29 ger 6 användbara adresser |
| 10.40.1.128/29 | DMZ  | 10.40.1.129–10.40.1.134 | DMZ | 1 | 4 × 1.25 = 5 adresser. /29 ger 6 användbara adresser |
| 10.40.1.136/30 | Länk 1 | 10.40.1.137–10.40.1.138 | Routing | / | 2 ändpunkter. /30 ger 2 använbara adresser |
| 10.40.1.140/30 | Länk 2 | 10.40.1.141–10.40.1.142 | Routing | / | 2 ändpunkter. /30 ger 2 använbara adresser |
| 10.40.1.144/30 | Länk 3 | 10.40.1.145–10.40.1.146 | Routing | / | 2 ändpunkter. /30 ger 2 använbara adresser |

# Subnät Beräkningar

### Klienter /24
Nuvarande : 120
Tillväxt : 25% = 150
/25 ger bara 126 adresser som räcker inte
/24 ger 254 adresser, vald

Nätmask: 255.255.255.0
Broadcastadress: 10.40.0.255

### Gäster  /26
Nuvarande : 40
Tillväxt : 25% = 50
/26 ger 62 adresser, vald

Nätmask: 255.255.255.192
Broadcastadress: 10.40.1.63

### Servrar  /27
Nuvarande : 14
Tillväxt : 25%= 18
/28 ger 14 adresser som räcker inte med 25% tillväxt
/27 ger 30 adresser, vald

Nätmask: 255.255.255.224
Broadcastadress: 10.40.1.95

### Admin  /28
Nuvarande : 6
Tillväxt : 8
/29 ger 6 adresser som räcker inte med 25% tillväxt
/28 ger 14 adresser, vald

Nätmask: 255.255.255.240
Broadcastadress: 10.40.1.111

### DB  /29
Nuvarande : 4
Tillväxt : 25% = 5
/29 ger 6 adresser, vald

Nätmask: 255.255.255.248
Broadcastadress: 10.40.1.119


### Logs  /29
Nuvarande : 3
Tillväxt : 25% = 4
/29 ger 6 adresser, vald

Nätmask: 255.255.255.248
Broadcastadress: 10.40.1.127

### DMZ  /29
Nuvarande : 4
Tillväxt : 25% = 5
/29 ger 6 adresser, vald

Nätmask: 255.255.255.248
Broadcastadress: 10.40.1.135

### Routerlänkar /30
Antal länkar: 3
Behov per länk: 2 IP-adresser, en för varje ändpunkt
/30 innehåller 4 IP-adresser, varav 2 är användbara, vald

*Länk 1 — 10.40.1.136/30*

Nätmask: 255.255.255.252
Broadcastadress: 10.40.1.139

*Länk 2 — 10.40.1.140/30*

Nätmask: 255.255.255.252
Broadcastadress: 10.40.1.143

*Länk 3 — 10.40.1.144/30*

Nätmask: 255.255.255.252
Broadcastadress: 10.40.1.147
