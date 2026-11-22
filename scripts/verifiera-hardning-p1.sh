#!/usr/bin/env bash
# Verifieringsskript – Person 1 (SELinux, SSH-härdning och konton)
set -u
status=0

# Rad P1-1: SELinux körs i tvingande läge nu och är konfigurerat för enforcing efter omstart
if [ "$(getenforce)" = "Enforcing" ] && grep -qx 'SELINUX=enforcing' /etc/selinux/config; then
    echo "GÄLLER: P1-1 – SELinux körs i Enforcing nu och har SELINUX=enforcing i /etc/selinux/config"
else
    echo "GÄLLER INTE: P1-1 – SELinux är inte Enforcing både nu och efter omstart"
    status=1
fi

# Rad P1-2: Lösenordsinloggning och tomma lösenord är avstängda i SSH
sshd_out="$(sudo sshd -T 2>/dev/null || sshd -T 2>/dev/null)"
if echo "$sshd_out" | grep -qx "passwordauthentication no" && echo "$sshd_out" | grep -qx "permitemptypasswords no"; then
    echo "GÄLLER: P1-2 – SSH tillåter endast nyckelautentisering (PasswordAuthentication no, PermitEmptyPasswords no)"
else
    echo "GÄLLER INTE: P1-2 – SSH tillåter lösenordsinloggning eller tomma lösenord"
    status=1
fi

# Rad P1-3: Begränsat antal inloggningsförsök och avstängd X11-vidarebefordran i SSH
if echo "$sshd_out" | grep -Eq "^maxauthtries [1-3]$" && echo "$sshd_out" | grep -qx "x11forwarding no"; then
    echo "GÄLLER: P1-3 – SSH begränsar MaxAuthTries (<= 3) och har X11Forwarding no"
else
    echo "GÄLLER INTE: P1-3 – SSH saknar begränsning av MaxAuthTries eller har X11Forwarding aktivt"
    status=1
fi

# Rad P1-4: Endast avsedda administrativa konton (root och student) har interaktivt inloggningsskal
ovantade_skal=$(awk -F: '$7 !~ /(nologin|false|sync|shutdown|halt)$/ && $1 != "root" && $1 != "student" {print $1}' /etc/passwd)
if [ -z "$ovantade_skal" ]; then
    echo "GÄLLER: P1-4 – Endast root och student har interaktivt inloggningsskal i /etc/passwd"
else
    echo "GÄLLER INTE: P1-4 – Oväntade konton med inloggningsskal hittades: $ovantade_skal"
    status=1
fi

exit $status
