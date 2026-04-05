---
description: Automate building, testing, and deploying containerized apps with GitHub Actions and Kubernetes.
---

# CI/CD for Containers: Automating Builds, Tests, and Deployments with GitHub Actions & Kubernetes

In the previous articles we covered **what containers are**, **how they work inside Kubernetes**, and **why you should avoid common pitfalls**.  
Now it’s time to **automate** everything.

Manual `docker build`, `docker push`, `kubectl apply`‑drills are fine for experiments, but they don’t scale.  
A proper **CI/CD pipeline** lets you:

- Build images on every commit  
- Run automated test suites inside those images  
- Scan for security vulnerabilities automatically  
- Deploy only **verified**, **version‑controlled** images to your clusters  

Below you’ll get a **step‑by‑step blueprint** for a production‑ready workflow that uses only **GitHub Actions** (free for public repos) and **Helm** for releases. No extra CI services required.

---

## 📦 1. Repository layout (recommended)

```
my-app/
├─ .github/
│   └─ workflows/
│   └─ ci-cd.yml          # The GitHub Actions workflow
├─ src/                   # Your application source code
├─ Dockerfile
├─ helm/
│   └─ my-app/
│       ├─ Chart.yaml
│       ├─ values.yaml
│       └─ templates/
│           └─ deployment.yaml
├─ tests/                 # Unit / integration tests
└─ README.md
```

**Why this layout?**

- All CI/CD configuration lives under `.github/workflows/` – GitHub recognises it automatically.  
- Helm charts stay under `helm/` so you can version‑control releases.  
- Tests live in `tests/` and can be run inside the Docker build stage.

---

## 🚀 2. The GitHub Actions workflow (ci‑cd.yml)

```yaml
name: CI/CD – Build, Test, Deploy

on:
  push:
    branches: [ main ]          # Run on pushes to main
  pull_request:
    branches: [ main ]          # And on PRs targeting main

env:
  IMAGE_NAME: ghcr.io/${{ github.repository }}   # GitHub Container Registry
  HELM_RELEASE: my-app
  KUBEVERSION: "1.28"        # Adjust to your cluster version

jobs:
  build-test:
    runs-on: ubuntu-latest
    steps:
      # -----------------------------------------------------------------
      # 1️⃣ Checkout source
      # -----------------------------------------------------------------
      - name: Checkout repository
        uses: actions/checkout@v4

      # -----------------------------------------------------------------
      # 2️⃣ Set up Docker Buildx (multi‑platform builds)
      # -----------------------------------------------------------------
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # -----------------------------------------------------------------
      # 3️⃣ Log in to GitHub Container Registry
      # -----------------------------------------------------------------
      - name: Log in to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # -----------------------------------------------------------------
      # 4️⃣ Build & push the image (cache layers for speed)
      # -----------------------------------------------------------------
      - name: Build and push Docker image
        id: docker_build
        uses: docker/build-push-action@v5
        with:
          context: .
          file: Dockerfile
          push: true
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=registry,ref=${{ env.IMAGE_NAME }}:buildcache
          cache-to: type=registry,ref=${{ env.IMAGE_NAME }}:buildcache,mode=max

      # -----------------------------------------------------------------
      # 5️⃣ Run unit tests *inside* the built image
      # -----------------------------------------------------------------
      - name: Run unit tests
        run: |
          # Pull the just‑built image
          docker pull ${{ env.IMAGE_NAME }}:${{ github.sha }}
          # Run tests (example assumes a Python test suite)
          docker run --rm ${{ env.IMAGE_NAME }}:${{ github.sha }} pytest -q

      # -----------------------------------------------------------------
      # 6️⃣ Security scan (Trivy)
      # -----------------------------------------------------------------
      - name: Scan image for vulnerabilities
        uses: aquasecurity/trivy-action@latest
        with:
          image-ref: ${{ env.IMAGE_NAME }}:${{ github.sha }}
          format: 'sarif'
          output: 'trivy-results.sarif'
          exit-code: '1'  # Fail the job if any vulnerability > median severity is found
      - name: Upload Trivy SARIF (GitHub Security scans)
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif

  deploy:
    needs: build-test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    permissions:
      contents: read
      id-token: write   # Needed for OIDC to talk to the cluster
    steps:
      # -----------------------------------------------------------------
      # 7️⃣ Checkout again (needed for helm chart files)
      # -----------------------------------------------------------------
      - name: Checkout repository (for helm chart)
        uses: actions/checkout@v4

      # -----------------------------------------------------------------
      # 8️⃣ Set up kubectl (cluster access via OIDC)
      # -----------------------------------------------------------------
      - name: Set up kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'v1.28.0'

      # -----------------------------------------------------------------
      # 9️⃣ Authenticate to the cluster (example uses OIDC with GitHub)
      # -----------------------------------------------------------------
      - name: Authenticate to Kubernetes cluster
        env:
          KUBECONFIG: /tmp/kubeconfig
        run: |
          # Example for a cluster that trusts GitHub OIDC:
          # az aks get-credentials --resource-group MyRG --name MyCluster --overwrite-existing
          # Replace the above with your own method (e.g., kubeconfig from secret)
          echo "KUBECONFIG=/tmp/kubeconfig" >> $GITHUB_ENV

      # -----------------------------------------------------------------
      # 10️⃣ Deploy with Helm (only if image passes tests & security scan)
      # -----------------------------------------------------------------
      - name: Deploy to Kubernetes with Helm
        env:
          IMAGE_TAG: ${{ github.sha }}
        run: |
          # Add Helm repo (if not already added)
          helm repo add bitnami https://charts.bitnami.com/bitnami
          helm repo update

          # Upgrade the release – this performs a rolling update
          helm upgrade --install ${{ env.HELM_RELEASE }} ./helm/my-app \
            --namespace production \
            --create-namespace \
            --set image.repository=${{ env.IMAGE_NAME }} \
            --set image.tag=${{ env.IMAGE_TAG }} \
            --set resources.limits.cpu=200m \
                     resources.limits.memory=512Mi
```

