# Oxylite Icon Style Guide

## Overview

Oxylite is a skeuomorphic SVG icon theme. Icons aim to look like real physical objects with 3D depth, realistic lighting, and rich material textures. Think KDE Oxygen-era aesthetics: glossy, tactile, detailed.

## Canvas

- Dimensions: `width="256" height="256" viewBox="0 0 256 256"`
- All coordinates in the 0-256 range
- Main icon content should sit roughly within a 200x200 area centered on the canvas, leaving margin for shadows

## Layer Structure

Build icons in this order (back to front):

### 1. Shadow Layer
A near-identical copy of the icon's silhouette, placed directly behind it and shifted down ~2-3px. This creates a subtle depth effect that makes the icon pop off the background — not a "floating above a surface" shadow.

Duplicate the main icon path, fill it black at low opacity, and apply a moderate blur. A single well-tuned shadow layer is enough:
```xml
<filter id="shadowBlur" color-interpolation-filters="sRGB"
  height="1.15" width="1.15" x="-.075" y="-.075">
  <feGaussianBlur stdDeviation="4"/>
</filter>
<!-- ... -->
<path d="[same as main shape]" fill="#000" fill-opacity=".45"
  filter="url(#shadowBlur)" transform="translate(0,3)"/>
```

**Key values** (derived from a known-good icon):
- **`stdDeviation="4"`** — soft enough to look natural, tight enough to retain the shape. Values below 2 look harsh/hard-edged; above 8 loses definition
- **`fill-opacity=".45"`** — subtle, not heavy. Values above .6 look too dark
- **Offset: 2-3px** down in final 256px space. If using a `scale()` transform on the path, account for it (e.g. 6px pre-scale at scale(0.41) = ~2.5px final)
- **Filter bounds**: Always set `height="1.15" width="1.15" x="-.075" y="-.075"` or similar — without this the blur clips at the filter region edges
- **Single layer**: One shadow layer at the right opacity is better than stacking multiple harsh ones

### 2. Base Shape
The main silhouette of the icon, filled with a rich radial or linear gradient:
```xml
<path d="..." fill="url(#baseGradient)"/>
```
Gradients should have 2-4 stops going from a lighter center/top to a darker edge/bottom for 3D depth.

### 3. Detail Layers
Interior details that define the object — panels, dividers, smaller shapes. Use:
- Separate gradient fills (not flat colors)
- Slight opacity variations (0.7-1.0) for depth
- Strokes with gradient fills for edges between sections

### 4. Specular Highlight
A white-to-transparent radial gradient overlaid on the upper portion of the icon for a glossy/reflective look:
```xml
<radialGradient id="specular" cx="128" cy="80" r="90"
  gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="#fff" stop-opacity=".6"/>
  <stop offset="1" stop-color="#fff" stop-opacity="0"/>
</radialGradient>
```
Apply to an ellipse or the main shape clipped to the top half.

### 5. Edge Highlight
A thin bright stroke or a narrow light gradient along the top edge to simulate rim lighting:
```xml
<path d="..." fill="none" stroke="#fff" stroke-opacity=".4" stroke-width="2"/>
```
Or a 1-2px bright line at the very top of the shape.

### 6. Specular Dots (Optional)
Small white ellipses placed at specific points where light would catch a surface — on curves, tips, or raised areas. These add a final layer of realism:
```xml
<ellipse cx="200" cy="80" rx="3" ry="1.5"
  fill="#fff" opacity=".6"/>
```
Place 2-4 of these at highlights on the icon's geometry.

### 7. Gradient Stroke Outline
A thin outline around the main shape using a **gradient stroke** (not solid color). This creates a luminous border that ties the icon together:
```xml
<radialGradient id="outlineGrad" cx="128" cy="60" r="140"
  gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="#fff"/>
  <stop offset="1" stop-color="#fff" stop-opacity="0"/>
</radialGradient>
<!-- ... -->
<path d="[main shape path]" fill="none"
  stroke="url(#outlineGrad)" stroke-width="2"/>
```
The gradient is typically white-to-transparent, radiating from the upper area so the outline is brightest at the top and fades toward the bottom.

## Gradient Patterns

### Radial Gradient (most common for base fills)
Center-to-edge, lighter in the upper-center area:
```xml
<radialGradient id="baseGrad" cx="128" cy="100" r="110"
  gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="#[lighter]"/>
  <stop offset=".6" stop-color="#[mid]"/>
  <stop offset="1" stop-color="#[darker]"/>
</radialGradient>
```

### Linear Gradient (for flat surfaces, bars, panels)
Top-to-bottom or angled:
```xml
<linearGradient id="panelGrad" x1="128" y1="40" x2="128" y2="220"
  gradientUnits="userSpaceOnUse">
  <stop offset="0" stop-color="#[lighter]"/>
  <stop offset="1" stop-color="#[darker]"/>
</linearGradient>
```

### Metallic/Chrome Gradient
Multiple stops alternating light and dark for a brushed-metal look:
```xml
<linearGradient id="chrome" ...>
  <stop offset="0" stop-color="#eee"/>
  <stop offset=".3" stop-color="#888"/>
  <stop offset=".5" stop-color="#fff"/>
  <stop offset=".7" stop-color="#888"/>
  <stop offset="1" stop-color="#bbb"/>
</linearGradient>
```

## Filters

