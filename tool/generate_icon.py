#!/usr/bin/env python3
"""Genera el icono de la app Nómina Fácil y sus variantes de tamaño.

Uso:  python3 tool/generate_icon.py
Requiere: Pillow  (pip install Pillow)

Diseño (referido a un lienzo de 1024x1024):
  - Fondo #00C896 con esquinas redondeadas (radio 180).
  - Círculo blanco centrado, radio 380.
  - Símbolo "€" en #00C896, negrita, tamaño ~420, centrado ópticamente.

El maestro se renderiza a 4x (4096x4096) y se reduce con LANCZOS para
obtener bordes suaves en todos los tamaños.
"""

from __future__ import annotations

import os
from PIL import Image, ImageDraw, ImageFont

# --- Parámetros de diseño (base 1024) --------------------------------------
BASE = 1024
BG_COLOR = (0, 200, 150, 255)        # #00C896
CIRCLE_COLOR = (255, 255, 255, 255)  # blanco
GLYPH_COLOR = (0, 200, 150, 255)     # #00C896
CIRCLE_RADIUS = 380
CORNER_RADIUS = 180
GLYPH = "€"                     # €
GLYPH_SIZE = 420

SUPERSAMPLE = 4
S = BASE * SUPERSAMPLE

OUT_DIR = os.path.join(os.path.dirname(__file__), os.pardir, "assets", "icon")
OUTPUTS = {
    "app_icon.png": 1024,
    "icon_512.png": 512,
    "icon_192.png": 192,
    "icon_48.png": 48,
}

# Primer plano para el icono adaptativo de Android: fondo transparente y
# el contenido reducido para caer dentro de la "safe zone" (~66 %).
FOREGROUND_NAME = "app_icon_foreground.png"
FOREGROUND_SIZE = 1024
FOREGROUND_SCALE = 0.60  # el círculo ocupa el 60 % del lienzo

# Fuentes negrita candidatas (con glifo €), en orden de preferencia.
FONT_CANDIDATES = [
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
    "/Library/Fonts/Arial Bold.ttf",
    "/System/Library/Fonts/Helvetica.ttc",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/System/Library/Fonts/SFNSRounded.ttf",
    "/System/Library/Fonts/SFNS.ttf",
    "DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
]


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for path in FONT_CANDIDATES:
        try:
            font = ImageFont.truetype(path, size)
            # Comprobar que la fuente tiene el glifo del euro.
            if font.getmask(GLYPH).getbbox() is not None:
                print(f"Fuente usada: {path}")
                return font
        except (OSError, ValueError):
            continue
    raise SystemExit(
        "No se encontró una fuente negrita con el símbolo €. "
        "Instala DejaVu o Arial Bold."
    )


def _draw_circle_and_glyph(draw: ImageDraw.ImageDraw, canvas: int,
                           circle_radius: float) -> None:
    """Dibuja el círculo blanco y el símbolo € centrados en un lienzo
    cuadrado de lado ``canvas`` con radio de círculo ``circle_radius``."""
    cx = cy = canvas / 2
    draw.ellipse(
        [cx - circle_radius, cy - circle_radius,
         cx + circle_radius, cy + circle_radius],
        fill=CIRCLE_COLOR,
    )

    # El glifo mantiene su proporción respecto al círculo (420 / 380).
    glyph_px = int(round(GLYPH_SIZE / CIRCLE_RADIUS * circle_radius))
    font = load_font(glyph_px)
    bbox = draw.textbbox((0, 0), GLYPH, font=font)
    gw = bbox[2] - bbox[0]
    gh = bbox[3] - bbox[1]
    draw.text(
        (cx - gw / 2 - bbox[0], cy - gh / 2 - bbox[1]),
        GLYPH, font=font, fill=GLYPH_COLOR,
    )


def render_master() -> Image.Image:
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Fondo con esquinas redondeadas.
    draw.rounded_rectangle(
        [0, 0, S - 1, S - 1],
        radius=CORNER_RADIUS * SUPERSAMPLE,
        fill=BG_COLOR,
    )

    _draw_circle_and_glyph(draw, S, CIRCLE_RADIUS * SUPERSAMPLE)
    return img


def render_foreground() -> Image.Image:
    """Primer plano transparente para el icono adaptativo de Android."""
    size = FOREGROUND_SIZE * SUPERSAMPLE
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    radius = size / 2 * FOREGROUND_SCALE
    _draw_circle_and_glyph(draw, size, radius)
    return img.resize((FOREGROUND_SIZE, FOREGROUND_SIZE), Image.LANCZOS)


def main() -> None:
    os.makedirs(OUT_DIR, exist_ok=True)
    master = render_master()

    for name, size in OUTPUTS.items():
        out = master.resize((size, size), Image.LANCZOS)
        path = os.path.normpath(os.path.join(OUT_DIR, name))
        out.save(path, "PNG")
        print(f"  {path}  ({size}x{size})")

    fg_path = os.path.normpath(os.path.join(OUT_DIR, FOREGROUND_NAME))
    render_foreground().save(fg_path, "PNG")
    print(f"  {fg_path}  ({FOREGROUND_SIZE}x{FOREGROUND_SIZE}, adaptativo)")

    print("Icono generado.")


if __name__ == "__main__":
    main()
