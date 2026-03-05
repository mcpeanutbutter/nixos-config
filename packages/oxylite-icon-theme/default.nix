{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  kdePackages,
  # Path to a directory of custom SVG icons mirroring the theme's category structure
  # (e.g. custom-icons/apps/my-app.svg). Merged into the theme before alias creation.
  customIconsDir ? ./custom-icons,
}:

stdenvNoCC.mkDerivation {
  pname = "oxylite-icon-theme";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "mx-2";
    repo = "oxylite-icon-theme";
    rev = "v1.2.0";
    hash = "sha256-sPXSvaHHro6bd1QgIcpl+6WVtnOrwLJjTqGYe7dpbHQ=";
  };

  nativeBuildInputs = [ gtk3 ];

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
