# Troubleshooting

Este documento es una guía rápida para diagnosticar fallas comunes en el reverse proxy.

## 1) El servicio no arranca

### Síntomas

- `systemctl status megacable-reverse-proxy` muestra `failed`
- `journalctl` contiene errores al iniciar

### Pasos

1) Revisa el detalle:

```bash
sudo systemctl status megacable-reverse-proxy
sudo journalctl -u megacable-reverse-proxy -n 200 --no-pager
```

2) Valida configuración:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

3) Si `nginx -t` falla, corrige la config y vuelve a intentar:

```bash
sudo systemctl restart megacable-reverse-proxy
```

## 2) Devuelve 404 para un path esperado

### Causa probable

- El path no está incluido en `web.xviewplusn2.com.mx.conf`
- El request trae un path ligeramente distinto (mayúsculas/minúsculas, trailing slash, subpath)

### Pasos

1) Verifica el path exacto en access log:

```bash
sudo tail -n 50 /var/log/megacable-reverse-proxy/access.log
```

2) Busca el `location` correspondiente en:

- `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`

## 3) 502 / 504 (Bad Gateway / Gateway Timeout)

### Causas probables

- El upstream no responde (servicio down)
- Firewall/ruta de red
- Timeout insuficiente
- Upstreams saturados

### Pasos

1) Verifica cuál upstream está fallando (ver `ua=` y `us=` en access log):

```bash
sudo tail -n 50 /var/log/megacable-reverse-proxy/access.log
```

2) Probar conectividad desde el nodo proxy hacia un upstream (ejemplos):

```bash
curl -si http://10.7.50.46/is_alive
curl -si http://10.7.50.11:3128
```

3) Si solo falla un subset de IPs, revisar pool, red o salud del nodo upstream.

## 4) Problemas con CORS o apps que dependen de Host

### Punto clave

Esta configuración **preserva `Host`** (`web.xviewplusn2.com.mx`) hacia upstreams por compatibilidad.

Si un upstream exige otro `Host`, debes ajustar el `location` específico, por ejemplo:

- `proxy_set_header Host <otro-host>;` solo dentro de ese `location`

## 5) El deploy con Ansible falla

### Caso A: falla por permisos / sudo

- Confirma que el usuario remoto tiene `sudo` sin interacción (o usa `--ask-become-pass` si aplica)

### Caso B: falla por `nginx -t`

El handler de validación corta el deploy antes del reload.

Pasos:

1) Lee el error exacto en la salida de Ansible
2) Reproduce manualmente en el host:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

## 6) Checklist rápido (cuando hay incidente)

- `systemctl status megacable-reverse-proxy`
- `nginx -t -c /etc/megacable-reverse-proxy/nginx.conf`
- revisar `access.log` y `error.log`
- probar `curl` a `/rtvbff/*/is_alive`
- probar reachability a upstreams desde el proxy

