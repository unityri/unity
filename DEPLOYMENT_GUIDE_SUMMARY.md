# Unity RI Application - Deployment Guide Summary

**Last Updated:** 2026-01-06
**Project:** Unity RI Application
**Server:** your-server-ip (replace with actual IP)

---

## 📚 Available Documentation

### 1. **SCRIPT_DEPLOYMENT.md** 🚀 AUTOMATED (NEW!)
Use automated unitysetup.sh script for deployment

**Status:** ✅ Recommended for Fresh Installations
**Time:** 10-15 minutes
**Difficulty:** ⭐ Very Easy
**Best For:** Automated deployment, fresh server setup

[View Full Guide →](./SCRIPT_DEPLOYMENT.md)

### 2. **LOCAL_BUILD_DEPLOYMENT.md** ✅ RECOMMENDED
Build Docker images on your local machine, transfer to cloud server

**Status:** ✅ Production Ready
**Time:** 15-20 minutes
**Difficulty:** ⭐ Easy
**Best For:** Regular deployments, updates

[View Full Guide →](./LOCAL_BUILD_DEPLOYMENT.md)

### 3. **SERVER_BUILD_DEPLOYMENT.md** ⚠️ ALTERNATIVE METHOD
Build Docker images directly on cloud server

**Status:** ⚠️ Alternative option (takes longer)
**Time:** 30-60 minutes
**Difficulty:** ⭐⭐ Medium
**Best For:** When local build isn't available

[View Full Guide →](./SERVER_BUILD_DEPLOYMENT.md)

### 4. **AZURE_BUILD_ISSUE_SUMMARY.md** 📋 Technical Analysis
Root cause analysis of deployment issues

[View Full Analysis →](./AZURE_BUILD_ISSUE_SUMMARY.md)

---

## 🎯 Quick Decision Guide

### Which Method Should I Use?

```
Is this a fresh server installation?
│
├─ YES → Use SCRIPT_DEPLOYMENT.md 🚀
│         (Automated script - fastest and easiest)
│         Time: 10-15 min | Fully automated
│
└─ NO → Are you updating existing deployment?
    │
    ├─ YES → Use LOCAL_BUILD_DEPLOYMENT.md ✅
    │         (Build locally, transfer images)
    │         Time: 15-20 min | Recommended for updates
    │
    └─ NO local machine available?
              Use SERVER_BUILD_DEPLOYMENT.md
              (Build directly on server)
              Time: 30-60 min | Alternative method
```

---

## 📊 Method Comparison

| Factor | Local Build | Server Build |
|--------|-------------|--------------|
| **Build Time** | 8-12 min | 30-60 min |
| **Transfer Time** | 2-5 min | Not needed |
| **Total Time** | **15-20 min** | **30-60 min** |
| **Complexity** | ⭐ Easy | ⭐⭐ Medium |
| **Server Resources** | Low | High during build |
| **Best For** | Recommended | No local machine |
| **Requires** | Local machine | Good server connection |

---

## 🚀 Quick Start (Recommended Method)

### On Local Machine:
```bash
# 1. Build images
cd /path/to/your-project
sudo docker-compose build

# 2. Save images
sudo docker save ntm-unityri-unity-backend:latest | gzip > backend.tar.gz
sudo docker save ntm-unityri-unity-frontend:latest | gzip > frontend.tar.gz

# 3. Transfer to cloud server
scp *.tar.gz username@your-server-ip:/tmp/
```

### On Cloud Server:
```bash
# 1. Load images
cd /path/to/your-project
sudo docker load < /tmp/backend.tar.gz
sudo docker load < /tmp/frontend.tar.gz

# 2. Deploy
sudo docker-compose down
sudo docker-compose up -d

# 3. Verify
sudo docker-compose ps
```

### Configure Firewall:
```bash
# Open required ports
sudo ufw allow 3006/tcp comment 'Backend API'
sudo ufw allow 8081/tcp comment 'Frontend'

# If using cloud provider firewall, configure it too
# Add inbound rules for ports 3006 and 8081
```

**Access Application:**
- Frontend: http://your-server-ip:8081
- Backend: http://your-server-ip:3006

---

## 🔧 Port Configuration

### Application Ports:
| Service | Port | Access | Purpose |
|---------|------|--------|---------|
| **Frontend** | 8081 | Public | Web Application |
| **Backend API** | 3006 | Public | REST API |
| **MongoDB** | 27017 | Internal | Database |

### Firewall Configuration Required:

#### 1. Ubuntu Firewall (UFW):
```bash
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3006/tcp  # Backend
sudo ufw allow 8081/tcp  # Frontend
sudo ufw reload
```

#### 2. Cloud Provider Firewall:
```
Rule 1: Unity-Backend  | Port 3006 | TCP | Allow
Rule 2: Unity-Frontend | Port 8081 | TCP | Allow
```

Configure via:
- cloud provider dashboard → VM → Networking → Add inbound port rule
- Or use cloud provider CLI (see full guides for examples)

---

## 📈 Performance Metrics

### Local Build + Transfer (Actual Results):
```
Build locally:      10 min  ✅
Save images:         2 min  ✅
Transfer to Azure:   3 min  ✅
Load on Azure:       1 min  ✅
Start services:     30 sec  ✅
─────────────────────────────
Total:            ~17 min  ✅
Success rate:        100%  ✅
```

### Server Build on Azure (Actual Results):
```
Build attempt 1:  40 min  → HUNG ❌
Build attempt 2:  35 min  → HUNG ❌
Build attempt 3:  37 min  → HUNG ❌
Build attempt 4:  44 min  → HUNG ❌
─────────────────────────────
Total wasted:   2.5 hours ❌
Success rate:          0% ❌
```

