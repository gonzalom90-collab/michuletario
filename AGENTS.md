# michuletario — instrucciones para agentes (Claude y otros)

Léelo entero antes de tocar nada. Si algo de aquí no cuadra con lo que ves, pregunta a la usuaria antes de actuar.

> **Dos reglas básicas:**
> 1. **La usuaria (Almudena) no es técnica.** No sabe programar ni usar git, la terminal o Cloudflare. Háblale siempre en español sencillo, sin jerga, y explica los cambios por lo que se ve en la web, no por el código. No le pidas que ejecute comandos ni que edite archivos: hazlo tú.
> 2. **Todo cambio se despliega en GitHub.** Ningún cambio se queda solo en el ordenador: cuando termines y lo hayas probado, haz commit y push a `main` (eso publica la web) y comprueba que se ve en michuletario.com. Si hay un Artifact asociado, actualízalo también.

## Qué es este proyecto

Este repositorio es el código de la web **https://michuletario.com**, un "chuletario" de herramientas de consulta clínica para atención primaria. Son páginas HTML estáticas, sin paso de compilación ni dependencias:

| Página en la web | Archivo | Qué es |
|---|---|---|
| `michuletario.com/` | `index.html` | Calculadora de riesgo cardiovascular (SCORE2, SCORE2-OP, SCORE2-Diabetes), de gonzalom90-collab |
| `michuletario.com/vacunas/` | `vacunas/index.html` (generado desde `vacunas/src/herramienta.html`) | Herramienta de consulta de vacunas de la Comunidad de Madrid 2026 ("Vacunas CM 2026"), de Almudena |

Las dos páginas tienen un **menú lateral** (botón ☰ arriba a la izquierda, con el título "Mi chuletario") que enlaza una con otra. Si se añade una herramienta nueva, añade su enlace **en los dos menús**: en `index.html` (enlaces relativos, p. ej. `vacunas/index.html`) y en `vacunas/src/herramienta.html` (enlaces absolutos a `https://michuletario.com/...`, porque esa página también se ve como Artifact de Claude y como copia sin conexión).

## Personas y cuentas

- **Dueño del repositorio:** `gonzalom90-collab`. También es el dueño de la cuenta de Cloudflare donde está publicada la web.
- **Almudena** (cuenta GitHub `IceBubbleChezz`): colaboradora con permiso de escritura y quien pide los cambios. Gestora de centro de salud, **usuaria no técnica, sin conocimientos informáticos**: háblale en lenguaje sencillo, sin jerga, y explica qué ha cambiado en términos de la herramienta, no del código.
- En su PC: `git` y GitHub CLI (`C:\Program Files\GitHub CLI\gh.exe`) instalados; git usa la sesión de `gh` (`gh auth setup-git`). Identidad de commits configurada solo en este repo: `Almudena (IceBubbleChezz) <344986998+IceBubbleChezz@users.noreply.github.com>`.
- **Copia de trabajo del repo: `C:\Users\almud\Documents\1 Trabajo\Proyecto Web\michuletario`.** Trabaja siempre aquí.
- `C:\Users\almud\claude-code\michuletario` es una copia antigua del mismo repo: no la uses para editar. `C:\Users\almud\claude-code\_antiguo_vacunas` es una versión vieja de la herramienta de vacunas (octubre 2026): solo histórico.

## Cómo se despliega la web

