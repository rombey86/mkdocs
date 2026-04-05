---
description: Wie Passwörter wirklich gespeichert werden - von Klartext über Hashes bis zu modernen Passwort-Managern. Ein tiefgehender Einblick in Passwort-Sicherheit.
---

# Wie Passwörter wirklich gespeichert werden (und warum die meisten Methoden falsch sind)

Du gibst ein Passwort ein. Der Server speichert es. Doch **wie** genau?

Die Antwort ist erschreckend: Viele Websites speichern Passwörter immer noch falsch. Und wenn ihre Datenbank gestohlen wird, sind deine Passwörter in Gefahr.

In diesem Artikel erfährst du, wie Passwörter **richtig** gespeichert werden, warum alte Methoden katastrophal unsicher sind, und was du tun kannst, um dich zu schützen.

---

## 🔓 Die schlechtesten Methoden (und warum du sie fürchten solltest)

### 1. Klartext-Speicherung

**Was passiert**: Der Server speichert dein Passwort genau so, wie du es eingibst.

```
Datenbank-Eintrag:
  username: max.mustermann
  password: MeinSicheresPasswort123!
```

**Warum das katastrophal ist**:
- ❌ Jeder mit Datenbank-Zugriff kann alle Passwörter lesen
- ❌ Bei Datenleck sind **alle** Passwörter sofort kompromittiert
- ❌ Viele Nutzer verwenden dasselbe Passwort auf mehreren Sites → Domino-Effekt

**Berühmte Beispiele**:
- **Adobe (2013)**: 153 Millionen Passwörter im Klartext oder schwach verschlüsselt
- **RockYou (2009)**: 32 Millionen Passwörter im Klartext
- **Yahoo (2014)**: 500 Millionen Accounts, Passwörter schwach gehasht

> 🚨 **Realitätscheck**: Wenn eine Website dein Passwort im Klartext per E-Mail sendet ("Ihr Passwort ist: XYZ"), **lauf weg**. Sie speichern es im Klartext.

### 2. Verschlüsselung (symmetrisch)

**Was passiert**: Der Server verschlüsselt Passwörter mit einem geheimen Schlüssel.

```
Verschlüsselung:
  password: MeinSicheresPasswort123!
  key: geheimerSchluessel123
  encrypted: a3f5b8c2d9e1f4g7h0i3j6k9...
```

**Warum das problematisch ist**:
- ⚠️ Wenn der Schlüssel gestohlen wird, sind **alle** Passwörter entschlüsselbar
- ⚠️ Verschlüsselung ist reversibel (kann rückgängig gemacht werden)
- ⚠️ Besser als Klartext, aber immer noch riskant

**Unterschied zu Hashing**:
- **Verschlüsselung**: Reversibel (kann entschlüsselt werden)
- **Hashing**: Einweg-Funktion (kann **nicht** umgekehrt werden)

---

## 🔐 Die richtige Methode: Hashing

### Was ist Hashing?

Ein **Hash** ist eine Einweg-Funktion, die beliebige Eingabedaten in eine feste Ausgabelänge umwandelt.

**Eigenschaften**:
- ✅ **Deterministisch**: Gleiche Eingabe = gleicher Hash
- ✅ **Einweg**: Aus Hash kann **nicht** zurück zur Eingabe berechnet werden
- ✅ **Kollisionsresistent**: Extrem schwer, zwei Eingaben mit gleichem Hash zu finden
- ✅ **Avalanche-Effekt**: Kleine Änderung → komplett anderer Hash

**Beispiel (SHA-256)**:
```
"Passwort" → SHA-256 → 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8

"passwort" → SHA-256 → d5f9c8b3e2a1f4d7c6b9e8a2f5d8c3b6e9a2f5d8c3b6e9a2f5d8c3b6e9a2f5d8
```

Beachte: Nur Großschreibung geändert → komplett anderer Hash!

### Einfaches Hashing (und warum es nicht reicht)

**Naive Implementierung**:
```python
import hashlib

def store_password(password):
    hash = hashlib.sha256(password.encode()).hexdigest()
    # Speichere hash in Datenbank
    return hash

def verify_password(password, stored_hash):
    hash = hashlib.sha256(password.encode()).hexdigest()
    return hash == stored_hash
```

