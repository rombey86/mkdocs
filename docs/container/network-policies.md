---
description: Implementierung von Netzwerk-Policies in Kubernetes für Sicherheit und Isolation.
---

# Kubernetes Network Policies: Sicherheitsrichtlinien für Container-Netzwerke

In Kubernetes ist Netzwerkisolation ein zentraler Aspekt der Sicherheit. Standardmäßig können alle Pods mit jeder anderen Kommunikation erfolgen, was ein hohes Risiko darstellt. **Network Policies** ermöglichen es, definierte Regeln zu erstellen, die den Datenverkehr zwischen Pods steuern und somit Angriffsflächen reduzieren. In diesem Artikel erfahren Sie, wie Sie Network Policies effektiv einsetzen, um Ihre Cluster‑Umgebung zu sichern.

---

## 🔐 1. Warum Network Policies benötigen

- **Standardverhalten**: Standardmäßig dürfen alle Pods miteinander kommunizieren – das ist unsicher.  
- **Angriffsfläche reduzieren**: Durch gezielte Isolation lassen sich Angreifer daran hindern, lateral zu bewegen.  
- **Compliance**: Viele Regulierungsstandards (z. B. ISO 27001, PCI‑DSS) verlangen Netzwerk‑Isolation.  
- **Graceful Segmentation**: Pods können in logische Gruppen (z. B. "frontend", "backend", "db") eingeteilt werden, um den Verkehr zu steuern.

---

## 📦 2. Netzwerk‑Policy – Grundlagen

Eine **NetworkPolicy** ist ein Kubernetes‑Objekt, das definiert, welche Podsverkehr akzeptieren dürfen. Sie arbeitet mit **Label‑Selektoren**, um Pods zu gruppieren, und regelt Eingangs‑ und Ausgangs‑Traffic.

### 1.1. Grundstruktur einer NetworkPolicy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: backend
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
  policyTypes:
    - Ingress
```

- **`podSelector`**: Definiert, welche Pods von der Policy betroffen sind (hier: alle Pods mit dem Label `app: backend`).  
- **`ingress`**: Listet die zulässigen Quell-Pods auf (hier: Pods mit dem Label `app: frontend`).  
- **`policyTypes`**: Bestimmt, ob die Policy **only Ingress**, **only Egress** oder **Ingress & Egress** gilt.  

### 1.2. Wichtige Felder im Detail

| Feld | Beschreibung |
|------|--------------|
| `podSelector` | Wählt die Ziel‑Pods aus, auf die die Policy angewendet wird. |
| `ingress` | Liste von Quellen (Pods), die tráfico zum Ziel‑Pod zulassen dürfen. |
| `policyTypes` | Aktiviert entweder **Ingress**, **Egress** oder beides. Standardmäßig ist nur Ingress aktiv. |
| `except` | (Optional) List of pod selector(s), die **ausgeschlossen** werden (Erlaubnis‑Umkehrung). |

### 1.3. Typische Use‑Cases

| Use‑Case | Beispiel‑Policy |
|----------|-----------------|
| **Frontend ↔ Backend** | Nur Frontend‑Pods dürfen Verbindungen zu Backend‑Pods herstellen. |
| **Datenbank‑Zugriff** | Nur Pods mit dem Label `app=database` dürfen Verbindungen zur Datenbank herstellen; alle anderen Pods dürfen keinen Traffic über Port 3306 senden. |
| **Externer Zugriff von außen** | Nur bestimmte externe Pods (z. B. aus einem anderen Namespace) dürfen auf Pods mit einem bestimmten Service zugreifen. |
| **Verbot von lateraler Kommunikation** | Alle Pods dürfen nur mit Pods desselben Namensraums kommunizieren; alle anderen Verbindungen werden abgelehnt. |

---

## 🛠️ 2. Praxis: Netzwerk‑Policy erstellen und testen

### 2.1. Create‑Beispiel für eine isolierte Datenbank‑Policy

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-db-access
  namespace: prod
spec:
  podSelector:
    matchLabels:
      app: database
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: backend   # Nur Pods mit dem Label "app=backend" dürfen kommunizieren
  policyTypes:
    - Ingress   # Nur Ingress‑Regeln sind relevant
```

**Anwendung:**  
```bash
kubectl apply -f allow-db-access.yaml
```

### 2.2. Testen der Policy

