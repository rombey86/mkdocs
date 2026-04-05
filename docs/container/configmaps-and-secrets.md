---
description: Effizientes Management von Konfigurationsdaten und geheimen Werten in Kubernetes.
---

# Konfigurationsmanagement in Kubernetes: ConfigMaps & Secrets

In virtuosen Kubernetes-Umgebungen trennen sich **Konfiguration** und **Code** strikt.  
**ConfigMaps** und **Secrets** sind die offiziellen Mechanismen, um Konfigurationsdaten sicher zu speichern und zur Laufzeit in Pods bereitzustellen.  
Dieser Artikel erklärt, wie man ConfigMaps und Secrets effektiv nutzt, häufige Fallen vermeidet und bewährte Sicherheitspraktiken implementiert – alles auf Deutsch und mit praxisnahen Codebeispielen.

---

## 📦 1. Grundlagen: Warum ConfigMaps & Secrets?

### 1.1. Warum nicht einfach in Umgebungsvariablen oder Config-Dateien?

- **Sicherheit**: Secrets enthalten sensible Daten (Passwörter, API‑Keys). Das Speichern im Klartext ist ein schwerwiegender Sicherheitsrisiko.  
- **Versionierung**: ConfigMaps/Secrets können versioniert und rollback‑fähig sein.  
- **Entkoppelung**: Anwendungen müssen nicht wissen, woher die Konfiguration stammt.  
- **Mehrfachnutzung**: Derselbe ConfigMap kann von mehreren Pods verwendet werden.

### 1.2. Definitionen im Überblick

| Typ | Zweck | Datenart | Verschlüsselung |
|-----|-------|----------|-----------------|
| **ConfigMap** | Nicht‑geheime Konfiguration (z. B. URL‑Endpunkte, Feature‑Toggles) | Schlüssel‑Wert‑Paare (String‑Daten) | Keine Verschlüsselung nötig |
| **Secret** | Vertrauliche Daten (Passwörter, API‑Keys, TLS‑Zertifikate) | Schlüssel‑Wert‑Paare, Base64‑kodiert | Intern verschlüsselt, optional encrypted at rest | 

> **Hauptunterschied**: Secrets werden standardmäßig **base64‑verschlüsselt** im etcd‑Speicher, ConfigMaps nicht.

---

## 🛠️ 2. Erstellen & Verwalten von ConfigMaps

### 2.1. Erstellen aus Dateien

```bash
kubectl create configmap app-config \
  --from-file=./config/app.properties \
  --from-file=./config/logging.conf
```

**Inhalt von `app.properties`:**
```properties
db.url=jdbc:postgresql://db:5432/appdb
db.user=app_user
db.password=very_secret_password
```

**Ergebnis:**  
Ein ConfigMap-Objekt mit den Schlüsseln `app.properties` und `loggin.conf` (der Pfad ist der Dateiname, nicht der Inhalt).

### 2.2. Erstellen aus Literal‑Werten

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  enable_feature_x: "true"
  log_level: "debug"
  feature_y_enabled: "false"
```

### 2.3. Verwendung im Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
  - name: my-container
    image: my-app:1.0
    env:
      - name: APP_CONFIG
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: app.properties
    # Oder direkt als Umgebungsvariable:
    env:
      - name: LOG_LEVEL
        valueFrom:
          configMapKeyRef:
            name: app-config
            key: log_level
```

- **`configMapKeyRef`**: Greift auf einen spezifischen Schlüssel im ConfigMap zu.  
- **`valueFrom`** ermöglicht das Injizieren als Umgebungsvariable oder als Volume‑Mount.

### 2.3. ConfigMap als Volume mounten

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:1.0
    volumeMounts:
      - name: config-volume
        mountPath: /etc/app-config
        readOnly: true
  volumes:
    - name: config-volume
      configMap:
        name: app-config
        items:
          - key: app.properties
            name: app.properties
            mode: 0644
```

- **`items`**: Definiert, welche Schlüssel als Dateien im Pod gemountet werden und unter welchem Pfad.  
- **`mode`**: Dateirechte (hier 0644).

---

## 🔐 3. Secrets – Sichere Geheimnisse

### 3.1. Secrets erstellen

```bash
kubectl create secret generic db-credentials \
  --from-literal=username='admin' \
  --from-literal=password='S3cr3tP@ssw0rd!' \
  --dry-run=client -o yaml > db-credentials-secret.yaml
```

Oder als Manifest:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=          # base64 admin
  password: czNjc3RwckBzc2Vzcw==   # base64 of "S3cr3tP@ssw0rd!"
```

### 3.1.1. Base64‑Kodierung verstehen

