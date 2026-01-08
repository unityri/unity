# Screenshots Directory

This directory contains screenshots for the deployment documentation.

## Required Screenshots

### For SCRIPT_DEPLOYMENT.md:
| Filename | Description |
|----------|-------------|
| `ssh-connection.png` | SSH terminal showing successful login to server |
| `file-structure.png` | Terminal showing `ls -la` with unitysetup.sh and deploy.sh |
| `nano-editor-config.png` | Nano editor with deploy.sh showing configuration section |
| `ip-address-config.png` | Nano editor with IP_ADDRESS line highlighted |
| `deployment-progress.png` | Terminal showing colored deployment progress messages |
| `docker-containers-status.png` | Terminal showing `docker-compose ps` with "Up" status |
| `browser-frontend.png` | Browser showing Unity application login page |
| `firewall-status.png` | Terminal showing UFW firewall status |

### For LOCAL_BUILD_DEPLOYMENT.md:
| Filename | Description |
|----------|-------------|
| `docker-build-progress.png` | Terminal showing Docker build progress |
| `docker-images-list.png` | Terminal showing `docker images` output |
| `scp-transfer-progress.png` | SCP transfer showing percentage and speed |
| `docker-load-success.png` | Terminal showing `docker load` success message |
| `docker-compose-status.png` | Terminal showing containers running |
| `browser-frontend-local.png` | Browser showing application frontend |

### For SERVER_BUILD_DEPLOYMENT.md:
| Filename | Description |
|----------|-------------|
| `server-docker-build-progress.png` | Docker build progress on server |
| `server-docker-compose-status.png` | Containers running on server |

### For DEPLOYMENT_GUIDE_SUMMARY.md:
| Filename | Description |
|----------|-------------|
| `deployment-decision-flowchart.png` | Visual flowchart for choosing deployment method |
| `application-running.png` | Browser showing application running |

## How to Add Screenshots

1. Take screenshots during actual deployment process
2. Save with the exact filenames listed above
3. Use PNG format for best quality
4. Recommended size: 800-1200px width
5. Crop to show relevant content only
6. Add red boxes/arrows to highlight important areas

## Screenshot Tips

- Use a clean terminal with readable font size
- Show success messages clearly
- Include timestamps where relevant
- Blur any sensitive information (IPs, passwords)
- Use consistent terminal theme across all screenshots
