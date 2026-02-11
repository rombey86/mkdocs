# SSH-Härtung: Ein grundlegendes Rezept

Eine der ersten und wichtigsten Maßnahmen zur Absicherung eines neuen Linux-Servers ist die Härtung des SSH-Dienstes. Die Standardkonfiguration ist oft zu permissiv.

## Grundlegende `sshd_config` Anpassungen

Bearbeiten Sie die Konfigurationsdatei `/etc/ssh/sshd_config` und passen Sie die folgenden Werte an.

!!! warning "Vorsicht bei Änderungen"
    Eine fehlerhafte Konfiguration kann Sie vom System aussperren. Stellen Sie sicher, dass Sie eine alternative Zugriffsmöglichkeit (z.B. eine Konsolensitzung) haben, bevor Sie den SSH-Dienst neu starten.

```bash
# /etc/ssh/sshd_config

# Deaktiviere Root-Login
PermitRootLogin no

# Deaktiviere Passwort-Authentifizierung (nur Key-basiert)
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no # Falls Sie PAM nicht für SSH benötigen

# Ändere den Standard-Port (optional, aber empfohlen)
# Port 2222

# Erlaube nur bestimmte Benutzer
# AllowUsers user1 user2
```
## Netzwerk-Topologie
Hier siehst du, wie der Verkehrsfluss architektonisch aufgebaut ist:

```mermaid
graph TD
    A[Remote Client] -->|Port 2222 / Key-Auth| B(Jump Host)
    B --> C{Internes Netz}
    C --> D[Webserver]
    C --> E[Datenbank]
    C --> F[Home Automation]
Nach den Änderungen müssen Sie den SSH-Dienst neu starten, um die Konfiguration zu übernehmen:

```bash
sudo systemctl restart sshd
```
