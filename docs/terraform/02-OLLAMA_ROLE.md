# Ollama Role - AI Model Runtime

**Ollama installation, configuration, and model management.**

See detailed documentation: `../../ansible/roles/ollama/README.md`

---

## Overview

Installs and configures Ollama:
- Ollama binary installation
- Systemd service setup
- Model downloading (Gemma 3, Llama 3.2)
- Health verification

---

## Sub-Tasks

1. **install.yml** - Download and install Ollama
2. **configure.yml** - Service setup and environment
3. **models.yml** - Download and verify models
4. **verify.yml** - Health checks and testing

---

## Models Downloaded

- `gemma:3` - Google Gemma 3 model
- `llama2:latest` - Meta Llama 3.2 model

---

## Configuration

- **Port**: 11434
- **Service**: ollama (systemd)
- **Models**: /var/lib/ollama/models

---

## Execution

```bash
ansible-playbook playbooks/ollama.yml -i inventory/hosts.yml
```

---

## API Endpoint

```
http://ollama-instance:11434/api/tags
```

---

For complete documentation, see:
`../../ansible/roles/ollama/README.md`

---

**Last Updated**: August 3, 2026 | **Version**: 1.0
