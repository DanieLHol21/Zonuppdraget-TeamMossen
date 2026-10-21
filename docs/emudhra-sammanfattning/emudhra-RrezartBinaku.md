**Svaga nycklar hotar säkerheten på nätet**

Datorn använder sig av certifikat för att kunna lita på att en webbplats är äkta som t.ex. banker. Nu har det upptäckts att åtta certifikat från företaget eMudhra (Indien) var skyddade av väldigt svaga nycklar. Dessa nycklar var så svaga och enkla att vem som helst kunde knäcka dem efter en väldigt kort tid.

När detta händer kan en bedragare skapa falska certifikat med en sådan nyckel för vilken webbplats som helst. Detta är allvarligt då datorn tror att den kommunicerar med den riktiga webbplatsen, men istället får sin trafik läst av någon i bakgrunden. Detta fel upptäcktes när en okänd person kunde visa att hen fått tag på en av nycklarna. De flesta experter tror att orsaken till detta är slarvfel, och att de är chockade över hur detta inte kunde upptäckas tidigare.

Nu har de flesta webbläsare, stora appar redan blockerat certifikaten. Det finns i nuläget inga tecken på att någon tagit vara på att utnyttja felet ännu.

Det finns väldigt många system som är svåra att uppdatera, till exempel servrar, smarta prylar (IoT), och program som är lite äldre. Detta kan ta väldigt lång tid att åtgärda möjligtvis flera år enligt experter. Det kan jämföras med säkerhetsfelet Heartbleed 2014 som tog lång tid att åtgärda.

För att kunna utnyttja denna sårbarhet måste angriparen avlyssna nätverket, här kan det variera allt från ett öppet wifi till stater som övervakar sina medborgare. De som är särskilt eller mest utsatta är VPN-användare i sådana länder. För att säkra sina egna system bör man uppdatera webbläsare, appar och sitt operativsystem i detta läge.

Källa: 
Ars Technica, 20 oktober 2026: The Internet goes on high alert after discovery of 8 compromised TLS certs - Ars Technica 

eMudhra Intermediate CA Compromise, 20 oktober 2026: eMudhra Intermediate CA Compromise 
