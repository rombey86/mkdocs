
# Linux & Server Administration

Dieser Bereich meiner Knowledge Base widmet sich der Administration, Absicherung und Automatisierung von Linux-Systemen. Mein Fokus liegt auf stabilen, reproduzierbaren Konfigurationen und dem "Security by Design"-Prinzip.



---

## 🛠 Aktuelle Dokumentationen

Hier findest du meine Best Practices und technischen Anleitungen:

### 🔐 Sicherheit & Hardening
* **[SSH-Härtung](./ssh-hardening.md)** Grundlegende Absicherung des SSH-Zugangs, Deaktivierung von Root-Logins und Key-basierte Authentifizierung.
* **[ACME-DNS Challenge](./acme-dns.md)** Automatisierte SSL-Zertifikate für interne Systeme und Wildcards ohne offene Ports.

### ⚙️ Infrastruktur & Dienste
* *Demnächst:* Docker & Container-Orchestrierung
* *Demnächst:* Monitoring mit Prometheus & Grafana
* *Demnächst:* Backup-Strategien mit Restic

---

## 📋 Schnellzugriff: Daily Commands

| Befehl | Beschreibung |
| :--- | :--- |
| `journalctl -xe` | Fehleranalyse in Systemd-Units |
| `tail -f /var/log/auth.log` | Echtzeit-Überwachung von Login-Versuchen |
| `ss -tulpn` | Übersicht aller offenen Ports und Prozesse |

!!! info "Status der Dokumentation"
    Diese Sektion wird laufend erweitert, sobald neue Lösungen in meine produktive Infrastruktur in Mönchengladbach übernommen werden.
