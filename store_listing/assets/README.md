# Store graphics

- `play-store-icon-512.png`: upload as the Play app icon
- `feature-graphic-1024x500.png`: upload as the Play feature graphic
- `app-icon-master.png`: generated source used for Android launcher assets
- `feature-graphic-background.png`: generated source for the feature graphic

The final icon and feature graphic are RGB PNG files without alpha.

Icon generation prompt:

> Premium Android memory-game icon on midnight navy, with a simple brain and
> waveform mark built from coral, mint, blue, gold, and violet signals; no text,
> strong silhouette, adaptive-icon safe area.

Feature-art generation prompt:

> Wide dark-navy Play feature background with calm negative space on the left
> and five colorful memory signals orbiting a white waveform on the right; no
> text or device mockup, restrained neon glow, center-safe composition.

`tool/generate_feature_graphic.py` adds the policy-safe title and supporting
copy at exactly 1024×500.