```bash
echo -n "admin" | base64   # gibt "YWRtaW4="
echo -n "S3cr3tP@ssw0rd!" | base64   # gibt "czNjc3RwckBzc2Vzcw=="
```

### 3.2. Secrets im Pod nutzen

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:1.0
    env:
      - name: DB_USER
        valueFrom:
          secretKeyRef:
            name: db-credentials
            key: username
      - name: DB_PASS
        valueFrom:
          secretKeyRef:
            name: db-credentials
            key: password
```

### 3.2. Secrets als Volume mounten (alternativ)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: my-app:1.0
    volumeMounts:
      - name: secret-volume
        mountPath: /etc/secret
        readOnly: true
  volumes:
    - name: secret-volume
      secret:
        secretName: db-credentials
```

### 3.3. Best Practices für Secrets

| Praxis | Warum wichtig |
|--------|---------------|
| **Never commit Secrets** | Git‑Historien残留 führt zu Datenlecks. | Nutze `.gitignore` für `*.secret.yaml`. |
| **Least‑Privilege‑Access** | Nur Pods, die den Secret benötigen, dürfen darauf zugreifen. | Nutze RBAC‑Rollen und Secrets‑Selektoren. |
| **Enable Encryption at Rest** | Schützt Daten im etcd‑Speicher. | Aktiviere `EncryptionConfiguration` im API‑Server. |
| **Limit Secret Usage** | Vermeide das Verbreiten von Secrets über Umgebungsvariablen. | Nutze nur wo nötig; bevorzugen Volume‑Mounts. |
| **Rotate Secrets Regular** | Reduziert Schaden bei einem Leak. | Automatisierte Rotation via Vault oder Kubernetes `Secret` Update. |

### 3.3. Beispiel: Secret‑Rotierung mit `kubectl`

```bash
kubectl create secret generic db-credentials-new \
  --from-literal=username='admin_new' \
  --from-literal=password='Neu3str0ngPassword!' \
  --dry-run=client -o yaml > db-credentials-new.yaml
kubectl replace secret db-credentials --from-file=db-credentials=db-credentials-new.yaml
```

> **Hinweis:** Nach der Rotation müssen Pods neu starten, um die neuen Werte zu erhalten.

---

## 📚 4. Praktische Anwendungsfälle

| Szenario | Empfohlene Vorgehensweise |
|----------|--------------------------|
| **Datenbank‑Verbindung** | Konfiguration via ConfigMap (URL, Treiber) + Secrets für Passwort |
| **Feature‑Toggles** | ConfigMap‑Schlüssel wie `feature_x_enabled=true` – kann über Ingress‑Regeln oder UI aktiviert werden |
| **API‑Schlüssel für Drittanbieter** | Secret‑Secret, nicht als Code in Repositories |
| **TLS‑Zertifikate** | In Secret einbinden und als Volume in Pods mounten, Anwendung liest Zertifikat zur TLS‑Terminierung |
| **Umgebungsvariablen für CI/CD** | ConfigMap zur Bereitstellung von Build‑Versionen oder Feature‑Flags |

---

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Kubernetes ConfigMap Docs | Official K8s Docs | <https://kubernetes.io/docs/concepts/configuration/configmap/> |
| Kubernetes Secrets Docs | Official K8s Docs | <https://kubernetes.io/docs/concepts/configuration/secret/> |
| `kubectl` Cheat Sheet | Kelsey Hightower | <https://kubernetes.io/docs/reference/kubectl/cheatsheet/> |
| OCP – Secrets Management | Red Hat Docs | <https://docs.openshift.com/container-platform/latest/security/authentication/managing-secrets.html> |
| HashiCorp Vault Integration | Vault Docs | <https://www.vaultproject.io/docs/secrets/kubernetes/k8s> |

---

## 🎯 Fazit

- **ConfigMaps** sind ideal für **nicht‑geheime** Konfigurationen.  
- **Secrets** schützen **vertrauliche Daten** und werden automatisch base64‑kodiert sowie optional verschlüsselt.  
- **Volume‑Mounts** und **Umgebungsvariablen** ermöglichen flexiselektives Injizieren von Daten.  
- **Sicherheit** erfordert bewusste Praxis: Verschlüsselung, Zugriffskontrolle und Rotation.  

Mit diesen Mitteln können Sie Ihre Anwendungen **sauber entkoppeln**, **sicher betreiben** und gleichzeitig **wartungsfreundlich** halten – ein entscheidender Schritt für jede moderne, cloud‑native Infrastruktur.

---

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Konfigurationsmanagement‑Praxis entwickelt sich kontinuierlich; aktualisieren Sie regelmäßig Ihre Bild‑ und Helm‑Charts, um sicherzustellen, dass geheime Daten sicher behandelt werden.* 