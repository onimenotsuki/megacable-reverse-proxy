# Guía Git (Megacable): flujo de trabajo para este repositorio

Esta guía describe un flujo **simple, seguro y repetible** para trabajar con Git en este repo y colaborar vía **GitLab**.

> Recomendación del equipo: trabajar con **ramas cortas** + **Merge Request (MR)** y mantener `main` siempre “deployable”.

## Pre-requisitos

- Tener instalado `git`.
- Tener acceso al repositorio en GitLab.

URL del repo (GitLab interno):
- `http://10.7.57.203/devops/nginxreversproxy.git`

## Configuración inicial (una sola vez por máquina)

Configura tu identidad (se usa en commits):

```bash
git config --global user.name "Nombre Apellido"
git config --global user.email "tu.correo@megacable.com.mx"
```

Opcional (recomendado): que el `pull` use rebase por defecto (historial más limpio):

```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
```

## Clonar el repositorio

```bash
git clone http://10.7.57.203/devops/nginxreversproxy.git
cd nginxreversproxy
```

Valida qué remotos tienes configurados:

```bash
git remote -v
```

Nota: si tu remoto se llama `origin` pero en tu equipo prefieren `gitlab`, puedes agregar un alias:

```bash
git remote add gitlab http://10.7.57.203/devops/nginxreversproxy.git
```

## Flujo recomendado (día a día)

### 1) Actualizarte antes de empezar

```bash
git switch main
git fetch --all --prune
git pull --rebase
```

### 2) Crear una rama de trabajo

Usa un nombre que explique el cambio:

```bash
git switch -c feature/ruta-nueva-search
# o
git switch -c fix/headers-forwarded-proto
```

### 3) Hacer cambios y revisar qué se va a commitear

```bash
git status
git diff
```

### 4) Preparar el commit (stage) y commitear

```bash
git add -A
git commit -m "Add routing for /search subpaths"
```

Recomendaciones:
- Un commit = un cambio lógico (evita “megacommits”).
- Mensajes en **inglés** para consistencia técnica (convención común en equipos de ingeniería).

### 5) Publicar tu rama

La primera vez que empujas tu rama:

```bash
git push -u origin HEAD
```

Si tu remoto se llama `gitlab`:

```bash
git push -u gitlab HEAD
```

### 6) Crear un Merge Request (MR) en GitLab

En GitLab:
- Crea un MR desde tu rama hacia `main`
- Pide revisión a 1–2 personas
- Espera a que el pipeline (CI/CD) valide

### 7) Mantener tu rama actualizada (mientras revisan)

Cuando `main` avance, actualiza tu rama rebasando:

```bash
git fetch origin
git rebase origin/main
git push
```

Si el rebase reescribe commits, el push puede requerir `--force-with-lease` **solo en tu rama**:

```bash
git push --force-with-lease
```

> No uses `--force` en `main`.

### 8) Merge y limpieza

Después de que el MR se mergea:

```bash
git switch main
git pull --rebase
git branch -d feature/ruta-nueva-search
```

## Buenas prácticas específicas del repo

- Cambios de Nginx/Ansible pueden impactar producción: prefiere MR y revisiones.
- Si tocas configuración, valida antes:

```bash
sudo nginx -t -c /etc/megacable-reverse-proxy/nginx.conf
```

- Para despliegue automatizado, revisa:
  - `docs/02-despliegue-ansible.md`
  - `docs/06-gitlab-ci-deploy.md`

## Checklist rápido antes de pedir review

- `git status` limpio (solo lo que quieres incluir)
- Cambio pequeño y con explicación en el MR
- Si aplica, actualizaste documentación en `reverse-proxy/docs/`