---

## ⚠️ Common Issues & Solutions

### Issue 1: Build Hangs on Server
**Symptom:** npm install runs for 40+ minutes with no progress

**Solution:**
```bash
# STOP - Don't waste time
# Use LOCAL_BUILD_DEPLOYMENT.md instead
```

### Issue 2: Cannot Access Application
**Symptom:** Connection refused when accessing http://your-server-ip:8081

**Solution:**
```bash
# Check firewall
sudo ufw status | grep -E "3006|8081"

# Check cloud firewall rules in cloud provider dashboard
# Add inbound rules for ports 3006 and 8081

# Test locally first
curl http://localhost:8081
```

### Issue 3: Containers Not Starting
**Symptom:** docker-compose ps shows "Exit 1"

**Solution:**
```bash
# Check logs
sudo docker-compose logs backend
sudo docker-compose logs frontend

# Common fixes:
# - Check .env files exist
# - Ensure MongoDB is running
# - Verify ports not in use
```

---

## 🔒 Security Checklist

### Before Deployment:
- [ ] Environment variables secured (.env not in Git)
- [ ] SSH key authentication enabled
- [ ] Firewall configured (UFW/NSG)
- [ ] Only required ports open (3006, 8081)
- [ ] MongoDB not exposed externally
- [ ] Strong passwords in .env files

### After Deployment:
- [ ] SSL/HTTPS configured (recommended)
- [ ] Regular backups scheduled
- [ ] Monitoring enabled
- [ ] Logs rotation configured
- [ ] Security updates automated

---

## 📝 Deployment Checklist

### Pre-Deployment:
- [ ] Choose deployment method (Local build recommended)
- [ ] Read appropriate deployment guide
- [ ] Verify prerequisites met
- [ ] Backup current deployment (if exists)
- [ ] Ensure .env files configured

### Deployment:
- [ ] Build Docker images (local or server)
- [ ] Transfer images (if local build)
- [ ] Load images on server
- [ ] Stop old containers
- [ ] Start new containers
- [ ] Configure firewall ports

### Post-Deployment:
- [ ] Verify containers running
- [ ] Check logs for errors
- [ ] Test frontend (http://your-server-ip:8081)
- [ ] Test backend (http://your-server-ip:3006)
- [ ] Monitor for 15 minutes
- [ ] Clean up temporary files

---

## 💡 Understanding the Methods

### Why Local Build is Faster:

**Local Build Benefits:**
- Build uses your local internet connection
- Only transfers final images (smaller size)
- Server resources stay available for running application
- Faster overall deployment time

**Server Build Considerations:**
- Server downloads all packages during build
- Uses server CPU and memory during build
- Takes longer but doesn't require local machine
- Good option when local build isn't available

---

## 🚀 Future Improvements

### Short-term:
1. ✅ Use local build method (implemented)
2. ✅ Document all procedures (done)
3. [ ] Set up automated backups
4. [ ] Configure SSL/HTTPS
5. [ ] Set up monitoring (Prometheus/Grafana)

### Long-term:
1. [ ] Implement CI/CD pipeline (GitHub Actions)
2. [ ] Use Container Registry
3. [ ] Set up staging environment
4. [ ] Implement blue-green deployment
5. [ ] Configure auto-scaling

---

## 📞 Support & Resources

### Documentation:
- **Local Build Guide:** [LOCAL_BUILD_DEPLOYMENT.md](./LOCAL_BUILD_DEPLOYMENT.md)
- **Server Build Guide:** [SERVER_BUILD_DEPLOYMENT.md](./SERVER_BUILD_DEPLOYMENT.md)
- **Technical Analysis:** [AZURE_BUILD_ISSUE_SUMMARY.md](./AZURE_BUILD_ISSUE_SUMMARY.md)

### Useful Commands:
```bash
# Check deployment status
sudo docker-compose ps

# View logs
sudo docker-compose logs -f

# Restart services
sudo docker-compose restart

# Stop services
sudo docker-compose down

# Start services
sudo docker-compose up -d

# Check firewall
sudo ufw status

# Test ports
sudo netstat -tlnp | grep -E "3006|8081"
```

---

## ✅ Success Criteria

Your deployment is successful when:

- [x] Containers running: `sudo docker-compose ps` shows "Up"
- [x] Frontend accessible: http://your-server-ip:8081 loads
- [x] Backend accessible: http://your-server-ip:3006 responds
- [x] No errors in logs: `sudo docker-compose logs` clean
- [x] Firewall configured: Ports 3006, 8081 open
- [x] Application functional: Can login, use features
- [x] Database connected: Backend connects to MongoDB

---

## 📊 Deployment Best Practices

**For Production Deployments:**
- ✅ Always test in a staging environment first
- ✅ Keep backups before deploying new versions
- ✅ Monitor application logs after deployment
- ✅ Have a rollback plan ready
- ✅ Document any custom configurations

**Current Deployment Status:**
- Check with: `sudo docker-compose ps`
- View logs: `sudo docker-compose logs -f`

---

## 🎯 Recommended Approach

```
╔════════════════════════════════════════════════════════════╗
║                                                            ║
║  RECOMMENDED: Use LOCAL_BUILD_DEPLOYMENT.md               ║
║                                                            ║
║  ✅ 100% success rate                                      ║
║  ✅ 15-20 minute deployment                                ║
║  ✅ Reliable and repeatable                                ║
║  ✅ No VM upgrade needed                                   ║
║  ✅ Proven to work                                         ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝
```

---

**Documentation Complete**
**Status:** Ready for Production Use
**Last Tested:** 2026-01-06
**Success Rate:** 100% (Local Build Method)
