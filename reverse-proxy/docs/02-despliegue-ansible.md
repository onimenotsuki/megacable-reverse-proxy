# Despliegue con Ansible (control node `10.7.57.203`)

Este reverse proxy está diseñado para desplegarse de forma **automatizada** a:

- `10.7.50.201`
- `10.7.50.202`

desde un **control node** (por ejemplo `10.7.57.203`).

## Archivos relevantes

- **Inventario**: `reverse-proxy/ansible/inventory.ini`
- **Playbook**: `reverse-proxy/ansible/playbook.yml`
- **Role**: `reverse-proxy/ansible/roles/megacable_reverse_proxy_nginx/`

## Pre-requisitos en el control node

- `ansible` instalado
- Conectividad de red hacia `10.7.50.201` y `10.7.50.202`
- Acceso SSH al usuario remoto
- Privilegios de `sudo` (porque el playbook usa `become: true`)

## Ejecución estándar

Desde el repo:

```bash
cd reverse-proxy/ansible
ansible-playbook -i inventory.ini playbook.yml
```

## Qué hace el despliegue (paso a paso)

En cada host destino:

1) Crea directorios necesarios:

- `/etc/megacable-reverse-proxy/`
- `/etc/megacable-reverse-proxy/conf.d/`
- `/var/log/megacable-reverse-proxy/`
- `/run/megacable-reverse-proxy/`

2) Copia archivos de configuración:

- `nginx.conf` a `/etc/megacable-reverse-proxy/nginx.conf`
- `web.xviewplusn2.com.mx.conf` a `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`

3) Copia el unit de systemd:

- `/etc/systemd/system/megacable-reverse-proxy.service`

4) Valida configuración:

- Ejecuta `nginx -t -c /etc/megacable-reverse-proxy/nginx.conf`

5) Aplica cambios:

- Si cambió configuración → `systemctl reload megacable-reverse-proxy`
- Si cambió el unit → `systemctl daemon-reload` y `systemctl restart megacable-reverse-proxy`

## Validación post-deploy

En cada nodo (o vía SSH):

```bash
sudo systemctl status megacable-reverse-proxy
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

Smoke tests locales (en el nodo):

```bash
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/linear/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/search
```

## Rollback (práctico)

Opciones comunes:

- **Rollback por git**: revertir commit/branch y re-ejecutar el playbook.
- **Rollback manual**: restaurar archivos en `/etc/megacable-reverse-proxy/` desde un backup y hacer `systemctl reload`.

Si el deploy falla por `nginx -t`:

- No se hace reload (se corta el flujo en la validación)
- Revisa el error exacto en la salida de Ansible