```bash
# Prüfen, welche Pods die Policy treffen:
kubectl get pods -n prod -l app=backend

# Ein Test-Pod starten, um Verbindung zur Datenbank herzustellen:
kubectl run -n prod test-pod --image=busybox --rm -it --restart=Never -- sh
# Inside the pod:
curl http://backend-service.prod.svc.cluster.local:3306   # Sollte funktionieren, wenn von allowed Pod aus
# Wenn von einem nicht‑ausgewählten Pod versucht wird, wird die Verbindung abgelehnt.
```

### 2.3. Kombinieren mehrerer Policies

- **Mehrere Policies** können gleichzeitig aktiv sein; sie werden **additiv** angewendet.  
- **Default‑Deny‑Ansatz**: Ohne explizite Erlaubnis wird der Verkehr abgelehnt – das ist ein Sicherheits‑Best‑Practice‑Ansatz.  
- **Reihenfolge**: Die Reihenfolge spielt keine Rolle; jede_policy wird unabhängig geprüft.  

---

## 🛡️ 3. Best Practices & Häufige Fallen

| Falle | Warum problematisch | Lösung |
|-------|--------------------|--------|
| **Alle Pods erlauben** | Erlaubt jeden Traffic → keine Isolierung | Beginnen Sie mit einer **Default‑Deny‑Policy**, dann gezielte Erlaubnisse hinzufügen. |
| **Zu breite Label‑Selektion** | Zu viele Pods erhalten Zugang → Sicherheitslücke | Nutzen Sie spezifische, eindeutige Labels (z. B. `app=backend`, `tier=database`). |
| **Egress‑Regeln vergessen** | Durch Fehlen von `policyTypes: [Egress]` kann ausgehenden Traffic unbeabsichtigt erlaubt werden. | Definieren Sie explizit `policyTypes: [Ingress, Egress]` oder setzen Sie `egress`‑Regeln. |
| **Verwendung von `hostSelector` unsicher** | Erlaubt Kommunikation mit Host‑Netzwerk – potenziell unsicher. | Vermeiden, es sei denn, es ist ausdrücklich erforderlich. |
| **Ignorieren von Policy‑Updates** | Änderungen an Namen oder Labels können Policy‑Regeln brechen. | Dokumentieren Sie Label‑Definitionen und aktualisieren Sie Policys synchron. |
| **Fehlende Logging‑Erfassung** | Fehlermeldungen werden nicht protokolliert → schwer zu debuggen. | Combine NetworkPolicy mit Logging‑Tools (e.g., `falco`, `audit logs`). |

---

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| NetworkPolicy – Offizielle Dokumentation | Kubernetes Docs | <https://kubernetes.io/docs/concepts/cluster-admin/networkpolicy/> |
| CNCF – Network Policies Landscape | CNCF | <https://landscape.cncf.io/?selected=network-policy> |
| OPA (Open Policy Agent) für Policy‑as‑Code | OPA Docs | <https://www.openpolicyagent.org/> |
| Falco – Runtime Threat Detection | Falco Docs | <https://falco.org/> |
| Kubernetes Security Best Practices | NIST | <https://csrc.nist.gov/publications/detail/sp/800-190/rev-1/final> |

---

## 💭 Fazit

- **Network Policies** sind das zentrale Werkzeug, um **Verkehr in Kubernetes-Clustern zu kontrollieren** und **seitliche Kommunikation zu verhindern**.  
- Der Schlüssel liegt im **selektiven Verwenden von Labels** und **klaren Ingress‑Regeln**, die nur die ausdrücklich erlaubten Pods zulassen.  
- Durch Kombination von **Ingress‑ und Egress‑Regeln** sowie **PolicyTypes** können Sie feingranular steuern, welcher Traffic fließt.  
- Die Kombination mit **Security‑Context**, **PodDisruptionBudget**, und **Runtime‑Security‑Tools** (Falco, Sysdig) schafft eine **tiefenabgeschirmte, konforme Umgebung**.  

Mit diesen Konzepten können Sie Ihre Container‑Workloads nicht nur funktional, sondern auch **sicher und auditierbar** betreiben – ein Muss für jede moderne, produktionsreife Anwendung.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Netzwerk‑Sicherheits‑Praxis entwickelt sich kontinuierlich; aktualisieren Sie Policies regelmäßig, um neuen Bedrohungen vorzubeugen.* 