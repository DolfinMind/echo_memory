"""Prepare real emulator captures as Play-compliant 9:16 RGB screenshots."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "store_listing/screenshots"
OUTPUT = RAW / "phone"

CAPTURES = {
    "04-gameplay.png": "01-classic-recall.png",
    "05-pattern-watch.png": "02-classic-watch.png",
    "07-reflex-gameplay.png": "03-reflex-match.png",
    "01-home.png": "04-home.png",
    "02-difficulty.png": "05-difficulty.png",
    "03-tutorial.png": "06-tutorial.png",
}


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    for source_name, output_name in CAPTURES.items():
        screenshot = Image.open(RAW / source_name).convert("RGB")
        target_width = round(screenshot.height * 9 / 16)
        if target_width < screenshot.width:
            raise ValueError(f"{source_name} is wider than 9:16")

        canvas = Image.new("RGB", (target_width, screenshot.height), "#070B16")
        left = (target_width - screenshot.width) // 2
        canvas.paste(screenshot, (left, 0))
        canvas.save(OUTPUT / output_name, format="PNG", optimize=True)


if __name__ == "__main__":
    main()
