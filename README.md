# NginxReversProxy


## Primeros pasos

Para facilitarte el inicio con GitLab, aquí tienes una lista de próximos pasos recomendados.

¿Ya eres experto? Edita este `README.md` y ajústalo a las necesidades del proyecto. ¿Quieres hacerlo más fácil? [Usa la plantilla al final](#edición-de-este-readme).

## Agrega tus archivos

- [Crear](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#create-a-file) o [subir](https://docs.gitlab.com/ee/user/project/repository/web_editor.html#upload-a-file) archivos
- [Agregar archivos usando la línea de comandos](https://docs.gitlab.com/topics/git/add_files/#add-files-to-a-git-repository) o empujar un repositorio Git existente con el siguiente comando:

```
cd existing_repo
git remote add origin http://10.7.57.203/devops/nginxreversproxy.git
git branch -M main
git push -uf origin main
```

## Integra con tus herramientas

- [Configura integraciones del proyecto](http://10.7.57.203/devops/nginxreversproxy/-/settings/integrations)

## Colabora con tu equipo

- [Invita miembros del equipo y colaboradores](https://docs.gitlab.com/ee/user/project/members/)
- [Crea un nuevo merge request](https://docs.gitlab.com/ee/user/project/merge_requests/creating_merge_requests.html)
- [Cierra issues automáticamente desde merge requests](https://docs.gitlab.com/ee/user/project/issues/managing_issues.html#closing-issues-automatically)
- [Habilita aprobaciones para merge requests](https://docs.gitlab.com/ee/user/project/merge_requests/approvals/)
- [Configura auto-merge](https://docs.gitlab.com/user/project/merge_requests/auto_merge/)

## Pruebas y despliegue

Usa la integración continua incluida en GitLab.

- [Comienza con GitLab CI/CD](https://docs.gitlab.com/ee/ci/quick_start/)
- [Analiza tu código en busca de vulnerabilidades conocidas con Static Application Security Testing (SAST)](https://docs.gitlab.com/ee/user/application_security/sast/)
- [Despliega a Kubernetes, Amazon EC2 o Amazon ECS usando Auto Deploy](https://docs.gitlab.com/ee/topics/autodevops/requirements.html)
- [Usa despliegues “pull-based” para mejorar la administración de Kubernetes](https://docs.gitlab.com/ee/user/clusters/agent/)
- [Configura entornos protegidos](https://docs.gitlab.com/ee/ci/environments/protected_environments.html)

***

# Edición de este README

Cuando estés listo para adaptar este README al proyecto, edita este archivo y usa la plantilla práctica de abajo (o siéntete libre de estructurarlo como prefieras: esto solo es un punto de partida). Gracias a [makeareadme.com](https://www.makeareadme.com/) por esta plantilla.

## Sugerencias para un buen README

Cada proyecto es distinto, así que considera cuáles de estas secciones aplican al tuyo. Las secciones de la plantilla son sugerencias para la mayoría de proyectos open source. También ten en cuenta que, aunque un README puede ser demasiado largo y detallado, normalmente es mejor que sea “demasiado largo” a que sea “demasiado corto”. Si crees que tu README quedó muy extenso, considera usar otro tipo de documentación en lugar de recortar información importante.

## Nombre
Elige un nombre autoexplicativo para tu proyecto.

## Descripción
Hazle saber a la gente qué puede hacer tu proyecto de forma específica. Aporta contexto y agrega enlaces a referencias con las que los visitantes podrían no estar familiarizados. Aquí también puedes agregar una lista de características o una subsección de antecedentes. Si existen alternativas a tu proyecto, este es un buen lugar para listar los diferenciadores.

## Insignias
En algunos READMEs verás pequeñas imágenes que muestran metadatos, por ejemplo si las pruebas del proyecto están pasando o no. Puedes usar Shields para agregar badges a tu README. Muchos servicios también incluyen instrucciones para añadir un badge.

## Visuales
Dependiendo de lo que estés construyendo, puede ser buena idea incluir capturas de pantalla o incluso un video (a menudo verás GIFs en lugar de videos). Herramientas como ttygif pueden ayudar, pero revisa Asciinema si necesitas un método más sofisticado.

## Instalación
Dentro de un ecosistema puede existir una forma común de instalar cosas, por ejemplo usando Yarn, NuGet o Homebrew. Aun así, considera que quien lea tu README podría ser principiante y necesitar más guía. Listar pasos específicos reduce ambigüedad y ayuda a que la gente use tu proyecto lo antes posible. Si solo funciona en un contexto específico (por ejemplo cierta versión de lenguaje, sistema operativo o dependencias que deben instalarse manualmente), agrega también una subsección de Requisitos.

## Uso
Usa ejemplos sin miedo y, si puedes, muestra la salida esperada. Es útil incluir el ejemplo más pequeño posible que demuestre el uso, y agregar enlaces a ejemplos más sofisticados si son demasiado largos para incluirlos razonablemente en el README.

## Soporte
Indica a la gente dónde puede pedir ayuda. Puede ser cualquier combinación de un issue tracker, un chat, un correo, etc.

## Hoja de ruta
Si tienes ideas para releases futuras, es buena idea listarlas en el README.

## Contribuciones
Aclara si estás abierto a contribuciones y cuáles son los requisitos para aceptarlas.

Para quienes quieran hacer cambios al proyecto, es útil contar con documentación de cómo empezar. Quizá exista un script que deban ejecutar o variables de entorno que deban configurar. Haz explícitos esos pasos. Estas instrucciones también pueden ser útiles para tu “yo” del futuro.

También puedes documentar comandos para linting o para ejecutar pruebas. Estos pasos ayudan a asegurar alta calidad del código y reducen el riesgo de que los cambios rompan algo inadvertidamente. Tener instrucciones para correr pruebas es especialmente útil si requiere configuración externa, por ejemplo levantar un servidor de Selenium para pruebas en navegador.

## Autores y agradecimientos
Muestra tu agradecimiento a quienes han contribuido al proyecto.

## Licencia
Para proyectos open source, indica bajo qué licencia se publica.

## Estado del proyecto
Si te quedaste sin energía o tiempo para el proyecto, agrega una nota al inicio del README indicando que el desarrollo se ha ralentizado o se detuvo por completo. Alguien podría decidir hacer un fork o ayudar como mantenedor/owner, permitiendo que el proyecto continúe. También puedes hacer una solicitud explícita de mantenedores.
