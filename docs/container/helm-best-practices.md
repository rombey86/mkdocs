---
description: Best Practices für Helm-Charts – Versionierung, Struktur und Deployment-Strategien.
---

# Helm‑Best Practices: Versionierung, Struktur und Deployment‑Strategien

Helm ist das offizielle Paket‑Management‑Tool für Kubernetes. Es vereinfacht das Installieren, Versionieren und Verwalten von Anwendungen im Cluster. Doch wie genau verwendet man Helm effektiv, um clustersichere, wartbare und versionierte Deployments zu erstellen? In diesem Artikel erhalten Sie einen praxisorientierten Leitfaden zu **Best Practices** für Helm, die Ihnen helfen, Helm‑Charts sauber zu strukturieren, Versionen nachvollziehbar zu halten und Deployments sicher und automatisiert zu steuern.

---

## 📦 1. Helm‑Grundlagen und Projektstruktur

Ein Helm‑Chart ist ein Paket, das alle Ressourcen enthält, die ein Kubernetes‑Manifest benötigen: **Templates**, **Values**, **Dependencies** und **Hooks**. Eine gut strukturierte Verzeichnisstruktur ist entscheidend für Wartbarkeit und Wiederverwendbarkeit.

### Empfohlene Verzeichnisstruktur

```
mychart/
├─ Chart.yaml          # Metadaten (Name, Version, Description)
├─ values.yaml         # Standard‑Standardwerte
├─ templates/          # Jinja‑ähnliche Templates (.yaml)
│   ├─ deployment.yaml
│   ├─ service.yaml
│   ├─ ingress.yaml
│   └─ tests/
│       └─ test-connection.yaml
├─ templates/_helpers.tpl   # Wiederverwendbare Vorlagen
├─ .helmignore            # Wie .gitignore – ignoriert unnötige Dateien
└─ requirements.yaml      # Abhängigkeiten zu anderen Charts
```

### Warum diese Struktur?

- **Trennung von Code und Konfiguration**: `templates/` enthält nur Templates, `values.yaml` enthält anpassbare Werte.  
- **Test‑Ordner**: Enthält Tests (mit `helm test`), um die Installation zu verifizieren.  
- **`.helmignore`**: Verhindert, dass unnötige Dateien in das Chart‑Archiv gelangen (z. B. `node_modules`, `\node_modules`).  
- **`requirements.yaml`** ermöglicht Versionierung und Wiederholbarkeit von Abhängigkeiten.

> 💡 **Tipp:** Nutze `helm lint` zum Überprüfen der Chart‑ strukturellen Integrität, bevor du versionierst.

---

## 🔖 2. Versionierung & Releasing

### 2.1. Semantische Versionsierung (SemVer)

- **Format:** `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking Changes (z. B. API‑Änderungen)  
- **MINOR**: Backward‑kompatible Funktionserweiterungen  
- **PATCH**: Fehlerbehebungen, keine Funktionsänderungen  

**Praxis:**  
- Bei jedem Release ein neuer Git‑Tag: `v1.2.3`  
- Helm‑Chart‑Version in `Chart.yaml` muss mit Git‑Tag übereinstimmen.  

```yaml
# Chart.yaml
apiVersion: v2
name: mychart
description: A Helm chart for my application
version: 1.2.3      # → entspricht Git‑Tag v1.2.3
appVersion: "1.2.3"
```

### 2.2. Automated Releasing mit CI/CD

- **Git‑Tag → CI‑Pipeline** → `helm package` → `helm repository update` → Upload zu Chart‑Repository (z. B. ChartMuseum).  
- **Automatisierte Tests** (Lint, Test‑Templates) laufen vor dem Publish.  

**Beispiel GitHub‑Actions-Snippet:**

```yaml
name: Helm Release
on:
  push:
    branches: [ main ]
    tags: [ 'v*.*.*' ]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Helm
        uses: azure/setup-helm@v2
        with:
          version: v3.14.0
      - name: Package Chart
        run: helm package mychart --destination . --maturity-mode=stability
      - name: Upload Package
        uses: actions/upload-artifact@v3
        with:
          name: helm-package
          path: ./mychart-*.tgz
