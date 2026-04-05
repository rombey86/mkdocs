---
description: Comprehensive guide to logging, metrics, and tracing for containerized applications in Kubernetes.
---

# Container Logging, Monitoring & Tracing: Observability in a Distributed World

You’ve got your containers running in Kubernetes, but **how do you actually know what’s happening inside them?**  
Logs disappear, metrics vanish, and tracing spans get lost in the ether.  

In this article we’ll turn that chaos into **structured observability**. You’ll learn:

- ✅ How to collect **structured JSON logs** and ship them to centralized stores (Loki, Elasticsearch, CloudWatch)  
- ✅ Export **metrics** with Prometheus using the right annotations and exporters  
- ✅ Propagate **traces** across service boundaries with OpenTelemetry  
- ✅ Avoid the three biggest observability anti‑patterns that cripple debugging at scale  

By the end you’ll have a **repeatable, production‑ready observability stack** that lets you answer questions like:

- “Why did this request spike latency?”  
- “Which pod is consuming 90 % of our memory?”  
- “Did a recent deployment introduce new errors?”  

Let’s turn your unobservable containers into **first‑class citizens** of your monitoring ecosystem.

---

## 📊 1. The Observability Triangle

Modern distributed systems are built on three pillars:

| Pillar | What it Answers | Typical Tools |
|--------|----------------|---------------|
| **Logs** | *What happened?* (events, errors, audit trail) | Loki, Elasticsearch, Fluent Bit, CloudWatch Logs |
| **Metrics** | *How much?* (CPU, memory, request rate, latency) | Prometheus, Grafana, OpenTelemetry Collector |
| **Tracing** | *Why did it happen?* (request flow across services) | Jaeger, Zipkin, OpenTelemetry Collector |

If any one of these pillars is missing, your debugging capability is **crippled**.  

> 🎯 **Goal:** Build a full triangle: logs → metrics → traces, with automatic correlation.

---

## 📁 2. Structured Logging: From Chaos to Queryable Data

### The Problem with Plain Text Logs

```
[2026-04-06 00:12:45] ERROR Failed to connect to database:timeout
```

- Hard to parse automatically  
- No context (which request, which user)  
- No severity levels you can filter on  

### JSON Logging – The De‑Facto Standard

```json
{
  "timestamp":"2026-04-06T00:12:45Z",
  "level":"ERROR",
  "message":"Failed to connect to database",
  "error":"Timeout",
  "request_id":"a1b2c3d4",
  "service":"payment-api",
  "host":"payment-worker-7c9d5f9b9c-4f8a2"
}
```

**Why JSON?**  
- Easy to ingest with log processors (Fluent Bit, Fluentd)  
- Enables powerful queries (e.g., “show all ERROR logs from `payment-api` in the last 5 min”)  
- Works seamlessly with structured search engines (Elasticsearch, Loki)

### Implementing JSON Logging in Popular Languages

| Language | Quick Setup |
|----------|-------------|
| **Node.js (Express)** | Use `pino` – `pino().info({msg:'User logged in', userId:123})` automatically outputs JSON |
| **Python (FastAPI)** | Use `jsonlog` – configure `logging.basicConfig(level=logging.INFO, format='%(message)s')` with a dictionary payload |
| **Go** | Use `zap` – `zap.String("user", userID).Info("Login success")` |
| **Java (Spring Boot)** | Use `logback-json-appender` to emit JSON directly |

**Best Practices**

1. **Include a unique request ID** (`trace_id` or `request_id`) in every log entry – enables correlation across services.  
2. **Add structured fields** (service name, pod name, namespace) – makes filtering trivial.  
3. **Never log sensitive data** (passwords, credit‑card numbers). Mask or omit.  
4. **Set appropriate log levels** (`INFO` for normal ops, `DEBUG` only on demand).  

### Shipping Logs to a Central Store

1. **Sidecar Container Approach** – Run a lightweight log shipper (Fluent Bit) next to each pod.  
2. **DaemonSet** – Deploy Fluent Bit as a cluster‑wide daemon that reads `/var/log/containers/*.log` and forwards to Loki/Elasticsearch.  
3. **Tagging** – Add `job="my-app"` and `env="prod"` labels so you can filter in Grafana/Loki UI.

