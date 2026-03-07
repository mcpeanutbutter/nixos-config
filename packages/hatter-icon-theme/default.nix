{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
}:

stdenvNoCC.mkDerivation {
  pname = "hatter-icon-theme";
  version = "unstable-2026-03-07";

  src = fetchFromGitHub {
    owner = "Mibea";
    repo = "Hatter";
    rev = "a037ce7b786c5be82f10e6b9d2bad12338295892";
    hash = "sha256-Xt0TkORNDR+cC9JvnLCFb7Xt8fsMhDCCkUh0G3TcwHw=";
  };

  nativeBuildInputs = [ gtk3 ];

  propagatedBuildInputs = [ hicolor-icon-theme ];

  dontDropIconThemeCache = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -a Hatter $out/share/icons/Hatter
    cp -a Hatter-kde $out/share/icons/Hatter-kde
    cp -a Hatter-kde-dark $out/share/icons/Hatter-kde-dark

    # Remove dangling symlinks (upstream has some broken cross-references)
    find $out/share/icons -xtype l -delete

    gtk-update-icon-cache --force $out/share/icons/Hatter
    gtk-update-icon-cache --force $out/share/icons/Hatter-kde
    gtk-update-icon-cache --force $out/share/icons/Hatter-kde-dark

    runHook postInstall
  '';

  meta = {
    description = "Hatter - rounded square icon theme (KDE dark variant)";
    homepage = "https://github.com/Mibea/Hatter";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