```

> 🎯 **Resultat:** Jeder Git‑Tag löst automatisch ein Helm‑Package‑Release aus, das versioniert und testet wird.

---

## 🛡️ 3. Sicherheit & Compliance

### 4.1. Helm‑Chart‑Signing

- **Helm 3** unterstützt **signature verification** über `helm key`.  
- **Prozess:**  
  1. Schlüsselpaar erzeugen (`helm key generate`).  
  2. Chart signieren (`helm sign mychart-1.2.3.tgz --key signing.key`).  
  3. Empfänger prüft Signatur (`helm verify mychart-1.2.3.tgz`).  

**Resultat:** Nur signierte Charts können installiert werden, falls das Repository nicht uneingeschränkt vertraut.

### 4.2. Scan‑Policyen

- **Antes‑Install‑Scans:** Nutzen Sie **Trivy** oder **Grype**, um Container‑Images im Chart zu prüfen, bevor sie deployed werden.  
- **Chart‑Lint** prüft strukturelle Integrität und Syntax.  

```bash
# Beispiel: Trivy-Scan eines Images, das im Chart referenziert wird
trivy image --severity CRITICAL mychart-image:1.2.3
```

---

## 🧪 5. Test‑Strategien für Helm‑Charts

Helm bietet eingebaute **Test‑Hooks**, die nach einem `helm install` ausgeführt werden.

### 5.1. Beispiel‑Test‑Template (`templates/tests/test-connection.yaml`)

```yaml
apiVersion: v2
kind: Service
metadata:
  name: {{ .Release.Name }}-test-connection
annotations:
  "helm.sh/hook": test
  "helm.sh/hook-delete-policy": hook-succeeded, before-serve
spec:
  containers:
  - name: wget
    image: busybox
    command: ["/bin/sh", "-c", "wget http://{{ .Release.Name }}.{{ .Release.Namespace }}:{{ .Values.service.port }}/healthz -q -O- && echo OK"]
---
```

**Ausführen:**  
```bash
helm install mychart ./mychart --generate-secrets
helm test mychart   # führt das Test‑Template aus
```

**Vorteile:**  
-Automatisierte Verifikation, bevor ein Release als „deployed“ gilt.  
-Can be extended with custom scripts (curl, curl‑health, curl‑metrics).  

---

## 📚 5. Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Helm Documentation | Official Helm Docs | <https://helm.sh/docs/> |
| Semantic Versioning 2.0.0 | Spec | <https://semver.org/> |
| Helm Test Lifecycle | Helm Docs | <https://helm.sh/docs/chart_tests/> |
| Helm Security – Signing | Helm Docs | <https://helm.sh/docs/topics/chart_signing/> |
| CNCF Landscape – Helm | CNCF | <https://landscape.cncf.io/?selection=tool=helm> |
| Helm-best‑practices repo | GitHub | <https://github.com/helm/helm-bloc> |

---

## ✅ Zusammenfassung

- **Struktur**: Saubere Verzeichnisaufteilung (`Chart.yaml`, `values.yaml`, `templates/`, `tests/`).  
- **Versionierung**: SemVer und Git‑Tags nutzen, automatisierte CI‑Pipelines für Release.  
- **Sicherheit**: Chart‑Signing, Chart‑Lint, Image‑Scanning (Trivy).  
- **Tests**: Helm‑Test‑Templates validieren Deployment‑Health.  
- **Deployment‑Strategien**: Canary, Blue‑Green, Rolling‑Update via Helm `--set` oder `--values`.  

Durch die Anwendung dieser Praktiken wird Ihr Helm‑Workflow **robust**, **nachvollziehbar** und **sicher** – ideal für Produktion und Continuous‑Delivery‑Umgebungen.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Helm‑Praxis entwickelt sich kontinuierlich; prüfen Sie regelmäßig die offizielle Helm‑Dokumentation für Updates.* 