"""Render the complete program to a new master file.

    .venv/bin/python scripts/render_final.py output/final/<name>.mp4 [--crf N] [--preset NAME] [--level 5.1]

Defaults: CRF 16, preset slow (the V1 settings). Refuses to overwrite an existing file. Prints the stream summary afterwards.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from mimi_video import config, program, video  # noqa: E402
from mimi_video.graphics import ROOT  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("target")
    parser.add_argument("--crf", type=int, default=16)
    parser.add_argument("--preset", default="slow")
    parser.add_argument("--level", choices=sorted(video.LEVELS), help="constrain the stream to this H.264 level")
    args = parser.parse_args()
    target = (ROOT / args.target).resolve()
    if target.exists():
        raise SystemExit(f"{target} already exists; choose a new name")
    style, timeline, cards = config.load()
    renderer = program.Renderer(style, timeline, cards)
    total = renderer.frame_count

    def frames():
        for index, _, image in renderer.render(0, total - 1):
            if index % 600 == 0:
                print(f"  frame {index}/{total}", flush=True)
            yield image

    count = video.encode(frames(), target, renderer.fps, renderer.size, crf=args.crf, preset=args.preset, level=args.level)
    if count != total:
        raise SystemExit(f"wrote {count} frames, expected {total}")
    probe = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-count_frames", "-show_entries",
         "stream=codec_name,profile,width,height,pix_fmt,r_frame_rate,nb_read_frames,color_range,color_space,color_primaries,color_transfer:format=duration",
         "-of", "json", str(target)],
        capture_output=True, check=True, text=True,
    )
    print(json.dumps(json.loads(probe.stdout), indent=2))


if __name__ == "__main__":
    main()