**Das Problem**: **Rainbow Tables**

Eine Rainbow Table ist eine vorausberechnete Tabelle von Hashes:

```
Passwort → Hash
"123456" → 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
"password" → 5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
"letmein" → 1c8bfe8f801d79745c4631d09fff36c82aa37fc4cce4fc946683d7b336b63032
...
```

**Angreifer**:
1. Stiehlt Datenbank mit gehashten Passwörtern
2. Lookupt Hash in Rainbow Table
3. Findet Original-Passwort in Millisekunden

> ⚠️ **Fakt**: SHA-256, MD5, SHA-1 sind für Passwort-Hashing **ungeeignet**, weil sie zu schnell sind. Angreifer können Milliarden von Hashes pro Sekunde berechnen.

---

## 🛡️ Die Lösung: Salting + Langsame Hash-Funktionen

### Salting: Das Geheimnis der Individualität

Ein **Salt** ist ein zufälliger Wert, der zu jedem Passwort hinzugefügt wird, bevor es gehasht wird.

**So funktioniert's**:
```python
import os, hashlib

def store_password(password):
    # Generiere zufälligen Salt (16 Bytes)
    salt = os.urandom(16)
    
    # Salt + Passwort hashen
    hash = hashlib.sha256(salt + password.encode()).hexdigest()
    
    # Speichere BEIDES: salt und hash
    return salt, hash

def verify_password(password, salt, stored_hash):
    hash = hashlib.sha256(salt + password.encode()).hexdigest()
    return hash == stored_hash
```

**Warum Salting hilft**:
- ✅ Jeder User hat einen **einzigartigen** Salt
- ✅ Rainbow Tables sind nutzlos (müsste für jeden Salt neu berechnet werden)
- ✅ Gleiche Passwörter haben unterschiedliche Hashes

**Beispiel**:
```
User 1:
  password: "Passwort123"
  salt: a3f5b8c2d9e1f4g7
  hash: 7d8e9f0a1b2c3d4e5f6g7h8i9j0k1l2m

User 2:
  password: "Passwort123"  (gleiches Passwort!)
  salt: h7i8j9k0l1m2n3o4
  hash: 3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r  (anderer Hash!)
```

> ✅ **Salt muss nicht geheim sein**. Er wird im Klartext neben dem Hash gespeichert. Der Zweck ist **Einzigartigkeit**, nicht Geheimhaltung.

### Langsame Hash-Funktionen: Der Zeitfaktor

Das eigentliche Problem mit SHA-256 für Passwörter: Es ist **zu schnell**.

**Moderne GPUs** können Milliarden von SHA-256-Hashes pro Sekunde berechnen:
- NVIDIA RTX 4090: ~5 Milliarden SHA-256/s
- Angreifer kann 8-stellige Passwörter in Stunden bruteforcen

**Lösung**: Verwende **absichtlich langsame** Hash-Funktionen, die für Passwörter designed wurden.

---

## 🏆 Moderne Passwort-Hashing-Algorithmen

### 1. bcrypt (1999)

**Der Klassiker**, immer noch weit verbreitet.

**Features**:
- ✅ Eingebauter Salt (automatisch generiert)
- ✅ **Work Factor** (Anpassbare Kosten): Macht Hashing langsamer
- ✅ Bewährt, weit implementiert
- ✅ Resist gegen GPU-Angriffe (speicher-intensiv)

**So funktioniert's**:
```python
import bcrypt

# Passwort hashen (Salt wird automatisch generiert)
password = b"MeinSicheresPasswort123!"
hash = bcrypt.hashpw(password, bcrypt.gensalt(rounds=12))
# Ausgabe: $2b$12$KIXxGvLqLqLqLqLqLqLqLq...

# Passwort verifizieren
bcrypt.checkpw(password, hash)  # True/False
```

**Work Factor**:
- `rounds=10`: ~80 ms (schnell, aber sicher)
- `rounds=12`: ~320 ms (empfohlen)
- `rounds=14`: ~1.3 s (sehr sicher, aber langsam)

