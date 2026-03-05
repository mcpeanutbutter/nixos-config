{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  python3,
  hicolor-icon-theme,
  kdePackages,
  # Path to a directory of custom SVG icons mirroring the theme's category structure
  # (e.g. custom-icons/apps/my-app.svg). Merged into the theme before alias creation.
  customIconsDir ? ./custom-icons,
  # Optional hex color (without #) to recolor default folder icons, e.g. "82aaff"
  folderColor ? null,
}:

let
  # Yellow gradient hex values from the default folder SVGs
  yellowHexes = [
    "f0c923"
    "fff1a5"
    "ffcd44"
    "f5e38c"
    "b79b0a"
    "dcb50c"
    "f5ce0c"
    "f7d435"
    "ffe564"
    "ffe76d"
    "ffe051"
    "e3a700"
    "9b7200"
  ];

  # Explicit color-variant folders to skip
  colorVariants = [
    "folder-black.svg"
    "folder-blue.svg"
    "folder-brown.svg"
    "folder-cyan.svg"
    "folder-green.svg"
    "folder-grey.svg"
    "folder-magenta.svg"
    "folder-orange.svg"
    "folder-red.svg"
    "folder-violet.svg"
    "folder-yellow.svg"
  ];

  # Python script that computes sed args for hue-shifting hex colors
  recolorScript = ''
    import colorsys, sys
    target = sys.argv[1]
    tr, tg, tb = (int(target[i:i+2], 16) / 255 for i in (0, 2, 4))
    th, _, ts = colorsys.rgb_to_hls(tr, tg, tb)
    for old in sys.argv[2:]:
        r, g, b = (int(old[i:i+2], 16) / 255 for i in (0, 2, 4))
        _, l, _ = colorsys.rgb_to_hls(r, g, b)
        nr, ng, nb = colorsys.hls_to_rgb(th, l, ts)
        new = f"{int(nr*255+.5):02x}{int(ng*255+.5):02x}{int(nb*255+.5):02x}"
        print(f"-e s/#{old}/#{new}/g", end=" ")
  '';
in
stdenvNoCC.mkDerivation {
  pname = "oxylite-icon-theme";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mx-2";
    repo = "oxylite-icon-theme";
    rev = "v1.2.0";
    hash = "sha256-sPXSvaHHro6bd1QgIcpl+6WVtnOrwLJjTqGYe7dpbHQ=";
  };

  nativeBuildInputs = [
    gtk3
  ]
  ++ lib.optional (folderColor != null) python3;

  propagatedBuildInputs = [
    hicolor-icon-theme
    kdePackages.breeze-icons
  ];

  dontDropIconThemeCache = true;
  dontWrapQtApps = true;

  # Skip build phase — the Makefile runs check scripts with /bin/bash shebangs
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons/oxylite
    cp -a actions apps categories devices emblems emotes mimetypes places preferences status ui index.theme $out/share/icons/oxylite/

    # Merge custom icons (preserving category subdirectory structure)
    if [ -d "${customIconsDir}" ]; then
      cp -r ${customIconsDir}/* $out/share/icons/oxylite/ 2>/dev/null || true
    fi

    ${lib.optionalString (folderColor != null) ''
      # Recolor folder icons (skip explicit color variants)
      SED_ARGS=$(python3 -c ${lib.escapeShellArg recolorScript} ${folderColor} ${lib.concatStringsSep " " yellowHexes})
      for svg in $out/share/icons/oxylite/places/folder*.svg; do
        case "$(basename "$svg")" in
          ${lib.concatMapStringsSep "|" lib.escapeShellArg colorVariants}) continue ;;
        esac
        eval "sed -i $SED_ARGS \"$svg\""
      done
    ''}

    gtk-update-icon-cache --force $out/share/icons/oxylite

    runHook postInstall
  '';

  meta = {
    description = "Oxylite - skeuomorphic SVG icon theme";
    homepage = "https://github.com/mx-2/oxylite-icon-theme";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
