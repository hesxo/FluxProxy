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
docker-compose up --build
```

### Logging Stack Build ( Grafana )

```bash
docker compose -f docker-compose.logging.yml up --build
```

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

## 📈 Monitoring Dashboard

Visit **Grafana** at: `http://localhost:3000`
Default credentials:

- **User**: `admin`
- **Password**: `admin`
