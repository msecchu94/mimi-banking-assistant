"""The opening: reference-style splash → Home with the focus effect → the
real tap and chat opening, as one continuous sequence of output frames."""

from __future__ import annotations

from collections.abc import Iterator
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image

from . import home, motion, video
from .graphics import ROOT

ASSETS = ROOT / "output" / "assets"


def splash_still(timeline: dict[str, Any]) -> np.ndarray:
    """The reference video's splash as one clean still.

    The splash is static in the reference, so averaging its frames removes
    compression noise; a fine random dither on the way back to 8 bits keeps
    the background gradient from banding. Cached in output/assets/.
    """
    spec = timeline["intro"]["splash"]
    first, last = spec["average_frames"]
    cached = ASSETS / f"splash_reference_{first}-{last}.png"
    if cached.exists():
        return np.asarray(Image.open(cached).convert("RGB"))
    v = timeline["video"]
    total = np.zeros((v["height"], v["width"], 3), np.float64)
    count = 0
    for frame in video.decode(ROOT / spec["source"], first, last - first + 1, v["fps"], (v["width"], v["height"]), in_range="limited"):
        total += frame
        count += 1
    mean = total / count
    rng = np.random.default_rng(0)  # deterministic dither
    still = np.clip(np.floor(mean + rng.random(mean.shape)), 0, 255).astype(np.uint8)
    ASSETS.mkdir(parents=True, exist_ok=True)
    Image.fromarray(still).save(cached)
    return still


@dataclass(frozen=True)
class Frame:
    index: int  # output frame
    source: int | None  # recording frame shown, None while only the splash shows
    rel: int | None  # output frames since Home appeared
    image: np.ndarray


def sequence(style: dict[str, Any], timeline: dict[str, Any], last_source: int) -> Iterator[Frame]:
    intro, focus_cfg, v = timeline["intro"], timeline["home_focus"], timeline["video"]
    size, fps = (v["width"], v["height"]), v["fps"]
    splash = splash_still(timeline).astype(np.float32)
    keep = home.button_mask(size, focus_cfg["button"], style)
    bubble = home.render_bubble(focus_cfg["bubble"]["text"], style)
    bubble_px = motion.premultiplied(bubble.image)
    bx, by = home.bubble_origin(bubble, timeline, style)
    protect = home.button_body(size, focus_cfg["button"], grow=3)

    first = intro["home_first_frame"]
    hold = intro["home_hold"]
    source_frames = list(video.decode(ROOT / timeline["source"], first, last_source - first + 1, fps, size))

    # Output order of recording frames: Home, with `hold.frames` extra copies
    # of one static frame.
    order: list[int] = []
    for src in range(first, last_source + 1):
        order.append(src)
        if src == hold["source_frame"]:
            order.extend([src] * hold["frames"])

    n_splash, n_dissolve = intro["splash"]["frames"], intro["splash"]["dissolve_frames"]
    index = 0
    # Splash: fully visible, then dissolving into Home's first (static) frame
    # within its own 1.5 s, so Home starts exactly when the splash ends.
    for i in range(n_splash):
        dissolve_at = i - (n_splash - n_dissolve)
        if dissolve_at < 0:
            yield Frame(index, None, None, splash.astype(np.uint8))
        else:
            t = motion.ease_in_out_sine((dissolve_at + 1) / (n_dissolve + 1))
            mixed = splash * (1 - t) + source_frames[0].astype(np.float32) * t
            yield Frame(index, None, None, (mixed + 0.5).astype(np.uint8))
        index += 1

    for rel, src in enumerate(order):
        rgb = source_frames[src - first]
        out = home.apply_focus(rgb, rel, src, timeline, style, keep)
        state = home.bubble_state(rel, src, timeline, style)
        if state:
            out = motion.composite(out, bubble_px, bx + state[1], by, state[0])
            out[protect] = rgb[protect]  # no overlay, not even a shadow, ever draws on the button
        yield Frame(index, src, rel, out)
        index += 1
