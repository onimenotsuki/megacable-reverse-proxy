# Agent guide (Megacable / Nginx reverse proxy)

Use this file as the project map for Cursor and other coding agents.

## Repository layout

| Path | Purpose |
|------|---------|
| `reverse-proxy/README.md` | Main technical overview (topology, routes, smoke tests). |
| `reverse-proxy/nginx/` | Reference Nginx config for **manual** installs (paths under `/etc/megacable-reverse-proxy/`). |
| `reverse-proxy/systemd/` | Reference unit for manual installs. |
| `reverse-proxy/ansible/` | **Source of truth for deployments** via Ansible (GitLab CI runs `ansible-playbook` from here). |
| `reverse-proxy/ansible/roles/megacable_reverse_proxy_nginx/files/` | Files actually copied to target nodes by the role (`nginx/`, `systemd/`). |
| `reverse-proxy/docs/` | Runbooks, Git workflow, troubleshooting, `white-list.csv` (egress DNS list). |
| `reverse-proxy/scripts/` | `smoke-test.sh`, `validate-on-node.sh`, `check-whitelist-dns.sh`. |
| `.gitlab-ci.yml` | `ansible-playbook --syntax-check`, `ansible-lint`, manual deploy over SSH to control node. |
| `megacable-diagrams/` | Submodule / diagrams (usually not part of proxy changes). |

## Critical convention: two Nginx trees

Ansible `copy` tasks deploy from:

`reverse-proxy/ansible/roles/megacable_reverse_proxy_nginx/files/nginx/`

not from `reverse-proxy/nginx/`. Those trees **must stay aligned** when you change routing, upstreams, or `nginx.conf`. After edits, diff both paths and update the manual tree if the team relies on it for docs or non-Ansible installs.

## Operations snapshot

- **VHost**: `web.xviewplusn2.com.mx` (HTTP `80` on nodes; TLS terminates upstream per docs).
- **Upstream pools**: SQUID (`10.7.50.11-18:3128`), BFF pools documented in `reverse-proxy/README.md`.
- **Unknown paths**: `location /` returns `404` by design (fail closed).

## CI and validation

- Local or MR: same checks as CI — from `reverse-proxy/ansible`: `ansible-playbook -i inventory.ini playbook.yml --syntax-check` and `ansible-lint`.
- Post-deploy on a node: `reverse-proxy/scripts/validate-on-node.sh` (requires `nginx`, `systemctl`, `curl`, sudo as documented in `reverse-proxy/README.md`).

## Language and tone

- **User-facing repo docs** may be Spanish (existing `reverse-proxy/docs/`).
- **Code, shell comments, and inline technical notes** in new or edited files: **English**.

## Secrets and access

- Do not commit SSH keys, tokens, or production passwords. GitLab CI uses variables such as `SSH_PRIVATE_KEY`; keep them out of the repo.
