"""Compose the Play Store feature graphic from the generated brand artwork."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "store_listing/assets/feature-graphic-background.png"
OUTPUT = ROOT / "store_listing/assets/feature-graphic-1024x500.png"


def font(name: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(f"/System/Library/Fonts/Supplemental/{name}", size)


def main() -> None:
    source = Image.open(SOURCE).convert("RGB")
    target_ratio = 1024 / 500
    source_ratio = source.width / source.height

    if source_ratio > target_ratio:
        crop_width = int(source.height * target_ratio)
        left = (source.width - crop_width) // 2
        source = source.crop((left, 0, left + crop_width, source.height))
    else:
        crop_height = int(source.width / target_ratio)
        top = (source.height - crop_height) // 2
        source = source.crop((0, top, source.width, top + crop_height))

    canvas = source.resize((1024, 500), Image.Resampling.LANCZOS)
    draw = ImageDraw.Draw(canvas, "RGBA")

    # Calm the title area while keeping the generated texture visible.
    draw.rounded_rectangle((42, 62, 487, 438), radius=34, fill=(7, 11, 22, 176))
    draw.rounded_rectangle(
        (68, 94, 285, 128),
        radius=17,
        fill=(73, 198, 220, 34),
        outline=(73, 198, 220, 100),
        width=1,
    )

    badge_font = font("Arial Bold.ttf", 15)
    title_font = font("Arial Bold.ttf", 52)
    body_font = font("Arial.ttf", 22)
    note_font = font("Arial Bold.ttf", 16)

    draw.text((86, 102), "FOCUS • RECALL • FLOW", font=badge_font, fill=(91, 219, 221, 255))
    draw.text((68, 156), "ECHO", font=title_font, fill=(248, 250, 255, 255))
    draw.text((68, 210), "MEMORY", font=title_font, fill=(248, 250, 255, 255))
    draw.text((70, 288), "Watch the signal.", font=body_font, fill=(199, 205, 222, 255))
    draw.text((70, 320), "Echo the pattern.", font=body_font, fill=(199, 205, 222, 255))
    draw.text((70, 382), "EIGHT FOCUSED MEMORY MODES", font=note_font, fill=(255, 210, 92, 255))

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUTPUT, format="PNG", optimize=True)


if __name__ == "__main__":
    main()
