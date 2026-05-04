# Reverse Proxy Megacable (Nginx)

Esta carpeta contiene un **reverse proxy en Nginx** (con **systemd**) y un **despliegue automatizado con Ansible** para que cualquier ingeniero pueda **operarlo, mantenerlo y extenderlo** de forma segura.

## Objetivo

Recibir tráfico para el virtual host **`web.xviewplusn2.com.mx`** y enrutar por **path** hacia pools internos (SQUID y BFFs), con:

- Balanceo **round-robin**
- Headers `X-Forwarded-*` consistentes
- Validación de sintaxis con `nginx -t` antes de recargar
- Despliegue reproducible a dos nodos

## Topología (quién despliega y dónde corre)

- **Nodo(s) destino (donde corre Nginx)**:
  - `10.7.50.201`
  - `10.7.50.202`
- **Nodo controlador (desde donde se ejecuta Ansible)**:
  - `10.7.57.203`

Asunción operativa: **TLS termina antes de Nginx** (por ejemplo F5/LB). Este Nginx escucha **HTTP/80**.

## Qué rutas se enrutan (source: `flujos.csv`)

### Virtual host
- `web.xviewplusn2.com.mx`

### Rutas hacia SQUID (pool HTTP `:3128`)
- `/RTEFacade` (y subpaths)
- `/compass` (y subpaths)
- `/search` (y subpaths)
- `/personalization` (y subpaths)
- `/SessionManagement` (y subpaths)

Pool SQUID:
- `10.7.50.11:3128` … `10.7.50.18:3128`

### Rutas hacia BFFs (pools HTTP `:80`)
- `/rtvbff/linear` → pool LINEAR (`10.7.50.46` … `10.7.50.51`)
- `/rtvbff/vod` → pool VOD (`10.7.50.61` … `10.7.50.66`)
- `/rtvbff/image` → pool IMAGE (`10.7.50.71` … `10.7.50.74`)

Healthcheck observado en los servicios:
- `http://<ip>/is_alive`

## Comportamiento de headers (importante)

Por defecto el proxy:

- **Preserva `Host`** (envía `Host: web.xviewplusn2.com.mx` hacia upstreams)
- Setea `X-Forwarded-For`
- Setea `X-Forwarded-Host`
- Setea `X-Forwarded-Proto` así:
  - si viene `X-Forwarded-Proto` desde el LB, lo preserva
  - si no viene, hace fallback a `$scheme` (normalmente `http`, ya que TLS termina upstream)

## Estructura de archivos (en este repo)

- `nginx/nginx.conf`: configuración principal (log_format, timeouts, includes)
- `nginx/conf.d/web.xviewplusn2.com.mx.conf`: upstream pools y `server {}` con ruteo por path
- `systemd/megacable-reverse-proxy.service`: servicio systemd
- `ansible/`: inventario, playbook y role para despliegue

Documentación extendida (lee esto si vas a operar o cambiar algo):

- `docs/01-operacion.md`
- `docs/02-despliegue-ansible.md`
- `docs/03-troubleshooting.md`
- `docs/04-como-agregar-rutas.md`
- `docs/07-git-flujo-de-trabajo.md`
- `docs/08-git-resolver-problemas.md`

## Despliegue con Ansible (recomendado)

Desde el nodo `10.7.57.203` (control node), en el repo:

```bash
cd reverse-proxy/ansible
ansible-playbook -i inventory.ini playbook.yml
```

Qué hace el role:

- Copia config a `/etc/megacable-reverse-proxy/`
- Copia unit a `/etc/systemd/system/megacable-reverse-proxy.service`
- Ejecuta `nginx -t` en el nodo destino
- Recarga (reload) el servicio si solo cambió la config
- Reinicia (restart) si cambió el unit y requiere `daemon-reload`

## Instalación manual (solo si Ansible no está disponible)

1) Copiar archivos:

- `reverse-proxy/nginx/nginx.conf` → `/etc/megacable-reverse-proxy/nginx.conf`
- `reverse-proxy/nginx/conf.d/web.xviewplusn2.com.mx.conf` → `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`
- `reverse-proxy/systemd/megacable-reverse-proxy.service` → `/etc/systemd/system/megacable-reverse-proxy.service`

2) Crear directorios:

```bash
sudo mkdir -p /etc/megacable-reverse-proxy/conf.d \
  /var/log/megacable-reverse-proxy \
  /run/megacable-reverse-proxy
```

3) Habilitar y arrancar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now megacable-reverse-proxy
```

## Validación (smoke tests)

Scripts reutilizables (desde el directorio `reverse-proxy/` o con ruta absoluta):

| Script | Uso |
|--------|-----|
| `scripts/smoke-test.sh` | Comprueba BFF `is_alive`, rutas SQUID (sin 502/503/504) y 404 en ruta desconocida. Variables: `BASE_URL` (default `http://127.0.0.1`), `VHOST` (default `web.xviewplusn2.com.mx`). |
| `scripts/validate-on-node.sh` | **En el nodo** (201/202): `nginx -t`, servicio activo y luego `smoke-test.sh`. |
| `scripts/check-whitelist-dns.sh` | Resuelve DNS de cada dominio en `docs/white-list.csv` (sanidad de allowlist). |

Validar sintaxis y estado:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
sudo systemctl status megacable-reverse-proxy
```

Probar health endpoints BFF (ejemplos):

```bash
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/linear/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/vod/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/image/is_alive
```

Probar rutas a SQUID (ejemplos):

```bash
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/search
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/RTEFacade
```

## Limitaciones conocidas

- **Nginx OSS** no hace health-checks HTTP activos por endpoint; por eso se usa `max_fails`/`fail_timeout` para “degradar” upstreams temporalmente.
- `flujos.csv` menciona flujos adicionales fuera del archivo; esta implementación cubre lo explícito en el CSV.


