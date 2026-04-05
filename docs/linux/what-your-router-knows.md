---
description: Dein Router weiß mehr über dich, als du denkst. Eine tiefgehende Analyse dessen, was dein Netzwerk-Gateway über deine digitalen Gewohnheiten verrät - und was du dagegen tun kannst.
---

# Was dein Router wirklich über dich weiß (und was er dir nicht erzählt)

Dein Router ist das Tor zur digitalen Welt. Jedes Paket, das du sendest oder empfängst, passiert dieses eine Gerät. Es ist der stillste, unsichtbarste Beobachter in deinem digitalen Leben.

Aber **was weiß dein Router wirklich über dich?** Die Antwort wird dich überraschen – und vielleicht ein wenig beunruhigen.

---

## 🏠 Dein Router: Der zentrale Beobachter

Stell dir vor, du lebst in einem Haus mit nur einem Ausgang. Jeder, der das Haus betritt oder verlässt, muss durch diese eine Tür. Der Türsteher sieht:

- **Wer** kommt und geht
- **Wann** sie kommen und gehen
- **Wie oft** sie kommen
- **Wohin** sie gehen (zumindest grob)
- **Wie viel Gepäck** sie tragen

**Dein Router ist dieser Türsteher.** Und er führt akribisch Buch.

---

## 📊 Was dein Router protokolliert (auch wenn du es nicht aktivierst)

### 1. Verbindungslogs

Jede Verbindung, die dein Gerät aufbaut, wird registriert:

```
192.168.1.100 → 142.250.185.78:443 (google.com) - 2026-04-05 23:15:42
192.168.1.105 → 151.101.1.140:443 (reddit.com) - 2026-04-05 23:15:45
192.168.1.100 → 13.107.42.14:443 (microsoft.com) - 2026-04-05 23:16:01
```

**Enthaltene Informationen**:
- **Interne IP-Adresse**: Welches Gerät hat die Verbindung aufgebaut?
- **Externe IP-Adresse**: Wohin wurde verbunden?
- **Port**: Welcher Dienst? (443 = HTTPS, 80 = HTTP, etc.)
- **Zeitstempel**: Wann genau?
- **Protokoll**: TCP, UDP, ICMP?
- **Bytes übertragen**: Wie groß war die Datenmenge?

> ⚠️ **Realität**: Die meisten Consumer-Router loggen diese Informationen **standardmäßig**, auch wenn du keine explizite Logging-Funktion aktiviert hast.

### 2. DNS-Anfragen

Jedes Mal, wenn du eine Website besuchst, muss dein Gerät die Domain in eine IP-Adresse auflösen. Diese **DNS-Anfragen** laufen typisch durch deinen Router (oder den DNS-Server, den er konfiguriert).

**Was dein Router sieht**:
```
192.168.1.100 fragt: www.bank.de → 185.12.34.56
192.168.1.105 fragt: pornhub.com → 104.16.89.20
192.168.1.100 fragt: jobs.google.com → 142.250.185.78
192.168.1.110 fragt: dating-app.com → 52.20.8.123
```

**Warum das kritisch ist**:
- 🔍 **Browsing-Historie**: DNS-Anfragen verraten, welche Websites du besuchst
- 🔍 **Suchanfragen**: Viele Suchmaschinen loggen Suchbegriffe in Subdomains
- 🔍 **Gesundheitsinformationen**: Besuche bei Arztportalen, Krankheitsforen
- 🔍 **Finanzielle Situation**: Banking, Kreditportale, Job-Suchseiten
- 🔍 **Politische Ansichten**: Nachrichtenquellen, Foren, soziale Medien
- 🔍 **Persönliche Vorlieben**: Streaming-Dienste, Shopping, Hobbies

> 🚨 **Schockierend**: Selbst wenn du HTTPS verwendest (was den Inhalt verschlüsselt), sind **DNS-Anfragen oft unverschlüsselt** und können von deinem Router (und ISP) gelesen werden.

### 3. DHCP-Leases

Dein Router vergibt IP-Adressen an alle Geräte im Netzwerk und protokolliert:

```
MAC: AA:BB:CC:DD:EE:01 → IP: 192.168.1.100 → Hostname: Johns-iPhone
MAC: AA:BB:CC:DD:EE:02 → IP: 192.168.1.105 → Hostname: Marias-Laptop
MAC: AA:BB:CC:DD:EE:03 → IP: 192.168.1.110 → Hostname: Smart-TV-Wohnzimmer
```

