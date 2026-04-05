---
description: Einführung in Kubernetes Services, Ingress und Netzwerkkonzepte für stabile Anwendungen.
---

# Kubernetes Services, Ingress und Netzwerkkonzepte – Ein praxisnaher Leitfaden

Wenn Container in Kubernetes laufen, stellt sich schnell die Frage: **Wie erreichen sie das Netzwerk?**  
In diesem Artikel erhalten Sie einen umfassenden Überblick über die wichtigsten Netzwerkbausteine von Kubernetes – **Services**, **Endpoints**, **Load Balancing** und **Ingress** – und lernen, wie Sie stabile, erreichbare und sichere Anwendungen bereitstellen.

Sie erfahren:

- ✅ Wie ein Service funktioniert und welche Typen es gibt (ClusterIP, NodePort, LoadBalancer)  
- ✅ Wie Services automatisch mit Pods über **Endpoint‑Tracking** verknüpft werden  
- ✅ Wie **Ingress‑Controller** externen Zugriff steuern und welche Optionen (NGINX, Traefik, Istio) verfügbar sind  
- ✅ Best Practices für sichere und performante Netzwerkkonfigurationen  
- ✅ Typische Fallen und wie Sie sie vermeiden  

Egal, ob Sie gerade erst mit Kubernetes starten oder bereits Erfahrung haben – dieser Leitfaden liefert Ihnen das nötige Werkzeugwissen, um Ihre Anwendungen zuverlässig und sicher zu exponieren.

---

## 📦 1. Der Service – Der stabile Zugangspunkt zu Pods

### 1.1. Warum Services nötig sind  

Pods in Kubernetes sind **flüchtig**. Sie können jederzeit neu gestartet, neu geplant oder gelöscht werden. Ein Pod bekommt erst dann eine IP-Adresse, wenn er tatsächlich läuft – und diese Adresse ist **nicht fest**.  

Ein **Service** ist daher ein stabiler,namespacedes Objekt, das einen *logischen Pool* von Pods definiert und automatisch den aktuellen Zustand (welche Pods sind gerade aktiv) abbildet.  

> **Kurzfassung:**  
> *Pod = flüchtig → Service = beständig*

### 1.2. Service‑Typen im Überblick  

| Service‑Typ | Routing‑Methode | Typische Nutzung |
|------------|----------------|------------------|
| **ClusterIP** | Internes VPN‑ähnliches Netz (kube‑proxy) | Nur für interne Kommunikation innerhalb des Clusters |
| **NodePort** | Öffnet einen Port auf jedem Node (30000‑32767) | Einfacher Zugang von außen ohne Load‑Balancer |
| **LoadBalancer** | Nutzt Cloud‑Load‑Balancer (AWS ELB, GCP Cloud Load Balancing, Azure Load Balancer) | Externer Zugriff von außen, ideal für Produktion |
| **ExternalName** | Mappt einen Service auf einen externen DNS‑Namen | Hybride Lösungen, z. B. Zugang zu einem externen Drittanbieterservice |

### 1.3. Beispiel: Einen Service anlegen

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: my-web-app
  ports:
    - protocol: TCP
      port: 80          # Service‑Port (wie er von außen gerufen wird)
      targetPort: 8080  # Port im Pod, der die Anwendung bedient
  type: LoadBalancer    # Oder: ClusterIP / NodePort
```

- **`selector`**: Verknüpft den Service mit allen Pods, die das Label `app: my-web-app` besitzen.  
- **`port`**: Definiert den außen zugänglichen Port (`port`) und den Zielport im Pod (`targetPort`).  
- **`type`**: Bestimmt, wie der Service extern erreichbar ist.  

### 1.4. Wie kube‑proxy das Routing erledigt  

Kubernetes nutzt **kube‑proxy** (ein Netzwerk‑Proxy‑Daemon), um den Datenverkehr zu den Pods weiterzuleiten.  
Der Proxy:

1. **Observiert Endpoint‑Objekte** (die die IPs der Pods enthalten).  
2. **Konstruiert passende iptables‑ oder IPVS‑Regeln**, um den Verkehr an die richtigen Pods zu leiten.  
3. Unterstützt **Round‑Robin**, **Least‑Connection** oder **Weighted‑Schichtalgorithmen**, je nach aktivierter Proxy‑Modus.

> **Wichtig:** Der Service‑Typ `LoadBalancer` löst das externe IP‑Mapping durch den Cloud‑Provider aus – Kubernetes kann das nicht selbst erledigen.

---

## 🌐 2. Ingress – Der intelligente Türsteher für außenliegenden Verkehr

### 2.1. Was ist Ingress?

Ein **Ingress‑Controller** ist ein **Reverse‑Proxy**, der am Cluster‑Rand läuft und eingehenden HTTP/HTTPS‑Traffic annimmt, ihn nach Regeln weiterleitet und ggf. weitere Layers (TLS‑Termination, Rate‑Limiting, Authentifizierung) hinzufügt.  

Der zugehörige Kubernetes‑Objekt **Ingress** definiert:

- **Welche Regeln** (Host‑Header, Pfad‑Basispfade) bestimmen, welcher Service bei welchem Host erreicht wird.  
- **Welcher Controller** den Traffic actually verarbeitet (NGINX, Traefik, Istio, …).

### 2.2. Ingress‑Ressource – Minimalbeispiel

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
    - host: www.meine-app.de
      http:
        paths:
        - path: /api(/|\\?.*)?
          pathType: Prefix
          backend:
            service:
              name: web-service
              port:
                number: 80
```

