---
name: oxylite-icon
description: Create custom SVG application icons in the Oxylite skeuomorphic style. Use this skill whenever the user wants to create an icon, make an app icon, generate an SVG icon, design a desktop icon, or add a missing icon for an application. Also trigger when the user mentions Oxylite, icon theme, or custom icons for their desktop.
---

# Oxylite Icon Creator

Create SVG application icons that match the Oxylite icon theme's skeuomorphic style. Icons are placed in the NixOS config at `packages/oxylite-icon-theme/custom-icons/apps/`.

## Workflow

### 1. Identify the application

Ask the user which application needs an icon, then find the correct icon filename:

```bash
grep '^Icon=' /run/current-system/sw/share/applications/<app>.desktop
```

The `Icon=` value becomes the SVG filename (e.g. `Icon=brave-browser` -> `brave-browser.svg`).

If unsure which `.desktop` file to check:

```bash
ls /run/current-system/sw/share/applications/ | grep -i <appname>
```

### 2. Understand what the icon should depict

If you're confident you know what the application's icon looks like (e.g. Firefox = globe with fox, VS Code = blue folded ribbon), proceed directly. Otherwise, ask the user for a reference image URL:

> "I want to make sure I get the icon right. Could you share a reference image URL of the icon you'd like me to recreate in Oxylite style?"

Use `WebFetch` on the URL to study the reference before designing.

### 3. Design and create the SVG

Read `references/style-guide.md` for the full Oxylite style specification, then write the SVG to:

```
packages/oxylite-icon-theme/custom-icons/apps/<icon-name>.svg
```

**Critical rules:**
- NEVER use `<text>` elements — librsvg won't render them. Use `<path>` elements for any lettering
- NEVER use `<use>` or `xlink:href` — always inline full path data, even if duplicated
- Canvas: `width="256" height="256" viewBox="0 0 256 256"`
- Use only SVG elements: `<path>`, `<circle>`, `<ellipse>`, `<rect>`, `<polygon>`, `<defs>`, `<linearGradient>`, `<radialGradient>`, `<filter>`, `<clipPath>`

### 4. Visual verification loop

After writing the SVG, render it to PNG with librsvg (the same renderer GTK/Fuzzel use) and read the result to self-check:

```bash
nix-shell -p librsvg --run "rsvg-convert -w 256 -h 256 packages/oxylite-icon-theme/custom-icons/apps/<icon-name>.svg -o /tmp/<icon-name>.png"
```

Then use the Read tool on `/tmp/<icon-name>.png` to visually inspect the rendered icon. Check for:
- Is the shape recognizable as the intended application?
- Are gradients and shadows rendering correctly?
- Is the icon visually balanced and centered?
- Are there any missing or broken elements?

If something looks wrong, fix the SVG and re-render. Repeat until the icon looks good. Only then proceed to the next step.

### 5. Stage for build

After creating the icon, remind the user to stage and rebuild:

```bash
git add packages/oxylite-icon-theme/custom-icons/
sudo nixos-rebuild switch --flake .#<hostname>
```

Check the hostname first with `hostname` if needed.

### 6. Review

Tell the user to check the icon in Fuzzel (application launcher) or their taskbar. If adjustments are needed, iterate on the SVG.
