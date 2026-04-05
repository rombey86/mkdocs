# System Health Check Script

Ein selbstgenügsames Überwachungsskript für Windows-Systeme, erstellt als praktisches Experiment zur Validierung von Selbstgenügsamkeitsprinzipien.

## Überblick

Dieses PowerShell-Skript überwacht wichtige Systemmetriken und kann unabhängig ohne AI-Abhängigkeiten laufen. Es wurde entwickelt um Tobias's Prinzipien zu testen:
- Selbstgenügsamkeit: Funktioniert ohne externe Abhängigkeiten
- Hintergrundbetrieb: Kann als automatisierter Prozess laufen
- Verlässlichkeit: Bietet konsistente Überwachung
- Unabhängigkeit: Keine AI erforderlich für Kernfunktionalität
- Praktische Validierung: Einfach zu testen und zu verifizieren

## Funktionen

- Überwacht CPU-, Speicher- und Festplattenauslastung
- Prüft essentielle Windows-Dienste
- Konfigurierbare Schwellenwerte für Warnungen und Kritische Zustände
- Umfassende Logging in Datei und Konsolausgabe
- Farbkodierte Konsolausgabe für schnelles Erfassen
- Rückgabecodes für Integration in Überwachungssysteme
- Komplett eigenständig - keine externen Bibliotheks- oder AI-Abhängigkeiten

## Konfiguration

Die folgenden Schwellenwerte können leicht am Anfang des Skripts angepasst werden:

```powershell
$ThresholdCpuWarning = 80          # Warnung bei 80% CPU-Auslastung
$ThresholdCpuCritical = 95         # Kritisch bei 95% CPU-Auslastung
$ThresholdMemoryWarning = 80       # Warnung bei 80% Speicherauslastung
$ThresholdMemoryCritical = 95      # Kritisch bei 95% Speicherauslastung
$ThresholdDiskWarning = 85         # Warnung bei 85% Festplattenauslastung
$ThresholdDiskCritical = 95        # Kritisch bei 95% Festplattenauslastung
$LogFile = "H:\OpenClaw\logs\system_health_check.log"  # Log-Dateipfad
$AlertEmail = ""                   # E-Mail für Benachrichtigungen (leer = nur Konsole)
```

## Verwendung

### Manuelle Ausführung
```powershell
powershell -ExecutionPolicy Bypass -File H:\OpenClaw\SystemHealthCheck.ps1
```

### Als Hintergrundprozess einrichten
Um das Skript regelmäßig auszuführen, kannst du den Task Scheduler verwenden:

1. Öffne den Task Scheduler
2. Erstelle eine neue Aufgabe
3. Setze den Trigger auf dein gewünschtes Intervall (z.B. alle 5 Minuten)
4. Setze die Aktion auf:
   - Programm: `powershell.exe`
   - Argumente: `-ExecutionPolicy Bypass -File "H:\OpenClaw\SystemHealthCheck.ps1"`

### Rückgabecodes
Das Skript gibt folgende Exit-Codes zurück:
- `0`: Alle Systeme OK
- `1`: Eine oder mehrere Warnungen erkannt
- `2`: Kritische Probleme erkannt

## Anpassung

Dieses Skript ist bewusst einfach gehalten, damit es leicht verstanden und angepasst werden kann. Ideen für Erweiterungen:

- Zusätzliche Metriken hinzufügen (Netzwerk, spezifische Anwendungen)
- Unterschiedliche Schwellenwerte für verschiedene Zeiten des Tages
- E-Mail-Benachrichtigungen implementieren
- Integration mit bestehenden Überwachungssystemen
- Mehr detaillierte Logging-Optionen
- Web-basiertes Dashboard für die Anzeige von Trends

## Testen und Validieren

Um dieses Skript nach Tobias's Prinzipien zu validieren:

1. **Führe es manuell aus** und beobachte die Ausgabe
2. **Überprüfe das Logfile** um sicherzustellen, dass Einträge korrekt geschrieben werden
3. **Teste die Schwellenwerte** indem du sie vorübergehend änderst
4. **Simuliere Bedingungen** (z.B. große Datei erstellen um Festplattenwarnung zu testen)
5. **Überprüfe die Rückgabecodes** für die Integration in Überwachungssysteme
6. **Passe es an** deine spezifischen Bedürfnisse an und teste erneut

Dieses Skript folgt genau dem Prinzip, das Tobias bevorzugt: Es ist selbstgenügsam, zuverlässig, unabhängig und praktisch validierbar.