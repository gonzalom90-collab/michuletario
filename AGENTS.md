# michuletario — instrucciones para agentes (Claude y otros)

Léelo entero antes de tocar nada. Si algo de aquí no cuadra con lo que ves, pregunta a la usuaria antes de actuar.

## Personas y cuentas

- **Dueño del repositorio:** `gonzalom90-collab`.
- **Almudena** (cuenta GitHub `IceBubbleChezz`): colaboradora con permiso de escritura. Gestora de centro de salud, **sin conocimientos informáticos**: háblale en lenguaje sencillo, sin jerga, y explica qué ha cambiado en términos de la herramienta, no del código.
- En su PC: `git` y GitHub CLI (`C:\Program Files\GitHub CLI\gh.exe`) instalados; git usa la sesión de `gh` (`gh auth setup-git`). Identidad de commits configurada solo en este repo: `Almudena (IceBubbleChezz) <344986998+IceBubbleChezz@users.noreply.github.com>`.
- Copia local del repo: `C:\Users\almud\claude-code\michuletario`.

## Qué hay en el repositorio

| Ruta | Qué es | ¿Se puede editar? |
|---|---|---|
| `index.html` | Dashboard RCV (SCORE2…), calculadora de riesgo cardiovascular de gonzalom90-collab | **No**, salvo petición expresa |
| `wrangler.jsonc` | Despliegue en Cloudflare Workers (`assets.directory = "."`): **cada push a `main` publica la web** | No |
| `.assetsignore` | Archivos que NO se publican en la web (instrucciones, scripts, fuentes) | Sí, con cuidado |
| `vacunas/src/herramienta.html` | **Fuente única** de la herramienta de vacunas. Es un fragmento HTML sin `<!doctype>`, porque también se publica como Claude Artifact | **Sí: aquí se hacen todos los cambios** |
| `vacunas/index.html` | Página web completa **generada** por el script a partir de la fuente | **Nunca a mano** |
| `vacunas/imagenes/`, `vacunas/mpox/` | Copias sueltas de recursos (las imágenes ya van incrustadas en base64 dentro de la herramienta) | Sí |
| `scripts/publicar-vacunas.ps1` | Genera `vacunas/index.html`, copia a Documentos, hace commit y push | Sí |

La herramienta de vacunas se ve en la web de Cloudflare de este repo, en la ruta `/vacunas/`.

## Reglas de contenido (obligatorias)

1. **No inventar nada ni usar fuentes externas sin permiso de Almudena.** Ella lo pidió expresamente. Solo vale lo que esté en sus documentos o lo que ella escriba o envíe (capturas, notas).
2. Si un dato viene de fuera (por ejemplo, nombres comerciales o enlaces a CIMA), dilo claramente.
3. Si ves una discrepancia entre fuentes o con lo que ella dice, **señálala y pregunta**; no corrijas por tu cuenta.
4. Al cambiar contenido, actualiza la fecha **"Última actualización de la herramienta"** de la pantalla de inicio, y la lista de documentos fuente si añades uno.
5. La pantalla de inicio lleva un **aviso** legal redactado por ella: no lo cambies sin que lo pida.

Documentos fuente, en `C:\Users\almud\Documents\1 Trabajo\Teoría y artículos\Vacunas\`:

- `BVCM051747.pdf`: Calendario de vacunación e inmunización para toda la vida 2026 (CM). Los anexos II y III son las tablas de grupos de riesgo de "Situaciones especiales".
- `GRUPOS DE POBLACIÓN DIANA DE VACUNACIÓN ANTIGRIPAL_2026-27.pdf`
- `doc-tecnico-vacunacion-covid-19-temporada-2026-2027.pdf`
- Calendario acelerado de vacunación 2026 (CM, febrero 2026), usado en "Ups, sin registros previos".
- Para leer las tablas de los PDF, renderiza las páginas como imagen (PyMuPDF): la extracción de texto desordena las columnas.

## Flujo para CUALQUIER cambio en la herramienta de vacunas

1. Trae lo último: `git pull --rebase --autostash origin main` en `C:\Users\almud\claude-code\michuletario`.
2. **Comprueba el Artifact.** Lee el Artifact (`Artifact` → `read`, URL abajo). Si tiene una versión más nueva que `vacunas/src/herramienta.html` (por ejemplo, la cambió otra sesión o un comentario), fusiona primero esos cambios en la fuente.
3. Edita **solo** `vacunas/src/herramienta.html`.
4. Prueba en un navegador (por ejemplo, Edge en modo headless sobre una copia temporal). Revisa sobre todo las vistas que has tocado.
5. Publica el Artifact con `Artifact` → `publish`:
   - `file_path`: `C:\Users\almud\claude-code\michuletario\vacunas\src\herramienta.html`
   - `url`: `https://claude.ai/artifact/YWdbu2WqM6hCGapt79ZhxK`. **Pásala siempre**; sin ella se crea un artifact nuevo.
   - Si lo rechaza porque hay una versión más nueva, fusiona esa versión en la fuente y vuelve a publicar. Nunca sobrescribas.
6. Sube a GitHub con el script:
   ```
   powershell -ExecutionPolicy Bypass -File scripts/publicar-vacunas.ps1 -Mensaje "Describe el cambio en una frase"
   ```
   El script genera `vacunas/index.html`, actualiza la copia de Documentos (`...\Vacunas\Herramienta de consulta de vacunas\`) y hace commit y push de `vacunas/`.
7. Cambios fuera de `vacunas/` (este archivo, `.assetsignore`, el script…): commit y push con git normal, con un mensaje claro.
8. Cuéntale a Almudena qué ha cambiado, en lenguaje sencillo, con el enlace al Artifact.

**El Artifact y GitHub deben quedar siempre iguales.** No dejes uno publicado sin el otro.

## Comentarios en el Artifact

Almudena deja peticiones como comentarios en el Artifact. Léelos con `ArtifactComments`, haz el cambio siguiendo el flujo anterior, responde en el hilo diciendo qué has hecho y resuélvelo.

## Enlaces

- Repositorio: https://github.com/gonzalom90-collab/michuletario
- Artifact (versión con inicio de sesión en Claude): https://claude.ai/artifact/YWdbu2WqM6hCGapt79ZhxK
- Copia sin conexión para Almudena: `C:\Users\almud\Documents\1 Trabajo\Teoría y artículos\Vacunas\Herramienta de consulta de vacunas\`