- La web está alojada en **Cloudflare Workers** (proyecto `michuletario`), conectado al repositorio de GitHub. **Cada `git push` a la rama `main` publica la web automáticamente**: Cloudflare construye y despliega en aproximadamente 1 minuto. No hay otro paso.
- `wrangler.jsonc` sirve como archivos estáticos todo el repositorio (`assets.directory = "."`), excepto lo que aparece en `.assetsignore` (instrucciones, scripts, fuentes, `vacunas/src`).
- Direcciones donde se ve la web: **https://michuletario.com** (dominio propio) y https://michuletario.gonzalom-90.workers.dev (dirección de Cloudflare). `www.michuletario.com` no responde.
- **No hace falta acceso a Cloudflare para publicar.** En este PC no están instalados Node.js ni Wrangler, y no hay ninguna sesión de Cloudflare, por decisión de Almudena. Basta con tener permiso de push en GitHub. El acceso al panel de Cloudflare (dominio, registros, historial de despliegues) lo tiene el dueño.
- **Comprobar un despliegue:** tras el push, espera alrededor de 1 minuto y descarga la página publicada (por ejemplo, `curl -s "https://michuletario.com/vacunas/?t=1"`) para buscar el cambio. Si no aparece, vuelve a intentarlo cada 15 segundos durante unos minutos.
- **Deshacer una publicación:** `git revert <commit>` y push a `main`. Nunca uses push forzado.
- Para probar en local antes de publicar, sirve la carpeta con `python -m http.server` y ábrela en el navegador. `vacunas/index.html` no se regenera hasta que se ejecuta el script: para probar cambios de vacunas, genera una copia temporal envolviendo `vacunas/src/herramienta.html` y bórrala después.

## Qué hay en el repositorio

| Ruta | Qué es | ¿Se puede editar? |
|---|---|---|
| `index.html` | Calculadora de riesgo cardiovascular de gonzalom90-collab, con el menú lateral del chuletario | **No**, salvo petición expresa |
| `wrangler.jsonc` | Configuración de Cloudflare Workers (ver "Cómo se despliega la web") | No |
| `.assetsignore` | Archivos que NO se publican en la web (instrucciones, scripts, fuentes) | Sí, con cuidado |
| `vacunas/src/herramienta.html` | **Fuente única** de la herramienta de vacunas. Es un fragmento HTML sin `<!doctype>`, porque también se publica como Claude Artifact | **Sí: aquí se hacen todos los cambios** |
| `vacunas/index.html` | Página web completa **generada** por el script a partir de la fuente | **Nunca a mano** |
| `vacunas/imagenes/`, `vacunas/mpox/` | Copias sueltas de recursos (las imágenes ya van incrustadas en base64 dentro de la herramienta) | Sí |
| `vacunas/docs/` | PDF para pacientes enlazados desde la herramienta con su URL absoluta de Cloudflare (p. ej. `vacunacion-viajero-pacientes.pdf`) | Regenerar desde su fuente |
| `vacunas/src/viajero-pacientes.html` | Fuente del PDF del viajero. Se imprime a PDF con Edge headless (`--print-to-pdf --no-pdf-header-footer`) | Sí |
| `scripts/publicar-vacunas.ps1` | Genera `vacunas/index.html`, copia a Documentos, hace commit y push (y, con el push, publica la web) | Sí |

## Reglas de contenido (obligatorias)

1. **No inventar nada ni usar fuentes externas sin permiso de Almudena.** Ella lo pidió expresamente. Solo vale lo que esté en sus documentos o lo que ella escriba o envíe (capturas, notas).
2. Si un dato viene de fuera (por ejemplo, nombres comerciales o enlaces a CIMA), dilo claramente.
3. Si ves una discrepancia entre fuentes o con lo que ella dice, **señálala y pregunta**; no corrijas por tu cuenta.
4. Al cambiar contenido, actualiza la fecha **"Última actualización de la herramienta"** de la pantalla de inicio, y la lista de documentos fuente si añades uno.
5. La pantalla de inicio lleva un **aviso** legal redactado por ella: no lo cambies sin que lo pida.
6. **Todo cambio termina subido a GitHub** (y, por tanto, publicado en la web). Que ella pida un cambio ya incluye publicarlo: no lo dejes solo en local ni le preguntes si lo subes. Pruébalo bien antes, porque el push cambia la web pública al momento. Si algo es dudoso (contenido, discrepancias, cambios en la calculadora de gonzalom90-collab), pregunta **antes de hacer el cambio**, no antes de subirlo.