**Was das verrät**:
- **Anzahl der Geräte**: Wie viele Personen leben im Haushalt?
- **Gerätetypen**: iPhones, Android-Phones, Laptops, Smart TVs, IoT-Geräte
- **Anwesenheit**: Welche Geräte sind online? (Wenn das Smartphone online ist, ist jemand zu Hause)
- **Gewohnheiten**: Zu welchen Zeiten sind welche Geräte aktiv?

### 4. Port-Scanning und Firewall-Logs

Moderne Router mit Firewall-Funktion loggen:

```
BLOCKED: Externe IP 203.0.113.42 versucht Port 22 (SSH) auf 192.168.1.100
BLOCKED: Externe IP 198.51.100.17 versucht Port 3389 (RDP) auf 192.168.1.105
ALLOWED: 192.168.1.100 initiiert Verbindung zu 93.184.216.34:443
```

**Was das zeigt**:
- **Externe Angriffsversuche**: Jemand scannt dein Netzwerk
- **Deine Reaktionen**: Welche Dienste sind erreichbar?
- **Sicherheitslücken**: Hast du Ports offen, die es nicht sollten?

### 5. Bandbreiten-Nutzung

Viele Router tracken Bandbreiten-Nutzung pro Gerät:

```
192.168.1.100 (Johns-iPhone):
  - Upload: 2.3 GB heute
  - Download: 15.7 GB heute
  - Peak-Zeit: 20:00-23:00 Uhr
  - Hauptziele: Netflix, YouTube, Instagram

192.168.1.105 (Marias-Laptop):
  - Upload: 8.1 GB heute
  - Download: 4.2 GB heute
  - Peak-Zeit: 09:00-17:00 Uhr
  - Hauptziele: Office 365, Zoom, GitHub
```

**Was das verrät**:
- **Aktivitätsmuster**: Wer ist wann online?
- **Nutzungsverhalten**: Streamt jemand viel? Arbeitet jemand remote?
- **Datenintensive Aktivitäten**: Gaming, 4K-Streaming, Cloud-Backups

### 6. UPnP-Logs

Universal Plug and Play (UPnP) erlaubt Geräten, automatisch Port-Weiterleitungen zu erstellen:

```
UPnP: 192.168.1.110 (Smart-TV) öffnet Port 8080 → Internet
UPnP: 192.168.1.120 (IP-Camera) öffnet Port 554 → Internet
UPnP: 192.168.1.130 (Gaming-Console) öffnet Port 3074 → Internet
```

**Sicherheitsrisiko**: UPnP ist einer der **größten Schwachstellen** in Heimnetzwerken. Kompromittierte IoT-Geräte können automatisch Ports öffnen und dein Netzwerk angreifbar machen.

### 7. ARP-Tabellen

ARP (Address Resolution Protocol) mappt IP-Adressen zu MAC-Adressen:

```
IP: 192.168.1.100 → MAC: AA:BB:CC:DD:EE:01 → Hersteller: Apple, Inc.
IP: 192.168.1.105 → MAC: AA:BB:CC:DD:EE:02 → Hersteller: Dell Inc.
IP: 192.168.1.110 → MAC: AA:BB:CC:DD:EE:03 → Hersteller: Samsung Electronics
```

**Was das zeigt**:
- **Geräte-Hersteller**: Welche Marken nutzt du?
- **Neue Geräte**: Unbekannte MAC-Adressen könnten Eindringlinge sein
- **Netzwerktopologie**: Wie viele Geräte sind gleichzeitig aktiv?

---

## 🔍 Was dein Router NICHT sieht (dank HTTPS)

Moderne Verschlüsselung (HTTPS/TLS) schützt den **Inhalt** deiner Kommunikation. Dein Router sieht:

❌ **Was du suchst** (Suchbegriffe)
❌ **Was du liest** (Artikel-Inhalte)
❌ **Was du schreibst** (E-Mails, Nachrichten)
❌ **Deine Login-Daten** (Benutzernamen, Passwörter)
❌ **Formular-Daten** (Kreditkarten, Adressen)

Aber er sieht immer noch:

✅ **Welche Website du besuchst** (via DNS oder SNI)
✅ **Wann du sie besuchst**
✅ **Wie lange du bleibst**
✅ **Wie viel Daten du überträgst**

> 🔐 **Wichtig**: HTTPS schützt den Inhalt, aber nicht die Metadaten. Metadaten sind oft aussagekräftiger als der Inhalt selbst.

---

## 🎭 SNI: Die Lücke in HTTPS

**Server Name Indication (SNI)** ist ein TLS-Extension, das dem Server mitteilt, welche Domain du besuchen willst (wichtig für Shared Hosting).

**Das Problem**: SNI wird im **Klartext** gesendet, bevor die Verschlüsselung beginnt.

```
Client Hello (unverschlüsselt):
  - Server Name: www.geheimedating-site.de
  - Unterstützte Cipher Suites: ...
  
TLS Handshake (verschlüsselt ab hier)
```

**Was das bedeutet**: Selbst mit HTTPS kann dein Router (und ISP) sehen, **welche spezifische Website** du besuchst, dank SNI.

**Lösung**: **Encrypted SNI (ESNI)** oder **Encrypted Client Hello (ECH)** – neuere Standards, die SNI verschlüsseln. Leider noch nicht weit verbreitet.

> 🚨 **Realitätscheck**: Cloudflare, Firefox und Chrome testen ECH, aber die meisten Websites unterstützen es noch nicht. Bis dahin ist SNI eine Privatsphäre-Lücke.

---

## 📱 Was dein Router über einzelne Geräte weiß

### Smartphones

- **Always-online**: Smartphones sind fast immer mit dem WLAN verbunden
- **Hintergrundaktivität**: Apps senden ständig Daten (Push-Notifications, Sync)
- **Standort-Historie**: Wenn du zu Hause bist, weiß der Router es
- **App-Nutzung**: Welche Apps kommunizieren wann? (via DNS-Anfragen)
- **Schlafmuster**: Wann ist das Smartphone inaktiv? (Nachtmodus)

### Laptops/Desktops

- **Arbeitszeiten**: Regelmäßige Verbindungen zu Office 365, VPN, etc.
- **Entwickleraktivität**: GitHub, npm, Docker Hub Zugriffe
- **Streaming-Gewohnheiten**: Netflix, YouTube, Twitch Nutzung
- **Shopping-Verhalten**: Amazon, eBay, Preisvergleichsseiten
- **Informationskonsum**: Nachrichten, Blogs, Foren

### Smart TVs & Streaming-Geräte

- **Viewing-Habits**: Wann wird ferngesehen? Welche Dienste?
- **Content-Präferenzen**: Netflix vs. Amazon Prime vs. Disney+
- **Nutzungsdauer**: Stunden pro Tag im Durchschnitt
- **4K-Streaming**: Hohe Bandbreiten-Nutzung verrät Ultra-HD-Konsum

### IoT-Geräte (Smart Home)

- **Anwesenheitserkennung**: Smart Locks, Bewegungsmelder, Kameras
- **Energieverbrauch**: Smart Plugs zeigen, wann Geräte laufen
- **Temperatur-Präferenzen**: Smart Thermostats verraten Heizgewohnheiten
- **Sicherheitslücken**: Viele IoT-Geräte haben schwache Standardpasswörter

### Gaming-Konsolen

- **Spielzeiten**: Wann wird gezockt?
- **Online-Multiplayer**: Regelmäßige Verbindungen zu Game-Servern
- **Downloads**: Große Patches und Spiele-Downloads (10-100 GB)
- **Voice-Chat**: Discord, PlayStation Network, Xbox Live

---

## 🏢 Wer hat noch Zugriff auf diese Daten?

### 1. Dein Internet-Provider (ISP)

Dein ISP sieht **alles**, was dein Router sieht – und mehr:

- ✅ **Alle DNS-Anfragen** (wenn du ISP-DNS verwendest)
- ✅ **Alle unverschlüsselten Verbindungen** (HTTP, FTP, Telnet)
- ✅ **Metadaten aller Verbindungen** (IPs, Ports, Zeitstempel, Volumen)
- ✅ **SNI-Daten** (welche Websites du besuchst)
- ❌ **HTTPS-Inhalt** (dank Verschlüsselung sicher)