- **`host`**: Der externe Host‑Name, unter dem traffic ankommt.  
- **`path`**: Der URL‑Pfad, für den der Traffic weitergeleitet wird.  
- **`backend.service.name`**: Verknüpft den Ingress mit einem existierenden Service‑Objekt.  

### 2.3. Ingress‑Controller verstehen

| Controller | Charakteristik |
|------------|----------------|
| **NGINX Ingress** | Äus­serst verbreitet, stabil, umfangreiche Dokumentation, viele Features (Rate‑Limiting, Auth, TLS‑Termination). |
| **Traefik** | Leichtgewichtig, dynamische Konfiguration über Labels, sehr gut für dynamische Micro‑Service‑Umgebungen. |
| **Istio / Envoy** | Sehr leistungsstark, Advanced Traffic‑Management (Circuit‑Breaking, Rate‑Limiting) – aber höhere Komplexität. |
| **Google Cloud Load Balancing (GLBC)** | Native Google‑Cloud‑Lösung, automatisch in GKE integriert. |

> **Praxis‑Tipp:** Starten Sie mit **NGINX Ingress**, da es am häufigsten dokumentiert ist und eine stabile Basis bietet. Sie können später leicht zu einem fortschrittlicheren Controller migrieren.

### 2.4. TLS‑Termination & sichere Verbindungen

- **Ingress‑Controller** kann TLS‑Termination übernehmen: Der Client kommuniziert verschlüsselt bis zum Ingress‑Controller, der dann die Verbindung ggf. wieder entschlüsselt und an das Backend‑Pod weiterleitet.  
- **.well-known‑certificates**: Sie können eigene Zertifikate hinterlegen oder **Let's Encrypt** mit **cert‑manager** automatisieren.  

**Beispiel‑Konfiguration für TLS mit NGINX Ingress:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - www.meine-app.de
      secretName: tls-secret   # enthält das Zertifikat und den privaten Schlüssel
    rules:
      - host: www.meine-app.de
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: web-service
                  port:
                    number: 80
```

---

## 🛡️ 3. Best Practices für stabile Netzwerke

| Best Practice | Warum wichtig | Umsetzung |
|---------------|---------------|-----------|
| **Labels & Selectors eindeutig wählen** | Verhindert versehentliche Service‑Verknüpfungen | Nutzen Sie sprechende Namen wie `app=frontend` |
| **Namespace‑Einteilung** | Isoliert Traffic logisch (z. B. `dev`, `prod`) | In Service‑Definition `namespace: prod` angeben |
| **Health‑Checks via Liveness/Readiness** | Verhindert, dass ein nicht‑gesunder Pod Traffic erhält | `livenessProbe` und `readinessProbe` im Pod‑Spec setzen |
| **Rate‑Limiting & Quotas** | Verhindert DDoS‑Attacken und Überlastung | Ingress‑Controller‑Spezifische Regeln (z. B. NGINX `limit_req`) |
| **Security‑Context Hardening** | Schränkt Pod‑Rechte ein, reduziert Angriffsfläche | `runAsNonRoot`, `readOnlyRootFilesystem`, `capabilities: drop_all: true` |
| **NetworkPolicies** | firewallartige Regeln *innerhalb* des Clusters | Beispiel: nur Backend‑Pods dürfen mit Datenbank‑Pods kommunizieren |

### Beispiel: NetworkPolicy für isolierten Datenbankzugriff

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
              app: backend-api
```

---

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Kubernetes Services Deep‑Dive | Kubernetes Documentation | <https://kubernetes.io/docs/concepts/cluster-administration/service/> |
| Ingress Controllers Comparison | CNCF Landscape | <https://landscape.cncf.io/?project=ingress-nginx> |
| TLS with cert‑manager | Cert‑Manager Docs | <https://cert-manager.io/> |
| NetworkPolicy – Official Guide | Kubernetes Docs | <https://kubernetes.io/docs/concepts/cluster-administration/network-policy/> |
| CNCF Ingress‑Controller Landscape | CNCF Landscape | <https://landscape.cncf.io/icons/ingress> |

---

## 💡 Fazit

- **Services** geben Pods einen stabilen Netzwerk‑Endpoint und abstractieren die Fluktuation von Pod‑IP‑Adressen.  
- **Ingress** ist der zentrale Einstiegspunkt für externen Verkehr und ermöglicht feingranulare Routing‑Regeln, TLS‑Termination und zusätzliche Sicherheitsfeatures.  
- Durch **korrekte Labels**, **service‑typische Konfiguration** und **best Practices** (non‑root, read‑only, network‑policy) lassen sich robuste, sichere und skalierbare Netzwerk‑Topologien in Kubernetes bauen.  

Mit diesem Wissen können Sie Ihre Container‑Anwendungen nicht nur **funktionieren**, sondern auch **sicher und zuverlässig** im produktiven Umfeld bereitstellen.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Netzwerk‑ und Ingress‑Konzepte entwickeln sich weiter; prüfen Sie regelmäßig die offizielle Kubernetes‑Dokumentation für neue Features und Best Practices.* 