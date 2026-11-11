"""Home focus: blur Home around the untouched Mimi button, plus the
"Tu asistente bancario" bubble that points at it.

Both belong to Home's layer: when Mimi's sheet slides up (frame
`sheet_frame`), the bubble is behind it and the blur only continues, fading,
on the part of Home still visible above the sheet.
"""

from __future__ import annotations

import math
from functools import lru_cache
from typing import Any

import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFilter

from . import graphics as g
from .card import Graphic, draw_icon, surface, title_face
from .motion import ease_in_out_sine, ease_out_cubic


def render_bubble(text: str, style: dict[str, Any]) -> Graphic:
    """A one-line Mimi card, ✦ icon and title, with a tail pointing at the button.

    Icon, text, surface, border, radius, shadow and padding are the feature
    cards' own (`style["card"]`); only the tail is specific to the bubble.
    The outline is built geometrically (outer shape minus the same shape
    inset by the border width), so it is equally thick along the straight
    edges, the rounded corners and both sides of the tail.
    """
    s = style["supersample"]
    card, spec = style["card"], style["bubble"]
    face = title_face(style)
    cap = round(card["title_size"] * 0.727)
    h = max(2 * card["padding_y"] + cap, card["icon_diameter"] + 2 * spec["icon_inset_y"])
    text_x = card["padding_x"] + card["icon_diameter"] + card["icon_gap"]
    body_w = text_x + round(face.getlength(text) / s) + card["padding_x"]
    width = body_w + spec["tail_width"]
    margin = card["shadow"]["blur"] * 2 + card["shadow"]["offset_y"]
    size = ((width + 2 * margin) * s, (h + 2 * margin) * s)
    ox, oy = margin * s, margin * s
    radius, bw = card["radius"] * s, card["border_width"] * s

    # The tail: an isosceles triangle from the tip back into the body, whose
    # sides cross the body's straight right edge `tail_height` apart.
    tip_x, mid = ox + width * s, oy + h * s / 2
    slope = (spec["tail_height"] / 2) / spec["tail_width"]
    base_x = ox + (body_w - spec["tail_depth"]) * s

    def tail(tip: float) -> list[tuple[float, float]]:
        half = slope * (tip - base_x)
        return [(base_x, mid - half), (tip, mid), (base_x, mid + half)]

    def body(inset: float) -> tuple[float, float, float, float]:
        return (ox + inset, oy + inset, ox + body_w * s - 1 - inset, oy + h * s - 1 - inset)

    outer = Image.new("L", size, 0)
    draw = ImageDraw.Draw(outer)
    draw.rounded_rectangle(body(0), radius=radius, fill=255)
    draw.polygon(tail(tip_x), fill=255)

    inner = Image.new("L", size, 0)
    draw = ImageDraw.Draw(inner)
    draw.rounded_rectangle(body(bw), radius=radius - bw, fill=255)
    # Moving each side of the tail inward by `bw` pulls its tip back by bw / sin(half-angle).
    draw.polygon(tail(tip_x - bw * math.hypot(1, slope) / slope), fill=255)

    border = ImageChops.subtract(outer, inner)
    layer = surface(outer, style, border)
    draw_icon(layer, ox + (card["padding_x"] + card["icon_diameter"] / 2) * s, mid, style)
    baseline = mid + cap * s / 2
    g.draw_text(layer, (ox + text_x * s, baseline), text, face, g.rgb(style["colors"]["textPrimary"]))
    return Graphic(g.downsample(layer, s), margin, margin, width, h)


