---
description: Best Practices für Dockerfile – Effiziente, sichere und wartbare Container-Images.
---

# Best Practices für Dockerfile – Effiziente, Sichere und Wartbare Container-Images

Ein Dockerfile ist mehr als nur eine Anleitung zum Bauen eines Images – es ist das Fundament für sichere, performante und wartbare Container. In diesem Artikel gehen wir auf die **wichtigsten Best Practices** ein, die you helfen, Images zu erstellen, die nicht nur klein und schnell sind, sondern auch **sicher**, **wartbar** und **produktionstauglich**.  

Wir behandeln Themen wie:

- ✅ Minimalistische Basis-Images  
- ✅ Multi‑Stage‑Builds für kleinere Images  
- ✅ Richtige Nutzer‑ und Gruppen‑Management  
- ✅ Sicherheit – keine Root‑Rechte, keine unnötigen Pakete  
- ✅ Layer‑Cache‑Optimierung  
- ✅ Gesundheit‑Checks und Entrypoint‑Strategien  

Am Ende wirst du ein **Checklist‑Template** besitzen, das du auf jedes Dockerfile anwenden kannst.

---

## 📦 1. Grundlagen: Dockerfile‑Aufbau

Ein Dockerfile besteht aus einer Reihe von **Anweisungen** (`INSTRUCTION`), die nacheinander ausgeführt werden, um ein Image zu erstellen. Jede Anweisung erzeugt eine **Layer** – ein diff‑basiertes Schichtbild, das im Image gespeichert ist.

### Häufige Anweisungen (in typischer Reihenfolge)

| Anweisung | Zweck |
|-----------|-------|
| `FROM` | Basis‑Image definieren (z. B. `alpine`, `node:18`) |
| `WORKDIR` | Arbeitsverzeichnis festlegen |
| `COPY` / `ADD` | Dateien ins Image kopieren |
| `RUN` | Shell‑Befehle ausführen (Installation, Konfiguration) |
| `ENV` | Umgebungsvariablen setzen |
| `EXPOSE` | Welche Ports das Container‑Image nutzt |
| `CMD` / `ENTRYPOINT` | Standard‑Befehl beim Starten des Containers |

> 💡 **Tipp:** `COPY` ist schneller und sicherer als `ADD` (letzteres kann Archive extrahieren und remote‑URLs unterstützen). Nutze `COPY`, wenn du keine zusätzlichen Features brauchst.

---

## 🛠️ 2. Best Practice #1 – Wähle ein Minimal‑Base‑Image

### Warum?
- **Größe:** Kleinere Images ladenchein schneller und reduzieren Angriffsfläche.  
- **Sicherheit:** Weniger installierte Pakete = weniger bekannte Schwachstellen.  
- **Wartbarkeit:** Einfacher zu patchen und zu aktualisieren.

### Empfohlene Minimal‑Images

| Anwendungsfall | Empfohlenes Base‑Image | Warum |
|--------------|----------------------|-------|
| **Alpine Linux** | `alpine` | Extrem klein (~5 MB), aber enthält `apk` für Paket‑Management. |
| **Distroless** | `gcr.io/distroless/base` | Keine Paket‑Manager, nur das Nötigste – ideal für Produktions‑Images. |
| **Debian‑Slim** | `python:3.11‑slim` | Größer als Alpine, aber mehr Werkzeuge und bessere Kompatibilität. |

> ⚠️ **Achtung:** `alpine` nutzt `musl libc`, das **nicht** alle glibc‑Abhängigkeiten unterstützt. Teste deine Anwendung gründlich!

---

## 🛡️ 3. Best Practice #2 – Vermeide Root‑Rechte

Standard‑Images laufen oft als `root`. Das ist ein großes Sicherheitsrisiko – falls ein Angreifer das Container‑Dateisystem kompromittiert, hat er volle Kontrolle.

### Lösung: Erstelle einen eigenen Nutzer

```Dockerfile
# Beispiel: Python‑App mit eigenem Nutzer
FROM python:3.11-slim

# 1. Erstelle Gruppe und Benutzer
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 2. Arbeitsverzeichnis erstellen und gehören lassen
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# 3. Nutzer wechseln
USER appuser

# 4. Port freigeben und CMD definieren
EXPOSE 5000
CMD ["python", "app.py"]
```

**Warum?**  
- Selbst wenn ein Angreifer das Container‑Dateisystem kompromittiert, hat er nur die Rechte von `appuser`.  
- `USER` muss **nach** `WORKDIR` und `COPY` kommen, sonst gibt es Pflieterungs‑Probleme.

---

## 🛡️ 3. Best Practice #3 – Nutze Multi‑Stage‑Builds

### Warum Multi‑Stage?

- **Aufbau**: Du kannst mehrere `FROM`‑Anweisungen nutzen, um **Intermediate‑Builds** zu erstellen, die später verworfen werden.  
- **Ergebnis**: Das finale Image enthält **nur** das, was für den Laufzeitbetrieb nötig ist – **keine Build‑Tools**, Compiler, `gcc`, etc.

### Beispiel: Go‑Programm kompilieren und kleines Image erzeugen

```Dockerfile
# 1️⃣ Build‑Stage
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY . .
RUN go build -o /app/app .

# 2️⃣ Run‑Stage (kleines Alpine‑Image)
FROM alpine:3.18
WORKDIR /app
COPY --from=builder /src/app .
EXPOSE 8080
CMD ["./app"]
```

