# opencode-canvas-design-skill

[![CI](https://github.com/MaxiGP0/opencode-canvas-design-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/MaxiGP0/opencode-canvas-design-skill/actions/workflows/ci.yml)

[English](README.md) | [Español](README.es.md)

Instalador de un solo comando que deja disponible en [OpenCode](https://opencode.ai) el skill **[canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design)** de Anthropic.

El skill original documenta su uso con Claude Code, Claude.ai y la API. OpenCode descubre los skills globales en `~/.config/opencode/skills/<nombre>/`, así que este repositorio agrega un instalador y un verificador para esa ruta. **Descarga el skill desde el repositorio oficial al instalar**; no lo reempaqueta, no lo modifica y no aloja sus fuentes.

> Este es un instalador no oficial. No está afiliado a Anthropic.

## Qué hace el skill

El skill canvas-design hace que OpenCode produzca arte visual original en lugar de layouts genéricos. Trabaja en dos pasos:

1. Escribe una filosofía de diseño breve (un movimiento estético, no una plantilla) como archivo `.md`.
2. Expresa esa filosofía en un lienzo único, exportado como `.pdf` o `.png`: composición fuerte, tipografía contenida, paleta limitada y una atención al detalle de nivel museo.

Está pensado para pósters, portadas, arte editorial, portadas de discos, invitaciones y otras piezas de diseño estático. La referencia conceptual al tema del usuario se integra en la obra de forma sutil, sin explicarla literalmente.

El repositorio original incluye:

- `SKILL.md` con el método de diseño completo.
- `LICENSE.txt` (Apache License 2.0).
- `canvas-fonts/` con **54 archivos de fuente TTF** y sus licencias OFL (81 archivos en total), para que el skill use tipografías reales en lugar de las fuentes del sistema.

## Requisitos

- [OpenCode](https://opencode.ai) con soporte de skills.
- **Windows:** PowerShell 5.1 o superior (viene con Windows 10/11). Las versiones actuales de Windows incluyen `tar.exe`; si falta, el instalador usa automáticamente el archivo ZIP y `Expand-Archive`.
- **macOS / Linux:** `bash`, `curl` y `tar`.
- **Opcional:** Python 3 con una librería para PDF/PNG (por ejemplo Pillow o ReportLab), o cualquier otra herramienta de generación de PDF/PNG, para renderizar la obra que diseña el skill. Las fuentes incluidas quedan listas para usar. Para instalar el skill no hace falta nada más que el instalador.

## Instalación

### Windows (PowerShell)

Descargá, revisá y ejecutá:

```powershell
Invoke-WebRequest https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 -OutFile install.ps1
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

O ejecutalo directamente:

```powershell
irm https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 | iex
```

Para actualizar:

```powershell
# Si guardaste install.ps1:
.\install.ps1 -Force

# O sin guardarlo:
$env:CANVAS_DESIGN_FORCE=1; irm https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.ps1 | iex
```

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh | bash
```

Para actualizar:

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh | bash -s -- --force
```

Si preferís leer el script antes:

```bash
curl -fsSL https://raw.githubusercontent.com/MaxiGP0/opencode-canvas-design-skill/main/install.sh -o install.sh
bash install.sh
```

### Opciones

| PowerShell | Bash | Descripción |
| --- | --- | --- |
| `-SkillDir PATH` | `--dir PATH` | Raíz de skills de OpenCode. Por defecto: `~/.config/opencode/skills` |
| `-Ref REF` | `--ref REF` | Rama, tag o commit del repo original. Por defecto: `main` |
| `-Force` | `--force` | Reemplaza una instalación existente |

También funcionan las variables de entorno `OPENCODE_SKILLS_DIR`, `CANVAS_DESIGN_REF` y `CANVAS_DESIGN_FORCE=1`.

El skill se instala en:

- Windows: `%USERPROFILE%\.config\opencode\skills\canvas-design`
- macOS / Linux: `~/.config/opencode/skills/canvas-design`

La instalación contiene `SKILL.md`, `LICENSE.txt` y la carpeta completa `canvas-fonts/`. Los archivos de fuente se copian como datos binarios, byte por byte.

## Verificar la instalación

```powershell
.\verify.ps1
```

```bash
bash verify.sh
```

El verificador comprueba que exista `SKILL.md`, que su frontmatter tenga `name: canvas-design` y una descripción no vacía, que exista `LICENSE.txt` y que `canvas-fonts/` contenga al menos 50 archivos TTF.

O comprobá a mano:

```bash
ls ~/.config/opencode/skills/canvas-design/SKILL.md
```

Después de instalar, **abrí una sesión nueva de OpenCode** para que tome el skill.

## Cómo usarlo

Solo pedí una pieza visual. El skill se activa automáticamente:

- *"Design a print-ready poster for a jazz festival in Lisbon."*
- *"Make a museum-quality cover about slow cities, exported as PDF."*
- *"Create an editorial illustration about deep time. Minimal text, limited palette."*
- *"Diseñá un póster para una obra de teatro sobre el silencio. Formato A2."*
- *"Here is my album concept. Turn it into cover art that feels meticulously crafted."*

Pedí un PDF o PNG y, si querés, el `.md` con la filosofía de diseño junto a la obra.

## Opcional: renderizar la obra

Las instrucciones del skill describen el diseño y el lienzo; la exportación final se hace con las herramientas disponibles en tu entorno. Un toolchain de Python 3 con Pillow o ReportLab es una opción habitual, y las fuentes incluidas se pueden referenciar directamente desde `canvas-fonts/`. Cualquier otra herramienta de generación de PDF/PNG, o un flujo HTML/SVG a PDF, también sirve. Este instalador no requiere ningún paso extra.

## Instalación manual

Si preferís no ejecutar un instalador:

```bash
git clone --depth 1 https://github.com/anthropics/skills.git
mkdir -p ~/.config/opencode/skills
cp -R skills/skills/canvas-design ~/.config/opencode/skills/
```

En Windows, reemplazá `~/.config/opencode/skills` por `%USERPROFILE%\.config\opencode\skills`.

## Actualizar y desinstalar

Actualizá volviendo a ejecutar el instalador con `-Force` / `--force`. Siempre baja la revisión actual del repositorio original, así que las actualizaciones llegan apenas Anthropic las publica.

Desinstalar:

```powershell
Remove-Item -Recurse -Force "$HOME\.config\opencode\skills\canvas-design"
```

```bash
rm -rf ~/.config/opencode/skills/canvas-design
```

## Cómo funciona

1. Descarga `https://codeload.github.com/anthropics/skills/tar.gz/<ref>` en un directorio temporal.
2. Extrae el archivo.
3. Busca `skills/canvas-design` y valida su `SKILL.md`, `LICENSE.txt` y las fuentes.
4. Copia todo el subárbol a la carpeta global de skills de OpenCode y revisa el resultado.

En este repositorio no se guarda una copia del skill: el instalador es un descargador fino más un verificador.

## Licencias y atribución

- **Este instalador:** MIT. Ver [LICENSE](LICENSE).
- **Skill canvas-design:** Apache License 2.0, Copyright Anthropic. Los términos completos están en el [LICENSE.txt](https://github.com/anthropics/skills/blob/main/skills/canvas-design/LICENSE.txt) original y se instalan junto al skill. Este repositorio no redistribuye el skill.
- **Fuentes:** cada fuente incluida conserva su propia licencia dentro de `canvas-fonts/` (los archivos OFL que distribuye el repositorio original). Revisá esos archivos antes de redistribuir o incrustar una fuente.
- **Anthropic y Claude:** los nombres y las marcas pertenecen a Anthropic, PBC. Este proyecto es no oficial y no está afiliado a Anthropic.

Ver [NOTICE](NOTICE) para el resumen de atribución.

Si el skill te resulta útil, dale una estrella al repositorio original: [anthropics/skills](https://github.com/anthropics/skills).

## Solución de problemas

**El skill no aparece en OpenCode.** Confirmá la ruta con `verify.ps1` / `verify.sh` y abrí una sesión nueva. OpenCode lee la carpeta de skills al iniciar la sesión.

**PowerShell bloquea el script.** Usá `powershell -ExecutionPolicy Bypass -File .\install.ps1`.

**Falta `tar` en Windows.** Windows 10/11 actual incluye `tar.exe`. Si el tuyo no lo tiene, el instalador descarga automáticamente el ZIP y usa `Expand-Archive` de PowerShell.

**Falta `curl` en Linux.** Instalalo (`sudo apt install curl`, `sudo dnf install curl` o el equivalente de tu distribución).

**La descarga falla.** El instalador necesita acceso a `github.com` y `codeload.github.com`. Revisá el proxy o el firewall.

**El verificador informa pocas fuentes.** La descarga quedó incompleta o hay una copia vieja. Volvé a ejecutar el instalador con `-Force` / `--force`.

**No hay herramienta para PDF/PNG.** Instalá Python 3 con Pillow o ReportLab, usá la exportación del navegador o cualquier otro renderizador que ya tengas. El skill solo necesita una forma de producir el archivo final.
