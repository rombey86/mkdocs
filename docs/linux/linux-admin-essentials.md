---
description: Essentielle Linux-Befehle und Verfahren für die tägliche Systemadministration. Praxisorientierte Schnellreferenz für Linux-Administratoren.
---
# Linux System Administration Essentials

Diese Schnellreferenz fasst die wichtigsten Befehle und Verfahren für die tägliche Linux-Systemadministration zusammen. Der Fokus liegt auf praxisnahen Beispielen, die sich direkt im Arbeitsalltag anwenden lassen.

!!! info "Hinweis"
    Diese Referenz wird schrittweise erweitert. Alle Befehle wurden in produktiven Umgebungen getestet und folgen dem "Security by Design"-Prinzip.

---

##  Dateisystem-Operationen

### `ls` - Verzeichnisinhalte auflisten

Der grundlegendste Befehl für die Navigation im Dateisystem.

```bash
# Alle Dateien inkl. versteckter und mit detaillierten Informationen
ls -la /home/tobias/

# Nach Änderungszeit sortiert (neueste zuerst), menschlich lesbar
ls -lht /var/log/

# Nur Verzeichnisse auflisten
ls -d */

# Rekursiv mit Tiefenangabe
ls -R /etc/nginx/
```

**Wichtige Optionen:**
- `-l`: Detaillierte Liste (Rechte, Owner, Größe, Datum)
- `-a`: Alle Dateien (inkl. versteckter, die mit `.` beginnen)
- `-h`: Menschlich lesbare Größen (KB, MB, GB)
- `-t`: Nach Zeit sortieren (neueste zuerst)
- `-S`: Nach Größe sortieren (größte zuerst)
- `-R`: Rekursiv in Unterverzeichnisse

---

### `find` - Dateien suchen

Leistungsstarkes Werkzeug um Dateien basierend auf verschiedenen Kriterien zu finden.

```bash
# Alle Konfigurationsdateien finden (ignoriere Fehlermeldungen)
find / -name "*.conf" -type f 2>/dev/null

# Dateien die in den letzten 24 Stunden geändert wurden
find /home -mtime -1 -type f

# Dateien größer als 100MB finden
find /var -size +100M -type f

# Dateien mit bestimmten Berechtigungen finden (z.B. world-writable)
find / -perm -o+w -type f 2>/dev/null

# Dateien finden und löschen (VORSICHT!)
find /tmp -name "*.tmp" -mtime +7 -delete
```

**Wichtige Optionen:**
- `-name`: Nach Name suchen (Groß-/Kleinschreibung beachten)
- `-iname`: Nach Name suchen (Groß-/Kleinschreibung ignorieren)
- `-type`: Dateityp (f=file, d=directory, l=symlink)
- `-mtime`: Modifikationszeit in Tagen
- `-size`: Dateigröße (+ für größer, - für kleiner)
- `-perm`: Dateiberechtigungen
- `-delete`: Gefundene Dateien löschen (mit Vorsicht verwenden!)
- `-exec`: Befehl auf gefundene Dateien ausführen

---

### `df` und `du` - Festplattennutzung analysieren

Unverzichtbar für die Überwachung der Speichernutzung.

```bash
# Festplattennutzung aller Mount-Points (menschlich lesbar)
df -h

# Inode-Nutzung zeigen (wichtig bei vielen kleinen Dateien)
df -i

# Speichernutzung eines Verzeichnisses
du -sh /var/log/

# Top 10 größte Verzeichnisse im aktuellen Pfad
du -h --max-depth=1 | sort -hr | head -10

# Dateien größer als 1GB im gesamten System finden
find / -type f -size +1G 2>/dev/null -exec du -h {} \;
```

**Wichtige Optionen:**
- `-h`: Menschlich lesbare Ausgabe (KB, MB, GB)
- `-s`: Summary (nur Gesamtsumme)
- `-i`: Inodes statt Blöcke anzeigen
- `--max-depth`: Maximale Verzeichnistiefe für du

---

## ⚙️ Prozess- und Ressourcenverwaltung

### `ps` - Prozesse auflisten

Zeigt laufende Prozesse und ihre Ressourcennutzung.

```bash
# Alle Prozesse mit Benutzer und完整em Befehl
ps auxf

# Prozessbaum anzeigen (hierarchische Struktur)
ps axjf

# Spezifischen Prozess finden
ps aux | grep nginx

# Top 5 speicherintensivste Prozesse
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -6

# Alle Prozesse eines bestimmten Benutzers
ps -u www-data
```

