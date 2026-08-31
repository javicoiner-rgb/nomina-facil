#!/usr/bin/env python3
"""Genera el icono "legacy" (mipmap ic_launcher.png) sólido, sin capas
adaptativas ni transparencia.

Por qué: `flutter_launcher_icons` escribe en los mipmaps una copia RGBA
de `assets/icon/app_icon.png`, que tiene las esquinas transparentes (el
fondo es un rectángulo redondeado sobre lienzo transparente). En launchers
que no respetan el icono adaptativo (p. ej. MIUI/Xiaomi), esa transparencia
hace que el icono se vea vacío o mal recortado.

Este script aplana `app_icon.png` sobre su propio color de fondo de marca,
descarta el canal alfa y sobrescribe los `ic_launcher.png` de cada
densidad con una versión opaca de borde a borde.

Uso: python3 tool/generate_legacy_icon.py
Ejecutar después de `dart run flutter_launcher_icons` cada vez que se
regenere el icono.
"""

from __future__ import annotations

import os
from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), os.pardir)
SOURCE = os.path.normpath(os.path.join(ROOT, "assets", "icon", "app_icon.png"))
BG_COLOR = (0, 200, 150)  # #00C896, igual que el fondo del icono adaptativo

MIPMAP_SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

RES_DIR = os.path.normpath(
    os.path.join(ROOT, "android", "app", "src", "main", "res")
)


def flatten_opaque(img: Image.Image) -> Image.Image:
    """Aplana [img] (RGBA) sobre un lienzo opaco del color de marca."""
    background = Image.new("RGB", img.size, BG_COLOR)
    background.paste(img, mask=img.split()[3])
    return background


def main() -> None:
    master = Image.open(SOURCE).convert("RGBA")
    flat = flatten_opaque(master)

    for folder, size in MIPMAP_SIZES.items():
        out = flat.resize((size, size), Image.LANCZOS)
        path = os.path.join(RES_DIR, folder, "ic_launcher.png")
        out.save(path, "PNG")
        print(f"  {path}  ({size}x{size}, opaco)")

    print("Icono legacy sólido generado.")


if __name__ == "__main__":
    main()
