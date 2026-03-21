# 📦 FluxProxy

**FluxProxy** is a scalable, containerized reverse proxy system built with Node.js and Express, managed via Docker Compose. It includes a centralized logging stack powered by Loki, Promtail, and Grafana, and features a CircleCI-based CI/CD pipeline for secure, automated deployment.

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

## ⚙️ CI/CD Pipeline (CircleCI)

1. 🛠️ Checkout code
2. 🏗️ Build Docker image
3. ▶️ Run `docker-compose`
4. 🔍 Trivy security scan
5. 🔐 Docker Hub login
6. 🏷️ Tag and push image

---

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Compose
- Node.js
- CircleCI account (optional for CI/CD)

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