**Wichtige Optionen:**
- `a`: Alle Prozesse aller Benutzer
- `u`: Benutzerorientiertes Format
- `x`: Prozesse ohne kontrollierendes Terminal
- `f`: ASCII-Prozessbaum
- `-%mem`: Nach Speichernutzung sortieren
- `-%cpu`: Nach CPU-Nutzung sortieren

---

### `top` / `htop` - Echtzeit-Systemüberwachung

Interaktive Echtzeit-Ansicht der Systemressourcen.

```bash
# Standard top
top

# Top mit 2-Sekunden-Update-Intervall
top -d 2

# Nur Prozesse eines bestimmten Benutzers zeigen
top -u tobias

# Htop (bessere visuelle Darstellung, falls installiert)
htop
```

**Nützliche top-Tastenkombinationen:**
- `P`: Nach CPU-Nutzung sortieren
- `M`: Nach Speichernutzung sortieren
- `k`: Prozess killen
- `q`: Beenden

**Htop Vorteile:**
- Farbcodierte Anzeige
- Mausunterstützung
- Einfacheres Scrollen durch Prozesse
- Visuelle CPU- und Speicherbalken

---

### `systemctl` - Diensteverwaltung (systemd)

Modernes Werkzeug zur Verwaltung von Systemdiensten.

```bash
# Status eines Dienstes prüfen
systemctl status nginx

# Dienst starten/stoppen/neustarten
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl reload nginx  # Konfiguration neu laden ohne Unterbrechung

# Dienst beim Boot aktivieren/deaktivieren
systemctl enable nginx
systemctl disable nginx

# Alle fehlgeschlagenen Dienste zeigen
systemctl --failed

# Alle aktiven Dienste auflisten
systemctl list-units --type=service --state=active

# Journal-Logs eines Dienstes anzeigen
journalctl -u nginx -f
```

**Wichtige systemctl-Befehle:**
- `start/stop/restart`: Dienstkontrolle
- `enable/disable`: Autostart-Konfiguration
- `status`: Aktueller Zustand
- `reload`: Konfiguration neu laden
- `mask/unmask`: Dienst vollständig deaktivieren/aktivieren
- `daemon-reload`: systemd-Konfiguration neu laden

---

## 🌐 Netzwerk-Grundlagen

### `ip` - Netzwerkschnittstellen und Routing

Modernes Werkzeug für Netzwerk-Konfiguration (ersetzt ifconfig).

```bash
# Alle Netzwerkschnittstellen mit IPs anzeigen
ip addr show

# Nur IPv4-Adressen zeigen
ip -4 addr show

# Routing-Tabelle anzeigen
ip route show

# Standard-Gateway finden
ip route | grep default

# ARP-Tabelle anzeigen
ip neigh show

# Netzwerkschnittstelle hoch/runter fahren
ip link set eth0 up
ip link set eth0 down
```

**Wichtige ip-Unterwerkzeuge:**
- `addr`: IP-Adressen verwalten
- `route`: Routing-Tabelle verwalten
- `link`: Netzwerkschnittstellen verwalten
- `neigh`: ARP/NDP-Tabelle verwalten

---

### `ss` - Socket-Statistiken

Moderner Ersatz für netstat, zeigt Netzwerkverbindungen.

```bash
# Alle lauschenden TCP- und UDP-Ports
ss -tuln

# Alle etablierten Verbindungen
ss -state established

# Alle Verbindungen mit Prozessinformation
ss -tulnp

# Verbindungen auf einem bestimmten Port
ss -tlnp sport = :22

# Statistiken aller Sockets
ss -s
```

**Wichtige ss-Optionen:**
- `-t`: TCP-Verbindungen
- `-u`: UDP-Verbindungen
- `-l`: Lauschende (listening) Sockets
- `-n`: Numerische Ausgabe (keine DNS-Auflösung)
- `-p`: Prozessinformation anzeigen
- `-state`: Nach Zustand filtern

---

### `netstat` - Legacy-Netzwerkdiagnose

Älteres Werkzeug, immer noch nützlich wenn ss nicht verfügbar ist.

```bash
# Alle lauschenden Ports
netstat -tulpn

# Alle aktiven Verbindungen
netstat -an

# Routing-Tabelle
netstat -rn

# Netzwerkstatistiken
netstat -s
```

---

