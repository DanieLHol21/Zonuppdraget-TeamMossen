# Härdningsrapport - elev-37

## 1. SELinux i enforcing-läge

Åtgärd:

SELinux är konfigurerat att använda läget Enforcing. Detta innebär att SELinux aktivt kontrollerar och begränsar processers åtkomst enligt säkerhetspolicyn.

Motivering:

Enforcing är viktigt eftersom SELinux då inte bara registrerar överträdelser utan även blockerar åtgärder som bryter mot säkerhetspolicyn.

Förväntad effekt:

Obehöriga åtkomstförsök blockeras av SELinux. Inställningen ska även finnas kvar efter omstart.

Verifiering:

getenforce visar Enforcing.

sestatus visar att SELinux är aktiverat och körs i enforcing-läge.

grep '^SELINUX=' /etc/selinux/config visar SELINUX=enforcing.

Verifieringsskript: Ja. Kontrolleras automatiskt av scripts/verifiera-hardning.sh.


## 2. Zonvakt med egen SELinux-policy

Åtgärd:

Zonvakt körs i en egen SELinux-domän, zonvakt_t. En separat SELinux-policy har skapats med hjälp av sepolicy generate och anpassats efter tjänstens behov.

Motivering:

Genom att använda en egen SELinux-domän kan tjänsten få begränsade behörigheter som är anpassade efter dess funktion. Det minskar risken att tjänsten får tillgång till resurser som den inte behöver.

Förväntad effekt:

Zonvakt ska endast kunna utföra de åtgärder som tillåts av dess egen policy. Eventuella otillåtna åtkomstförsök ska blockeras och registreras i auditloggen.

Verifiering:

ps -eZ | grep zonvakt visar att processen körs i zonvakt_t.

sudo semodule -l | grep zonvakt visar att policyn är installerad.

sudo semanage permissive -l visar att zonvakt_t inte är en permissiv domän.

Verifieringsskript: Ja. Kontrolleras automatiskt av scripts/verifiera-hardning.sh.


## 3. Automatisk verifiering av härdningen

Åtgärd:

Ett eget Bash-skript, scripts/verifiera-hardning.sh, har skapats för att kontrollera serverns SELinux-inställningar och Zonvakts SELinux-domän.

Motivering:

Automatisk verifiering gör det enklare att kontrollera att säkerhetsinställningarna är korrekta utan att behöva utföra varje kontroll manuellt.

Förväntad effekt:

Skriptet upptäcker om någon av de kontrollerade säkerhetsinställningarna inte uppfyller kraven.

Verifiering:

Skriptet kontrollerade fyra punkter:

SELinux körs i Enforcing.
Konfigurationen innehåller SELINUX=enforcing.
Zonvakt körs i zonvakt_t.
zonvakt_t är inte en permissiv domän.

Samtliga fyra kontroller gav resultatet GÄLLER och skriptet avslutades med exitkod 0.

Verifieringsskript: Ja – scripts/verifiera-hardning.sh.
