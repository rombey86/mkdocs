---
description: KnockKnock scannt macOS nach installierter persistenter Software.
---
# KnockKnock – „Who’s there?“ für persistente Software

Während BlockBlock präventiv arbeitet, ist **KnockKnock** ein Analyse-Tool, das das System nach bereits installierter Software durchsucht, die so konfiguriert ist, dass sie bei jedem Systemstart automatisch geladen wird.

Projektseite: https://objective-see.org/products/knockknock.html  
GitHub-Repository: https://github.com/objective-see/KnockKnock  

---

## Aktueller Status (Februar 2026)

- **Tool-Typ:** Standalone-Scanner (keine Hintergrundüberwachung nötig).
- **Update:** Regelmäßige Definitions-Updates für neue macOS-Persistenz-Methoden.

---

## Kernfunktionen

### Umfassender System-Scan
Listet alles auf, was automatisch startet:
- Launch Items, Cronjobs und Login-Skripte.
- Spotlight-Plugins und Auth-Definitionen.
- Kernel-Extensions und Bibliotheken (Dynamic Libraries).

### VirusTotal-Integration
Gefundene Dateien können mit einem Klick gegen die Datenbank von VirusTotal geprüft werden, um die Erkennungsrate von bekannter Malware zu maximieren.

### Signature-Check
Identifiziert unsignierte oder falsch signierte Binärdateien, was oft ein Indikator für Schadsoftware ist.

---

## Download

- Offizielle Website: https://objective-see.org/products/knockknock.html  
- GitHub Releases: https://github.com/objective-see/KnockKnock/releases