**Format des Hashes**:
```
$2b$12$KIXxGvLqLqLqLqLqLqLqLq
 ^  ^  ^
 |  |  └─ Hash (31 Zeichen)
 |  └──── Work Factor (12 = 2^12 Iterationen)
 └─────── Algorithmus (2b = bcrypt)
```

**Vorteile**:
- ✅ Einfach zu verwenden
- ✅ Bewährte Sicherheit
- ✅ Automatic Salt

**Nachteile**:
- ❌ Begrenzt auf 72 Bytes Passwort-Länge
- ❌ Nicht speicher-hard (GPU-resistent, aber nicht ASIC-resistent)

> ✅ **Empfehlung**: bcrypt ist immer noch eine gute Wahl für die meisten Anwendungen.

### 2. scrypt (2009)

**Speicher-harte** Hash-Funktion, designed von Colin Percival (Tarsnap-Gründer).

**Features**:
- ✅ Salt + Work Factor + **Speicher-Parameter**
- ✅ ASIC-resistent (benötigt viel RAM)
- ✅ Konfigurierbare Parameter (N, r, p)

**So funktioniert's**:
```python
import hashlib, os, binascii

def scrypt_hash(password, salt=None, n=16384, r=8, p=1):
    if salt is None:
        salt = os.urandom(16)
    
    # scrypt benötigt viel RAM!
    hash = hashlib.scrypt(
        password.encode(),
        salt=salt,
        n=n,      # CPU/Memory cost (muss Potenz von 2 sein)
        r=r,      # Block size
        p=p,      # Parallelization
        dklen=64  # Output length
    )
    
    return salt, binascii.hexlify(hash).decode()

# Verwendung
salt, hash = scrypt_hash("MeinPasswort")
```

**Parameter**:
- **N**: CPU/Memory-Kosten (höher = langsamer, mehr RAM)
  - Empfohlen: 16384 (2^14) bis 1048576 (2^20)
- **r**: Block-Größe (typisch 8)
- **p**: Parallelisierung (typisch 1)

**RAM-Verbrauch**: `128 * N * r * p` Bytes
- N=16384, r=8, p=1 → ~16 MB RAM pro Hash

**Vorteile**:
- ✅ Speicher-hard (ASIC-resistent)
- ✅ Sehr sicher bei korrekter Konfiguration
- ✅ Flexibel (Parameter anpassbar)

**Nachteile**:
- ❌ Komplexer zu konfigurieren
- ❌ Weniger weit implementiert als bcrypt

> ✅ **Empfehlung**: scrypt ist ideal, wenn du ASIC-Resistenz brauchst.

### 3. Argon2 (2015) - **Gewinner des Password Hashing Competition**

**Der Gold-Standard** für Passwort-Hashing.

