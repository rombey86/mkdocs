---
description: BlockBlock überwacht macOS auf Persistenz-Versuche von Malware.
---
# BlockBlock – Schutz vor dauerhafter Malware-Installation

**BlockBlock** ist ein spezialisiertes Sicherheitstool, das macOS kontinuierlich auf Versuche überwacht, Software **persistent** im System zu verankern. Da sich Malware fast immer so einrichtet, dass sie einen Neustart übersteuert (z. B. via Launch Agents oder Daemons), bietet BlockBlock hier eine effektive Verteidigungslinie.

Projektseite: https://objective-see.org/products/blockblock.html  
GitHub-Repository: https://github.com/objective-see/BlockBlock  

---

## Aktueller Status (Februar 2026)

- **Version:** 2.2.2  
- **Kompatibilität:** Optimiert für macOS Sequoia und neuere Systemerweiterungen (System Extensions).  
- **Plattform:** Native Unterstützung für Apple Silicon (M1/M2/M3/M4) und Intel.

---

## Kernfunktionen

### Überwachung in Echtzeit
BlockBlock agiert im Hintergrund und schlägt sofort Alarm, wenn eine Anwendung versucht, sich in einem der vielen Persistenz-Verzeichnisse von macOS zu registrieren.

### Schutz kritischer Orte
Überwacht unter anderem:
- Launch Daemons und Launch Agents
- Kernel-Erweiterungen (Kexts)
- Login Items
- Browser-Erweiterungen und Plugins

### Interaktive Entscheidungen
Der Nutzer erhält ein Popup-Fenster mit Details zum Prozess und kann die dauerhafte Installation entweder **erlauben** oder **blockieren**.

---

## Besonderheiten
- **Scan-Modus:** Ermöglicht es, das System manuell nach bereits existierenden persistenten Einträgen zu durchsuchen.
- **Digitale Signaturen:** Zeigt direkt an, ob der Prozess, der die Änderung vornimmt, von Apple oder einem verifizierten Entwickler signiert wurde.

---

## Download

- Offizielle Website: https://objective-see.org/products/blockblock.html  
- GitHub Releases: https://github.com/objective-see/BlockBlock/releases
