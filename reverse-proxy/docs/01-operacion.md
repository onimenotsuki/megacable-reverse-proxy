# Operación (systemd + Nginx)

Este documento explica cómo operar el reverse proxy en los nodos:

- `10.7.50.201`
- `10.7.50.202`

## Componentes

- **Nginx**: proceso del reverse proxy.
- **systemd**: supervisor del proceso.
- **Config desplegada**: `/etc/megacable-reverse-proxy/`
- **Logs**: `/var/log/megacable-reverse-proxy/`

## Ubicaciones clave en el servidor

- **Config principal**: `/etc/megacable-reverse-proxy/nginx.conf`
- **Vhost / ruteo**: `/etc/megacable-reverse-proxy/conf.d/web.xviewplusn2.com.mx.conf`
- **Unit systemd**: `/etc/systemd/system/megacable-reverse-proxy.service`
- **PID**: `/run/megacable-reverse-proxy/nginx.pid`
- **Access log**: `/var/log/megacable-reverse-proxy/access.log`
- **Error log**: `/var/log/megacable-reverse-proxy/error.log`

## Comandos de operación

### Ver estado

```bash
sudo systemctl status megacable-reverse-proxy
```

### Validar la configuración (sin aplicar cambios)

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

### Recargar configuración (sin cortar conexiones activas)

```bash
sudo systemctl reload megacable-reverse-proxy
```

La recarga está definida para validar primero con `nginx -t` y luego enviar `HUP`.

### Reiniciar el servicio

```bash
sudo systemctl restart megacable-reverse-proxy
```

Úsalo cuando:

- Se cambió el unit de systemd
- Se sospecha un estado inconsistente del proceso
- Se requiere reinicio como parte de troubleshooting

### Ver logs

systemd:

```bash
sudo journalctl -u megacable-reverse-proxy -n 200 --no-pager
```

Nginx (archivos):

```bash
sudo ls -lh /var/log/megacable-reverse-proxy/
```

## Qué esperar en logs (rápido)

En `access.log`:

- `rt=`: tiempo total de request
- `urt=`: tiempo de respuesta de upstream
- `ua=`: upstream address elegido (IP:port)
- `us=`: upstream status (código HTTP)
- `rid=`: request id (útil para correlación)

## Semántica de ruteo (para evitar sorpresas)

- El ruteo está definido por **locations** por path.
- La configuración está pensada para **preservar el path completo** (no reescribe el URI).
- Hay rutas “exactas” (por ejemplo `location = /search`) y rutas de “prefijo” (por ejemplo `location ^~ /search/`) para cubrir subpaths.

