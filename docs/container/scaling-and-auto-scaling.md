---
description: Leitfaden zur Skalierung von Container-Anwendungen in Kubernetes – HPA, Cluster Autoscaling und Best Practices.
---

# Skalierung von Container-Anwendungen in Kubernetes: HPA, Cluster Autoscaling und Best Practices

In modernen Cloud‑Native‑Umgebungen muss Ihre Anwendung **dynamisch** auf wechselnde Lasten reagieren können. Kubernetes bietet dafür leistungsstarke Mechanismen zur automatischen Skalierung:  
- **Horizontal Pod Autoscaler (HPA)** – skaliert Pods horizontal (mehrere Instanzen).  
- **Cluster Autoscaler** – skaliert die Node‑Anzahl des Clusters automatisch.  

In diesem Artikel zeigen wir, wie Sie diese Mechanismen nutzen, um Ihre Container‑Anwendungen **robust, kosten‑effizient und performant** zu betreiben. Wir erklären die Funktionsweise, konfigurieren typische Szenarien und geben praxisnahe Tipps, um häufige Fallen zu vermeiden.

---

## 📈 1. Horizontal Pod Autoscaler (HPA) – Die erste Skalierungsebene

### 1.1. Was ist HPA?

Der **Horizontal Pod Autoscaler (HPA)** erhöht oder reduziert die **Anzahl der Pods** in einer Deployment oder ReplicaSet, basierend auf beobachteten Metriken wie CPU‑Last, Speicherverbrauch oder benutzerdefinierten Metriken.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 60   # Ziel: 60 % CPU-Auslastung
```

- **`minReplicas` / `maxReplicas`**: Definieren die Grenzen des Skalierungsraums.  
- **`targetUtilization`**: Der Prozentsatz der CPU (oder anderer Metriken), den die Pods durchschnittlich erreichen dürfen, bevor neue Pods gestartet werden.  

### 1.2. Metriken‑Anbieter

- **Resource‑Metriken** (CPU, Speicher): Einfach zu konfigurieren, aber nur bedingt aussagekräftig.  
- **Custom‑Metrics**: Ermöglichen die Nutzung von Anwendungsspezifischen Metriken (z. B. Anfragen pro Sekunde). Dafür wird **Prometheus Adapter** oder **KEDA** eingesetzt.  
- **External‑Metrics**: Metriken aus anderen Quellen (z. B. Cloud‑Watch, Azure Monitor).  

#### Beispiel: Skalierung anhand von Requests pro Sekunde (RPS)

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 15
  metrics:
    - type: Pods
      type: External
      external:
        metric:
          type: Pods
         pods:
            metric:
              name: requests-per-second
              target:
                type: AverageValue
                averageValue: "100"
```

Mit dem `requests-per-second`‑Metric können Sie **verkehrsabhängig skalieren**, ohne dass CPU‑Auslastung ausschlaggebend ist.

### 1.3. Best Practices für HPA

| Best Practice | Warum | Umsetzung |
|---------------|---------|-----------|
| **Min‑Replicas > 0** | Verhindert vollständiges Abschalten bei kurzfristigen Spitzen | Setzen Sie mindestens 1‑2 Pods, selbst bei geringer Last |
| **Target‑Utilization nicht zu niedrig** | Zu niedrige Zielwerte führen zu unnötiger Skalierung | 60‑80 % ist ein guter Ausgangspunkt |
| **Separate HPA für jede Lastzone** | Unterschiedliche Traffic‑Muster pro Umgebung | HPA pro Deployment/Namespace separate konfigurieren |
| **Burst‑Handling** | Kurzfristige Spitzen werden nicht immer durch HPA abgedeckt | Kombinieren Sie HPA mit **PodDisruptionBudget** und **pre‑emptible Pods** für Burst‑Handling |
| **Metrics‑Server prüfen** | Ohne Metrics‑Server funktioniert HPA nicht | `kubectl get --raw /metrics-server` oder Helm‑Installation `helm install metrics-server` |

---

## 🏗️ 2. Cluster Autoscaler – Die zweite Skalierungsebene

### 2.1. Was ist Cluster Autoscaler?

Der **Cluster Autoscaler** erweitert den Cluster, indem er **Worker‑Nodes** hinzufügt oder entfernt, wenn Pods nicht mehr geplant werden können (z. B. weil kein passender Knoten vorhanden ist).  

**Wichtig:** Der Autoscaler wirkt nur, wenn **Pods nicht geplant werden können** (z. B. wegen fehlender Ressourcen oder fehlender Node‑Platz).

### 2.2. Installation (Beispiel mit Helm)

```bash
helm repo add autoscaler https://kubernetes-sigs.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  --namespace=kube-system \
  --values-values.yaml
```

**Wichtige Parameter:**

| Parameter | Zweck |
|-----------|-------|
| `--nodes=10:max=30:min=2` | Mindest‑ und Höchstzahl von Nodes |
| `--scale-down-after-delete-delay=10m` | Verhindert sofortiges Entfernen von Nodes nach Pod‑Löschung |
| `--ignore-daemonsets=true` | Erlaubt das Skalieren, selbst wenn Daemon‑Sets laufen |