```yaml
# Example Fluent Bit ConfigMap (partial)
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [INPUT]
        Name   tail
        Path   /var/log/containers/*.log
        Tag    kube.* 
        Refresh_Interval 10
        Mem_Buf_Limit 5MB

    [OUTPUT]
        Name   es 
        Host   elasticsearch.logging.svc.cluster.local
        Port   9200
        Index  kube-logs
        Logstash_Format On
```

---

## 📈 3. Metrics: The Language of Health

### Exporting Prometheus‑Compatible Metrics

Kubernetes already ships **cAdvisor metrics** (CPU, memory, network I/O) for every container. But your **application** often needs custom metrics.

#### Example: Exporting a Custom Counter in Go

```go
var requestCounter = prometheus.NewCounter(
    prometheus.CounterOpts{
        Name: "my_app_requests_total",
        Help: "Total number of HTTP requests processed",
    })
    
func handler(w http.ResponseWriter, r *http.Request) {
    requestCounter.Inc()
    // ... handle request ...
}
```

Add the following endpoint to expose metrics:

```go
http.Handle("/metrics", prometheus.Handler())
log.Fatal(http.ListenAndServe(":8080", nil))
```

Now Prometheus can scrape `http://my-service:8080/metrics`.

#### Prometheus Query Examples

| Query | Meaning |
|-------|---------|
| `rate(my_app_requests_total[5m])` | Requests per second over the last 5 min |
| `my_app_requests_total{service="payment-api"} == 0` | Alert if the payment API has no traffic (possible outage) |
| `kube_pod_container_status_cpu_seconds_total{containers="payment-worker"}` | CPU usage per container |

#### Best Practice: Export **process‑level** metrics in addition to **application‑level** ones. This helps you differentiate “my code is slow” vs. “the container is CPU‑starved”.

### Visualizing Metrics

- **Grafana**: Import dashboards (e.g., the official “Kubernetes Cluster Overview” dashboard) and replace the `namespace`, `pod`, and `container` variables with dropdowns to drill down.  
- **Alerting**: Create a rule like:  
  ```yaml
  - alert: HighErrorRate
    expr: sum(rate(my_app_errors_total[1m])) by (service) > 0.05
    for: 2m
    labels:
      severity: warning
    annotations:
      summary: "High error rate in {{ $labels.service }}"
      description: "More than 5 % of requests in {{ $labels.service }} have failed in the last 2 min."
  ```

---

## 🔍 4. Tracing: Following a Request Across Services

When a user clicks “Pay”, that request may travel through **payment‑service → auth‑service → db‑service**. With **tracing**, you can see the entire flow and pinpoint the exact microservice that caused the delay.

### OpenTelemetry – The New Standard

- **Vendor‑agnostic** – works with Jaeger, Zipkin, AWS X‑Ray, etc.  
- **Auto‑instrumentation** libraries exist for many languages (Node, Python, Go, Java).  
- **Context propagation** automatically passes trace IDs through HTTP headers.

#### Quick Start (Node.js + Express)

```bash
# Install the auto‑instrumentation library
npm install --save @opentelemetry/sdk-node @opentelemetry/instrumentation-express @opentelemetry/exporter-zipkin
```

```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { Zipkin } = require('@opentelemetry/exporter-zipkin');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');

const sdk = new NodeSDK({
  traceExporter: new Zipkin({
    url: 'http://jaeger-collector.jaeger.svc.cluster.local:9411/api/v2/spans',
  }),
  instrumentations: [new ExpressInstrumentation()],
});

sdk.start();
```

Now every incoming HTTP request is automatically traced, and you can see:

- **Latency per HTTP handler**  
- **Downstream calls** (e.g., “payment‑service → auth‑service: 120 ms”)  
- **Bottlenecks** (e.g., a DB call taking 300 ms)  

### Trace Sampling Strategies

| Strategy | When to Use | How It Works |
|----------|-------------|--------------|
| **Head‑Based Sampling** | Low traffic, keep everything | Sample the first N traces per minute |
| **Rate‑Based Sampling** | Steady traffic, keep a target TPS | Sample X traces per minute regardless of burst |
| ** Adaptive Sampling** | Mixed traffic patterns | Increase sampling when traffic spikes, decrease during quiet periods |

