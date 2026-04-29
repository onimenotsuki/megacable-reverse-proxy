# Git: resolver problemas comunes (Megacable)

Esta guía es un recetario de comandos para **resolver problemas típicos** al trabajar con Git en este repositorio.

## 1) Error al hacer push: `rejected (fetch first)`

Síntoma:

```text
! [rejected] main -> main (fetch first)
Updates were rejected because the remote contains work that you do not have locally
```

Significa:
- La rama remota avanzó (alguien empujó commits) y tu rama local se quedó atrás.

Solución recomendada (rebase):

```bash
git fetch origin
git pull --rebase origin main
git push origin main
```

Si tu remoto se llama `gitlab`:

```bash
git fetch gitlab
git pull --rebase gitlab main
git push gitlab main
```

## 2) Conflictos durante `rebase` o `pull --rebase`

1) Ver qué archivos están en conflicto:

```bash
git status
```

2) Editar archivos y resolver marcadores:
- `<<<<<<<`
- `=======`
- `>>>>>>>`

3) Marcar como resuelto y continuar:

```bash
git add -A
git rebase --continue
```

Si quieres abortar y volver al estado anterior:

```bash
git rebase --abort
```

## 3) “Me equivoqué de rama” o “tengo cambios sin commitear”

Ver cambios:

```bash
git status
git diff
```

Guardar cambios temporalmente (stash):

```bash
git stash push -m "WIP"
```

Cambiar de rama y re-aplicar:

```bash
git switch feature/mi-rama
git stash pop
```

## 4) “No quiero este commit” (revertir de forma segura)

Si el commit ya está compartido (push), usa `revert` (no reescribe historia):

```bash
git revert <sha>
git push
```

## 5) “Quiero deshacer cambios locales” (sin afectar remoto)

Descartar cambios NO commiteados en archivos:

```bash
git restore .
```

O descartar también lo que esté staged:

```bash
git restore --staged .
git restore .
```

## 6) Mi rama quedó desactualizada respecto a `main`

Estando en tu rama:

```bash
git fetch origin
git rebase origin/main
```

Si el push es rechazado después del rebase:

```bash
git push --force-with-lease
```

Notas:
- Úsalo **solo** en tu rama de trabajo (no en `main`).
- `--force-with-lease` es más seguro que `--force`.

## 7) Ver rápidamente qué pasó (diagnóstico)

```bash
git log --oneline --decorate --graph --all --max-count=30
git remote -v
git branch -vv
```

