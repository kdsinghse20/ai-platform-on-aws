# NGINX Role - Reverse Proxy

**NGINX installation and reverse proxy configuration.**

See detailed documentation: `../../ansible/roles/nginx/README.md`

---

## Overview

Sets up NGINX as reverse proxy:
- Installation from packages
- Reverse proxy configuration
- SSL/TLS setup (optional)
- Health checks

---

## Sub-Tasks

1. **install.yml** - NGINX installation
2. **configure.yml** - Reverse proxy setup
3. **ssl.yml** - SSL/TLS configuration
4. **verify.yml** - Syntax checks

---

## Configuration

- **Upstream**: OpenWebUI:8080
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Features**: Reverse proxy, headers, redirects

---

## Proxy Setup

Routes requests:
```
Internet (ALB)
  ↓
NGINX:80
  ↓
OpenWebUI:8080
```

---

## SSL/TLS

- ACM certificate installation
- HTTPS listener
- HTTP → HTTPS redirect

---

## Execution

```bash
ansible-playbook playbooks/nginx.yml -i inventory/hosts.yml
```

---

## Testing

```bash
nginx -t              # Test config
systemctl status nginx # Check status
curl http://localhost:80  # Test HTTP
```

---

For complete documentation, see:
`../../ansible/roles/nginx/README.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
