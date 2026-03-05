{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
  kdePackages,
  # Attrset mapping alias icon names to target icon names (without .svg extension).
  # Symlinks are created in every icon category directory where the target exists.
  aliases ? {
    brave-browser = "internet-web-browser";
    "com.mitchellh.ghostty" = "utilities-terminal";
    vscodium = "accessories-text-editor";
    kitty = "utilities-terminal";
    "dev.zed.Zed" = "accessories-text-editor";
  },
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

    # Create icon aliases
    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (alias: target: ''
        for dir in $out/share/icons/oxylite/*/; do
          if [ -f "$dir/${target}.svg" ]; then
            ln -sf "${target}.svg" "$dir/${alias}.svg"
          fi
        done
      '') aliases
    )}

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