**Rechtliche Situation in Deutschland**:
- ISPs müssen Verbindungsdaten **10 Wochen** speichern (Vorratsdatenspeicherung, umstritten)
- Behörden können auf diese Daten zugreifen (mit richterlichem Beschluss)
- ISPs dürfen Daten für "Geschäfts purposes" verwenden (oft für targeted Advertising)

> ⚖️ **EU-Urteil**: Die Vorratsdatenspeicherung wurde mehrfach für verfassungswidrig erklärt, aber einige Provider speichern trotzdem.

### 2. Router-Hersteller

Moderne Consumer-Router (FRITZ!Box, ASUS, TP-Link, Netgear) senden oft Telemetrie-Daten an den Hersteller:

- **Nutzungsstatistiken**: Wie wird der Router genutzt?
- **Fehlerberichte**: Crashes, Verbindungsabbrüche
- **Geräte-Informationen**: Welche Geräte sind verbunden?
- **Standort-Daten**: Grober Standort (via IP)

**FRITZ!Box (AVM)**:
- Sendet anonyme Nutzungsdaten (opt-in, aber oft vorausgewählt)
- MyFRITZ!-Dienst ermöglicht Remote-Zugriff (mit Passwort geschützt)
- AVM betont Datenschutz, aber Details sind intransparent

**ASUS/TP-Link/Netgear**:
- Oft aggressive Telemetrie (opt-out, nicht opt-in)
- Cloud-basierte Management-Plattformen
- Einige Hersteller haben Sicherheits-Skandale erlebt (Backdoors, unsichere Cloud-Dienste)

> 🔍 **Tipp**: Überprüfe die Datenschutz-Einstellungen deines Routers. Deaktiviere Telemetrie, wenn möglich.

### 3. Smart Home Cloud-Dienste

IoT-Geräte kommunizieren oft mit Cloud-Servern:

- **Amazon Alexa**: Jede Sprachanfrage geht an Amazon-Server
- **Google Home**: Ähnlich wie Alexa, Daten bei Google
- **Philips Hue**: lighting-Steuerung via Philips-Cloud
- **Ring/Nest**: Kamera-Feeds in der Cloud gespeichert
- **iCloud/HomeKit**: Apple-Ökosystem, Ende-zu-Ende-verschlüsselt (besser)

**Das Problem**: Diese Dienste wissen mehr über dein Zuhause als dein Router:
- Wann bist du zu Hause?
- Welche Räume nutzt du?
- Wann schaust du TV?
- Wer besucht dich? (Gast-Erkennung)
- Was sprichst du? (Sprachaufnahmen)

### 4. Arbeitgeber (bei Remote Work / VPN)

Wenn du von zu Hause arbeitest und ein **Corporate VPN** verwendest:

- ✅ Arbeitgeber sieht **alle beruflichen Verbindungen**
- ⚠️ Je nach Konfiguration: **auch private Verbindungen** (Split-Tunneling vs. Full-Tunneling)
- ✅ Zeitstempel: Wann arbeitest du?
- ✅ Bandbreiten-Nutzung: Wie viel arbeitest du?

**Split-Tunneling**: Nur Unternehmens-Traffic geht durch VPN, privater Traffic direkt zum Internet (besser für Privatsphäre)

**Full-Tunneling**: Alle Traffic geht durch VPN (Arbeitgeber sieht alles)

> 💼 **Beratung**: Überprüfe deine VPN-Konfiguration. Wenn möglich, verwende Split-Tunneling, um private und berufliche Aktivitäten zu trennen.

### 5. Angreifer (bei Kompromittierung)

Wenn dein Router gehackt wird (durch schwache Passwörter, veraltete Firmware, oder Exploits):

- ❌ **Komplette Kontrolle**: Angreifer kann alle Einstellungen ändern
- ❌ **Man-in-the-Middle**: Angreifer kann HTTPS-Zertifikate fälschen
- ❌ **DNS-Hijacking**: Umleiten von Traffic auf Phishing-Seiten
- ❌ **Botnet-Teilnahme**: Dein Router wird Teil eines DDoS-Netzwerks
- ❌ **Krypto-Mining**: Angreifer nutzt deine Rechenleistung

**Berühmte Beispiele**:
- **Mirai Botnet** (2016): Hunderttausende IoT-Geräte und Router für DDoS-Angriffe
- **VPNFilter** (2018): Malware, die Router weltweit infizierte (Russland zugeschrieben)
- **FRITZ!Box-Schwachstellen**: Mehrfach kritische Lücken in AVM-Routern

