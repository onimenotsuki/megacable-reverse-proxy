# GitLab CI/CD (deploy de Ansible vía control node)

Este repositorio se puede desplegar desde GitLab CI haciendo **SSH al control node de Ansible** y ejecutando el playbook existente:

- El control node ejecuta Ansible
- Los nodos destino están definidos en `reverse-proxy/ansible/inventory.ini`

La definición del pipeline vive en la raíz del repo: `.gitlab-ci.yml`.

## Jobs

### `validate:ansible`

Ejecuta:

- `ansible-playbook --syntax-check`
- `ansible-lint`

### `deploy:ansible` (manual)

En la rama default y en tags, corre un job **manual** que:

1. Empaqueta (archive) el contenido actual del repositorio
2. Lo copia al control node
3. Lo extrae en un directorio específico del commit
4. Ejecuta `ansible-playbook -i inventory.ini playbook.yml`

## Variables requeridas de GitLab CI

Créales en GitLab en **Settings → CI/CD → Variables**.

### `SSH_PRIVATE_KEY` (requerida)

Una llave privada SSH que pueda autenticarse en el control node como `DEPLOY_USER`.

- Recomendado: marcarla como **protected** y **masked**

### `SSH_KNOWN_HOSTS` (recomendada)

La entrada de `known_hosts` para el control node, por ejemplo:

```
10.7.57.203 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...
```

Si no se define, el pipeline usará `ssh-keyscan` en runtime.

### Variables opcionales

- `DEPLOY_HOST`: por defecto `10.7.57.203`
- `DEPLOY_USER`: por defecto `ansible`
- `ANSIBLE_ARGS`: flags extra que se pasan a `ansible-playbook` (ejemplo: `--limit 10.7.50.201`)

## Notas

- El control node debe tener `ansible` instalado y conectividad de red hacia los hosts destino.
- El usuario remoto debe tener permisos de `sudo` porque el playbook usa `become: true`.

