# Ansible - Configuration Management

**Service configuration and deployment automation.**

See detailed documentation: `../../ansible/README.md`

---

## Overview

Ansible playbooks configure services:
1. **Common Role** - System setup
2. **Ollama Role** - AI model runtime
3. **OpenWebUI Role** - Web interface
4. **NGINX Role** - Reverse proxy

---

## Playbooks

```yaml
playbooks/site.yml          # Main orchestration (all roles)
playbooks/common.yml        # System setup
playbooks/ollama.yml        # AI runtime
playbooks/openwebui.yml     # Web UI
playbooks/nginx.yml         # Reverse proxy
```

---

## Execution Order

1. **common.yml** - System packages, dependencies
2. **ollama.yml** - Ollama installation, model download
3. **openwebui.yml** - Docker, OpenWebUI, integration
4. **nginx.yml** - NGINX reverse proxy, SSL/TLS

---

## Quick Start

```bash
# Test connectivity
ansible all -m ping -i inventory/hosts.yml

# Run all playbooks
ansible-playbook playbooks/site.yml -i inventory/hosts.yml

# Run specific playbook
ansible-playbook playbooks/ollama.yml -i inventory/hosts.yml
```

---

## Roles

| Role | Purpose | Documentation |
|------|---------|---|
| **common** | System setup | `01-COMMON_ROLE.md` |
| **ollama** | AI runtime | `02-OLLAMA_ROLE.md` |
| **openwebui** | Web UI | `03-OPENWEBUI_ROLE.md` |
| **nginx** | Reverse proxy | `04-NGINX_ROLE.md` |

---

## Inventory

Generated from Terraform:
```bash
terraform output -raw ansible_inventory > ../../ansible/inventory/hosts.yml
```

Groups:
- `all` - All hosts
- `openwebui` - OpenWebUI instances
- `ollama` - Ollama instances

---

## Features

- ✓ Idempotent (safe to run multiple times)
- ✓ Service-based organization
- ✓ Automatic health checks
- ✓ Model management
- ✓ Configuration templates

---

For complete documentation, see:
`../../ansible/README.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
