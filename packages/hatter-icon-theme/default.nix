{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  gtk3,
  hicolor-icon-theme,
}:

stdenvNoCC.mkDerivation {
  pname = "hatter-icon-theme";
  version = "unstable-2026-07-25";

  src = fetchFromGitHub {
    owner = "Mibea";
    repo = "Hatter";
    rev = "f582a508922736e55e4fd75aca82964cde108921";
    hash = "sha256-8vOFxNKj6YaEBa9h5Y+Qs30HDN/CtYJuay8EfueGWVU=";
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
