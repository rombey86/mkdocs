---
description: OverSight überwacht den Zugriff auf Mikrofon und Webcam unter macOS.
---
# OverSight – Mikrofon- und Kamera-Überwachung

**OverSight** erhöht die Privatsphäre unter macOS, indem es den Nutzer jedes Mal benachrichtigt, wenn das interne Mikrofon oder die integrierte FaceTime-Kamera aktiviert werden. Es hilft dabei, Spionage durch Malware oder neugierige Apps zu verhindern.

Projektseite: https://objective-see.org/products/oversight.html  
GitHub-Repository: https://github.com/objective-see/OverSight  

---

## Aktueller Status (Februar 2026)

- **Status:** Voll kompatibel mit den neuesten macOS-Sicherheitsarchitekturen.
- **Hardware:** Unterstützt alle integrierten Apple-Kameras sowie externe USB-Peripherie.

---

## Kernfunktionen

### Kamera-Aktivierung
Sobald die Kamera eingeschaltet wird, identifiziert OverSight den Prozess, der auf den Videostream zugreift, und informiert den Nutzer per Benachrichtigung.

### Mikrofon-Überwachung
Erkennt, wenn Audiogeräte aktiv werden. Dies ist besonders nützlich, da die grüne LED am Mac nur die Kamera, aber nicht zwingend das Mikrofon visualisiert.

### Piggybacking-Schutz
Malware versucht oft, sich an legitime Video-Sitzungen (wie Zoom oder Teams) "anzuhängen". OverSight erkennt diesen doppelten Zugriff und warnt davor.

---

## Download

- Offizielle Website: https://objective-see.org/products/oversight.html  
- GitHub Releases: https://github.com/objective-see/OverSight/releases