## 🔐 Berechtigungen und Eigentümerschaft

### `chmod` - Dateirechte ändern

Kontrolliert wer Dateien lesen, schreiben und ausführen kann.

```bash
# Rechte numerisch setzen (Owner=rwx, Group=rx, Other=rx)
chmod 755 /usr/local/bin/script.sh

# Private SSH-Schlüssel (nur Owner lesbar)
chmod 600 ~/.ssh/id_rsa

# Rekursiv Verzeichnisrechte ändern
chmod -R 755 /var/www/html/

# Rechte symbolisch setzen (Owner hinzufügen: execute)
chmod u+x script.sh

# Gruppe und Others entfernen: write, execute
chmod go-wx file.txt

# SetUID Bit setzen (für spezielle Ausführungsrechte)
chmod 4755 /usr/bin/passwd
```

**Numerische Rechte-Referenz:**
- `4`: Read (r)
- `2`: Write (w)
- `1`: Execute (x)
- `0`: Keine Berechtigung (-)

**Beispiele:**
- `755` = rwxr-xr-x (Owner: alles, Group/Others: lesen+ausführen)
- `644` = rw-r--r-- (Owner: lesen+schreiben, Group/Others: nur lesen)
- `600` = rw------- (Nur Owner: lesen+schreiben)
- `700` = rwx------ (Nur Owner: alles)

---

### `chown` - Eigentümerschaft ändern

Ändert den Besitzer und die Gruppe von Dateien und Verzeichnissen.

```bash
# Owner einer Datei ändern
chown tobias file.txt

# Owner und Gruppe gleichzeitig ändern
chown tobias:users file.txt

# Rekursiv Verzeichnis und alle Unterverzeichnisse ändern
chown -R www-data:www-data /var/www/html/

# Nur Gruppe ändern (Owner bleibt gleich)
chown :developers project/

# Symlink-Ziel folgen (ändert tatsächliche Datei, nicht Symlink)
chown -h tobias symlink_file
```

**Wichtige chown-Optionen:**
- `-R`: Rekursiv
- `-h`: Symlinks selbst ändern (nicht deren Ziele)
- `-v`: Ausführliche Ausgabe

---

## 📊 System-Information und -Diagnose

### `uname` - Systeminformationen

Zeigt grundlegende Systeminformationen.

```bash
# Alle Systeminformationen
uname -a

# Nur Kernel-Version
uname -r

# Nur Hostname
uname -n

# Nur Betriebssystem
uname -o
```

**Ausgabe von `uname -a`:**
```
Linux server01 5.15.0-91-generic #101-Ubuntu SMP x86_64 GNU/Linux
```

---

### `free` - Speicherauslastung

Zeigt RAM- und Swap-Nutzung.

```bash
# Menschlich lesbare Ausgabe
free -h

# Ausgabe in Megabytes
free -m

# Alle 5 Sekunden aktualisieren
watch -n 5 free -h

# Niedrigen Speicher anzeigen (wichtig für Monitoring)
free -h | awk '/Mem:/ {print $3/$2 * 100.0}'
```

**Wichtige Spalten:**
- `total`: Gesamter verfügbarer Speicher
- `used`: Tatsächlich genutzter Speicher
- `free`: Nicht genutzter Speicher
- `shared`: Geteilter Speicher (tmpfs)
- `buff/cache`: Für Buffer/Cache genutzter Speicher
- `available`: Geschätzter verfügbarer Speicher für neue Apps

---

### `journalctl` - systemd-Journal untersuchen

Modernes Werkzeug zur Untersuchung von System-Logs.

```bash
# Aktuelle Logs mit Priorität Error oder höher
journalctl -p err -b

# Logs eines spezifischen Dienstes
journalctl -u nginx

# Logs in Echtzeit verfolgen (wie tail -f)
journalctl -u nginx -f

# Logs seit einem bestimmten Zeitpunkt
journalctl --since "2026-04-05 20:00:00"

# Anzahl der Log-Einträge zählen
journalctl --no-pager | wc -l

# Logs im JSON-Format (für Skripte)
journalctl -o json-pretty
```

**Nützliche journalctl-Optionen:**
- `-b`: Seit dem letzten Boot
- `-u`: Spezifische Unit
- `-f`: Follow (Echtzeit)
- `-p`: Priorität (emerg, alert, crit, err, warning, notice, info, debug)
- `--since/--until`: Zeitbereich
- `-n`: Anzahl der Einträge zeigen

