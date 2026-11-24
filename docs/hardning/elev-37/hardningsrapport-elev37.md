# Underlag som matades in:

hardningslista-elev37.md
serverresultat.txt
verifiera-hardning.sh
zonvakt.fc
zonvakt.service
zonvakt.sh
zonvakt.te


# Prompt:

Uppgift: Granska SELinux-härdning på Rocky Linux

Du ska agera som en teknisk granskare av en Rocky Linux-server.

Jag bifogar underlag från min egen server, elev-37. Underlaget innehåller:

Min härdningslista.
Min SELinux-policy för Zonvakt (zonvakt.te).
Filkonfigurationen (zonvakt.fc).
Bygg- och installationsskriptet (zonvakt.sh).
Systemd-konfigurationen (zonvakt.service).
Mitt verifieringsskript.
Faktiska kommandoutskrifter från servern.

Din uppgift är att skriva ett utkast till en teknisk härdningsrapport.

Krav:

Beskriv hur SELinux används i enforcing-läge.
Beskriv hur Zonvakt använder en egen SELinux-domän.
Förklara hur filkontexter används.
Beskriv vad verifieringsskriptet kontrollerar.
Använd endast information som stöds av underlaget.
Hitta inte på resultat eller konfigurationer.
Om information saknas ska du uttryckligen ange att den inte går att verifiera.
Skilj mellan vad konfigurationsfilerna säger och vad som faktiskt har verifierats på servern.

Skriv rapporten på svenska med rubrikerna Åtgärd, Motivering, Förväntad effekt och Verifiering.

Avsluta med en lista över påståenden som behöver kontrolleras manuellt mot servern.


# Svar:

Slutsats: SELinux enforcing och Zonvakt i zonvakt_t är verifierade på servern. Filkontexterna och auditloggen är inte verifierade.
1. SELinux i enforcing-läge

Åtgärd
Konfigurationen anger enforcing. Servern körde i enforcing vid kontrollen.

Motivering
I enforcing blockeras otillåtna åtkomster, de loggas inte bara.

Förväntad effekt
Otillåtna åtkomstförsök blockeras. Inställningen ska överleva omstart.

Verifiering

Konfiguration: härdningslistan och skriptet kontrollerar SELINUX=enforcing i /etc/selinux/config.
Verifierat på servern: sestatus visar Current mode: enforcing och Mode from config file: enforcing.
Inte verifierat: getenforce och grep mot configfilen finns inte i underlaget som egen utskrift. Omstart är inte testad, så att läget överlever en omstart är inte verifierat.

2. Zonvakt i egen SELinux-domän

Åtgärd

Policyn zonvakt.te definierar zonvakt_t, med init_daemon_domain för zonvakt_exec_t.
Policyn är installerad enligt semodule -l.
Processen kör i zonvakt_t enligt ps -eZ.

Motivering
Domänen ger tjänsten bara de rättigheter som policyn beviljar, inte bredare åtkomst.

Förväntad effekt
Zonvakt kan bara göra det policyn tillåter. Otillåtna försök ska blockeras och loggas i auditloggen.

Verifiering

Verifierat på servern: processen kör i system_u:system_r:zonvakt_t:s0, policyn zonvakt finns installerad och zonvakt_t finns inte i listan över permissiva domäner.
Konfiguration: #permissive zonvakt_t; är utkommenterad i .te-filen, vilket stämmer med utskriften.
Inte verifierat:
Att policyn skapades med sepolicy generate. Underlaget visar bara bygg- och installationsskriptet.
Att blockerade försök loggas. Ingen ausearch-utskrift finns.
Att policyn är minimal. .te-filen ger bland annat corecmd_exec_bin, auth_read_passwd_file och bindning till generiska TCP-portar. Om dessa behövs går inte att avgöra här.

3. Filkontexter

Åtgärd
zonvakt.fc mappar:

/usr/local/bin/zonvakt → zonvakt_exec_t
/var/log/zonvakt(/.*)? → zonvakt_log_t

zonvakt.sh kör restorecon på båda sökvägarna efter installation.

Motivering
Filkontexten avgör vilken domän som får köra binären och skriva loggar. Utan rätt kontext nekas åtkomst.

Förväntad effekt
Binären och loggkatalogen har rätt etikett, och Zonvakt kan köra och logga utan att få extra rättigheter.

Verifiering

Konfiguration: .fc-filen och restorecon-anropen finns i underlaget.
Inte verifierat: ingen ls -Z eller matchpathcon-utskrift finns. Att etiketterna är korrekta på servern är inte bekräftat. Att restorecon har körts går inte att se i underlaget.

4. Verifieringsskriptet

Åtgärd
scripts/verifiera-hardning.sh är skrivet för att endast läsa tillstånd. Det kontrollerar fyra punkter:

getenforce är Enforcing.
/etc/selinux/config innehåller SELINUX=enforcing.
ps -eZ visar zonvakt i zonvakt_t.
zonvakt_t finns inte i semanage permissive -l.

Motivering
Skriptet gör det möjligt att kontrollera läget upprepade gånger utan manuella steg.

Förväntad effekt
Skriptet ska ge GÄLLER INTE och exitkod 1 om något avviker.

Verifiering

Verifierat på servern: utskriften visar fyra GÄLLER och RESULTAT: Alla kontroller GÄLLER.
Inte verifierat:
Exitkod 0. Underlaget visar inte exitkoden, trots att rapporten påstår det.
Att semanage permissive -l körs med rätt rättigheter. Skriptet använder inte sudo.
Den utskrift som visas för permissiva domäner är bara listan över inbyggda domäner. Om det finns egna permissiva domäner syns de inte i underlaget.
Skriptet kontrollerar varken filkontexter eller auditlogg.

Påståenden att kontrollera manuellt på servern

getenforce returnerar Enforcing.
grep '^SELINUX=' /etc/selinux/config returnerar SELINUX=enforcing.
Läget överlever omstart.
ps -eZ | grep zonvakt visar zonvakt_t.
sudo semodule -l | grep zonvakt visar policyn.
sudo semanage permissive -l visar inte zonvakt_t, inklusive egna permissiva domäner.
ls -Z /usr/local/bin/zonvakt visar zonvakt_exec_t.
ls -Zd /var/log/zonvakt visar zonvakt_log_t.
sudo ausearch -m avc -se zonvakt visar att blockerade försök loggas.
bash scripts/verifiera-hardning.sh; echo $? returnerar 0.
Policyn skapades med sepolicy generate.
Policyn är minimal och alla beviljade rättigheter behövs.
