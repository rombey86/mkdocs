---
description: Schritt-für-Schritt Anleitung zur Let's Encrypt DNS-Challenge mit acme-dns und PowerDNS.
---
# Let's Encrypt Wildcard-Zertifikate via ACME-DNS

Die DNS-01 Challenge ist die sauberste Methode, um SSL-Zertifikate zu generieren, besonders für interne Dienste im LAN oder für Wildcard-Zertifikate (`*.it-virtuoso.de`). Der große Vorteil: Der Webserver muss nicht über Port 80/443 aus dem Internet erreichbar sein.

## Funktionsweise (Sequenzdiagramm)

Der Prozess nutzt einen temporären DNS-TXT-Eintrag zur Validierung der Inhaberschaft.

```mermaid
sequenceDiagram
    participant S as Ziel-Server (Certbot/acme.sh)
    participant DNS as Eigener DNS-Server (PowerDNS)
    participant LE as Let's Encrypt (ACME)
    
    S->>S: Erstellt CSR & Nonce
    S->>LE: "Ich möchte Zertifikat für *.it-virtuoso.de"
    LE-->>S: "Ok, erstelle TXT-Record: _acme-challenge"
    S->>DNS: API-Update (RFC 2136): Setze TXT-Token
    Note over DNS: DNS-Zone wird aktualisiert
    S->>LE: "TXT-Record ist bereit!"
    LE->>DNS: DNS-Abfrage (TXT)
    DNS-->>LE: Token gefunden
    LE-->>S: Validierung erfolgreich!
    LE->>S: Zertifikat wird ausgestellt
    S->>DNS: API-Update: Lösche TXT-Record (Cleanup)
```
```mermaid
sequenceDiagram
    participant S as Ziel-Server (Certbot)
    participant LE as Let's Encrypt (ACME)
    participant PDNS as PowerDNS (Main-Authoritative)
    participant ADNS as ACME-DNS (Spezial-Dienst)
    
    Note over S, ADNS: Vorab: CNAME im PowerDNS einmalig angelegt
    
    S->>LE: "Brauche Zertifikat für *.it-virtuoso.de"
    LE-->>S: "Hier ist dein Challenge-Token"
    
    S->>ADNS: API-Update: Setze TXT-Record (via REST API)
    Note right of ADNS: Token liegt in lokaler acme-dns DB
    
    S->>LE: "Token ist bereit, bitte prüfen!"
    
    LE->>PDNS: DNS-Abfrage: _acme-challenge.it-virtuoso.de
    PDNS-->>LE: "Siehe CNAME: xyz.auth.it-virtuoso.de"
    
    LE->>ADNS: DNS-Abfrage: xyz.auth.it-virtuoso.de
    ADNS-->>LE: TXT-Record gefunden!
    
    LE-->>S: Validierung erfolgreich & Zertifikat ausgestellt
```
