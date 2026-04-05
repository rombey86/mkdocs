---
description: Detailed guide to Kubernetes Services, Ingress, and traffic routing.
---

# Kubernetes Services, Ingress, und Routing – Ein umfassender Leitfaden

In Kubernetes wird der Verkehr von außen in den Cluster über verschiedene Mechanismen weitergeleitet: **Services**, **ClusterIP**, **NodePort**, **LoadBalancer** und **Ingress**. Dieser Leitfaden erklärt die Funktionsweise, die verschiedenen Typen und die besten Praktiken für die Exposition und Steuerung von Diensten in einem Kubernetes-Cluster.

---

## 📦 1. Services – Der stabile Endpunkt für Pods

### 1.1. Warum Services notwendig sind

Pods in Kubernetes sind **flüchtig** – sie können neu gestartet, neu geplant oder gelöscht werden. Ihre IP-Adresse ist **nicht stabil**. Ein Service提供一个 **stabile Endpunkt**, der den sich ändernden Pod-IP-Adressen abstrahiert und den Verkehr an die korrekten Pods weiterleitet.

### 1.2. Service‑Typen im Überblick

| Service‑Typ | Funktionsweise | Typische Nutzung |
|------------|----------------|------------------|
| **ClusterIP** | Interner Cluster‑IP‑Adressbereich (nur innerhalb des Clusters erreichbar) | Interner Kommunikation zwischen Pods |
| **NodePort** | Öffnet einen Port auf jedem Node (30000‑32767) | Externer Zugriff ohne Load‑Balancer, für Testumgebungen |
| **LoadBalancer** | Nutzt Cloud‑Load‑Balancer (AWS ELB, GCP Cloud Load Balancing, Azure Load Balancer) | Externer Zugriff von außerhalb des Clusters |
| **ExternalName** | Mappt einen Service auf einen externen DNS-Namen | Integration externer Services |

### 1.3. Service‑Beispiel (ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app
  ports:
    - protocol: TCP
      port: 80          # Service‑Port (wie von außen gerufen)
      targetPort: 8080  # Port im Pod, der die Anwendung bedient
  type: ClusterIP     # Standard‑Typ für interne Kommunikation
```

- **`selector`**: Bindet den Service an Pods mit dem Label `app: web-app`.  
- **`port`**: Definiert den **Service‑Port** (externer Zugang) und den **targetPort** (Port im Pod).  
- **`type`**: Legt das Routing‑Verhalten fest (`ClusterIP`, `NodePort`, `LoadBalancer` …).  

### 1.4. Wie kube‑proxy funktioniert

`kube-proxy` (auf jedem Node) implementiert den Service‑Proxy:

1. **IPtables‑ oder IPVS‑Modus** (je nach Konfiguration) leitet eingehenden Traffic weiter.  
2. **DNAT** (Destination Network Address Translation) ändert die Ziel‑IP von der Service‑IP auf eine der Pod‑IPs.  
3. **Round‑Robin‑ oder least‑connection‑Algorithmen** verteilen den Verkehr auf die Backend‑Pods.  

> ⚡ **Tip:** Der Standard‑Modus ist `ipvs` (IP Virtual Server) in neueren Kubernetes‑Versionen, das bessere Performance und CONN‑Tracking bietet.

---

## 🌐 2. Ingress – Der intelligente Türsteher für externen Traffic

### 2.1. Was ist Ingress?

Ein **Ingress** ist ein Kubernetes‑Objekt, das **externe HTTP/HTTPS‑Anfragen** in den Cluster leitet. Es fungiert als **Reverse‑Proxy** und ermöglicht:

- Mehrere Services über einen einzigen externen Endpunkt  
- TLS‑Termination (SSL‑Ending) am Rand des Clusters  
- Routing nach Host‑Header oder Pfad  

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
          - path: /api(/|\\??.*)?
            pathType: Prefix
            backend:
              service:
                name: web-service
                port:
                  number: 80
```

- **`host`**: Der externe Host‑Name, unter dem der Traffic ankommt.  
- **`path`**: Der URL‑Pfad, für den der Traffic weitergeleitet wird.  
- **`backend.service.name`**: Verknüpft den Ingress mit einem bestehenden Service.  

### 2.3. Ingress‑Controller verstehen

| Controller | Charakteristik |
|------------|----------------|
| **NGINX Ingress** | Sehr verbreitet, stabil, viele Features (Rate‑Limiting, TLS‑Termination). |
| **Traefik** | Leichtgewichtig, dynamische Konfiguration über Labels, ideal für Micro‑Service‑Umgebungen. |
| **Istio / Envoy** | Hochperformant, Advanced Traffic‑Management (Circuit‑Breaking, Rate‑Limiting) – aber höhere Komplexität. |
| **Google Cloud Load Balancing (GLBC)** | Native GKE‑Lösung, automatisch in GKE integriert. |

> **Praxis‑Tipp:** Starten Sie mit **NGINX Ingress**, da es am häufigsten dokumentiert ist. Sie können später problemlos zu einem fortschrittlicheren Controller migrieren.

### 2.4. TLS‑Termination & sichere Verbindungen

- **Ingress‑Controller** kann TLS‑Termination übernehmen: Der Client kommuniziert verschlüsselt bis zum Ingress‑Controller, der dann die Verbindung wieder entschlüsselt und an das Backend‑Pod weiterleitet.  
- **.well-known‑certificates**: Eigenes Zertifikat hinterlegen oder **Let’s Encrypt** mit **cert‑manager** automatisieren.  

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
        - www.secure-app.de
      secretName: tls-secret   # Enthält Zertifikat und privaten Schlüssel
    rules:
      - host: secure-app.de
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

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Ingress‑Controller‑Vergleich | CNCF Landscape | <https://landscape.cncf.io/?selected=ingress> |
| NGINX Ingress Documentation | NGINX Docs | <https://docs.nginx.com/en/ingress-nginx/> |
| Traefik Documentation | Traefik | <https://doc.traefik.io/traefik/> |
| Istio Service Mesh | Istio Docs | <https://istio.io/latest/docs/> |
| Kubernetes Ingress – Official | Kubernetes Docs | <https://kubernetes.io/docs/concepts/services-networking/ingress/> |

---

## 🎯 Fazit

- **Ingress** ist der zentrale Einstiegspunkt für externen Traffic und ermöglicht feingranulare Routing‑Regeln, TLS‑Termination und zusätzliche Sicherheitsfeatures.  
- Durch **Annotations** und **Backend‑Definitionen** können Sie mehrere Services über einen einzigen Host‑Namen exposen.  
- Die Wahl des **Ingress‑Controllers** hängt von Ihren Anforderungen ab: **NGINX** für Stabilität, **Traefik** für Dynamik, **Istio** für Advanced Traffic‑Management.  
- Durch **TLS‑Termination**, **Host‑Based‑Routing** und **Path‑Based** Weiterleitungen können Sie moderne, sicherheitsbewusste Web‑Applikationen betreiben.  

Mit diesem Verständnis können Sie Ihre Anwendungen sicher und effizient im Cluster exponieren – ein entscheidender Schritt für jede produktive Kubernetes‑Umgebung.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Ingress‑Konzepte entwickeln sich kontinuierlich; aktualisieren Sie Ihre Konfigurationen regelmäßig, um neuen Features und Best‑Practices vorauszukehren.* 