"""Feature cards: one clean RGBA graphic per card, drawn from its text."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from PIL import Image, ImageDraw

from . import graphics as g


@dataclass(frozen=True)
class Graphic:
    """An RGBA overlay; (`origin_x`, `origin_y`) is where the card's own
    top-left corner sits inside the image, which also holds its shadow."""

    image: Image.Image
    origin_x: int
    origin_y: int
    width: int
    height: int


def title_face(style: dict[str, Any]) -> Any:
    """The card title style, shared by every Mimi overlay."""
    return g.font(style["fonts"]["title"], style["card"]["title_size"] * style["supersample"])


def surface(shape: Image.Image, style: dict[str, Any], border: Image.Image | None = None) -> Image.Image:
    """Shadow, gradient fill and border of a Mimi overlay, for any `shape` mask.

    `border` is the border band; by default it is derived from `shape`.
    """
    s, spec = style["supersample"], style["card"]
    sh = spec["shadow"]
    layer = g.shadow(shape, sh["blur"] * s, sh["offset_y"] * s, sh["alpha"])
    fill = g.diagonal_gradient(shape.size, g.rgb(spec["background"][0]), g.rgb(spec["background"][1]))
    fill.putalpha(shape)
    layer.alpha_composite(fill)
    band = border if border is not None else g.outline(shape, spec["border_width"] * s)
    layer.alpha_composite(g.solid(shape.size, g.rgb(style["colors"]["primary"]), band, spec["border_alpha"]))
    return layer


def draw_icon(layer: Image.Image, cx: float, cy: float, style: dict[str, Any]) -> None:
    """The Mimi ✦ in a softly tinted circle, centered on (cx, cy) in supersampled pixels."""
    s, spec, colors = style["supersample"], style["card"], style["colors"]
    r = spec["icon_diameter"] / 2 * s
    disc = Image.new("L", layer.size, 0)
    ImageDraw.Draw(disc).ellipse((cx - r, cy - r, cx + r, cy + r), fill=255)
    layer.alpha_composite(g.solid(layer.size, g.rgb(colors["primary"]), disc, spec["icon_fill_alpha"]))
    star = Image.new("L", layer.size, 0)
    ImageDraw.Draw(star).polygon(g.star_polygon(cx, cy, spec["star_size"] * s), fill=255)
    layer.alpha_composite(g.solid(layer.size, g.rgb(colors["primaryBright"]), star))


def render_card(title: str, subtitle: str, style: dict[str, Any]) -> Graphic:
    s = style["supersample"]
    spec, colors, fonts = style["card"], style["colors"], style["fonts"]

    title_font = title_face(style)
    body_face = g.font(fonts["body"], spec["subtitle_size"] * s)
    text_x = spec["padding_x"] + spec["icon_diameter"] + spec["icon_gap"]
    text_width = spec["width"] - text_x - spec["padding_x"]
    lines = g.wrap(subtitle, body_face, text_width * s, spec["max_subtitle_lines"])

    # Vertical rhythm from Inter's metrics: cap-height boxes, not line boxes,
    # so the padding looks equal above the title and below the subtitle.
    title_ascent = round(spec["title_size"] * 0.727)  # Inter cap height
    body_ascent = round(spec["subtitle_size"] * 0.727)
    body_descent = round(spec["subtitle_size"] * 0.24)  # room for descenders
    body_line = round(spec["subtitle_size"] * spec["subtitle_line_height"])
    title_baseline = spec["padding_y"] + title_ascent
    first_body_baseline = title_baseline + spec["title_subtitle_gap"] + round(spec["title_size"] * 0.28) + body_ascent
    last_body_baseline = first_body_baseline + body_line * (len(lines) - 1)
    height = last_body_baseline + body_descent + spec["padding_y"]
    width = spec["width"]

    margin = spec["shadow"]["blur"] * 2 + spec["shadow"]["offset_y"]
    canvas_size = ((width + 2 * margin) * s, (height + 2 * margin) * s)
    box = (margin * s, margin * s, (margin + width) * s - 1, (margin + height) * s - 1)

    shape = Image.new("L", canvas_size, 0)
    ImageDraw.Draw(shape).rounded_rectangle(box, radius=spec["radius"] * s, fill=255)

    layer = surface(shape, style)

    # The Mimi ✦ icon, centered on the text block.
    draw_icon(layer, (margin + spec["padding_x"] + spec["icon_diameter"] / 2) * s, (margin + height / 2) * s, style)

    left = (margin + text_x) * s
    g.draw_text(layer, (left, (margin + title_baseline) * s), title, title_font, g.rgb(colors["textPrimary"]))
    for i, line in enumerate(lines):
        baseline = (margin + first_body_baseline + i * body_line) * s
        g.draw_text(layer, (left, baseline), line, body_face, g.rgb(colors["textSecondary"]))

    return Graphic(g.downsample(layer, s), margin, margin, width, height)
