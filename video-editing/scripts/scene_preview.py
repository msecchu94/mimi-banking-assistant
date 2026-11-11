"""Short previews of single scenes from the rendered program.

    .venv/bin/python scripts/scene_preview.py

Writes to output/previews/:
  scene_transferencias.mp4        the card entering, holding and leaving
  scene_transferencias_zoom.mp4   same, cropped to the card and the tile below
  scene_movimientos.mp4           receipt -> Consultar movimientos (approved spot)
  scene_movimientos_alt.mp4       same, with the alternative spot
  scene_movimientos_compare.png   both spots on the same frame
The configuration is not changed: the alternative is passed as an override.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, program, video  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402

OUT = ROOT / "output" / "previews"
ALT_MOVIMIENTOS = config.Position(x=103, top=885)  # over the success sentence, right above the receipt
LEAD = 30  # frames shown before and after each scene


def clip(renderer: program.Renderer, first: int, last: int, name: str, crop: tuple[int, int, int, int] | None = None) -> None:
    def frames():
        for _, _, image in renderer.render(first, last):
            yield image if crop is None else np.ascontiguousarray(image[crop[1] : crop[3], crop[0] : crop[2]])

    size = renderer.size if crop is None else (crop[2] - crop[0], crop[3] - crop[1])
    count = video.encode(frames(), OUT / name, renderer.fps, size)
    print(f"{name}: {count} frames ({count / renderer.fps:.2f} s), program {first / renderer.fps:.2f}-{(last + 1) / renderer.fps:.2f} s")


def main() -> None:
    style, timeline, cards = config.load()
    renderer = program.Renderer(style, timeline, cards)
    alt = program.Renderer(style, timeline, cards, placements={"movimientos": ALT_MOVIMIENTOS})
    by_id = {c.id: c for c in cards}

    def window(card_id: str) -> tuple[int, int]:
        c = by_id[card_id]
        start = renderer.first[c.start]
        return start, start + (c.end - c.start)

    a, b = window("transferencias")
    clip(renderer, a - LEAD, b + LEAD, "scene_transferencias.mp4")
    clip(renderer, a - LEAD, b + LEAD, "scene_transferencias_zoom.mp4", crop=(0, 860, 1206, 1460))

    # From the receipt's own card leaving to the movements card leaving.
    a, _ = window("comprobante")
    _, b = window("movimientos")
    clip(renderer, a + 90, b + LEAD, "scene_movimientos.mp4")
    clip(alt, a + 90, b + LEAD, "scene_movimientos_alt.mp4")

    s, e = window("movimientos")
    mid = (s + e) // 2
    caption = ImageFont.truetype(str(ROOT / "assets/fonts/Inter-Medium.ttf"), 26)
    panels = [(label, next(r.render(mid, mid))[2]) for label, r in (("Approved · y 657-872", renderer), ("Alternative · y 885-1100", alt))]
    w = 603
    sheet = Image.new("RGB", (w * 2 + 20, round(2622 * w / 1206) + 56), (12, 12, 12))
    for i, (label, image) in enumerate(panels):
        ImageDraw.Draw(sheet).text((i * (w + 20) + 8, 14), label, fill=(240, 240, 240), font=caption)
        sheet.paste(Image.fromarray(image).resize((w, round(2622 * w / 1206)), Image.Resampling.LANCZOS), (i * (w + 20), 56))
    sheet.save(OUT / "scene_movimientos_compare.png")
    print("scene_movimientos_compare.png")


if __name__ == "__main__":
    main()