### How the workflow works

| Step | What it does | Why it matters |
|------|--------------|----------------|
| **Checkout** | Pulls your repo into the runner | Needed for all subsequent steps |
| **Docker Buildx** | Enables multi‑platform builds and caching | Faster builds, ability to target `linux/amd64` & `linux/arm64` |
| **Login to GHCR** | Authenticates against GitHub Container Registry | Allows you to push images securely |
| **Build & Push** | Compiles the Docker image, tags it with `latest` and the commit SHA, caches layers | Immutable, traceable images; caching speeds up subsequent runs |
| **Run unit tests** | Executes your test suite **inside** the freshly built image | Guarantees the image you push actually works |
| **Trivy security scan** | Checks for known CVEs, tries to fail the job on high‑severity findings | Enforces “no vulnerable images” policy |
| **Upload SARIF** | Feeds results into GitHub’s Code Scanning UI | Gives you a visual security report |
| **Deploy** (only on `main`) | Runs `helm upgrade` to roll out the new image | Automated, zero‑downtime rolling update |
| **Helm values** | Passes `image.repository` and `image.tag` dynamically | No need to rebuild Helm charts manually |

#### Quick checklist to make this work in your cluster

1. **Create a service account** in your cluster that GitHub can impersonate via OpenID Connect (OIDC).  
2. **Grant it `get`/`list` permissions** on `secrets`, `configmaps`, and `deployments` – just enough for Helm to install/upgrade.  
3. **Store the kubeconfig** (or use OIDC token exchange) as a secret in GitHub (`KUBE_CONFIG_DATA`).  
4. **Add the secret** to the workflow (`secrets.KUBE_CONFIG_DATA`) and decode it at runtime (the example above assumes you already have `kubectl` configured).  

> 🎯 **Takeaway:** With just a few YAML files and a secret, you have a **full CI/CD pipeline** that builds, tests, scans, and deploys containerized apps to Kubernetes **without any external CI service**.

---

## 🧰 3. Handy tools & tips for a smooth pipeline

| Tool | What it does | Why you’ll love it |
|------|--------------|--------------------|
| **Docker Buildx** | Multi‑platform builds, cache export/import | Faster builds, can target ARM & AMD64 from a single runner |
| **Trivy** | Lightweight scanner for OS packages, language deps, and config files | Finds vulnerabilities before they reach production |
| **Syft** | Generates a **SBOM** (Software Bill of Materials) from your image | Great for compliance and audit trails |
| **GitHub Dependabot** | Auto‑opens PRs to bump vulnerable dependencies | Keeps your base images up‑to‑date |
| **helm test** | Runs post‑upgrade tests (e.g., health checks) | Verifies that a release is actually healthy before marking it “successful” |
| **Argo CD** (optional) | Git‑Ops continuous delivery engine | Syncs your Helm chart state with the cluster automatically |

---

## 🚦 4. Common pitfalls & how to avoid them