Documentos fuente, en `C:\Users\almud\Documents\1 Trabajo\Teoría y artículos\Vacunas\`:

- `BVCM051747.pdf`: Calendario de vacunación e inmunización para toda la vida 2026 (CM). Los anexos II y III son las tablas de grupos de riesgo de "Situaciones especiales".
- `GRUPOS DE POBLACIÓN DIANA DE VACUNACIÓN ANTIGRIPAL_2026-27.pdf`
- `doc-tecnico-vacunacion-covid-19-temporada-2026-2027.pdf`
- Calendario acelerado de vacunación 2026 (CM, febrero 2026), usado en "Ups, sin registros previos".
- Para leer las tablas de los PDF, renderiza las páginas como imagen (PyMuPDF): la extracción de texto desordena las columnas.

## Flujo para CUALQUIER cambio en la herramienta de vacunas

1. Trae lo último: `git pull --rebase --autostash origin main` en `C:\Users\almud\Documents\1 Trabajo\Proyecto Web\michuletario`.
2. **Comprueba el Artifact.** Lee el Artifact (`Artifact` → `read`, URL abajo). Si tiene una versión más nueva que `vacunas/src/herramienta.html` (por ejemplo, la cambió otra sesión o un comentario), fusiona primero esos cambios en la fuente.
3. Edita **solo** `vacunas/src/herramienta.html`.
4. Prueba en un navegador sobre una copia temporal (ver "Cómo se despliega la web"). Revisa sobre todo las vistas que has tocado, también en tamaño móvil.
5. Publica el Artifact con `Artifact` → `publish`:
   - `file_path`: `C:\Users\almud\Documents\1 Trabajo\Proyecto Web\michuletario\vacunas\src\herramienta.html`
   - `url`: `https://claude.ai/artifact/YWdbu2WqM6hCGapt79ZhxK`. **Pásala siempre**; sin ella se crea un artifact nuevo.
   - Si lo rechaza porque hay una versión más nueva, fusiona esa versión en la fuente y vuelve a publicar. Nunca sobrescribas.
6. Sube a GitHub con el script, desde la carpeta del repo:
   ```
   powershell -ExecutionPolicy Bypass -File scripts/publicar-vacunas.ps1 -Mensaje "Describe el cambio en una frase"
   ```
   El script genera `vacunas/index.html`, actualiza la copia de Documentos (`...\Vacunas\Herramienta de consulta de vacunas\`) y hace commit y push de `vacunas/`. Con el push, Cloudflare publica la web.
7. Cambios fuera de `vacunas/` (este archivo, `index.html`, `.assetsignore`, el script…): commit y push con git normal, con un mensaje claro.
8. Comprueba que el cambio ya se ve en https://michuletario.com/vacunas/.
9. Cuéntale a Almudena qué ha cambiado, en lenguaje sencillo, con el enlace al Artifact.

**El Artifact y GitHub deben quedar siempre iguales.** No dejes uno publicado sin el otro.

## Comentarios en el Artifact

Almudena deja peticiones como comentarios en el Artifact. Léelos con `ArtifactComments`, haz el cambio siguiendo el flujo anterior, responde en el hilo diciendo qué has hecho y resuélvelo.

## Enlaces

- Web: https://michuletario.com/ (calculadora RCV) y https://michuletario.com/vacunas/ (vacunas). También en https://michuletario.gonzalom-90.workers.dev/
- Repositorio: https://github.com/gonzalom90-collab/michuletario
- Artifact (versión con inicio de sesión en Claude): https://claude.ai/artifact/YWdbu2WqM6hCGapt79ZhxK
- Copia sin conexión para Almudena: `C:\Users\almud\Documents\1 Trabajo\Teoría y artículos\Vacunas\Herramienta de consulta de vacunas\`
