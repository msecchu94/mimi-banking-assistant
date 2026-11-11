"""Drawing primitives shared by every overlay.

Overlays are drawn at `supersample` times their final size and reduced with
premultiplied-alpha resampling, so edges and text stay clean and free of
dark fringes.
"""

from __future__ import annotations

import math
from functools import lru_cache
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]


def rgb(hex_color: str) -> tuple[int, int, int]:
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


@lru_cache(maxsize=None)
def font(relative_path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(ROOT / relative_path), size)


def star_polygon(cx: float, cy: float, size: float, steps: int = 24) -> list[tuple[float, float]]:
    """The Mimi ✦: four points joined by concave curves, `size` tip to tip."""
    r = size / 2
    pull = 0.16 * r  # how far the sides curve in toward the center
    tips = [(0, -r), (r, 0), (0, r), (-r, 0)]
    points: list[tuple[float, float]] = []
    for i, (x0, y0) in enumerate(tips):
        x1, y1 = tips[(i + 1) % 4]
        # Quadratic curve between consecutive tips, controlled near the center.
        qx = math.copysign(pull, x0 + x1)
        qy = math.copysign(pull, y0 + y1)
        for s in range(steps):
            t = s / steps
            x = (1 - t) ** 2 * x0 + 2 * (1 - t) * t * qx + t**2 * x1
            y = (1 - t) ** 2 * y0 + 2 * (1 - t) * t * qy + t**2 * y1
            points.append((cx + x, cy + y))
    return points


def outline(mask: Image.Image, width: int) -> Image.Image:
    """The inner band of `mask`, `width` pixels wide, following its whole shape."""
    eroded = mask.filter(ImageFilter.MinFilter(2 * width + 1))
    return ImageChops.subtract(mask, eroded)


def solid(size: tuple[int, int], color: tuple[int, int, int], mask: Image.Image, alpha: float = 1.0) -> Image.Image:
    """`color` wherever `mask` is set, scaled by `alpha`."""
    layer = Image.new("RGBA", size, (*color, 0))
    layer.putalpha(mask.point(lambda v: round(v * alpha)))
    return layer


def shadow(mask: Image.Image, blur: float, offset_y: int, alpha: float) -> Image.Image:
    """A soft black shadow of `mask`, moved down by `offset_y`."""
    moved = Image.new("L", mask.size, 0)
    moved.paste(mask, (0, offset_y))
    soft = moved.filter(ImageFilter.GaussianBlur(blur))
    return solid(mask.size, (0, 0, 0), soft, alpha)


def diagonal_gradient(size: tuple[int, int], start: tuple[int, int, int], end: tuple[int, int, int]) -> Image.Image:
    """A top-left to bottom-right gradient, fully opaque."""
    w, h = size
    x = np.linspace(0, 1, w, dtype=np.float32)[None, :]
    y = np.linspace(0, 1, h, dtype=np.float32)[:, None]
    t = ((x * w + y * h) / (w + h))[..., None]
    pixels = (1 - t) * np.array(start, np.float32) + t * np.array(end, np.float32)
    alpha = np.full((h, w, 1), 255, np.float32)
    return Image.fromarray(np.concatenate([pixels, alpha], axis=2).round().astype(np.uint8), "RGBA")


def downsample(image: Image.Image, factor: int) -> Image.Image:
    """Reduce a supersampled RGBA image with premultiplied alpha."""
    w, h = image.size
    reduced = image.convert("RGBa").resize((w // factor, h // factor), Image.Resampling.LANCZOS)
    return reduced.convert("RGBA")


def draw_text(layer: Image.Image, xy: tuple[float, float], text: str, face: ImageFont.FreeTypeFont, color: tuple[int, int, int]) -> None:
    ImageDraw.Draw(layer).text(xy, text, font=face, fill=(*color, 255), anchor="ls")


def wrap(text: str, face: ImageFont.FreeTypeFont, max_width: float, max_lines: int) -> list[str]:
    """Explicit `\\n` breaks win; otherwise one line, or the most balanced two."""
    if "\n" in text:
        lines = text.split("\n")
        too_wide = [line for line in lines if face.getlength(line) > max_width]
        if len(lines) > max_lines or too_wide:
            raise ValueError(f"text does not fit in {max_lines} line(s): {text!r}")
        return lines
    words = text.split()
    if face.getlength(text) <= max_width:
        return [text]
    best: list[str] | None = None
    for split in range(1, len(words)):
        first, second = " ".join(words[:split]), " ".join(words[split:])
        if face.getlength(first) <= max_width and face.getlength(second) <= max_width:
            score = abs(face.getlength(first) - face.getlength(second))
            if best is None or score < abs(face.getlength(best[0]) - face.getlength(best[1])):
                best = [first, second]
    if best is None or max_lines < 2:
        raise ValueError(f"text does not fit in {max_lines} line(s): {text!r}")
    return best