---

## 🛡️ So schützt du dich

### 1. Ändere das Admin-Passwort

Das **wichtigste** und einfachste:

```bash
# Schlecht: admin/admin (Standard)
# Schlecht: password123
# Gut: Y8#mK2$pL9@nQ5!wR3*xZ7&vB4^hJ6

# Verwende einen Passwort-Manager!
```

**Warum**: Default-Passwörter sind öffentlich bekannt. Angreifer scannen das Internet nach Routern mit Standard-Credentials.

### 2. Aktualisiere die Firmware

- Prüfe monatlich auf Updates
- Aktiviere automatische Updates, wenn verfügbar
- Abgelaufene Support-Zyklen: Ersetze alte Router

**Beispiel**:
- FRITZ!Box: AVM bietet 5+ Jahre Support
- ASUS: 2-3 Jahre für Consumer-Modelle
- TP-Link/Netgear: Oft nur 1-2 Jahre
- ISP-Router: Hängt vom Provider ab

> ⚠️ **Warnung**: Viele Consumer-Router erhalten **keine Sicherheitspatches** nach 1-2 Jahren. Kaufe routere mit langem Support-Zyklus.

### 3. Deaktiviere UPnP

UPnP ist bequem, aber ein **massives Sicherheitsrisiko**:

```
FRITZ!Box: Heimnetz → Netzwerk → Netzwerke Einstellungen → UPnP deaktivieren
ASUS: LAN → Switch Control → Enable UPnP → Disable
TP-Link: Advanced → NAT Forwarding → UPnP → Disable
```

**Alternative**: Manuelle Port-Weiterleitungen nur für Dienste, die du wirklich brauchst.

### 4. Verwende ein Gast-WLAN

Isoliere IoT-Geräte und Gäste vom Hauptnetzwerk:

```
Haupt-WLAN: Laptops, Smartphones (vertrauenswürdige Geräte)
Gast-WLAN: Smart TVs, IoT, Besucher (isoliert)
```

**Vorteile**:
- IoT-Geräte können nicht auf deine Laptops zugreifen
- Gäste können nicht dein NAS oder Drucker nutzen
- Kompromittierte Geräte sind isoliert

### 5. Nutze DNS over HTTPS (DoH) oder DNS over TLS (DoT)

Das schützt deine DNS-Anfragen vor Mitlesern:

**DNS over HTTPS (DoH)**:
- DNS-Anfragen werden über HTTPS gesendet
- Ununterscheidbar von normalem Web-Traffic
- Unterstützt von Firefox, Chrome, Edge

**DNS over TLS (DoT)**:
- Dedizierter verschlüsselter DNS-Kanal
- Benutzt Port 853
- Weniger weit verbreitet, aber sicherer

**Anbieter**:
- **Cloudflare**: 1.1.1.1 (DoH/DoT)
- **Quad9**: 9.9.9.9 (DoH/DoT, blockiert Malware)
- **NextDNS**: Customizable, detaillierte Logs
- **AdGuard DNS**: Blockiert Ads und Tracker

> 🔧 **How-to (FRITZ!Box)**:
> ```
> Heimnetz → Netzwerk → Netzwerke Einstellungen
> → DNSv6-Server: dns://dns.cloudflare.com
> → DNS über HTTPS aktivieren
> ```

### 6. Konfiguriere ein VPN

Ein VPN verschlüsselt **alle** Verbindungen zwischen deinem Gerät und dem VPN-Server:

**Vorteile**:
- ISP sieht nur verschlüsselten VPN-Traffic
- Standort-Verschleierung (wähle Server in anderen Ländern)
- Schutz in öffentlichen WLANs

**Nachteile**:
- Leicht verminderte Geschwindigkeit (5-20%)
- Vertraue dem VPN-Anbieter (sie sehen deinen Traffic)
- Kosten (gute VPNs sind nicht kostenlos)

**Empfohlene Provider**:
- **Mullvad**: Anonym, no-logs, transparent (Schweden)
- **ProtonVPN**: No-logs, Schweizer Datenschutzgesetze
- **IVPN**: Transparent, unabhängig auditiert
- **AirVPN**: Tech-fokussiert, Open Source

