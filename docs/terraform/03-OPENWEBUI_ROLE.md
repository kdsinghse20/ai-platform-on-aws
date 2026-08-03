# OpenWebUI Role - Web Interface

**OpenWebUI installation and configuration.**

See detailed documentation: `../../ansible/roles/openwebui/README.md`

---

## Overview

Deploys OpenWebUI via Docker:
- Docker and Docker Compose installation
- OpenWebUI container setup
- Ollama integration
- Configuration management

---

## Sub-Tasks

1. **install.yml** - Docker installation
2. **configure.yml** - Docker Compose setup
3. **models.yml** - Ollama connection configuration
4. **verify.yml** - Health checks

---

## Configuration

- **Port**: 8080 (internal)
- **Container**: open-webui (Docker)
- **Ollama Endpoint**: http://ollama:11434

---

## Docker Compose

Manages OpenWebUI container with:
- Port mapping
- Volume mounts
- Environment variables
- Network configuration

---

## Execution

```bash
ansible-playbook playbooks/openwebui.yml -i inventory/hosts.yml
```

---

## Access

Internal: `http://localhost:8080`
Via NGINX: Reverse proxy routing

---

For complete documentation, see:
`../../ansible/roles/openwebui/README.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
