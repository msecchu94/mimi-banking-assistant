"""Proof-of-concept previews rendered on the clean recording.

    .venv/bin/python scripts/preview.py intro       # splash → Home focus + bubble → tap → chat
    .venv/bin/python scripts/preview.py card-clip   # one card entering and leaving
    .venv/bin/python scripts/preview.py placements  # card stills, candidate positions side by side

Outputs go to output/previews/. Sources are only read.
"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, home, intro, motion, video  # noqa: E402
from mimi_video.card import Graphic, render_card  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402

OUT = ROOT / "output" / "previews"


def source(timeline: dict[str, Any]) -> tuple[Path, int, tuple[int, int]]:
    v = timeline["video"]
    return ROOT / timeline["source"], v["fps"], (v["width"], v["height"])


def place_card(frame_rgb: np.ndarray, graphic: Graphic, overlay: Any, position: config.Position, state: tuple[float, float]) -> np.ndarray:
    opacity, dy = state
    top = position.top_for(graphic.height)
    return motion.composite(frame_rgb, overlay, position.x - graphic.origin_x, top - graphic.origin_y + dy, opacity)


def intro_preview(style: dict[str, Any], timeline: dict[str, Any]) -> None:
    """The complete opening: splash → Home → focus and bubble → tap → chat."""
    v = timeline["video"]
    stills: dict[str, int] = {}
    hold = timeline["intro"]["home_hold"]
    first = timeline["intro"]["home_first_frame"]
    n_splash = timeline["intro"]["splash"]["frames"]
    # Key moments, as output frames.
    moments = {
        "splash": 30,
        "dissolve": n_splash - 6,
        "home_clean": n_splash + 30,
        "blur_building": n_splash + 100,
        "bubble_readable": n_splash + 180,
        "tap_ripple": n_splash + (279 - first) + hold["frames"] + 1,
        "sheet_opening": n_splash + (286 - first) + hold["frames"],
    }
    wanted = {i: name for name, i in moments.items()}

    def frames():
        for f in intro.sequence(style, timeline, timeline["intro"]["preview_last_source_frame"]):
            if f.index in wanted:
                Image.fromarray(f.image).save(OUT / f"intro_{f.index:03d}_{wanted[f.index]}.png")
            yield f.image

    count = video.encode(frames(), OUT / "intro_preview.mp4", v["fps"], (v["width"], v["height"]))
    print(f"intro: {count} frames ({count / v['fps']:.3f} s) -> output/previews/intro_preview.mp4")


def card_clip(style: dict[str, Any], timeline: dict[str, Any], cards: list[config.Card], card_id: str = "saldos") -> None:
    src, fps, size = source(timeline)
    card = next(c for c in cards if c.id == card_id)
    assert card.position is not None
    graphic = render_card(card.title, card.subtitle, style)
    overlay = motion.premultiplied(graphic.image)
    first, last = card.start - 30, card.end + 30

    def frames():
        for i, rgb in enumerate(video.decode(src, first, last - first + 1, fps, size)):
            state = motion.card_state(first + i, card.start, card.end, style["card_motion"])
            yield place_card(rgb, graphic, overlay, card.position, state) if state else rgb

    count = video.encode(frames(), OUT / f"card_{card_id}_preview.mp4", fps, size)
    print(f"card-clip: {count} frames ({first}-{last}) -> output/previews/card_{card_id}_preview.mp4")


def labelled(images: list[tuple[str, Image.Image]], width: int = 603) -> Image.Image:
    """Side-by-side half-size frames with a caption above each."""
    caption = ImageFont.truetype(str(ROOT / "assets/fonts/Inter-Medium.ttf"), 26)
    scaled = [im.resize((width, round(im.height * width / im.width)), Image.Resampling.LANCZOS) for _, im in images]
    sheet = Image.new("RGB", (width * len(images) + 20 * (len(images) - 1), scaled[0].height + 56), (12, 12, 12))
    for i, ((label, _), im) in enumerate(zip(images, scaled)):
        x = i * (width + 20)
        ImageDraw.Draw(sheet).text((x + 8, 14), label, fill=(240, 240, 240), font=caption)
        sheet.paste(im, (x, 56))
    return sheet


def placements(style: dict[str, Any], timeline: dict[str, Any], cards: list[config.Card]) -> None:
    src, fps, size = source(timeline)
    by_id = {c.id: c for c in cards}

    def still(card: config.Card, position: config.Position, frame: int) -> tuple[Image.Image, Image.Image]:
        rgb = next(video.decode(src, frame, 1, fps, size))
        graphic = render_card(card.title, card.subtitle, style)
        out = place_card(rgb, graphic, motion.premultiplied(graphic.image), position, (1.0, 0.0))
        return Image.fromarray(rgb), Image.fromarray(out)

    comparar = by_id["comparar"]
    frame = (comparar.start + comparar.end) // 2
    original, a = still(comparar, comparar.candidates["A_near_input"], frame)
    _, b = still(comparar, comparar.candidates["B_above_exchange"], frame)
    a.save(OUT / "card_comparar_A_near_input.png")
    b.save(OUT / "card_comparar_B_above_exchange.png")
    labelled([("Original", original), ("A · near input", a), ("B · above the exchange", b)]).save(
        OUT / "placement_comparar.png"
    )

    comprobante = by_id["comprobante"]
    frame = comprobante.start + 60
    original, chosen = still(comprobante, comprobante.position, frame)  # type: ignore[arg-type]
    chosen.save(OUT / "card_comprobante.png")
    labelled([("Original", original), ("Compartir comprobante", chosen)]).save(OUT / "placement_comprobante.png")

    # Every card graphic at 1:1, to review typography and wrapping.
    rendered = [render_card(c.title, c.subtitle, style) for c in cards]
    gap = 24
    board = Image.new("RGBA", (max(r.image.width for r in rendered), sum(r.image.height + gap for r in rendered)), (9, 26, 31, 255))
    y = 0
    for r in rendered:
        board.alpha_composite(r.image, (0, y))
        y += r.image.height + gap
    board.convert("RGB").save(OUT / "cards_all.png")
    print("placements: stills -> output/previews/placement_*.png, card_*.png, cards_all.png")


def home_check(style: dict[str, Any], timeline: dict[str, Any], cards: list[config.Card]) -> None:
    """Prove the focus mask never touches the button or its glow, then write
    full-resolution close-ups and the bubble/card comparison."""
    src, fps, size = source(timeline)
    focus_cfg = timeline["home_focus"]
    button = focus_cfg["button"]
    keep = home.button_mask(size, button, style)
    reach = style["home_focus"]["glow_reach"]  # measured, independent of the mask

    # The button itself: its rounded body, exactly.
    body_px = home.button_body(size, button)

    # Where the bubble (with its shadow and entrance slide) can draw: its own
    # overlay, not a change to the button's glow.
    bubble = home.render_bubble(focus_cfg["bubble"]["text"], style)
    bx, by = home.bubble_origin(bubble, timeline, style)
    bubble_area = np.zeros(size[::-1], bool)
    slide = abs(style["bubble"]["enter_offset_x"])
    bubble_area[max(by, 0) : by + bubble.image.height, max(bx - slide, 0) : bx + bubble.image.width] = True
    print(f"bubble overlay spans x {max(bx - slide, 0)}-{bx + bubble.image.width}, button starts at x {button['x']}")

    worst_body = worst_glow = 0.0
    glow_px = None
    checked = 0
    originals = {}
    last = focus_cfg["blur_out_end"]
    for i, rgb in enumerate(video.decode(src, 156, last - 156 + 1, fps, size)):
        originals[156 + i] = rgb
    for f in intro.sequence(style, timeline, last):
        if f.source is None:
            continue
        rgb, out, n = originals[f.source], f.image, f.source
        if glow_px is None:
            g = rgb[..., 1].astype(np.float32)
            y0, y1 = button["y"] - reach["top"], button["y"] + button["h"] + reach["bottom"]
            x0 = button["x"] - reach["left"]
            ring = np.zeros(size[::-1], bool)
            ring[y0 - 40 : y1 + 40, x0 - 40 :] = True
            ring[y0:y1, x0:] = False
            background = float(np.median(g[ring]))
            near = np.zeros(size[::-1], bool)
            near[y0:y1, x0:] = True
            glow_px = near & ~body_px & (g > background + 3)
            print(f"glow pixels {int(glow_px.sum())}; mask over glow min {keep[glow_px].min():.3f}, mean {keep[glow_px].mean():.3f}")
        # The bubble is a separate overlay beside the button; exclude its own pixels.
        diff = np.abs(out.astype(np.int16) - rgb.astype(np.int16)).max(axis=2)
        worst_body = max(worst_body, float(diff[body_px].max()))
        worst_glow = max(worst_glow, float(diff[glow_px & ~bubble_area].max()))
        checked += 1
        if f.rel == timeline["home_focus"]["blur_in"][1] + 40:
            box = (100, button["y"] - 130, size[0], button["y"] + button["h"] + 140)
            Image.fromarray(out).crop(box).save(OUT / "closeup_bubble_and_button.png")
            pair = Image.new("RGB", (box[2] - box[0], (box[3] - box[1]) * 2 + 20), (0, 0, 0))
            pair.paste(Image.fromarray(rgb).crop(box), (0, 0))
            pair.paste(Image.fromarray(out).crop(box), (0, box[3] - box[1] + 20))
            pair.save(OUT / "closeup_original_vs_focused.png")
    first = 156
    print(f"{checked} Home frames (source {first}-{last}, hold included): max change inside the button {worst_body:.0f}/255, inside its glow {worst_glow:.0f}/255")

    # The bubble next to a feature card, both at 1:1.
    bubble = home.render_bubble(focus_cfg["bubble"]["text"], style)
    card = next(c for c in cards if c.id == "analizar")
    graphic = render_card(card.title, card.subtitle, style)
    board = Image.new("RGBA", (graphic.image.width + 40, bubble.image.height + graphic.image.height + 40), (9, 26, 31, 255))
    board.alpha_composite(bubble.image, (20, 10))
    board.alpha_composite(graphic.image, (20, bubble.image.height + 30))
    board.convert("RGB").save(OUT / "bubble_vs_card.png")
    print(f"bubble {bubble.width}x{bubble.height}, card {graphic.width}x{graphic.height} -> output/previews/bubble_vs_card.png")


def main() -> None:
    style, timeline, cards = config.load()
    OUT.mkdir(parents=True, exist_ok=True)
    commands = {
        "intro": lambda: intro_preview(style, timeline),
        "card-clip": lambda: card_clip(style, timeline, cards),
        "placements": lambda: placements(style, timeline, cards),
        "home-check": lambda: home_check(style, timeline, cards),
    }
    for name in sys.argv[1:] or list(commands):
        commands[name]()


if __name__ == "__main__":
    main()
