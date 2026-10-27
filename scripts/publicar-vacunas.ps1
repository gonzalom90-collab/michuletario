<#
  Publica la herramienta de vacunas en GitHub (repo michuletario).

  Uso (desde la carpeta del repositorio):
    powershell -ExecutionPolicy Bypass -File scripts/publicar-vacunas.ps1 -Mensaje "Describe el cambio"
  Opciones:
    -SinSubir   Genera y copia a Documentos, pero no hace commit ni push.

  Pasos:
    1. Trae lo ultimo de GitHub (git pull --rebase --autostash).
    2. Genera vacunas/index.html a partir de vacunas/src/herramienta.html.
    3. Copia la herramienta a la carpeta de Documentos de Almudena.
    4. Hace commit de la carpeta vacunas/ y lo sube (push) a main.

  El Claude Artifact NO se publica desde aqui: lo hace Claude con su herramienta
  Artifact (ver AGENTS.md).
#>
param(
  [string]$Mensaje = "Actualiza la herramienta de vacunas",
  [switch]$SinSubir
)

$ErrorActionPreference = 'Stop'
$utf8 = New-Object System.Text.UTF8Encoding $false
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

function Assert-Ok([string]$paso) {
  if ($LASTEXITCODE -ne 0) { throw "Fallo en: $paso" }
}

Write-Host "1/4 Trayendo lo ultimo de GitHub..."
git pull --rebase --autostash origin main; Assert-Ok 'git pull'

Write-Host "2/4 Generando vacunas/index.html..."
$srcPath = Join-Path $repo 'vacunas\src\herramienta.html'
$frag = [IO.File]::ReadAllText($srcPath, $utf8)
if ($frag -match '(?i)<!doctype') {
  throw "vacunas/src/herramienta.html debe ser un fragmento sin <!doctype> (es la fuente del Artifact)."
}
$cabecera = @"
<!doctype html>
<html lang="es">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<style>:root{color-scheme:light}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>
</head>
<body>
<!-- GENERADO AUTOMATICAMENTE desde vacunas/src/herramienta.html por scripts/publicar-vacunas.ps1. NO EDITAR ESTE ARCHIVO. -->
"@
$html = $cabecera + "`n" + $frag.TrimEnd() + "`n</body>`n</html>`n"
[IO.File]::WriteAllText((Join-Path $repo 'vacunas\index.html'), $html, $utf8)

Write-Host "3/4 Copiando a Documentos..."
$doc = Join-Path $env:USERPROFILE ("Documents\1 Trabajo\Teor" + [char]0xED + "a y art" + [char]0xED + "culos\Vacunas\Herramienta de consulta de vacunas")
New-Item -ItemType Directory -Force -Path $doc, (Join-Path $doc 'imagenes'), (Join-Path $doc 'mpox') | Out-Null
Copy-Item (Join-Path $repo 'vacunas\index.html') (Join-Path $doc 'vacunas-cm-2026.html') -Force
Copy-Item (Join-Path $repo 'vacunas\imagenes\*') (Join-Path $doc 'imagenes') -Force
Copy-Item (Join-Path $repo 'vacunas\mpox\*') (Join-Path $doc 'mpox') -Force
if (Test-Path (Join-Path $repo 'vacunas\docs')) {
  New-Item -ItemType Directory -Force -Path (Join-Path $doc 'docs') | Out-Null
  Copy-Item (Join-Path $repo 'vacunas\docs\*') (Join-Path $doc 'docs') -Force
}
$leeme = Join-Path $doc 'LEEME.txt'
if (Test-Path $leeme) {
  $t = [IO.File]::ReadAllText($leeme, $utf8)
  $t = [regex]::Replace($t, 'Copia guardada el [^\r\n]*', ('Copia guardada el ' + (Get-Date -Format 'dd/MM/yyyy') + ' desde GitHub (michuletario/vacunas).'))
  [IO.File]::WriteAllText($leeme, $t, $utf8)
}

if ($SinSubir) {
  Write-Host "Hecho (sin subir a GitHub)."
  exit 0
}

Write-Host "4/4 Subiendo a GitHub..."
git add vacunas; Assert-Ok 'git add'
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  Write-Host "No hay cambios en vacunas/ que subir."
  exit 0
}
git commit -m $Mensaje; Assert-Ok 'git commit'
git push origin main; Assert-Ok 'git push'
$sha = (& git rev-parse --short HEAD)
Write-Host "Publicado en GitHub: commit $sha"
Write-Host "https://github.com/gonzalom90-collab/michuletario/tree/main/vacunas"
