"""The complete program: which recording frame every output frame shows,
and how each output frame is rendered.

Output = reference splash → recording from Home's first frame, with holds.
A hold repeats one still frame; where the text field's caret is blinking,
the caret keeps blinking through the hold on its real cycle (sampled from
the frames just before), so nothing visibly freezes.
"""

from __future__ import annotations

from collections import deque
from collections.abc import Iterator
from dataclasses import dataclass
from typing import Any

import numpy as np

from . import config, home, motion, video
from .card import render_card
from .graphics import ROOT
from .intro import splash_still


@dataclass(frozen=True)
class Slot:
    """One output frame: the recording frame shown (None: splash only), and
    for a held frame, which hold and how far into it."""

    source: int | None
    hold: str | None = None
    step: int = 0


def holds(timeline: dict[str, Any]) -> list[dict[str, Any]]:
    intro = timeline["intro"]
    home_hold = {"name": "home", "source_frame": intro["home_hold"]["source_frame"], "frames": intro["home_hold"]["frames"], "caret": "steady"}
    return [home_hold, *timeline["holds"]]


def slots(timeline: dict[str, Any]) -> list[Slot]:
    intro = timeline["intro"]
    by_frame = {h["source_frame"]: h for h in holds(timeline)}
    out = [Slot(None) for _ in range(intro["splash"]["frames"])]
    for src in range(intro["home_first_frame"], timeline["video"]["frames"]):
        out.append(Slot(src))
        if (h := by_frame.get(src)) is not None:
            out.extend(Slot(src, h["name"], k) for k in range(h["frames"]))
    return out


def first_output_frame(order: list[Slot]) -> dict[int, int]:
    """Output index where each recording frame is first shown."""
    first: dict[int, int] = {}
    for i, slot in enumerate(order):
        if slot.source is not None and slot.hold is None:
            first.setdefault(slot.source, i)
    return first


class Renderer:
    def __init__(self, style: dict[str, Any], timeline: dict[str, Any], cards: list[config.Card], placements: dict[str, config.Position] | None = None):
        self.style, self.timeline, self.cards = style, timeline, cards
        v = timeline["video"]
        self.size, self.fps = (v["width"], v["height"]), v["fps"]
        self.order = slots(timeline)
        self.first = first_output_frame(self.order)
        self.holds = {h["name"]: h for h in holds(timeline)}
        caret = timeline["caret"]
        self.caret_box = caret["box"]  # x, y, w, h
        self.caret_period = caret["period"]

        focus = timeline["home_focus"]
        self.keep = home.button_mask(self.size, focus["button"], style)
        bubble = home.render_bubble(focus["bubble"]["text"], style)
        self.bubble_px = motion.premultiplied(bubble.image)
        self.bubble_xy = home.bubble_origin(bubble, timeline, style)
        self.protect = home.button_body(self.size, focus["button"], grow=3)
        self.splash = splash_still(timeline).astype(np.float32)

        self.card_layers = []
        positions = placements or {}
        for c in cards:
            position = positions.get(c.id, c.position)
            if position is None:
                continue
            graphic = render_card(c.title, c.subtitle, style)
            start = self.first[c.start]
            self.card_layers.append((c, graphic, motion.premultiplied(graphic.image), position, start, start + (c.end - c.start)))

    @property
    def frame_count(self) -> int:
        return len(self.order)

    def render(self, first: int, last: int) -> Iterator[tuple[int, Slot, np.ndarray]]:
        """Output frames first..last (inclusive), streamed."""
        intro = self.timeline["intro"]
        n_splash, n_dissolve = intro["splash"]["frames"], intro["splash"]["dissolve_frames"]
        home_first = intro["home_first_frame"]
        wanted = self.order[first : last + 1]
        sources = [s.source for s in wanted if s.source is not None]
        x, y, w, h = self.caret_box
        patches: deque[np.ndarray] = deque(maxlen=self.caret_period)

        decoded: Iterator[np.ndarray] | None = None
        current_src, current = -1, None
        if sources or first < n_splash:
            lo = max(min(sources, default=home_first) - self.caret_period, home_first)
            hi = max(sources, default=home_first)
            decoded = video.decode(ROOT / self.timeline["source"], lo, hi - lo + 1, self.fps, self.size)
            current_src = lo - 1
        home_start = None
        if first < n_splash:
            home_start = next(video.decode(ROOT / self.timeline["source"], home_first, 1, self.fps, self.size)).astype(np.float32)

        for index in range(first, last + 1):
            slot = self.order[index]
            if slot.source is None:
                at = index - (n_splash - n_dissolve)
                if at < 0:
                    image = self.splash.astype(np.uint8)
                else:
                    t = motion.ease_in_out_sine((at + 1) / (n_dissolve + 1))
                    image = (self.splash * (1 - t) + home_start * t + 0.5).astype(np.uint8)
                yield index, slot, image
                continue
            while current_src < slot.source:
                current = next(decoded)  # type: ignore[arg-type]
                current_src += 1
                patches.append(current[y : y + h, x : x + w].copy())
            image = current
            hold = self.holds[slot.hold] if slot.hold is not None else None
            if hold is not None and hold["caret"] == "cycle":
                # The caret keeps blinking: the held (steady) state for the
                # first frames, then the real blink cycle that played just
                # before the hold (frames F-period+1..F). A whole cycle
                # brings the blink back to the exact phase of frame F+1.
                lead = hold["frames"] - self.caret_period
                if lead < 0 or len(patches) < self.caret_period:
                    raise ValueError(f"hold {slot.hold}: a blink cycle needs {self.caret_period} frames")
                if slot.step >= lead:
                    image = image.copy()
                    image[y : y + h, x : x + w] = patches[slot.step - lead]
            image = self._effects(index, slot, image, n_splash)
            yield index, slot, image

    def _effects(self, index: int, slot: Slot, rgb: np.ndarray, n_splash: int) -> np.ndarray:
        focus = self.timeline["home_focus"]
        out = rgb
        if slot.source is not None and slot.source <= focus["blur_out_end"]:
            rel = index - n_splash
            out = home.apply_focus(rgb, rel, slot.source, self.timeline, self.style, self.keep)
            state = home.bubble_state(rel, slot.source, self.timeline, self.style)
            if state:
                bx, by = self.bubble_xy
                out = motion.composite(out, self.bubble_px, bx + state[1], by, state[0])
                out[self.protect] = rgb[self.protect]
        for card, graphic, layer, position, start, end in self.card_layers:
            state = motion.card_state(index, start, end, self.style["card_motion"])
            if state:
                opacity, dy = state
                top = position.top_for(graphic.height)
                out = motion.composite(out, layer, position.x - graphic.origin_x, top - graphic.origin_y + dy, opacity)
        return out
