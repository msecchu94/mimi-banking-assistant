"""Easing, per-frame animation state and alpha compositing."""

from __future__ import annotations

from typing import Any

import numpy as np
from PIL import Image


def ease_out_cubic(t: float) -> float:
    t = min(max(t, 0.0), 1.0)
    return 1 - (1 - t) ** 3


def ease_in_cubic(t: float) -> float:
    t = min(max(t, 0.0), 1.0)
    return t**3


def ease_in_out_sine(t: float) -> float:
    t = min(max(t, 0.0), 1.0)
    return 0.5 - 0.5 * np.cos(np.pi * t)


def card_state(frame: int, start: int, end: int, motion: dict[str, Any]) -> tuple[float, float] | None:
    """(opacity, vertical offset in px) of a card at `frame`, or None when hidden."""
    if not start <= frame <= end:
        return None
    enter, leave = motion["enter_frames"], motion["exit_frames"]
    if frame < start + enter:
        # Frame `start` is the first visible step, so the card never pops in at full opacity.
        t = ease_out_cubic((frame - start + 1) / enter)
        return t, (1 - t) * motion["enter_offset_y"]
    if frame > end - leave:
        t = ease_in_cubic((frame - (end - leave)) / leave)
        return 1 - t, t * motion["exit_offset_y"]
    return 1.0, 0.0


def premultiplied(image: Image.Image) -> tuple[np.ndarray, np.ndarray]:
    """(premultiplied RGB, alpha) as float32 arrays in 0..1."""
    rgba = np.asarray(image, np.float32) / 255.0
    alpha = rgba[..., 3:4]
    return rgba[..., :3] * alpha, alpha


def composite(frame: np.ndarray, overlay: tuple[np.ndarray, np.ndarray], x: float, y: float, opacity: float) -> np.ndarray:
    """Place a premultiplied overlay at a sub-pixel position over an RGB frame.

    A fractional offset is rendered by blending the overlay at the two
    neighbouring whole-pixel positions, so slow movements stay smooth.
    """
    if opacity <= 0:
        return frame
    color, alpha = overlay
    h, w = alpha.shape[:2]
    out = frame.astype(np.float32) / 255.0
    ix, iy = int(np.floor(x)), int(np.floor(y))
    fx, fy = x - ix, y - iy
    # Pad by one pixel so both neighbouring placements fit in one region.
    padded_c = np.zeros((h + 1, w + 1, 3), np.float32)
    padded_a = np.zeros((h + 1, w + 1, 1), np.float32)
    c = np.zeros_like(padded_c)
    a = np.zeros_like(padded_a)
    for dy, wy in ((0, 1 - fy), (1, fy)):
        for dx, wx in ((0, 1 - fx), (1, fx)):
            weight = wy * wx
            if weight == 0:
                continue
            padded_c[:] = 0
            padded_a[:] = 0
            padded_c[dy : dy + h, dx : dx + w] = color
            padded_a[dy : dy + h, dx : dx + w] = alpha
            c += padded_c * weight
            a += padded_a * weight
    c *= opacity
    a *= opacity
    fh, fw = out.shape[:2]
    x0, y0 = max(ix, 0), max(iy, 0)
    x1, y1 = min(ix + w + 1, fw), min(iy + h + 1, fh)
    if x0 >= x1 or y0 >= y1:
        return frame
    region = out[y0:y1, x0:x1]
    sc = c[y0 - iy : y1 - iy, x0 - ix : x1 - ix]
    sa = a[y0 - iy : y1 - iy, x0 - ix : x1 - ix]
    out[y0:y1, x0:x1] = sc + region * (1 - sa)
    return (out * 255.0 + 0.5).clip(0, 255).astype(np.uint8)