### 2.3. Integration mit HPA

- Der Cluster Autoscaler reagiert **nach hinten** (wenn Pods nicht geplant werden können).  
- Der HPA reagiert **vorwärts** (wenn Pods mehr werden sollen).  
- **Synergie**: Wenn HPA viele Pods erstellt, aber kein Node verfügbar ist → Cluster Autoscaler fügt einen Node hinzu.  
- **Umgekehrt**: Wenn ein Node gelöscht wird, entfernt Cluster Autoscaler ihn, aber nur, wenn **keine Pods mehr darauf laufen**.  

### 2.4. Best Practices für Cluster Autoscaler

| Praxis | Warum |
|--------|---------|
| **Node‑Labels für Gruppen** | Kategorisieren Sie Nodes (z. B. `size=large`, `gpu=true`) und lassen Sie Autoscaler nur bestimmte Gruppen skalieren. |
| **Spot‑Instances nutzen** | Für fault‑tolerante Workloads können pre‑emptible Nodes Kosten senken. |
| **Separate Pools für kritische workloads** | Hochverfügbare Pods sollten auf dedizierten Nodes ohne Spot‑Instanz‑Risiko laufen. |
| **Drain‑Strategie prüfen** | Vor dem Entfernen eines Nodes muss sichergestellt sein, dass alle Pods migriert sind (Drain‑Befehle). |
| **Monitoring aktivieren** | Beobachten Sie `cluster_autoscaler_*` Metriken (z. B. `cluster_autoscaler_scale_up`) in Prometheus. |

---

## 📦 3. Beispiel‑Setup: HPA + Cluster Autoscaler in einer Development‑Umgebung

1. **Namespace anlegen**  
   ```bash
   kubectl create namespace demo
   ```

2. **Deployment & HPA definieren**  
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: web-app-hpa
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: web-app
     minReplicas: 2
     maxReplicas: 10
     metrics:
       - type: Resource
         resource:
           name: cpu
           target:
             type: Utilization
             averageUtilization: 55
   ```

3. **Cluster Autoscaler aktivieren** (im `values.yaml` des Helm‑Charts):
   ```yaml
   clusterAutoscaler:
     enabled: true
     minNodeSize: 2
     maxNodeSize: 5
     replicasPerNode: 1
   ```

4. **Starten Sie die Anwendung** und beobachten Sie:  
   ```bash
   kubectl get hpa
   kubectl describe hpa web-app-hpa
   kubectl get nodes
   ```

5. **Last‑Minute‑Check** – Simulieren Sie eine CPU‑Last, indem Sie einen Loop‑Pod starten:
   ```bash
   kubectl run stress --image=busybox --restart=Never -- /bin/sh -c "while true; do cpu=$(cat /proc/loadavg | cut -f1 -f1); echo \"$cpu\"; sleep 1; done"
   ```

   Beobachten Sie, wie HPA neue Pods erstellt und Cluster Autoscaler einen Node hinzufügt.

---

## 📚 Weiterführende Ressourcen

| Thema | Quelle | Link |
|-------|--------|------|
| Horizontal Pod Autoscaler (offiziell) | Kubernetes Docs | <https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscaler/> |
| Custom Metrics API | Kubernetes Docs | <https://kubernetes.io/docs/reference/command-line-tools-reference/metrics/> |
| Cluster Autoscaler – Dokumentation | Kubernetes Docs | <https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler> |
| KEDA (Kubernetes Event‑Driven Autoscaling) | CNCF | <https://keda.sh/> |
| Best Practices für Skalierung | CNCF Landscape | <https://landscape.cncf.io/?selection=component=autoscaling> |

---

## 💭 Fazit

- Der **Horizontal Pod Autoscaler** sorgt für eine dynamische Pod‑Anzahl basierend auf definierten Metriken.  
- Der **Cluster Autoscaler** ergänzt das Konzept, indem er die Infrastruktur‑Kapazität anpasst, wenn Pods nicht mehr geplant werden können.  
- Durch ** richtige Konfiguration** (min/max Replicas, target Utilization, Custom Metrics) und **kluge Integration** von Autoscaler‑Parametern erreichen Sie eine kosteneffiziente, reaktive Skalierung.  
- **Monitoring** und **Alerting** runden die Lösung ab, um proaktiv auf Engpässe zu reagieren.

Mit diesen Mechanismen können Sie Ihre Container‑Workloads **automatisch an veränderte Lasten anpassen**, Kosten senken und gleichzeitig die Anwendungs‑Verfügbarkeit sichern.

--- 

*Dieser Artikel wurde am 2026‑04‑06 erstellt. Skalierungs‑Mechanismen entwickeln sich kontinuierlich; prüfen Sie regelmäßig die neuesten Kubernetes‑Versionen und Best‑Practice‑Richtlinien.* 