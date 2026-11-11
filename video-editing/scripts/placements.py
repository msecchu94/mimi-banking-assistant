"""Placement candidates for the feature cards, on the real interface.

    .venv/bin/python scripts/placements.py [card_id ...]

For each card, on a frame from the middle of its window (the layout is
still for the whole window), it finds:

  near_input      the lowest position ending at or above `near_input_bottom`
  above_exchange  the lowest position ending above the user's latest request

Card edges (and a small margin) only fall on rows without UI detail, so a
card never cuts through text. Writes output/previews/placement_<id>.png and
prints what each candidate covers.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, motion, video  # noqa: E402
from mimi_video.card import render_card  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402

OUT = ROOT / "output" / "previews"
MARGIN = 8  # blank rows required on both sides of each card edge


def detail_rows(rgb: np.ndarray, x0: int = 60, x1: int = 1146) -> np.ndarray:
    """True for rows holding UI detail (text, borders) inside the content column."""
    gray = rgb[:, x0:x1].astype(np.int16).mean(axis=2)
    return np.abs(np.diff(gray, axis=1)).max(axis=1) > 18


def latest_request_top(rgb: np.ndarray, below: int = 300, above: int = 2370) -> int | None:
    """Top of the lowest user bubble (teal fill, right-aligned) on screen."""
    column = rgb[:, 1080:1120].astype(np.int16)
    teal = ((column[..., 1] - column[..., 0]) > 30).mean(axis=1) > 0.8
    rows = np.where(teal[below:above])[0] + below
    if not len(rows):
        return None
    # Group into bubbles; keep the last one.
    starts = [rows[0]] + [r for p, r in zip(rows, rows[1:]) if r - p > 6]
    return int(starts[-1])


def clusters(mask: np.ndarray, a: int, b: int) -> list[tuple[int, int]]:
    out: list[tuple[int, int]] = []
    for y in range(a, b):
        if mask[y]:
            if out and y - out[-1][1] <= 6:
                out[-1] = (out[-1][0], y)
            else:
                out.append((y, y))
    return out


def fits(detail: np.ndarray, top: int, height: int) -> bool:
    for edge in (top, top + height):
        if detail[max(edge - MARGIN, 0) : edge + MARGIN + 1].any():
            return False
    return True


def best_top(detail: np.ndarray, height: int, limit_bottom: int, floor: int = 300) -> int | None:
    for top in range(limit_bottom - height, floor, -1):
        if fits(detail, top, height):
            return top
    return None


def main() -> None:
    style, timeline, cards = config.load()
    v = timeline["video"]
    size, fps = (v["width"], v["height"]), v["fps"]
    near_bottom = timeline["layout"]["near_input_bottom"]
    x = timeline["layout"]["card_x"]
    only = set(sys.argv[1:])
    caption = ImageFont.truetype(str(ROOT / "assets/fonts/Inter-Medium.ttf"), 26)
    for card in cards:
        if only and card.id not in only:
            continue
        frame = (card.start + card.end) // 2
        rgb = next(video.decode(ROOT / timeline["source"], frame, 1, fps, size))
        detail = detail_rows(rgb)
        graphic = render_card(card.title, card.subtitle, style)
        overlay = motion.premultiplied(graphic.image)
        h = graphic.height
        request = card.exchange_top if card.exchange_top is not None else latest_request_top(rgb)
        found: dict[str, int | None] = {}
        near = best_top(detail, h, near_bottom) if card.near_input else None
        if not card.near_input:
            print("  near_input: none — the receipt and its Compartir button fill the space above the field")
        elif near is not None and request is not None and near < request + 16:
            print(f"  near_input: none — the only clean spot near the input (y {near}-{near + h}) would cover the start of the current exchange (y {request})")
        else:
            found["near_input"] = near
        if request is not None:
            found["above_exchange"] = best_top(detail, h, request - 16)
        for name, position in card.candidates.items():
            top = position.top_for(h)
            if not fits(detail, top, h):
                raise ValueError(f"{card.id}/{name}: an edge of y {top}-{top + h} crosses UI detail")
            found[name] = top
        print(f"{card.id} (frame {frame}, {frame / fps:.2f}s): card height {h}, latest request bubble top {request}")
        panels = [("Original", Image.fromarray(rgb))]
        for name, top in found.items():
            if top is None:
                print(f"  {name}: no position with clean edges")
                continue
            covered = clusters(detail, top, top + h)
            print(f"  {name}: top {top}, bottom {top + h}; covers UI rows {covered}")
            image = motion.composite(rgb, overlay, x - graphic.origin_x, top - graphic.origin_y, 1.0)
            Image.fromarray(image).save(OUT / f"placement_{card.id}_{name}.png")
            panels.append((f"{name} · y {top}-{top + h}", Image.fromarray(image)))
        width = 603
        scaled = [im.resize((width, round(im.height * width / im.width)), Image.Resampling.LANCZOS) for _, im in panels]
        sheet = Image.new("RGB", (width * len(panels) + 20 * (len(panels) - 1), scaled[0].height + 56), (12, 12, 12))
        for i, ((label, _), im) in enumerate(zip(panels, scaled)):
            ImageDraw.Draw(sheet).text((i * (width + 20) + 8, 14), label, fill=(240, 240, 240), font=caption)
            sheet.paste(im, (i * (width + 20), 56))
        sheet.save(OUT / f"placement_{card.id}.png")


if __name__ == "__main__":
    main()
