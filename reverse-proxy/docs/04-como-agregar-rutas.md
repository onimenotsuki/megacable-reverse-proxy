# Cómo agregar rutas / upstreams nuevos

Este documento explica cómo extender el reverse proxy cuando aparezcan nuevos flujos (por ejemplo los “other” mencionados fuera de `flujos.csv`).

## Regla de oro

Antes de aplicar a producción:

- Mantén cambios **pequeños**
- Ejecuta `nginx -t`
- Despliega con Ansible a **un nodo** (si tu proceso lo permite), valida, y luego al segundo

## Dónde se hacen los cambios

En el repo:

- `reverse-proxy/nginx/conf.d/web.xviewplusn2.com.mx.conf`

En los hosts (después del deploy):

- `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`

## Agregar un nuevo pool (upstream)

1) Define un `upstream` nuevo con servidores `IP:PORT`:

- Usa `max_fails` y `fail_timeout` para tolerancia básica
- Mantén el `keepalive` si aplica

2) Ejemplo conceptual:

```nginx
upstream new_service_pool {
  server 10.0.0.1:8080 max_fails=3 fail_timeout=10s;
  server 10.0.0.2:8080 max_fails=3 fail_timeout=10s;
  keepalive 32;
}
```

## Agregar un nuevo ruteo por path

1) Agrega un `location`:

- Para prefijos: `location ^~ /mi/path { ... }`
- Para exactos: `location = /mi/path { ... }`

2) Decide si necesitas cubrir subpaths:

- Si quieres que `/mi/path/foo` también rote, usa `^~ /mi/path` o agrega una segunda regla `/mi/path/`

3) Ejemplo conceptual:

```nginx
location ^~ /mi/path {
  proxy_pass http://new_service_pool;
}
```

## Consideraciones importantes

### 1) Preservar el URI (evitar reescrituras accidentales)

Nginx tiene reglas sutiles con `proxy_pass` y trailing slash. Esta implementación intenta **no reescribir** el path.

Regla práctica:

- Mantén `proxy_pass http://upstream_name;` (sin path y sin slash final)
- Mantén `location` consistente (si usas `location ^~ /foo/`, entonces la request original incluye `/foo/...` y se reenvía igual)

### 2) Header Host (casos especiales)

Por defecto se preserva `Host`. Si un upstream exige un host distinto:

```nginx
location ^~ /mi/path {
  proxy_set_header Host upstream.internal;
  proxy_pass http://new_service_pool;
}
```

### 3) Timeouts y payloads

Los timeouts/payload defaults están en `nginx.conf`. Si un servicio requiere valores distintos, se puede ajustar **por location**, pero documenta el porqué.

## Flujo recomendado de cambio

1) Editar archivo en el repo.
2) (Opcional) Revisar con un peer.
3) Desplegar con Ansible:

```bash
cd reverse-proxy/ansible
ansible-playbook -i inventory.ini playbook.yml
```

4) Validar:

- `systemctl status`
- `curl` al endpoint nuevo
- revisar logs

