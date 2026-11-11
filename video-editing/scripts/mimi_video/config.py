"""Load the timeline and style configuration, rejecting inconsistent timing."""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any

from .graphics import ROOT


@dataclass(frozen=True)
class Position:
    x: int
    top: int | None = None
    bottom: int | None = None

    @staticmethod
    def parse(data: dict[str, int]) -> Position:
        if ("top" in data) == ("bottom" in data):
            raise ValueError(f"a position needs exactly one of top/bottom: {data}")
        return Position(x=data["x"], top=data.get("top"), bottom=data.get("bottom"))

    def top_for(self, height: int) -> int:
        return self.top if self.top is not None else self.bottom - height  # type: ignore[operator]


@dataclass(frozen=True)
class Card:
    id: str
    title: str
    subtitle: str
    start: int
    end: int
    position: Position | None
    candidates: dict[str, Position]
    exchange_top: int | None = None
    near_input: bool = True


def load_json(name: str) -> dict[str, Any]:
    return json.loads((ROOT / "config" / name).read_text(encoding="utf-8"))


def load() -> tuple[dict[str, Any], dict[str, Any], list[Card]]:
    style, timeline = load_json("style.json"), load_json("timeline.json")
    frames = timeline["video"]["frames"]
    cards = [
        Card(
            id=c["id"],
            title=c["title"],
            subtitle=c["subtitle"],
            start=c["start"],
            end=c["end"],
            position=None if c["position"] == "pending" else Position.parse(c["position"]),
            candidates={k: Position.parse(v) for k, v in c.get("candidates", {}).items()},
            exchange_top=c.get("exchange_top"),
            near_input=c.get("near_input", True),
        )
        for c in timeline["cards"]
    ]
    validate(cards, frames, style)
    return style, timeline, cards


def validate(cards: list[Card], frames: int, style: dict[str, Any]) -> None:
    """At most one card on screen at a time, each long enough to read."""
    motion = style["card_motion"]
    ids = [c.id for c in cards]
    if len(ids) != len(set(ids)):
        raise ValueError(f"duplicate card ids: {ids}")
    titles = [c.title for c in cards]
    if len(titles) != len(set(titles)):
        raise ValueError(f"duplicate card titles: {titles}")
    ordered = sorted(cards, key=lambda c: c.start)
    for card in ordered:
        if not 0 <= card.start < card.end < frames:
            raise ValueError(f"{card.id}: frames {card.start}-{card.end} outside the video")
        held = card.end - card.start + 1 - motion["enter_frames"] - motion["exit_frames"]
        if held < 120:
            raise ValueError(f"{card.id}: fully visible for {held} frames, under 2 s")
    for a, b in zip(ordered, ordered[1:]):
        if b.start <= a.end:
            raise ValueError(f"cards overlap: {a.id} ends {a.end}, {b.id} starts {b.start}")
