Minor report 2026-10-21
eMudhra incident

8st privata Intermediate CA-certifikat (Certificate Authority) nycklar har läckts då dom saknade full enkryption. 
De privata nycklarna används till verifiera identiteten på webbplatser för krypterad TLS anslutning. En angripare kan skapa nya certifikat som kan påstå sig tillhöra en pålitlig källa eller hemsida. Och på så sätt skapa en Man-in-the-middle attack.

När de privata nycklarna generades användes inte alla bits för en normal NIST P-384 private key (384 bits). Istället använde nycklarna mellan 3-8 bits vilket gör dom extremt enkla att knäcka. Exempel på nycklar är: 4, 66, och 155.
Hur man genererat felaktiga nycklar är inte ännu säkert. Men user error verkar som en möjligt förklaring.

Certifikaten har redan blockerats av bland annat Firefox, Chrome, Apple och Microsoft.

