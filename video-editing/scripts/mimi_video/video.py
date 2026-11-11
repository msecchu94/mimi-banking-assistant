"""Frame-exact decoding and high-quality encoding through FFmpeg.

The recording is full-range H.264 without color tags. Frames are decoded to
full-range RGB with the BT.709 matrix and encoded back with the same matrix
to limited-range BT.709 4:2:0, tagged as such, so untouched pixels keep their
color and contrast in every player.
"""

from __future__ import annotations

import subprocess
from collections.abc import Iterable, Iterator
from pathlib import Path

import numpy as np

SCALE_FLAGS = "accurate_rnd+full_chroma_int+full_chroma_inp+lanczos"


def decode(source: Path, start: int, count: int, fps: int, size: tuple[int, int], in_range: str = "full") -> Iterator[np.ndarray]:
    """Frames start..start+count-1 as H×W×3 uint8 RGB. `in_range` is the
    source's YUV range: the recording is full range, the reference limited.

    Seeking half a frame before `start` lands exactly on it: FFmpeg decodes
    from the previous keyframe and drops everything earlier.
    """
    w, h = size
    cmd = [
        "ffmpeg", "-v", "error", "-nostdin",
        "-ss", f"{max(start - 0.5, 0) / fps:.6f}", "-i", str(source),
        "-frames:v", str(count),
        "-vf", f"scale=in_range={in_range}:in_color_matrix=bt709:out_range=full:flags={SCALE_FLAGS},format=rgb24",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-",
    ]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    assert process.stdout is not None
    frame_bytes = w * h * 3
    read = 0
    try:
        while read < count:
            buffer = process.stdout.read(frame_bytes)
            if len(buffer) < frame_bytes:
                break
            read += 1
            yield np.frombuffer(buffer, np.uint8).reshape(h, w, 3)
    finally:
        process.stdout.close()
        process.wait()
    if read != count:
        raise RuntimeError(f"decoded {read} of {count} frames from {start}")


# H.264 High-profile limits (Rec. ITU-T H.264, Table A-1; High: MaxBR and
# MaxCPB are 1.25x the Baseline/Main values).
LEVELS = {
    "5.1": {"max_dpb_mbs": 184_320, "max_br_kbps": 300_000, "max_cpb_kbits": 300_000},
}


def level_args(level: str, size: tuple[int, int]) -> list[str]:
    """x264 options that make the stream comply with `level` at this frame
    size, not just declare it: reference frames limited to what the level's
    decoded picture buffer holds, and VBV bounded by its bitrate/buffer caps."""
    limits = LEVELS[level]
    w, h = size
    frame_mbs = -(-w // 16) * -(-h // 16)
    refs = min(16, limits["max_dpb_mbs"] // frame_mbs)
    return [
        "-level:v", level, "-refs", str(refs),
        "-maxrate", f"{limits['max_br_kbps']}k", "-bufsize", f"{limits['max_cpb_kbits']}k",
    ]


def encode(frames: Iterable[np.ndarray], target: Path, fps: int, size: tuple[int, int], crf: int = 16, preset: str = "slow", level: str | None = None) -> int:
    """Encode RGB frames to H.264 High, limited-range BT.709; returns the frame
    count. With `level`, the stream is constrained to that level (see level_args)
    and x264's level warnings are shown."""
    w, h = size
    target.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg", "-v", "warning" if level else "error", "-nostdin", "-y",
        "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", f"{w}x{h}", "-r", str(fps), "-i", "-",
        "-vf",
        f"scale=in_range=full:out_range=limited:out_color_matrix=bt709:flags={SCALE_FLAGS},format=yuv420p,"
        "setparams=range=tv:colorspace=bt709:color_primaries=bt709:color_trc=bt709",
        "-c:v", "libx264", "-preset", preset, "-crf", str(crf), "-profile:v", "high",
        *(level_args(level, size) if level else []),
        "-color_range", "tv", "-colorspace", "bt709", "-color_primaries", "bt709", "-color_trc", "bt709",
        "-movflags", "+faststart", "-an", str(target),
    ]
    process = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    assert process.stdin is not None
    count = 0
    try:
        for frame in frames:
            process.stdin.write(np.ascontiguousarray(frame, np.uint8).tobytes())
            count += 1
    finally:
        process.stdin.close()
        if process.wait() != 0:
            raise RuntimeError(f"ffmpeg failed writing {target}")
    return count