### Gaussian Blur (for shadows and soft glows)
```xml
<filter id="blur4" color-interpolation-filters="sRGB">
  <feGaussianBlur stdDeviation="4"/>
</filter>
```
- Shadows: stdDeviation 4-8
- Soft inner glows: stdDeviation 1-3
- Subtle edge softening: stdDeviation 0.5-1

## Color Approach

Each icon has a dominant color palette derived from the application's branding. Apply it as:
1. **Base**: The brand's primary color as a rich gradient (lighter center, darker edges)
2. **Accent**: Secondary color for details/trim
3. **Universal**: All icons share white specular highlights and dark shadows regardless of palette

### Example Palettes
- **Blue app** (e.g. browser): Base #1297ff -> #092774, specular white, shadow #111
- **Green app** (e.g. LibreOffice Calc): Base #6bda78 -> #018b41, specular white
- **Orange app** (e.g. Blender): Base #ffbf38 -> #cf6600, specular white
- **Red app**: Base #e33e60 -> #a50400, specular white

## Common Icon Archetypes

### Circular Icon (globe, ball, orb)
- Outer circle with dark gradient (background depth)
- Inner circle with lighter gradient (the main surface)
- Specular highlight ellipse in upper-left quadrant
- Bottom shadow ellipse
- Optional: inner details (continents, logo shape)

### Rectangular Icon (document, window, device)
- Rounded rectangle base with gradient
- Inner panel/screen area (lighter)
- Top bar or title bar
- Page fold (triangular gradient in corner) for documents
- Shadow beneath

### Object Icon (tool, real-world item)
- Detailed path outline of the object
- Multiple gradient-filled sections for different materials
- Metallic gradients for metal parts
- Warm gradients for wood/organic parts
- Specular highlights on shiny surfaces

### Shield/Badge Icon
- Shield or badge outline path
- Inner emblem/symbol
- Gradient from top (lighter) to bottom (darker)
- Bright edge highlight at top

## Anti-Patterns (Avoid These)

- **`<use>` and `xlink:href`**: Do not use element references — they cause rendering issues. Always inline the full path data, even if it means duplicating a `<path d="...">`. No `<use href>` or `<use xlink:href>` elements anywhere
- **Flat colors**: Never use a single solid fill — always use gradients
- **`<text>` elements**: librsvg doesn't render them reliably — convert to `<path>`
- **Sharp pixel edges**: Use slight blur filters on shadows, feather edges
- **Overly simple shapes**: Oxylite icons are detailed — a simple circle with gradient isn't enough; add internal detail, specular highlights, edges
- **Pure black fills**: Use very dark versions of the icon's color palette instead of #000 for shape fills
- **Missing shadows**: Every icon should have a silhouette shadow behind it
- **Floating ellipse shadows**: Don't place a shadow ellipse far below the icon as if it's hovering — the shadow should match the icon's shape and sit just 2-4px below
- **Solid stroke outlines**: Prefer gradient strokes over solid-color strokes for outlines

## Structural Template

Here's a minimal template showing the layer order:

```xml
<svg height="256" width="256" viewBox="0 0 256 256"
  xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Shadow filter -->
    <filter id="shadowBlur" color-interpolation-filters="sRGB"
      height="1.15" width="1.15" x="-.075" y="-.075">
      <feGaussianBlur stdDeviation="4"/>
    </filter>
    <!-- Base gradient -->
    <radialGradient id="base" cx="128" cy="100" r="100"
      gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#LIGHTER"/>
      <stop offset="1" stop-color="#DARKER"/>
    </radialGradient>
    <!-- Specular highlight -->
    <radialGradient id="spec" cx="110" cy="80" r="80"
      gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#fff" stop-opacity=".5"/>
      <stop offset="1" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>
    <!-- Outline gradient -->
    <radialGradient id="outlineGrad" cx="128" cy="60" r="140"
      gradientUnits="userSpaceOnUse">
      <stop offset="0" stop-color="#fff"/>
      <stop offset="1" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>
  </defs>

  <!-- Layer 1: Shadow (same shape as icon, shifted down ~3px) -->
  <circle cx="128" cy="123" r="95"
    fill="#000" fill-opacity=".45" filter="url(#shadowBlur)"/>

  <!-- Layer 2: Base shape -->
  <circle cx="128" cy="120" r="95" fill="url(#base)"/>

  <!-- Layer 3: Details (icon-specific) -->
  <!-- ... interior paths, panels, emblems ... -->

  <!-- Layer 4: Specular highlight -->
  <ellipse cx="115" cy="85" rx="70" ry="50"
    fill="url(#spec)"/>

  <!-- Layer 5: Specular dots -->
  <ellipse cx="100" cy="75" rx="3" ry="1.5"
    fill="#fff" opacity=".6"/>

  <!-- Layer 6: Gradient stroke outline -->
  <circle cx="128" cy="120" r="94"
    fill="none" stroke="url(#outlineGrad)" stroke-width="2"/>
</svg>
```

## Quality Checklist

Before finalizing an icon, verify:
- [ ] 256x256 canvas with viewBox
- [ ] No `<text>` elements
- [ ] Silhouette shadow present (same shape, slight offset, blurred)
- [ ] No `<use>` or `xlink:href` elements
- [ ] At least one radial/linear gradient (no flat fills on main shapes)
- [ ] Specular highlight layer
- [ ] 3D depth is visible (lighter top/center, darker bottom/edges)
- [ ] Icon is recognizable at small sizes (48x48)
- [ ] Color palette matches the application's branding
