# Runbook de incidentes (Reverse Proxy Nginx)

Este runbook es para operar incidentes relacionados con el reverse proxy desplegado en:

- `10.7.50.201`
- `10.7.50.202`

Control node típico para despliegue/rollback con Ansible:

- `10.7.57.203`

## Objetivo

- Restaurar servicio lo más rápido posible (mitigación primero, RCA después).
- Ejecutar pasos repetibles: **verificar**, **aislar**, **mitigar**, **escalar**.

## Definiciones rápidas

- **Servicio**: `megacable-reverse-proxy` (systemd)
- **Config**: `/etc/megacable-reverse-proxy/nginx.conf` y `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`
- **Logs**: `/var/log/megacable-reverse-proxy/access.log` y `/var/log/megacable-reverse-proxy/error.log`
- **Rutas críticas**:
  - SQUID: `/RTEFacade`, `/compass`, `/search`, `/personalization`, `/SessionManagement`
  - BFF: `/rtvbff/linear`, `/rtvbff/vod`, `/rtvbff/image`

## Severidades (guía práctica)

> Ajusta a tu esquema oficial si ya existe.

- **SEV1**: caída total o afectación masiva del tráfico web (errores sistemáticos 5xx / timeouts).
- **SEV2**: degradación significativa (intermitencias, subset de rutas o subset de usuarios).
- **SEV3**: degradación menor o impacto limitado (un upstream específico, un pool parcial).

## Checklist inmediato (primeros 5 minutos)

En **cada nodo** (`10.7.50.201` y `10.7.50.202`):

1) Estado del servicio:

```bash
sudo systemctl status megacable-reverse-proxy
```

2) Validación de config:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

3) Logs recientes:

```bash
sudo journalctl -u megacable-reverse-proxy -n 200 --no-pager
sudo tail -n 100 /var/log/megacable-reverse-proxy/error.log
sudo tail -n 100 /var/log/megacable-reverse-proxy/access.log
```

4) Smoke tests locales:

```bash
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/linear/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/vod/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/rtvbff/image/is_alive
curl -si -H 'Host: web.xviewplusn2.com.mx' http://127.0.0.1/search
```

## Árbol de decisión (rápido)

### Caso A: El servicio está `failed` o no escucha

**Acciones**

1) Validar config:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

2) Si la config está bien, reiniciar:

```bash
sudo systemctl restart megacable-reverse-proxy
sudo systemctl status megacable-reverse-proxy
```

**Escalar si**

- Reinicio no levanta.
- `nginx -t` falla y no hay un cambio obvio reciente/seguro.

### Caso B: 404 en rutas que deberían existir

**Acciones**

1) Confirmar request real en `access.log` (path exacto):

```bash
sudo tail -n 100 /var/log/megacable-reverse-proxy/access.log
```

2) Verificar que el `Host` esperado esté llegando (el vhost es `web.xviewplusn2.com.mx`).

3) Confirmar ruteo en:

- `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`

**Mitigación rápida**

- Si el path nuevo no está contemplado, se necesita cambio de config + deploy controlado.

### Caso C: 502 / 504 (upstream no disponible / timeout)

**Acciones**

1) Identificar upstream fallido en access log (campos `ua=` y `us=`):

```bash
sudo tail -n 200 /var/log/megacable-reverse-proxy/access.log
```

2) Probar conectividad del proxy al upstream (ejemplos):

```bash
curl -si http://10.7.50.46/is_alive
curl -si http://10.7.50.61/is_alive
curl -si http://10.7.50.71/is_alive
```

Para SQUID (puerto 3128) prueba TCP/HTTP básico según tus herramientas disponibles; por ejemplo:

```bash
curl -si http://10.7.50.11:3128
```

3) Si falla un subconjunto de IPs:

- es probable que haya nodos upstream caídos o problemas de red/rutas/ACL

**Mitigación rápida**

- Si el problema está en upstream, el proxy solo puede “evitar” temporalmente nodos fallidos con `max_fails/fail_timeout` (ya configurado). Se requiere corregir upstreams.

**Escalar si**

- Fallan todos los upstreams de un pool (SEV1/SEV2).
- Parece tema de red entre VLANs (routing/ACL).

### Caso D: CORS / comportamiento extraño por headers

**Contexto**

- El proxy **preserva `Host`** y setea `X-Forwarded-*`.
- `X-Forwarded-Proto` depende de lo que envíe el LB; si falta, cae a `http`.

**Acciones**

1) Confirmar qué headers llegan desde el LB (revisar logs del LB si existen).
2) Si apps requieren `https` explícito y el LB no manda `X-Forwarded-Proto`, corregir en el LB (preferido).

**Escalar si**

- Hay cambios en LB/F5 relacionados con headers.

## Mitigaciones estándar

### 1) Reload seguro (sin cortar conexiones)

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf && sudo systemctl reload megacable-reverse-proxy
```

### 2) Restart (cuando reload no basta)

```bash
sudo systemctl restart megacable-reverse-proxy
sudo systemctl status megacable-reverse-proxy
```

### 3) Verificar ambos nodos y comparar

En incidentes intermitentes es común que solo un nodo esté mal:

- Compara `systemctl status`
- Compara `nginx -t`
- Compara `error.log`

Si solo uno falla, puedes mitigar **sacándolo del LB** mientras se repara (acción en LB/F5, fuera del alcance de este repo).

## Rollback (operación)

### Opción recomendada: rollback con Ansible (desde `10.7.57.203`)

1) Revertir cambio en git (según tu proceso).
2) Re-desplegar:

```bash
cd reverse-proxy/ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Opción manual (solo si no hay control node)

Restaurar archivos desde backup en:

- `/etc/megacable-reverse-proxy/`

y hacer reload:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf && sudo systemctl reload megacable-reverse-proxy
```

## Criterios de escalamiento

Escala inmediatamente si:

- **SEV1**: ambos nodos impactados + 5xx sostenido.
- `nginx -t` falla en ambos nodos y no hay cambio fácil de revertir.
- Se detecta **tema de red** hacia pools (routing/ACL/VLAN) o caída total de upstreams.
- Hay evidencia de cambio en LB/F5 afectando headers (`X-Forwarded-Proto`, `Host`, etc.).

## Datos mínimos para el post-mortem

Recolectar:

- Ventana de tiempo del incidente (inicio/fin).
- % o tasa de 5xx (si existe métrica externa).
- 20–50 líneas relevantes de `access.log` y `error.log` (redacta tokens si existieran).
- Resultado de:
  - `systemctl status`
  - `nginx -t`
  - `curl` a `/rtvbff/*/is_alive`
- Cambios recientes (deploy/rollback, cambios en LB/F5, cambios de red).

