"""Previews of every timing adjustment, with a seamlessness check.

    .venv/bin/python scripts/pacing_preview.py

For each hold it renders a short clip around it (cards included) to
output/previews/hold_<name>.mp4 and verifies, on the rendered frames:
  - inside the hold nothing changes except the caret area;
  - entering and leaving the hold changes no more than the recording's own
    frame-to-frame change at that point (no jump);
  - the caret's on/off runs stay within its natural range.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, program, video  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402

OUT = ROOT / "output" / "previews"

CLIPS = {
    # name: (first source frame, last source frame) around each adjustment
    "comparison": (1665, 1800),
    "block_confirm": (2470, 2700),
    "laura_confirm": (3880, 4075),
    "martin_confirm": (4630, 4900),
    "final_home": (5470, 5590),
}


def caret_level(image: np.ndarray, box: list[int]) -> int:
    x, y, w, h = box
    patch = image[y : y + h, x : x + w].astype(np.int16)
    return int((patch[..., 1] - patch[..., 0]).max())


def runs(levels: list[int], threshold: int = 90) -> list[tuple[str, int]]:
    out: list[tuple[str, int]] = []
    for level in levels:
        state = "on" if level > threshold else "off"
        if out and out[-1][0] == state:
            out[-1] = (state, out[-1][1] + 1)
        else:
            out.append((state, 1))
    return out


def main() -> None:
    style, timeline, cards = config.load()
    renderer = program.Renderer(style, timeline, cards)
    fps, size = renderer.fps, renderer.size
    first_out = renderer.first
    box = timeline["caret"]["box"]
    x, y, w, h = box
    only = set(sys.argv[1:])
    for name, (src_a, src_b) in CLIPS.items():
        if only and name not in only:
            continue
        a = first_out[src_a]
        b = len(renderer.order) - 1 if src_b == timeline["video"]["frames"] - 1 else first_out[src_b]
        frames: list[np.ndarray] = []
        slots: list[program.Slot] = []

        def stream():
            for _, slot, image in renderer.render(a, b):
                frames.append(image)
                slots.append(slot)
                yield image

        count = video.encode(stream(), OUT / f"hold_{name}.mp4", fps, size)

        held = [i for i, s in enumerate(slots) if s.hold == name]
        hold = renderer.holds[name]
        outside = np.ones(frames[0].shape[:2], bool)
        outside[y : y + h, x : x + w] = False

        def change(i: int, j: int, mask: np.ndarray | None = None) -> int:
            d = np.abs(frames[i].astype(np.int16) - frames[j].astype(np.int16)).max(axis=2)
            return int(d[mask].max() if mask is not None else d.max())

        inside = max((change(i, i - 1, outside) for i in held[1:]), default=0)
        enter = change(held[0], held[0] - 1)
        leave = change(held[-1] + 1, held[-1]) if held[-1] + 1 < len(frames) else None
        # The recording's own change at the same point, without the hold.
        last_frame = timeline["video"]["frames"] - 1
        pair = (hold["source_frame"], hold["source_frame"] + 1) if hold["source_frame"] < last_frame else (last_frame - 1, last_frame)
        source = list(video.decode(ROOT / timeline["source"], pair[0], 2, fps, size))
        natural = int(np.abs(source[1].astype(np.int16) - source[0].astype(np.int16)).max())
        window = range(max(held[0] - 60, 0), min(held[-1] + 61, len(frames)))
        caret_runs = runs([caret_level(frames[i], box) for i in window])
        print(f"{name}: {count} frames ({count / fps:.2f} s) -> output/previews/hold_{name}.mp4")
        print(f"  hold: {len(held)} frames ({len(held) / fps:.2f} s) of source frame {hold['source_frame']}, caret {hold['caret']}")
        print(f"  change inside the hold, outside the caret: {inside}/255")
        leaving = f"{leave}/255" if leave is not None else "the video ends on it"
        print(f"  entering the hold: {enter}/255; leaving it: {leaving}; recording's own change there: {natural}/255")
        if name != "final_home":
            print(f"  caret runs around the hold (state, frames): {caret_runs}")


if __name__ == "__main__":
    main()
