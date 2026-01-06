# Server Build & Deployment Guide

**Deployment Method:** Build Docker images directly on cloud server
**Status:** ⚠️ Alternative Method - May take longer
**Estimated Time:** 30-60 minutes

---

## 📝 About This Method

**This guide helps you build Docker images directly on your cloud server.**

### When to Use:
- ✅ You cannot build on your local machine
- ✅ You have a good network connection on the server
- ✅ You have time available for the build process

### For Faster Deployment:
👉 Consider using [LOCAL_BUILD_DEPLOYMENT.md](./LOCAL_BUILD_DEPLOYMENT.md)
- Faster process (15-20 minutes)
- Build once, deploy quickly
- Lower server resource usage

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Port Requirements](#port-requirements)
3. [Environment Configuration](#environment-configuration)
4. [Database Setup](#database-setup)
5. [Step 1: Prepare Server](#step-1-prepare-server)
6. [Step 2: Optimize Network](#step-2-optimize-network)
7. [Step 3: Build Images](#step-3-build-images)
8. [Step 4: Deploy Application](#step-4-deploy-application)
9. [Step 5: Configure Firewall](#step-5-configure-firewall)
10. [Step 6: Verify Deployment](#step-6-verify-deployment)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Cloud Server Requirements:
- ⚠️ **Minimum:** 4 vCPU, 16GB RAM recommended
- ⚠️ **Network:** Good network connectivity required
- ✅ Docker & Docker Compose installed
- ✅ Git installed
- ✅ MongoDB installed and running
- ✅ 20GB+ free disk space
- ✅ Root/sudo access

### Software Installation Links:

| Software | Installation Guide |
|----------|-------------------|
| **MongoDB** | https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/ |
| **Docker** | https://docs.docker.com/engine/install/ubuntu/ |
| **Docker Compose** | https://docs.docker.com/compose/install/ |
| **NGINX** | https://nginx.org/en/linux_packages.html#Ubuntu |
| **Git** | `sudo apt install git` |

### Quick Install Commands (Ubuntu):
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Git
sudo apt install -y git

# Install Docker
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker

# Install NGINX (optional)
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# For MongoDB, follow the official guide above
```

### Check Requirements:
```bash
# Check Docker
docker --version          # Should be 20.10+
docker-compose --version  # Should be 1.29+

# Check MongoDB
mongod --version          # Should be installed

# Check disk space
df -h /var/lib/docker    # Should show 20GB+ available

# Check memory
free -h                  # Should show 8GB+ available
```

---

## Port Requirements

### Application Ports:
| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| **Backend API** | 3006 | TCP | REST API endpoints |
| **Frontend** | 8081 | TCP | Web application |
| **MongoDB** | 27017 | TCP | Database (internal) |

### Firewall Rules:
```
ALLOW 3006/tcp from anywhere
ALLOW 8081/tcp from anywhere
ALLOW 27017/tcp from localhost only
```

---

## Environment Configuration

### ⚠️ IMPORTANT: Configure .env Files Before Deployment

You must create and configure **three .env files** on your cloud server before deploying.

### 1. Root `.env` File (Project Root)

**Location:** `/path/to/your-project/.env`

```bash
# Create root .env file
nano .env
```

**Contents:**
```bash
# Port Configuration
FRONTEND_PORT=8081
BACKEND_PORT=3006

# MongoDB Configuration
MONGO_DB_HOST=127.0.0.1
MONGO_DB_PORT=27017
MONGO_DB_NAME=unity
MONGO_DB_DUMP_DIR=./dump/database

# Display Settings
REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY=false
```

### 2. Backend `.env` File

**Location:** `/path/to/your-project/backend/.env`

```bash
# Create backend .env file
nano backend/.env
```

**Contents:**
```bash
# Server Configuration
PORT=3006
HOST=127.0.0.1

# Frontend URL (replace with your server IP)
FRONT_WEB_URL=http://your-server-ip:8081

# Backend URL (replace with your server IP)
BACK_UNITY_URL=http://your-server-ip:3006

# Database Configuration
DATABASE_NAME=unity
DB_PORT=27017
```

**⚠️ Replace `your-server-ip` with your actual server IP address!**

### 3. Frontend `.env` File

**Location:** `/path/to/your-project/frontend/.env`

```bash
# Create frontend .env file
nano frontend/.env
```

**Contents:**
```bash
# Application Port
PORT=8081

# Backend API URL (replace with your server IP)
REACT_APP_BACKEND_REST_API_URL=http://your-server-ip:3006

# Company Information (customize as needed)
REACT_APP_COMPANY_NAME="Your Company Name"
REACT_APP_COMPANY_URL="https://yourcompany.com"

# Display Settings
REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY=false
```

**⚠️ Replace `your-server-ip` with your actual server IP address!**

### Quick Setup Script

Create all .env files at once:

```bash
# Navigate to project directory
cd /path/to/your-project

# Set your server IP (replace with actual IP)
SERVER_IP="123.45.67.89"

# Create root .env
cat > .env << EOF
FRONTEND_PORT=8081
BACKEND_PORT=3006
MONGO_DB_HOST=127.0.0.1
MONGO_DB_PORT=27017
MONGO_DB_NAME=unity
MONGO_DB_DUMP_DIR=./dump/database
REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY=false
EOF

# Create backend .env
cat > backend/.env << EOF
PORT=3006
HOST=127.0.0.1
FRONT_WEB_URL=http://${SERVER_IP}:8081
BACK_UNITY_URL=http://${SERVER_IP}:3006
DATABASE_NAME=unity
DB_PORT=27017
EOF

# Create frontend .env
cat > frontend/.env << EOF
PORT=8081
REACT_APP_BACKEND_REST_API_URL=http://${SERVER_IP}:3006
REACT_APP_COMPANY_NAME="Your Company Name"
REACT_APP_COMPANY_URL="https://yourcompany.com"
REACT_APP_IS_EMPTY_BLANK_DATA_DISPLAY=false
EOF

echo "✅ All .env files created successfully!"
```

### Verify .env Files

```bash
# Check all .env files exist
ls -la .env backend/.env frontend/.env

# View contents
cat .env
cat backend/.env
cat frontend/.env
```

---

## Database Setup

### Import Database Using mongoImport.sh

After MongoDB is installed, import the initial database:

```bash
# Navigate to project directory
cd /path/to/your-project

# Make script executable
chmod +x mongoImport.sh

# Run database import
./mongoImport.sh
```

**Expected Output:**
```
Importing database...
Database imported successfully!
```

### Verify Database Import

```bash
# Connect to MongoDB
mongosh

# Check database exists
show dbs
# Should show: unity

# Check collections
use unity
show collections
```

---

## Step 1: Prepare Server

### 1.1 SSH to Cloud Server
```bash
ssh username@your-server-ip
```

### 1.2 Navigate to Project Directory
```bash
cd /path/to/your-project
# Example: cd /home/user/projects/unity-app
```

### 1.3 Pull Latest Code
```bash
# Backup current state
sudo docker-compose down
cp -r . ../ntm-unityri-unity-backup-$(date +%Y%m%d-%H%M%S)

# Pull latest code from Git
git pull origin master

# Or if working locally, upload via SCP
# scp -r /local/path/* username@your-server-ip:/path/to/your-project/
```

### 1.4 Verify Configuration Files
```bash
# Check .env files exist
ls -la backend/.env frontend/.env

# Check .npmrc files exist (network optimization)
ls -la backend/.npmrc frontend/.npmrc

# Check docker-compose.yaml has image tags
grep "image:" docker-compose.yaml
```

---

## Step 2: Optimize Network

### 2.1 Configure Docker DNS
```bash
# Create or edit Docker daemon config
sudo nano /etc/docker/daemon.json
```

**Add this configuration:**
```json
{
  "dns": ["1.1.1.1", "8.8.8.8", "8.8.4.4"],
  "max-concurrent-downloads": 3,
  "max-download-attempts": 10
}
```

**Restart Docker:**
```bash
sudo systemctl restart docker

# Verify configuration
sudo docker info | grep -A5 "DNS"
```

### 2.2 Configure System DNS
```bash
# Edit resolved configuration
sudo nano /etc/systemd/resolved.conf
```

**Add:**
```ini
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=8.8.4.4
```

**Restart DNS service:**
```bash
sudo systemctl restart systemd-resolved

# Verify DNS resolution speed
time nslookup registry.npmjs.org
# Should be < 1 second (if > 2 seconds, network is too slow)
```

### 2.3 Test npm Registry Connectivity
```bash
# Test connection speed to npm registry
curl -o /dev/null -s -w "Time: %{time_total}s\n" https://registry.npmjs.org/

# CRITICAL: If time > 5 seconds, STOP HERE
# Use LOCAL_BUILD_DEPLOYMENT.md instead
# Network is too slow for server builds
```

### 2.4 Increase System Limits
```bash
# Edit sysctl
sudo nano /etc/sysctl.conf
```

**Add:**
```ini
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 2048
fs.file-max = 65536
```

**Apply changes:**
```bash
sudo sysctl -p
```

---

## Step 3: Build Images

### ⚠️ WARNING: This Step Will Take 40-60 Minutes

### 3.1 Clean Previous Build Artifacts
```bash
# Stop containers
sudo docker-compose down

# Remove old images
sudo docker system prune -af

# Remove old node_modules (optional)
sudo rm -rf backend/node_modules frontend/node_modules
```

### 3.2 Start Build with Logging
```bash
# Build with progress logging
sudo docker-compose build --no-cache --progress=plain 2>&1 | tee build.log

# This will run for 40-60 minutes
# Watch for:
# - [backend X/Y] steps completing
# - npm install progress
# - Any timeout or error messages
```

### 3.3 Monitor Build Progress

**In another SSH session:**
```bash
# Monitor Docker resource usage
watch -n 2 'docker stats --no-stream'

# Monitor network activity
watch -n 2 'sudo netstat -an | grep ESTABLISHED | grep 443 | wc -l'

# Monitor build log
tail -f build.log

# Check for npm hanging
sudo docker exec -it $(docker ps -q) ps aux | grep npm
```

### 3.4 Common Build Issues

**Issue: Build hangs at "RUN npm install"**
```
Symptoms:
- No output for 10+ minutes
- Same npm warnings repeating
- Time counter increasing but no progress

Solution:
1. Wait 15 minutes to confirm it's truly hung
2. Press Ctrl+C to cancel
3. Use LOCAL_BUILD_DEPLOYMENT.md instead
```

**Issue: Network timeout errors**
```
Error: network timeout at: https://registry.npmjs.org/...

Solution:
- Network is too slow for server build
- Use LOCAL_BUILD_DEPLOYMENT.md instead
```

**Issue: Out of memory**
```
Error: JavaScript heap out of memory

Solution:
# Increase Docker memory limit
sudo nano /etc/docker/daemon.json
# Add: "default-memory": "4G"
sudo systemctl restart docker
```

### 3.5 Verify Build Success

```bash
# Check if build completed
tail -100 build.log | grep -i "successfully"

# Verify images created
sudo docker images | grep ntm-unityri-unity

# Expected output:
# ntm-unityri-unity-backend     latest    ...   X minutes ago   1.2GB
# ntm-unityri-unity-frontend    latest    ...   X minutes ago   450MB
```

---

## Step 4: Deploy Application

### 4.1 Start Services
```bash
# Start in detached mode
sudo docker-compose up -d

# This should be fast (30 seconds)
# Watch for:
# Creating unity-package-backend-1  ... done
# Creating unity-package-frontend-1 ... done
```

### 4.2 Verify Containers Running
```bash
sudo docker-compose ps
```

**Expected Output:**
```
NAME                       IMAGE                               STATUS         PORTS
unity-package-backend-1    ntm-unityri-unity-backend:latest    Up 30 seconds
unity-package-frontend-1   ntm-unityri-unity-frontend:latest   Up 30 seconds  0.0.0.0:8081->8081/tcp
```

### 4.3 Check Logs
```bash
# View all logs
sudo docker-compose logs

# Follow logs in real-time
sudo docker-compose logs -f

# Check specific service
sudo docker-compose logs backend --tail=50
sudo docker-compose logs frontend --tail=50
```

**Look for:**
```
backend-1   | Server is running on port 3006
frontend-1  | webpack compiled successfully
```

---

## Step 5: Configure Firewall

### 5.1 UFW (Ubuntu) Configuration

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (CRITICAL - do this first!)
sudo ufw allow 22/tcp

# Allow backend API
sudo ufw allow 3006/tcp comment 'Unity Backend API'

# Allow frontend
sudo ufw allow 8081/tcp comment 'Unity Frontend'

# MongoDB internal only
sudo ufw allow from 127.0.0.1 to any port 27017

# Reload firewall
sudo ufw reload

# Verify rules
sudo ufw status numbered
```

**Expected Output:**
```
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
3006/tcp                   ALLOW       Anywhere    # Unity Backend API
8081/tcp                   ALLOW       Anywhere    # Unity Frontend
27017                      ALLOW       127.0.0.1
```

### 5.2 firewalld (CentOS/RHEL) Configuration

```bash
# Add ports
sudo firewall-cmd --permanent --add-port=3006/tcp --zone=public
sudo firewall-cmd --permanent --add-port=8081/tcp --zone=public

# Reload
sudo firewall-cmd --reload

# Verify
sudo firewall-cmd --list-ports
```

### 5.3 Cloud Provider Firewall

**Via cloud provider dashboard:**
1. Go to cloud provider dashboard → Virtual Machines
2. Select your VM → Networking
3. Click "Add inbound port rule"

**Add Rule 1: Backend API**
```
Name: Unity-Backend
Priority: 1010
Port: 3006
Protocol: TCP
Source: Any
Action: Allow
```

**Add Rule 2: Frontend**
```
Name: Unity-Frontend
Priority: 1020
Port: 8081
Protocol: TCP
Source: Any
Action: Allow
```

**Via Cloud Provider CLI (example):**
```bash
# Consult your cloud provider's documentation for specific CLI commands
# to add firewall/security group rules for ports 3006 and 8081
```

### 5.4 Test Port Accessibility

```bash
# Check ports are listening
sudo netstat -tlnp | grep -E "3006|8081"

# Expected output:
# tcp  0  0 0.0.0.0:3006  0.0.0.0:*  LISTEN  12345/node
# tcp  0  0 0.0.0.0:8081  0.0.0.0:*  LISTEN  12346/node

# Test from external machine
# telnet your-server-ip 3006
# telnet your-server-ip 8081
```

---

## Step 6: Verify Deployment

### 6.1 Test Backend API
```bash
# From server
curl http://localhost:3006

# From external
curl http://your-server-ip:3006

# Expected: JSON response or HTML
```

### 6.2 Test Frontend
```bash
# From server
curl http://localhost:8081

# From external
curl http://your-server-ip:8081

# Expected: HTML content
```

### 6.3 Browser Testing

**Open in browser:**
- Frontend: http://your-server-ip:8081
- Backend: http://your-server-ip:3006

**Verify:**
- ✅ Frontend loads without errors
- ✅ API calls work
- ✅ No console errors
- ✅ All features functional

---

## Troubleshooting

### Build Fails After 40+ Minutes

**Most Likely Cause:** cloud server network is too slow for npm

**Solution:**
```bash
# 1. Cancel build
Ctrl+C

# 2. Clean up
sudo docker-compose down
sudo docker system prune -af

# 3. Switch to local build method
# See LOCAL_BUILD_DEPLOYMENT.md
```

### Out of Disk Space

```bash
# Check disk usage
df -h

# Clean Docker
sudo docker system prune -af --volumes

# Remove build cache
sudo rm -rf /var/lib/docker/overlay2/*

# Remove old logs
sudo journalctl --vacuum-time=7d
```

### Build Succeeded but Containers Won't Start

```bash
# Check logs
sudo docker-compose logs

# Common issues:
# - Missing .env files
# - MongoDB not running
# - Port conflicts

# Restart MongoDB
sudo systemctl restart mongod

# Restart containers
sudo docker-compose restart
```

---

## Tips for Successful Server Builds

### Network Optimization

**For Best Results:**
- Ensure stable internet connection
- Check network speed is adequate
- Verify DNS resolution is working
- Monitor build progress regularly

**If Build is Slow:**
- Check server network connection
- Verify firewall rules allow outbound traffic
- Consider using local build method
- Monitor server resources (CPU, RAM, disk)

---

## Comparison of Build Methods

| Aspect | Server Build | Local Build + Transfer |
|--------|--------------|------------------------|
| **Build Time** | 30-60 min | 8-12 min |
| **Transfer Time** | Not needed | 2-5 min |
| **Total Time** | 30-60 min | 15-20 min |
| **Server Resources** | High during build | Low (only runs containers) |
| **Internet Used** | Server downloads 600MB+ | Transfer 500MB to server |
| **Best For** | No local machine available | Faster, recommended method |

---

## Alternative: Container Registry Build

Instead of building on VM, use a Container Registry service (Docker Hub, AWS ECR, GCP GCR, etc.):

```bash
# Example using Docker Hub
# 1. Build locally
docker build -t yourusername/backend:latest ./backend
docker build -t yourusername/frontend:latest ./frontend

# 2. Push to registry
docker push yourusername/backend:latest
docker push yourusername/frontend:latest

# 3. On VM, pull from registry
docker pull yourusername/backend:latest
docker pull yourusername/frontend:latest
```

**Benefits:**
- ✅ Fast cloud network for builds
- ✅ Centralized image storage
- ✅ Integrated with CI/CD tools
- ✅ No VM resource usage during build

---

## Deployment Checklist

### Pre-Build:
- [ ] VM tier is Standard_D or higher (or skip this method)
- [ ] Network test shows <5s to npm registry
- [ ] Docker daemon configured with DNS settings
- [ ] Sufficient disk space (20GB+)
- [ ] Backup of previous deployment

### Build Phase:
- [ ] docker-compose build started
- [ ] Build log monitoring active
- [ ] Resource usage monitored
- [ ] Build completes within 60 minutes
- [ ] Images created successfully

### Deployment Phase:
- [ ] Containers started
- [ ] Logs show no errors
- [ ] Firewall configured
- [ ] Ports accessible
- [ ] Application functional

---

## Summary

**This guide provides an alternative method for building directly on your server.**

**Other Options to Consider:**
1. **Local Build + Transfer** (See LOCAL_BUILD_DEPLOYMENT.md) - Faster method
2. **Container Registry** - Build once, deploy many times
3. **CI/CD Pipeline** - Automated builds and deployments

**Server builds work best when:**
- You have adequate server resources
- Network connection is good
- You have time for the build process

---

**Last Updated:** 2026-01-06
**Status:** ✅ Alternative Deployment Method
**Estimated Time:** 30-60 minutes
**Faster Alternative:** LOCAL_BUILD_DEPLOYMENT.md (15-20 min)