**Zu vermeiden**:
- ❌ Kostenlose VPNs (verkaufen deine Daten)
- ❌ Unknown Anbieter (keine Transparenz)
- ❌ Anbieter in 14-Eyes-Ländern (US, UK, Kanada, Australien, etc.)

### 7. Segmentiere dein Netzwerk

Trenne Geräte in verschiedene VLANs/Subnetze:

```
VLAN 10: Vertrauenswürdige Geräte (Laptops, Smartphones)
VLAN 20: IoT-Geräte (Smart Home, Kameras, Drucker)
VLAN 30: Gast-Zugang (Besucher, temporäre Geräte)
VLAN 40: Server/NAS (isoliert, nur specific ports erlaubt)
```

**Vorteile**:
- Kompromittierte IoT-Geräte können nicht auf Laptops zugreifen
- Gäste können nicht auf dein NAS zugreifen
- Bessere Kontrolle über Netzwerk-Traffic

**How-to**: Erfordert Router mit VLAN-Unterstützung (FRITZ!Box, Ubiquiti, MikroTik, pfSense/OPNsense)

### 8. Überwache dein Netzwerk

Verwende Tools, um verdächtige Aktivitäten zu erkennen:

**Router-integriert**:
- FRITZ!Box: Heimnetz → Netzwerk → Verbindungen
- ASUS: Network Map → Client List
- pfSense/OPNsense: Status → DHCP Leases, Firewall Logs

**Externe Tools**:
- **Pi-hole**: DNS-basiertes Ad-Blocking + Monitoring
- **Grafana + Prometheus**: Netzwerk-Metriken visualisieren
- **Nmap**: Regelmäßige Netzwerk-Scans
- **Wireshark**: Packet-Analyse (fortgeschritten)

**Was du suchst**:
- Unbekannte Geräte im Netzwerk
- Ungewöhnliche Datenmengen (ein IoT-Gerät sollte nicht 50 GB/Tag senden)
- Verbindungen zu unbekannten IPs (mögliche C&C-Server)
- Port-Scans von internen Geräten (kompromittierte Geräte)

### 9. Ersetze ISP-Router durch eigene Hardware

ISP-Router (von Vodafone, Telekom, etc.) sind oft:
- ❌ Veraltet (alte Firmware)
- ❌ Eingeschränkt (wenig Konfigurationsmöglichkeiten)
- ❌ Überwacht (ISP hat Remote-Zugriff)
- ❌ Schlecht gewartet (seltene Updates)

**Bessere Alternativen**:
- **FRITZ!Box 7590/7530**: Benutzerfreundlich, guter Support
- **Ubiquiti UniFi**: Enterprise-Features, VLANs, Monitoring
- **MikroTik RouterBOARD**: Günstig, extrem konfigurierbar
- **pfSense/OPNsense**: Open Source, maximale Kontrolle (benötigt eigene Hardware)

> 💰 **Investition**: Ein guter Router kostet 150-300€, hält aber 5+ Jahre und schützt deine Privatsphäre.

### 10. Physikalische Sicherheit

- **Router-Zugang beschränken**: Nicht für Besucher zugänglich
- **WPS deaktivieren**: Wi-Fi Protected Setup ist unsicher (Brute-Force-Angriffe möglich)
- **LED-Indikatoren**: Verdecke LEDs, die Aktivität zeigen (nachts)
- **Stromversorgung**: USV für Router bei Stromausfällen (wichtig für Smart Home)

---

## 🔬 Experimentiere selbst!

### 1. Überprüfe deine Router-Logs

```bash
# FRITZ!Box: http://fritz.box -> System -> Ereignisse
# ASUS: http://router.asus.com -> System Log
# pfSense: Status -> System Logs
```

**Wonach suchen**:
- Unbekannte IP-Adressen
- Häufige Verbindungsabbrüche
- Firewall-Blocks von außen

### 2. Analysiere DNS-Anfragen

```bash
# Installiere Wireshark
# Capture auf WLAN-Interface starten
# Filter: dns
# Beobachte unverschlüsselte DNS-Anfragen
```

### 3. Teste DoH/DoT

```bash
# DoH mit curl testen
curl -H "accept: application/dns-json" \
  "https://cloudflare-dns.com/dns-query?name=google.com&type=A"

# DoT mit kdig testen
kdig @1.1.1.1 +tls google.com
```

### 4. Überprüfe UPnP

