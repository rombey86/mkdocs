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
