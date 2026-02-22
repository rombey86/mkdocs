---
description: LuLu ist eine kostenlose Open-Source-Firewall für macOS
---
# LuLu – Kostenlose Open-Source-Firewall für macOS

**LuLu** ist eine kostenlose Open-Source-Firewall für macOS, die speziell darauf ausgelegt ist, **ausgehende Netzwerkverbindungen** zu überwachen und zu blockieren.  

Während die in macOS integrierte Firewall primär **eingehende Verbindungen** filtert, schließt LuLu diese Sicherheitslücke und verhindert so unbefugten Datenabfluss durch Malware oder neugierige Anwendungen.

Projektseite: https://objective-see.org/products/lulu.html  
GitHub-Repository: https://github.com/objective-see/LuLu  

---

## Aktueller Status (Februar 2026)

- **Version:** 4.2.1 (veröffentlicht Anfang Februar 2026)  
- **Kompatibilität:** macOS 10.15 (Catalina) und neuer, einschließlich aktueller Versionen wie macOS Sequoia  
- **Plattform:** Optimiert für Apple Silicon und Intel-Prozessoren  

---

## Kernfunktionen

### Echtzeit-Warnungen
Sobald eine App versucht, eine Verbindung zum Internet herzustellen, zeigt LuLu ein Popup mit detaillierten Informationen zum Prozess und zum Zielhost an.

### Regelbasiertes System
Verbindungen können:
- permanent erlaubt  
- permanent blockiert  
- oder temporär (bis zum nächsten Neustart) freigegeben werden  

### Sicherheits-Check
Integrierte **VirusTotal-Abfrage**, um Prozesse direkt im Warnfenster auf bekannte Malware-Indikatoren zu prüfen.

### Betriebsmodi
- **Passiv-Modus:** Neue Verbindungen werden zunächst erlaubt, aber protokolliert.  
- **Block-Modus:** Neue, unbekannte Verbindungen werden standardmäßig blockiert.  

---

## Wichtige Neuerungen in Version 4.x

### Verbesserte Benutzeroberfläche
Modernisierte UI mit vereinfachtem Alert-Modus.

### Regel-Management
Benutzerdefinierte Regeln können exportiert und importiert werden.

### Relative Zeitregeln
Regeln können für eine definierte Zeitspanne (z. B. 1 Stunde) statt nur bis zu einem festen Zeitpunkt gesetzt werden.

---

## Download

- Offizielle Website: https://objective-see.org/products/lulu.html  
- GitHub Releases: https://github.com/objective-see/LuLu/releases  