```bash
# UPnP-Scanner
upnp-inspector

# Oder mit nmap
nmap --script upnp-info 192.168.1.1
```

### 5. Scanne dein Netzwerk

```bash
# Alle Geräte finden
nmap -sn 192.168.1.0/24

# Offene Ports scannen
nmap -p 1-1000 192.168.1.1

# Service-Versionen erkennen
nmap -sV 192.168.1.1
```

### 6. Überwache Bandbreiten-Nutzung

```bash
# iftop (Linux)
sudo iftop -i wlan0

# nethogs (pro Prozess)
sudo nethogs wlan0

# vnstat (langfristig)
vnstat -d
```

---

## 🌟 Faszinierende Fakten

1. **Die durchschnittliche FRITZ!Box in Deutschland hat 7-12 verbundene Geräte** – und die Zahl steigt jährlich.

2. **Ein typischer Haushalt generiert 500-2000 DNS-Anfragen pro Tag** – das sind 180.000-730.000 pro Jahr!

3. **IoT-Geräte sind die unsichersten Geräte im Netzwerk**: 60% haben schwache oder keine Authentifizierung.

4. **Dein Router weiß, wann du schläfst**: Wenn alle Geräte inaktiv sind, weiß der Router, dass du schläfst.

5. **Mirai-Botnet infizierte über 600.000 IoT-Geräte** und führte 2016 zu massiven DDoS-Angriffen (Twitter, Netflix, Reddit offline).

6. **NSA-Programme wie QUANTUMINSERT nutzen Router-Schwachstellen**, um Traffic umzuleiten und Malware zu injizieren (Snowden-Dokumente).

7. **Einige Router haben "Management Ports", die immer offen sind** – selbst wenn du sie deaktivierst (Backdoors).

8. **Dein ISP kann basierend auf Traffic-Mustern mit 90%+ Genauigkeit vorhersagen**, welche Website du besuchst – selbst mit HTTPS (via Paketgrößen und Timing).

9. **Router-Malware kann persistieren, selbst nach Factory Reset** (in einigen Fällen).

10. **Die durchschnittliche Lebensdauer eines Consumer-Routers beträgt 4-6 Jahre** – aber die meisten erhalten nur 1-2 Jahre Sicherheitsupdates.

---

## 📚 Weiterführende Ressourcen

### Bücher
- **"Privacy-Enhancing Technologies"** von Carmela Troncoso – Technische Perspektiven
- **"The Age of Surveillance Capitalism"** von Shoshana Zuboff – Gesellschaftliche Auswirkungen

### Tools
- **Pi-hole**: DNS-basiertes Ad-Blocking und Monitoring
- **pfSense/OPNsense**: Open Source Firewall/Router-Distributionen
- **Wireshark**: Packet-Analyse-Tool
- **Nmap**: Netzwerk-Scanner
- **NextDNS**: Cloud-basiertes DNS mit Filtering

### Online-Ressourcen
- [Electronic Frontier Foundation (EFF)](https://www.eff.org/) – Digitale Rechte
- [Router Security](https://routersecurity.org/) – Umfassende Router-Sicherheitsanleitung
- [Have I Been Pwned](https://haveibeenpwned.com/) – Überprüfe, ob deine Daten geleakt wurden

---

## 💭 Fazit

Dein Router ist mehr als nur ein technisches Gerät – er ist ein **zeugnis deines digitalen Lebens**. Er weiß, wann du aufstehst, welche Nachrichten du liest, welche Shows du schaust, wen du kontaktierst, und wann du schläfst.

Die gute Nachricht: **Du kannst dich schützen**. Mit den richtigen Maßnahmen (starkes Passwort, Firmware-Updates, DoH/DoT, VPN, Netzwerk-Segmentierung) kannst du die meisten Risiken minimieren.

Die Herausforderung: Die meisten Menschen wissen nicht, **was** ihr Router weiß – und noch weniger, wie sie sich schützen können.

**Verbreite dieses Wissen. Schütze deine Privatsphäre. Denn im digitalen Zeitalter ist Privatsphäre kein Luxus – sie ist ein Grundrecht.** 🔐

---

*Dieser Artikel wurde am 2026-04-05 erstellt. Router-Firmware und -Features entwickeln sich schnell – überprüfe regelmäßig auf Updates und neue Bedrohungen.*
