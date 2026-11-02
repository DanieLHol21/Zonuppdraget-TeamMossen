# Dokumentation: Loggning och centralisering (Person 4)

## Central loggning
Brandväggsloggar från Linux-kärnan (`kern.*`) vidarebefordras till den centrala loggservern via TCP.

- **Loggserver:** 172.20.1.58:514 (TCP)
- **Konfigurationsfil:** `configs/rsyslog/60-brandvagg.conf`
- **Kölösning:** LinkedList för att förhindra dataförlust vid nätverksavbrott (`queue.saveOnShutdown="on"`).

## Loggning i Brandväggen (nftables)
Blockerad och avvisad trafik loggas med `log prefix`-regler i `nftables` före drop/reject-åtgärder.
Loggposterna fångas av kärnan och skickas vidare via rsyslog-regeln ovan.

## Verifiering
1. **Nätverk:** Ansluten till teamnätet på `eth2` (IP `10.40.6.5/32`).
2. **rsyslog:** Tjänsten omstartad och aktiv utan felmeddelanden.
3. **Filsynkronisering:** Konfigurationsfil placerad under `configs/rsyslog/60-brandvagg.conf`.