**Resultat:** Das finale Image hat nur das kompilierte Binary und keine Go‑Toolchain.  
**Vorteil:** Größere Sicherheit, kleineres Image (~10 MB statt 200 MB).

---

## 🧹 3. Optimierung des Layer‑Caches

### Warum Caches wichtig sind

Jede Anweisung in einem Dockerfile erzeugt einen Layer. Wenn du häufig ändern musst (z. B. Code), willst du **nicht** jedes Mal neu bauen – **Cache‑Wiederverwendung** spart Zeit.

### Strategie

1. **COPY `requirements.txt`** *vor* `RUN pip install ...`  
2. **`RUN pip install -r requirements.txt`**  
3. **COPY .** (nach Anforderungen)  

Damit wird der Cache nur neu gebaut, wenn sich `requirements.txt` ändert – nicht jedes Mal, wenn du Quellcode änderst.

### Beispiel:

```Dockerfile
FROM node:18-alpine

# 1. Erst kopiere package‑Dateien (Cache‑Stabilität)
COPY package.json package-lock.json ./
RUN npm ci

# 2. Erst kopiere Quellcode (dieser Teil ändert sich oft)
COPY . .

# 3. Optional: weitere RUN‑Schritte (z. B. Transpiling)
# RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
```

---

## 🔐 4. Sicherheit – Minimiere Angriffsfläche

| Maßnahme | Wie umsetzen |
|----------|--------------|
| **Nutzer‑Namespace** | Erzeuge kein `root`‑Benutzer; nutze ein dedizierten Service‑Account. |
| **Capabilities drop** | Entferne unnötige Linux‑Capabilities (`CAP_NET_RAW`, `CAP_SYS_ADMIN`, …). |
| **Seccomp‑Profil** | Nutze das built‑in `runtime/default` Profil oder definire ein eigenes. |
| **Filesystem‑Read‑Only** | `READONLY` im Security‑Context, um Schreibzugriff zu verhindern. |
| **Drop‑All‑Capabilities** | `securityContext.capabilities.drop: ["ALL"]` – dann nur needed ones hinzufügen. |

### Beispiel‑Snippet für Security‑Context

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  readOnlyRootFilesystem: true
  capabilities:
    drop: ["ALL"]
  seccompProfile:
    type: RuntimeDefault
```

---

## 📦 4. Image‑Größe messen und reduzieren

### Tools

- **`docker image ls --format "{{.Repository}}:{{.Tag}} {{.Size}}"`** – Zeigt aktuelle Größe.  
- **`docker image prune`** – Entfernt nicht genutzte Images.  
- **`docker image inspect <image>`** – Zeigt detaillierte Layer‑Informationen.

### Techniken zur Reduktion

- **`.dockerignore`** verwenden – exclude unnötige Dateien (z. B. `node_modules`, `.git`).  
- **Multi‑Stage‑Builds** (siehe vorheriger Abschnitt).  
- **`upx`** zum Komprimieren binärer Dateien (nur im Build‑Schritt).  
- **Alpine‑Variante** statt `debian:latest` – reduziert Größe enorm.  

---

## 📋 Checklist: Minimal‑Secure‑Dockerfile‑Template

```Dockerfile
# 1️⃣ Base Image – klein und sicher
FROM alpine:3.18 AS base

# 2️⃣ Installiere nur nötige Pakete
RUN apk add --no-cache ca-certificates tzdata

# 2️⃣ Multi‑Stage Build (falls nötig)
FROM gcc:12 AS builder
WORKDIR /app
COPY . .
RUN gcc -o app main.c

# 3️⃣ Runtime‑Stage – nur das Nötigste
FROM alpine:3.18 AS runtime
WORKDIR /app
COPY --from=builder /app/app .
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
EXPOSE 8080
CMD ["./app"]

# 4️⃣ Security‑Context (via Kubernetes/YAML, nicht Dockerfile)
#    - runAsNonRoot: true
#    - readOnlyRootFilesystem: true
#    - capabilities: drop ALL
```

---

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Dockerfile Best Practices | Docker Docs | <https://docs.docker.com/develop/develop-images/dockerfile_best-practices/> |
| Distroless Images | Google | <https://developers.google.com/containers/distroless> |
| Docker Security Best Practices | Docker Docs | <https://docs.docker.com/engine/security/> |
| CIS Docker Benchmark | CIS | <https://www.cisecurity.org/benchmark/docker/> |
| Docker Content Trust | Docker Docs | <https://docs.docker.com/notary/> |

---

## ✅ Fazit

- **Größe & Sicherheit** hängen stark von der Wahl des Base‑Images und der Build‑Strategie ab.  
- **Nicht‑Root‑Nutzer** und **Read‑Only‑Dateisysteme** sind essenziell für Produktions‑Images.  
- **Multi‑Stage‑Builds** ermöglichen kleine, sichere Images, indem Build‑Tools im End‑Image verworfen werden.  
- **Caching** optimiert Build‑Zeit, wenn du die Anweisungen klugreihenfolgegestaltest.  
- Mit den hier vorgestellten Praktiken produzierst du Images, die **schnell**, **sicher** und **wartbar** sind – ideal für moderne Cloud‑Native‑Umgebungen.

> **Merke:** Ein Dockerfile ist mehr als Syntax – es ist das Fundament deiner Container‑Sicherheit und -Effizienz. Baue es bewusst.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Docker‑Best‑Practices entwickeln sich kontinuierlich; aktualisiere deine Dockerfiles regelmäßig, um neuen Sicherheitslücken und Optimierungen voraus zu sein.* 