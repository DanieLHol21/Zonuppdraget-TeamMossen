
#!/bin/bash

# Verifieringsskript för SELinux-härdning
# Kontrollerar endast tillstånd. Ändrar ingenting.

fel=0

kontrollera() {
    beskrivning="$1"

    if shift && "$@"; then
        echo "GÄLLER: $beskrivning"
    else
        echo "GÄLLER INTE: $beskrivning"
        fel=1
    fi
}

# Kontroll 1: Aktuellt SELinux-läge
kontrollera "SELinux körs i Enforcing" \
    test "$(getenforce)" = "Enforcing"

# Kontroll 2: Permanent SELinux-konfiguration
kontrollera "SELINUX=enforcing i konfigurationen" \
    grep -qx 'SELINUX=enforcing' /etc/selinux/config

# Kontroll 3: Zonvakt körs i rätt SELinux-domän
kontrollera "Zonvakt körs i zonvakt_t" \
    bash -c 'ps -eZ | grep zonvakt | grep -q zonvakt_t'

# Kontroll 4: Zonvakt är inte permissiv
kontrollera "zonvakt_t är inte permissiv" \
    bash -c '! semanage permissive -l | grep -qw zonvakt_t'

echo
if [ "$fel" -eq 0 ]; then
    echo "RESULTAT: Alla kontroller GÄLLER."
    exit 0
else
    echo "RESULTAT: En eller flera kontroller GÄLLER INTE."
    exit 1
fi