> ⚖️ **Balance**: You need enough samples to debug, but not so many that you drown in storage costs.

### Correlating Logs, Metrics, and Traces

The **OpenTelemetry Collector** can receive all three signals and **enrich** them:

- Add `trace_id` to log records  
- Attach metric time‑series to span metadata  
- Enable a single query in Grafana to view “All logs for span X”

This is the **true power of observability**: you can click a trace, then instantly see the logs and metrics that belong to that particular request.

---

## 🛠️ 4. Practical Setup Checklist

| Step | Action | Command / File |
|------|--------|----------------|
| **1️⃣ Enable Prometheus scraping** | Add `prometheus.io/scrape: true` to pod annotations, and configure Prometheus to target those endpoints. | `kubectl annotate pod my-pod my-app-prometheus-scrape="true"` |
| **2️⃣ Deploy a Prometheus instance** | Use the official Helm chart: `helm repo add prometheus-community https://prometheus-community.github.io/helm-charts` → `helm install prometheus prometheus-community/kube-prometheus-stack` | |
| **3️⃣ Deploy Loki for logs** | `helm install loki grafana/loki-stack` (includes Grafana) | |
| **4️⃣ Deploy Jaeger (or Tempo) for tracing** | `helm install jaeger jaegertracing/jaeger` (or `grafana/tempo`) | |
| **5️⃣ Verify the pipeline** | Generate a test request and watch it flow through Grafana dashboards linking logs, metrics, and traces. | `curl http://my-service:8080/healthz` then watch the trace in Jaeger UI |
| **6️⃣ Set up alerts** | Define Prometheus alert rules (see above) and route them to Alertmanager → Slack/Teams | |

> 🚦 **Tip:** Keep your observability stack **lightweight** at first (Loki + Prometheus + Grafana + Jaeger). Add complexity only when you truly need it.

---

## 📦 4. Sample Helm Chart Structure for Observability

If you want to package everything for easy deployment, here’s a minimal chart layout:

```
observability/
├─ Chart.yaml
├─ values.yaml
└─ templates/
│   ├─ prometheus.yaml
│   ├─ loki.yaml
│   ├─ jaeger.yaml
│   └─ grafana.yaml
```

**values.yaml snippet:**

```yaml
prometheus:
  enabled: true
  serviceMonitors:
    - path: /metrics
      interval: 15s
      scrapeTimeout: 10s
      honorLabels: true
      metricsPath: /metrics

loki:
  enabled: true
  logLevel: info
  retention: 30d

jaeger:
  enabled: true
  samplingRate: 1.0
  jaeger:
    strategy: elegance
```

Deploy with:

```bash
helm install observability ./observability -n monitoring --create-namespace
```

All components will be namespaced under `monitoring`, ready for Grafana dashboards and alert routing.

---

## 📚 Further Reading & Resources

| Topic | Resource | Link |
|-------|----------|------|
| Prometheus Query Language | <https://prometheus.io/docs/prometheus/latest/querying/> |
| Loki Logging | <https://grafana.com/oss/loki/> |
| OpenTelemetry Collector | <https://opentelemetry.io/collector/> |
| Grafana Loki Log Query Language | <https://grafana.com/docs/loki/latest/log-queries/> |
| CNCF Observability Landscape | <https://landscape.cncf.io/> |
| "The 12‑Factor App" (Logging) | <https://12factor.net/logs> |

---

## ✅ TL;DR

1. **Structured JSON logs** make your data queryable.  
2. **Prometheus** gives you metrics; **Loki** gives you logs; **Jaeger/Tempo** gives you traces.  
3. **OpenTelemetry** ties them together so a single request can be followed end‑to‑end.  
4. **Deploy** the stack via Helm, set up alerts, and you’ll never be in the dark again.

With observability in place, your containers stop being a black box and become **transparent, debuggable services** — the cornerstone of resilient, cloud‑native systems.

--- 

*This article was created on 2026‑04‑06. Observability tooling evolves rapidly; revisit this guide when you upgrade your stack.* 