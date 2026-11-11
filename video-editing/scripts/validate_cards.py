"""Check every feature card on the rendered program at its entrance (first
fully visible frame), midpoint and exit (last fully visible frame).

    .venv/bin/python scripts/validate_cards.py

Reports, per card: the card's box, that it lies inside the frame, which UI
rows of the recording lie under it (by y), and whether what is under it
changes while it is visible. Writes output/previews/validate_<id>.png with
the three frames side by side.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, program, video  # noqa: E402
from mimi_video.card import render_card  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402
from placements import clusters, detail_rows  # noqa: E402

OUT = ROOT / "output" / "previews"


def main() -> None:
    style, timeline, cards = config.load()
    renderer = program.Renderer(style, timeline, cards)
    motion = style["card_motion"]
    v = timeline["video"]
    caption = ImageFont.truetype(str(ROOT / "assets/fonts/Inter-Medium.ttf"), 24)
    for c in cards:
        g = render_card(c.title, c.subtitle, style)
        top = c.position.top_for(g.height)  # type: ignore[union-attr]
        x0, x1, y0, y1 = c.position.x, c.position.x + g.width, top, top + g.height  # type: ignore[union-attr]
        inside = x0 >= 0 and y0 >= 0 and x1 <= v["width"] and y1 <= v["height"]
        start = renderer.first[c.start]
        end = start + (c.end - c.start)
        moments = {"entrance": start + motion["enter_frames"], "midpoint": (start + end) // 2, "exit": end - motion["exit_frames"]}
        panels, under = [], []
        for label, index in moments.items():
            _, slot, image = next(renderer.render(index, index))
            src = next(video.decode(ROOT / timeline["source"], slot.source, 1, renderer.fps, renderer.size))
            under.append(src[y0:y1, x0:x1].astype(np.int16))
            panels.append((f"{label} · {index / renderer.fps:.2f}s", Image.fromarray(image)))
        detail = detail_rows(src, 110, 1100)
        changes = max(int(np.abs(a - b).max()) for a in under for b in under)
        print(f"{c.id}: box x {x0}-{x1}, y {y0}-{y1} ({'inside the frame' if inside else 'CLIPPED'}); "
              f"visible {start / renderer.fps:.2f}-{(end + 1) / renderer.fps:.2f}s")
        print(f"  UI rows under the card (recording): {clusters(detail, y0, y1)}")
        print(f"  what is under the card {'changes' if changes > 24 else 'stays the same'} between entrance, midpoint and exit (max {changes}/255)")
        w = 402
        sheet = Image.new("RGB", (w * 3 + 40, round(2622 * w / 1206) + 44), (12, 12, 12))
        for i, (label, im) in enumerate(panels):
            ImageDraw.Draw(sheet).text((i * (w + 20) + 6, 10), label, fill=(240, 240, 240), font=caption)
            sheet.paste(im.resize((w, round(im.height * w / im.width)), Image.Resampling.LANCZOS), (i * (w + 20), 44))
        sheet.save(OUT / f"validate_{c.id}.png")


if __name__ == "__main__":
    main()