**Features**:
- ✅ Winner der [Password Hashing Competition](https://www.password-hashing.net/) (gesponsert von OWASP)
- ✅ Drei Varianten: Argon2d, Argon2i, Argon2id
- ✅ Konfigurierbar: Time, Memory, Parallelism
- ✅ Resist gegen GPU, ASIC, Side-Channel-Angriffe

**Varianten**:
- **Argon2d**: Maximale GPU/ASIC-Resistenz, aber anfällig für Side-Channel-Angriffe
- **Argon2i**: Resist gegen Side-Channel-Angriffe, aber weniger GPU-resistent
- **Argon2id**: **Empfohlen**! Kombiniert beide Stärken

**So funktioniert's**:
```python
import argon2

# Argon2id (empfohlen)
ph = argon2.PasswordHasher(
    time_cost=3,      # Iterationen
    memory_cost=65536,  # 64 MB RAM
    parallelism=4,    # Threads
    hash_len=32,      # Hash-Länge
    salt_len=16       # Salt-Länge
)

# Hash erstellen
hash = ph.hash("MeinSicheresPasswort123!")
# Ausgabe: $argon2id$v=19$m=65536,t=3,p=4$...

# Verifizieren
ph.verify(hash, "MeinSicheresPasswort123!")  # True/False
```

**Parameter**:
- **time_cost**: Anzahl der Iterationen (höher = langsamer)
- **memory_cost**: RAM-Verbrauch in KB (höher = ASIC-resistenter)
- **parallelism**: Anzahl der Threads

**OWASP-Empfehlungen (2024)**:
- **Argon2id** mit:
  - time_cost: 3
  - memory_cost: 64 MB (65536 KB)
  - parallelism: 4
  - Oder: time_cost: 1, memory_cost: 256 MB, parallelism: 2

**Vorteile**:
- ✅ Modernster Algorithmus
- ✅ Resist gegen GPU, ASIC, Side-Channel
- ✅ Flexibel konfigurierbar
- ✅ Gewinner des Password Hashing Competition

**Nachteile**:
- ❌ Neuere Implementierung (weniger "Battle-Tested" als bcrypt)
- ❌ Komplexere Parameter

> 🏆 **Empfehlung**: **Argon2id ist der aktuelle Gold-Standard**. Verwende es für neue Projekte.

---

## 📊 Vergleich der Algorithmen

| Algorithmus | Jahr | Salt | Work Factor | Memory-Hard | ASIC-Resistent | Status |
|-------------|------|------|-------------|-------------|----------------|--------|
| MD5 | 1992 | ❌ | ❌ | ❌ | ❌ | ❌ Gebrochen |
| SHA-1 | 1995 | ❌ | ❌ | ❌ | ❌ | ❌ Gebrochen |
| SHA-256 | 2001 | ❌ | ❌ | ❌ | ❌ | ⚠️ Nicht für Passwörter |
| bcrypt | 1999 | ✅ | ✅ | ⚠️ Teilweise | ⚠️ Teilweise | ✅ Gut |
| scrypt | 2009 | ✅ | ✅ | ✅ | ✅ | ✅ Sehr gut |
| Argon2id | 2015 | ✅ | ✅ | ✅ | ✅ | 🏆 Beste Wahl |

---

## 🔑 Passwort-Policies: Was wirklich zählt

### Länge > Komplexität

**Mythos**: "Passwörter müssen Großbuchstaben, Kleinbuchstaben, Zahlen und Sonderzeichen enthalten!"

**Realität**: **Länge ist wichtiger als Komplexität**.

**Warum?**
- 8 Zeichen mit Komplexität: `95^8 = 6,6 × 10^15` Kombinationen
- 16 Zeichen nur Kleinbuchstaben: `26^16 = 4,3 × 10^22` Kombinationen

**16 einfache Zeichen sind sicherer als 8 komplexe!**

### Entropie: Das Maß für Passwort-Stärke

**Entropie** misst, wie "zufällig" ein Passwort ist.

```
Entropie (Bits) = log2(Zeichensatz^Länge)

Beispiele:
- "Passwort123!" (12 Zeichen, 95 mögliche Zeichen): ~66 Bits
- "korrekter-pferdebatterie-heftklammer" (32 Zeichen, 27 mögliche Zeichen): ~150 Bits
- Zufällige 16 Zeichen (95 mögliche Zeichen): ~105 Bits
```

**Empfehlungen**:
- **Mindestens 60 Bits Entropie** für Online-Accounts
- **80+ Bits** für wichtige Accounts (E-Mail, Banking)
- **120+ Bits** für Master-Passwörter (Passwort-Manager)

### Passphrasen vs. Passwörter

**Passwort**: `Tr0ub4dor&3` (schwer zu merken, mittelmäßig sicher)

**Passphrase**: `korrekter-pferdebatterie-heftklammer` (einfach zu merken, sehr sicher)

> 🎯 **Empfehlung**: Verwende **Passphrasen** (4+ zufällige Wörter) statt komplexer Passwörter.

### Passwort-Manager: Die beste Lösung

**Warum Passwort-Manager?**
- ✅ Generiert **starke, einzigartige** Passwörter für jeden Account
- ✅ Du musst dir nur **ein** Master-Passwort merken
- ✅ Auto-Fill in Browsern und Apps
- ✅ Sync über Geräte hinweg
- ✅ Viele bieten 2FA, Dark-Web-Monitoring, etc.

**Empfohlene Passwort-Manager**:
- **Bitwarden**: Open Source, kostenlos, self-hostbar ⭐
- **1Password**: Premium, exzellente UX
- **KeePassXC**: Lokal, keine Cloud, maximale Kontrolle
- **Proton Pass**: Von ProtonMail, Privacy-fokussiert

**Vermeide**:
- ❌ Browser-eigene Passwort-Speicher (bequem, aber weniger sicher)
- ❌ Excel/Text-Dateien (unverschlüsselt!)
- ❌ Aufschreiben auf Zetteln (offensichtlich unsicher)

> 🔐 **Tipp**: Dein Master-Passwort sollte **sehr stark** sein (20+ Zeichen oder 6+ Wörter). Es ist der Schlüssel zu allem.

---

## 🚨 Passwort-Leaks: Was tun, wenn es passiert?

### Berühmte Passwort-Leaks

| Firma | Jahr | Accounts | Problem |
|-------|------|----------|---------|
| Adobe | 2013 | 153M | Klartext/schwach verschlüsselt |
| LinkedIn | 2012 | 165M | Ungesalzene SHA-1 Hashes |
| Yahoo | 2014 | 500M | Schwach gehasht |
| MySpace | 2008 | 360M | Ungesalzene SHA-1 |
| Collection #1 | 2019 | 773M | Aggregierte Leaks |
| RockYou | 2009 | 32M | Klartext |

### Prüfe, ob deine Passwörter geleakt wurden

**Have I Been Pwned**:
- [haveibeenpwned.com](https://haveibeenpwned.com/)
- Gib deine E-Mail ein
- Siehst, ob deine Daten in bekannten Leaks sind

**Firefox Monitor**:
- [monitor.firefox.com](https://monitor.firefox.com/)
- Ähnlich wie HIBP, von Mozilla

**Password Checkup**:
- Chrome: Einstellungen → Autofill → Passwords → Check Passwords
- Prüft gegen bekannte Leaks

### Was tun nach einem Leak?

1. **Sofort Passwort ändern** (auf betroffener Site)
2. **Passwort auch auf anderen Sites ändern**, wenn du es wiederverwendet hast
3. **2FA aktivieren** (Two-Factor Authentication)
4. **Passwort-Manager verwenden**, um eindeutige Passwörter zu generieren
5. **Konten überwachen** auf verdächtige Aktivitäten

> ⚠️ **Realität**: Wenn du dasselbe Passwort auf mehreren Sites verwendest, ist **ein Leak = alle Accounts kompromittiert**.

---

## 🔐 Zwei-Faktor-Authentifizierung (2FA)

### Warum 2FA kritisch ist

Selbst mit starkem Passwort bist du verwundbar:
- **Phishing**: Du gibst Passwort auf gefälschter Site ein
- **Keylogger**: Malware zeichnet Tastatureingaben auf
- **Daten-Leaks**: Passwort wird gestohlen

**2fa fügt eine zweite Sicherheitsebene hinzu**.

### 2FA-Methoden (von schwach nach stark)

#### 1. SMS-Codes (schwach)

**So funktioniert's**: Du erhältst einen 6-stelligen Code per SMS.

**Probleme**:
- ❌ SIM-Swapping: Angreifer übernimmt deine Telefonnummer
- ❌ SMS kann abgefangen werden (SS7-Exploits)
- ❌ Kein Schutz bei verlorenem Telefon

**Vermeide**, wenn möglich.

#### 2. E-Mail-Codes (mittel)

**So funktioniert's**: Code wird per E-Mail gesendet.

**Probleme**:
- ❌ Wenn E-Mail-Account kompromittiert ist, ist 2FA nutzlos
- ❌ E-Mails sind oft unverschlüsselt

**Besser als nichts, aber nicht ideal**.

#### 3. TOTP (Time-based One-Time Password) (stark) ⭐

**So funktioniert's**:
- App (Google Authenticator, Authy, Raivo, etc.) generiert alle 30 Sekunden einen 6-stelligen Code
- Basiert auf gemeinsamem Secret + aktueller Zeit
- Funktioniert offline!

**Vorteile**:
- ✅ Kein Internet nötig
- ✅ Nicht anfällig für SIM-Swapping
- ✅ Weit verbreitet

**Nachteile**:
- ❌ Wenn Telefon verloren geht, brauchst du Backup-Codes
- ❌ Phishing-resistent, aber nicht perfekt

**Empfohlene Apps**:
- **Raivo OTP** (iOS): Open Source, iCloud-Sync
- **Aegis Authenticator** (Android): Open Source, verschlüsselt
- **Authy**: Multi-Device, Cloud-Backup (aber proprietär)
- **Google Authenticator**: Einfach, aber keine Cloud-Sync (bis vor kurzem)

#### 4. FIDO2/WebAuthn Hardware Keys (stärkste) 🏆

**So funktioniert's**:
- Physischer USB/NFC-Schlüssel (YubiKey, SoloKey, etc.)
- Public-Key-Kryptographie
- **Phishing-resistent**: Funktioniert nur auf der echten Domain

**Vorteile**:
- ✅ **Phishing-resistent** (stärkster Schutz)
- ✅ Kein Code eingeben (einfach Key berühren)
- ✅ Keine Codes zu speichern

**Nachteile**:
- ❌ Kosten Geld ($20-50 pro Key)
- ❌ Physisches Gerät (kann verloren gehen)
- ❌ Nicht alle Sites unterstützen es

**Empfohlene Keys**:
- **YubiKey 5 Series**: Gold-Standard, NFC, USB-A/C
- **SoloKey**: Open Source, günstiger
- **Nitrokey**: Open Source, made in Germany

> 🏆 **Empfehlung**: Verwende **FIDO2-Keys** für wichtige Accounts (E-Mail, Passwort-Manager, Banking). TOTP für den Rest.

### 2FA-Best-Practices

1. **Aktiviere 2FA überall**, wo es verfügbar ist
2. **Verwende TOTP oder FIDO2**, vermeide SMS
3. **Speichere Backup-Codes** sicher (ausgedruckt, verschlüsselt)
4. **Teste 2FA-Setup**, bevor du dich aussperrst
5. **Verwende mehrere Methoden** (TOTP + Backup-Codes + FIDO2)

---

## 🔬 Praktische Beispiele

### 1. Prüfe Passwort-Stärke

```python
import math

def password_entropy(password):
    # Zeichensatz-Größe schätzen
    charset_size = 0
    if any(c.islower() for c in password):
        charset_size += 26
    if any(c.isupper() for c in password):
        charset_size += 26
    if any(c.isdigit() for c in password):
        charset_size += 10
    if any(c in "!@#$%^&*()_+-=[]{}|;:',.<>?/~`" for c in password):
        charset_size += 32
    
    # Entropie berechnen
    entropy = len(password) * math.log2(charset_size)
    return entropy

# Test
print(password_entropy("Passwort123!"))  # ~66 Bits
print(password_entropy("korrekter-pferdebatterie-heftklammer"))  # ~150 Bits
```

### 2. Hash ein Passwort mit Argon2

```python
import argon2

ph = argon2.PasswordHasher()

# Hash erstellen
password = "MeinSicheresPasswort123!"
hash = ph.hash(password)
print(f"Hash: {hash}")

# Verifizieren
try:
    ph.verify(hash, "MeinSicheresPasswort123!")
    print("Passwort korrekt!")
except argon2.exceptions.VerifyMismatchError:
    print("Falsches Passwort!")
```

### 3. Prüfe, ob Passwort geleakt wurde (HIBP API)

```python
import hashlib, requests

def check_password_breach(password):
    # SHA-1 Hash berechnen
    sha1 = hashlib.sha1(password.encode()).hexdigest().upper()
    
    # Erst 5 Zeichen (Prefix)
    prefix = sha1[:5]
    suffix = sha1[5:]
    
    # HIBP API abfragen
    response = requests.get(f"https://api.pwnedpasswords.com/range/{prefix}")
    
    # Prüfe, ob Suffix in Response
    for line in response.text.split('\n'):
        hash_suffix, count = line.strip().split(':')
        if hash_suffix == suffix:
            return int(count)
    
    return 0

# Test
count = check_password_breach("password123")
print(f"Passwort wurde {count} mal in Leaks gefunden!")
```

> ⚠️ **Warnung**: Gib **niemals** echte Passwörter in Online-Checker ein! Verwende nur für Test-Passwörter.

---

## 🌟 Faszinierende Fakten über Passwörter

1. **Das häufigste Passwort der Welt ist immer noch "123456"** - gefolgt von "password", "123456789", und "qwerty".

2. **Die durchschnittliche Person hat 100+ Online-Accounts**, aber verwendet oft nur 5-10 verschiedene Passwörter.

3. **Ein 8-stelliges Passwort mit allen Zeichentypen kann von einer modernen GPU in Minuten geknackt werden**. 12+ Zeichen sind das neue Minimum.

4. **Der erste Computer-Passwort-Leak war 1962** am MIT - ein Student hat die Passwort-Datei des CTSS-Systems gedruckt.

5. **NIST-Empfehlungen (2017)**: Verwende lange Passphrasen, erzwinge keine Komplexität, erlaube alle Zeichen (inkl. Emojis!), prüfe gegen bekannte Leaks.

6. **Passwort-Wiederverwendung ist die #1 Ursache für Account-Übernahmen**: 65% der Menschen verwenden Passwörter auf mehreren Sites.

7. **FIDO2-Keys sind phishingsicher**: Selbst wenn du auf einer gefälschten Site bist, funktioniert der Key nicht (Domain-Check).

8. **Apple, Google, und Microsoft pushen "Passkeys"**: Passwort-lose Authentication via FIDO2/WebAuthn. Die Zukunft ist hier!

9. **Ein YubiKey kostet $20-50, aber kann Identitätsdiebstahl verhindern**, der Tausende kostet.

10. **Die USA, EU, und andere Regierungen empfehlen FIDO2/WebAuthn als Gold-Standard** für Regierungs-Accounts.

---

## 📚 Weiterführende Ressourcen

### Standards und Guidelines
- [NIST SP 800-63B: Digital Identity Guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html)
- [OWASP Password Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html)
- [Password Hashing Competition](https://www.password-hashing.net/)

### Tools
- **Have I Been Pwned**: [haveibeenpwned.com](https://haveibeenpwned.com/)
- **Bitwarden**: Open Source Passwort-Manager
- **YubiKey**: FIDO2 Hardware-Key
- **Aegis Authenticator**: Open Source TOTP-App (Android)

### Bücher
- **"Password Security"** by Joseph Bonneau et al.
- **"Security Engineering"** by Ross Anderson (Kapitel zu Authentication)

---

## 💭 Fazit

Passwörter sind ein notwendiges Übel. Aber wie sie gespeichert werden, macht den Unterschied zwischen Sicherheit und Katastrophe.

**Die wichtigsten Lektionen**:

1. **Websites sollten Passwörter niemals im Klartext speichern** - immer hashen!
2. **Einfache Hashes (SHA-256, MD5) sind nicht genug** - verwende bcrypt, scrypt, oder Argon2
3. **Salting ist essentiell** - verhindert Rainbow-Table-Angriffe
4. **Länge ist wichtiger als Komplexität** - Passphrasen > komplexe Passwörter
5. **Verwende einen Passwort-Manager** - generiere einzigartige, starke Passwörter
6. **Aktiviere 2FA** - besonders TOTP oder FIDO2
7. **Prüfe regelmäßig, ob deine Passwörter geleakt wurden** - Have I Been Pwned

Die Zukunft ist **passwortlos**: FIDO2/WebAuthn, Biometrie, Passkeys. Aber bis dahin: Sichere Passwörter speichern und verwenden.

**Denn im digitalen Zeitalter ist dein Passwort oft der einzige Schutz zwischen dir und Identitätsdiebstahl.** 🔐

---

*Dieser Artikel wurde am 2026-04-05 erstellt. Passwort-Standards entwickeln sich weiter (Passkeys, WebAuthn) - bleib auf dem Laufenden.*