def button_body(size: tuple[int, int], button: dict[str, int], grow: int = 0) -> np.ndarray:
    """Boolean mask of the button's own rounded body, grown by `grow` px."""
    x0, y0 = button["x"] - grow, button["y"] - grow
    x1, y1 = button["x"] + button["w"] + grow, button["y"] + button["h"] + grow
    body = Image.new("L", size, 0)
    ImageDraw.Draw(body).rounded_rectangle((x0, y0, x1, y1), radius=(y1 - y0) // 2, fill=255)
    return np.asarray(body) > 0


def button_mask(size: tuple[int, int], button: dict[str, int], style: dict[str, Any]) -> np.ndarray:
    """1 over the button and the full reach of its glow (kept sharp), 0
    elsewhere. The feathered edge lies where the glow has already faded into
    the smooth background, so the transition has nothing to reveal."""
    focus = style["home_focus"]
    pad = focus["keep_padding"]
    x0, y0 = button["x"] - pad["left"], button["y"] - pad["top"]
    x1, y1 = button["x"] + button["w"] + pad["right"], button["y"] + button["h"] + pad["bottom"]
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((x0, y0, x1, y1), radius=(y1 - y0) // 2, fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(focus["mask_feather"]))
    return np.asarray(mask, np.float32)[..., None] / 255.0


@lru_cache(maxsize=4)
def _dim_ramp(shape: tuple[int, int], box: tuple[int, int, int, int], falloff: tuple[int, int]) -> np.ndarray:
    h, w = shape
    x0, y0, x1, y1 = box
    xs = np.arange(w, dtype=np.float32)[None, :]
    ys = np.arange(h, dtype=np.float32)[:, None]
    dx = np.maximum(np.maximum(x0 - xs, xs - x1), 0)
    dy = np.maximum(np.maximum(y0 - ys, ys - y1), 0)
    t = np.clip((np.hypot(dx, dy) - falloff[0]) / (falloff[1] - falloff[0]), 0, 1)
    return (t * t * (3 - 2 * t))[..., None]  # smoothstep


def dim_ramp(shape: tuple[int, int], button: dict[str, int], falloff: tuple[int, int]) -> np.ndarray:
    """0 at the button rising smoothly to 1 at `falloff[1]` px away from it."""
    box = (button["x"], button["y"], button["x"] + button["w"], button["y"] + button["h"])
    return _dim_ramp(shape, box, falloff)


def focus_amount(rel: int, src: int, timeline: dict[str, Any]) -> float:
    """0..1 strength of the focus effect.

    `rel` counts output frames since Home appeared (holds included), so the
    build-up is unhurried; `src` is the recording's frame, which decides when
    the real sheet arrives and the effect releases.
    """
    home = timeline["home_focus"]
    if src >= home["sheet_frame"]:
        if src > home["blur_out_end"]:
            return 0.0
        span = home["blur_out_end"] - home["sheet_frame"] + 1
        return 1.0 - ease_out_cubic((src - home["sheet_frame"] + 1) / span)
    start, full = home["blur_in"]
    if rel < start:
        return 0.0
    return float(ease_in_out_sine((rel - start) / (full - start)))


def apply_focus(frame_rgb: np.ndarray, rel: int, src: int, timeline: dict[str, Any], style: dict[str, Any], keep: np.ndarray) -> np.ndarray:
    """Blur and gently dim Home except the button region `keep`."""
    amount = focus_amount(rel, src, timeline)
    if amount <= 0:
        return frame_rgb
    focus = style["home_focus"]
    home = timeline["home_focus"]
    image = Image.fromarray(frame_rgb)
    blurred = np.asarray(image.filter(ImageFilter.GaussianBlur(focus["blur_radius"] * amount)), np.float32)
    sharp = frame_rgb.astype(np.float32)
    # Dimming fades in very gradually with distance from the button, so it
    # never draws an edge or a lighter halo around the sharp area.
    blurred *= 1 - focus["dim"] * amount * dim_ramp(sharp.shape[:2], home["button"], tuple(focus["dim_falloff"]))

    weight = 1 - keep  # where the blur applies
    if src >= home["sheet_frame"]:
        # Only on Home above the sheet: fade the effect out toward its edge.
        top = home["sheet_top"][str(src)] - focus["sheet_clearance"]
        rows = np.arange(sharp.shape[0], dtype=np.float32)[:, None, None]
        weight = weight * np.clip((top - rows) / focus["sheet_feather"], 0, 1)
    out = sharp + (blurred - sharp) * weight
    return (out + 0.5).clip(0, 255).astype(np.uint8)


def bubble_state(rel: int, src: int, timeline: dict[str, Any], style: dict[str, Any]) -> tuple[float, float] | None:
    """(opacity, horizontal offset) of the bubble, or None once the sheet covers it."""
    home = timeline["home_focus"]
    start, full = home["bubble"]["enter"]
    if rel < start or src >= home["sheet_frame"]:
        return None
    t = ease_out_cubic((rel - start + 1) / (full - start + 1))
    return t, (1 - t) * style["bubble"]["enter_offset_x"]


def bubble_origin(bubble: Graphic, timeline: dict[str, Any], style: dict[str, Any]) -> tuple[int, int]:
    """Top-left of the bubble image so its tail tip points at the button."""
    button = timeline["home_focus"]["button"]
    tip_x = button["x"] - style["bubble"]["gap_to_button"]
    center_y = button["y"] + button["h"] / 2
    return round(tip_x - bubble.width - bubble.origin_x), round(center_y - bubble.height / 2 - bubble.origin_y)