| Pitfall | Symptom | Fix |
|---------|----------|-----|
| **Image tag drift** – using `latest` | New builds silently replace the tag, causing deployments to roll back unexpectedly | **Never use `latest`.** Tag with Git SHA (`${{ github.sha }}`) and increment a version number. |
| **Helm values out of sync** | `helm upgrade` shows “nothing changed” even after a new image is pushed | Ensure you **explicitly** reference the new `image.tag` in the `values.yaml` or via `--set`. |
| **Insufficient resource requests** | Pods get OOM‑killed, leading to repeated restarts | Start with modest requests (`200m` CPU, `128Mi` RAM) and monitor; bump based on metrics. |
| **Missing readiness probes** | Service routes traffic to pods that are still initializing | Add `readinessProbe` to your Pod spec (e.g., `httpGet` on `/healthz`). |
| **Hard‑coded image pulls from Docker Hub** | Rate‑limited or unavailable when Docker Hub is down | Prefer a **private registry** (GHCR, ECR, GCR) or mirror Docker Hub via a cache. |
| **Secrets in Helm values** | Plain‑text secrets end up in Git history | Use **Helm Secrets** (`helm-secrets` plugin) or **sealed‑secrets** to encrypt them. |
| **Running tests only on the host** | Tests might pass locally but fail in the container | Always **run tests inside the built image** (as shown in the workflow). |

---

## 📈 5. Monitoring the pipeline’s health

A CI/CD pipeline is only as good as its visibility.

| Metric | How to collect | Example alert |
|--------|----------------|---------------|
| **Build duration** | Use GitHub Actions `jobs.<job>.steps.<step>.duration` or export to Prometheus | Alert if a build takes > 15 min |
| **Vulnerability count** | Parse Trivy SARIF output or use `github-advisory-db` | Fail the pipeline if any `high` severity CVE is found |
| **Deployment success rate** | Use `helm status` exit code or Prometheus metric `kube_deployment_status.available` | Alert if success rate drops below 95 % |
| **Cluster resource usage** | Prometheus `cluster:resource:cpu:usage` | Warn if CPU > 80 % on a node for > 5 min |

You can expose these metrics to **Prometheus** via the `prometheus/github-actions-exporter` (community project) or simply log them to a centralized file and ship them with **Fluent Bit**.

---

## 🛠️ 6. One‑click starter repo

If you’d rather start from a ready‑made template, clone this minimal repo and follow the `README.md`:

```
git clone https://github.com/rombey86/ci-cd-k8s-starter.git
cd ci-cd-k8s-starter
# Edit .github/workflows/ci-cd.yml to match your image name
# Run `helm dependency update helm/my-app` if you added chart deps
# Push and watch the pipeline run!
```

The repo includes:

- A tiny Flask API (`src/app.py`) with a unit test (`tests/test_api.py`)  
- A multi‑stage `Dockerfile` that compiles, runs tests, then produces the final image  
- A Helm chart (`helm/my-app/`) that deploys the Flask API to a `Deployment` and a `Service`  
- The full GitHub Actions workflow (`.github/workflows/ci-cd.yml`) pre‑configured for the above steps  

> 🎉 **Result:** After the first push, GitHub Actions will build the image, run tests, scan for vulnerabilities, and automatically roll out the new version to your Kubernetes cluster — all without manual intervention.

---

## 📚 Where to go from here?

| Next step | Resource |
|----------|----------|
| **Deep‑dive into Helm templating** | <https://helm.sh/docs/chart_template_guide/> |
| **GitHub OIDC for Kubernetes** | <https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-action/> |
| **Production‑grade CI/CD with Argo CD** | <https://argo-cd.readthedocs.io/en/stable/> |
| **Secure supply‑chain fundamentals** | <https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-161.pdf> |
| **Kubernetes security baselines** | <https://www.cisecurity.org/benchmark/kubernetes> |

---

## ✅ TL;DR

- **Define** your desired state (Pod → Service → Deployment).  
- **Automate** the full lifecycle with a GitHub Actions workflow: build → test → scan → push → deploy.  
- **Keep it secure**: version images, scan for CVEs, store secrets safely, and use immutable tags.  
- **Monitor** the pipeline and the resulting workloads to catch regressions early.  

With the workflow above you can push a change, watch the pipeline verify it, and have a **working, roll‑back‑ready** version of your app on Kubernetes — all **automatically**.  

Happy containerizing! 🚀

--- 

*This article was created on 2026‑04‑06. CI/CD practices evolve rapidly; keep your workflows up‑to‑date with the latest GitHub Actions and Helm releases.* 