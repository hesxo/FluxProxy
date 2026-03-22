# 📦 FluxProxy

**FluxProxy** is a scalable, containerized reverse proxy system built with Node.js and Express, managed via Docker Compose. It includes a centralized logging stack powered by Loki, Promtail, and Grafana, and uses **GitHub Actions** for CI (build, Compose smoke test, Trivy scan, and Docker Hub publish on `main`).

---

## 📌 Architecture Overview

![FluxProxy Architecture](https://i.postimg.cc/ht9SNxb7/pixelproxy-arch.png)

---

## 🏗️ Application Layers

### 🌐 Client Layer

- Multiple clients (Web Browsers on Desktop and Mobile) access the system.

### 🔄 Load Balancer Layer

- **Nginx Load Balancer**

  - Listens on **port 80**
  - Uses **least-connections** algorithm
  - Has **failover support** for backup server

### 🧱 Application Layer

- **FluxProxy Instances (Node.js/Express)**:

  - `FluxProxy 1`: `3001:3000`
  - `FluxProxy 2`: `3002:3000`
  - `FluxProxy 3`: `3003:3000`
  - `Backup Proxy`: `3004:3000` (activated only when primaries fail)

- **Environment Variables**: `APP_NAME`
- **Live Reload**: Docker Compose Watch enabled

### 🌐 Network Layer

- Custom Docker network: `pixpro-network`

  - Supports internal container communication
  - External ports: `80`, `3001-3004`

### 💾 File System

- Volume Mounts:

  - `nginx.conf`: Configuration
  - `nginx/logs/`: Access/Error Logs

### 📊 Centralized Logging System

- **Promtail** collects logs from Nginx
- **Loki** stores logs
- **Grafana** visualizes logs in real-time

### 🔁 Traffic Flow

- Clients → Nginx → Least-busy FluxProxy
- Backup traffic (dashed line) to backup server only when needed

---

## 🚧 Development Features

- 🔁 **Live Reload** with Docker Compose Watch
- 📂 **File Syncing**
- ❌ Ignored Paths: `node_modules/`, `logs/`, `.git/`

---

## ⚙️ CI/CD (GitHub Actions)

Workflow: `.github/workflows/ci.yml` (runs on pushes and pull requests to `main`).

1. Checkout code  
2. Build Docker image (`fluxproxy:latest`)  
3. `docker compose up -d --build` and HTTP smoke test on port 80  
4. Trivy image scan (`--exit-code 1`, OS + library vulns)  
5. On **push to `main` only** (when push secrets are configured): Docker Hub login and push `fluxproxy:latest`  

**Repository secrets** (Settings → Secrets and variables → Actions):

| Secret | What to use |
|--------|----------------|
| `DOCKERHUB_USERNAME` | Your **Docker Hub ID** — the short username in your profile URL (`hub.docker.com/u/thisname`). **Not** your email address. |
| `DOCKERHUB_PASSWORD` | A [Docker Hub access token](https://docs.docker.com/security/for-developers/access-tokens/) (recommended) or your account password. |

If these secrets are missing, CI still passes; the image is not pushed.

---

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Compose
- Node.js
- GitHub repository with Actions enabled (for CI/CD)

### Development Build

```bash
docker compose up --build
```

### Logging stack (Grafana, Loki, Promtail)

```bash
docker compose -f docker-compose.logging.yml up -d --build
```

Keep the **main app stack** running as well so Nginx writes to `./logs/nginx`; Promtail tails those files and ships them to Loki.

**Ports:** Grafana `3000`, Loki API `3100` (no browser UI—use Grafana).

---

## 🩺 Health Checks

- Internal endpoints expose health status
- Health checks used by Docker and monitoring tools

---

## 🔖 Versioning

| Component      | Version   |
| -------------- | --------- |
| Node.js        | 23-alpine |
| Express        | 4.x       |
| Nginx          | latest    |
| Docker Compose | v2+       |
| Grafana        | 10.x      |
| Loki           | latest    |
| Promtail       | latest    |

---

## 🧪 Security

- Automated scanning with **Trivy**
- Minimal base images
- Regular dependency updates

---

## 📈 Grafana dashboard (Nginx → Loki)

Provisioned dashboard: **Dashboards → folder *FluxProxy* → *FluxProxy — Nginx (Loki)***.  
Data path: **Nginx access/error logs** (host bind mount) → **Promtail** → **Loki** → **Grafana**.

**Open Grafana:** `http://localhost:3000`  

**Default login**

| Field    | Value   |
| -------- | ------- |
| User     | `admin` |
| Password | `admin` |

Use the time picker (e.g. **Last 30 minutes**) and the **HTTP status** variable to filter. The dashboard includes traffic rates by status and method, volume and 5xx trends, summary stats, distribution charts, top paths and client IPs (regex on the combined log line), filtered 5xx/4xx log panels, and full raw access/error streams.

### Screenshots

**Traffic and volume**

![Request rate by status/method and total lines/s](https://i.postimg.cc/jjnBL121/Screenshot_2026_03_22_at_12_23_25_PM.png)

**Overview**

![Dashboard overview: traffic, volume, summary, distribution, top paths](https://i.postimg.cc/nhP6VxFy/Screenshot_2026_03_22_at_12_23_14_PM.png)

**Summary and distribution**

![Summary counts, donut by status, bars by method, 5xx by code](https://i.postimg.cc/MGfgvLX8/Screenshot_2026_03_22_at_12_23_30_PM.png)

**Top paths and clients**

![Tables: top request paths and top client IPs](https://i.postimg.cc/jjnBL129/Screenshot_2026_03_22_at_12_23_36_PM.png)

**Filtered log streams**

![5xx-only, 4xx-only, and status-variable log panels](https://i.postimg.cc/1zVbfd4S/Screenshot_2026_03_22_at_12_24_07_PM.png)

**Raw Nginx logs**

![Full access log stream and error log panel](https://i.postimg.cc/wBRn7r3v/Screenshot_2026_03_22_at_12_24_11_PM.png)