---

## 📦 Paketverwaltung und -Wartung

### `apt` (Debian/Ubuntu) und `dnf/yum` (RHEL/CentOS)

Paketverwaltung je nach Distribution.

```bash
# Debian/Ubuntu (apt)
apt update                    # Paketquellen aktualisieren
apt upgrade                   # Installierte Pakete upgraden
apt install nginx            # Paket installieren
apt remove nginx             # Paket entfernen (Konfig bleibt)
apt purge nginx              # Paket komplett entfernen (inkl. Konfig)
apt autoremove               # Nicht mehr benötigte Abhängigkeiten entfernen
apt search mysql             # Pakete suchen
apt show nginx               # Paketinformationen anzeigen

# RHEL/CentOS/Fedora (dnf - moderner)
dnf update                   # System komplett aktualisieren
dnf install nginx            # Paket installieren
dnf remove nginx             # Paket entfernen
dnf autoremove               # Nicht mehr benötigte entfernen
dnf search mysql             # Pakete suchen
dnf info nginx               # Paketinformationen

# RHEL/CentOS älter (yum - legacy)
yum update
yum install nginx
```

**Wichtige Wartungsbefehle:**
```bash
# Nicht mehr benötigte Pakete entfernen
apt autoremove

# Defekte Abhängigkeiten reparieren
apt --fix-broken install

# apt-Cache aufräumen
apt clean

# Installierte Pakete auflisten
dpkg --list | grep nginx     # Debian/Ubuntu
rpm -qa | grep nginx         # RHEL/CentOS
```

---

### `systemd` Diensteverwaltung - Erweitert

Weitere nützliche systemctl-Befehle für die täglichen Aufgaben.

```bash
# Dienst-Status mit erweitertem Output
systemctl status nginx --no-pager

# Alle fehlgeschlagenen Units finden
systemctl --failed --no-pager

# Abhängigkeiten eines Dienstes zeigen
systemctl list-dependencies nginx

# System-Shutdown planen
systemctl poweroff
systemctl reboot

# System-Runtime anzeigen
systemctl status | grep "since"

# Boot-Zeit analysieren (was dauert am längsten?)
systemd-analyze blame

# Boot-Wasserfalldiagramm erstellen
systemd-analyze plot > boot-plot.svg
```

---

## 🔍 Praktische Diagnose-Werkzeuge

### Kombinationen für schnelle Problemanalyse

```bash
# System-Last und Uptime
uptime

# Wer ist eingeloggt?
who
w

# Letzte Logins anzeigen
last

# System-Load im Verlauf (1, 5, 15 Minuten)
cat /proc/loadavg

# Temperatur überwachen (wenn lm-sensors installiert)
sensors

# Festplatten-S.M.A.R.T.-Status prüfen
smartctl -H /dev/sda
```

---

## 📝 Best Practices für Linux-Administratoren

### 1. Immer mit geringstmöglichen Rechten arbeiten
```bash
# Nicht als Root arbeiten wenn nicht nötig
sudo -u www-data command

# Temporär Root-Rechte für einzelne Befehle
sudo command
```

### 2. Konfigurationsdateien vor Änderungen sichern
```bash
# Backup vor Bearbeitung
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Oder mit Versionskontrolle arbeiten
cd /etc/nginx/
git init
git add .
git commit -m "Initial config backup"
```

### 3. Logs regelmäßig überprüfen
```bash
# Tägliche Log-Überprüfung
journalctl -p err -b --no-pager

# Automatisierte Log-Rotation konfigurieren
cat /etc/logrotate.conf
```

### 4. Sicherheit zuerst
```bash
# Regelmäßige Sicherheitsupdates
apt update && apt upgrade -y

# Unnötige Dienste deaktivieren
systemctl disable --now unused-service

# Firewall-Regeln prüfen
ufw status verbose
# oder
iptables -L -n -v
```

### 5. Dokumentation führt manuell oder automatisiert
```bash
# System-Dokumentation generieren
hostnamectl    # Host-Informationen
ip addr        # Netzwerk-Konfiguration
df -h          # Speichernutzung
systemctl list-units --type=service --state=running  # Aktive Dienste
```

---

!!! tip "Nächste Schritte"
    Diese Referenz wird kontinuierlich erweitert. Für spezifischere Themen wie SSH-Härtung oder ACME-DNS-Challenges siehe die entsprechenden Dokumente in dieser Wissensbasis.