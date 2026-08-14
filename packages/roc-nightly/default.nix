# Prebuilt roc nightly (new Zig compiler) from roc-lang/nightlies.
# The binary is fully static, so no patching or wrapping is needed.
#
# To update: bump date/shortRev to the latest tag
#   curl -s https://api.github.com/repos/roc-lang/nightlies/releases/latest | jq -r .tag_name
# and re-prefetch the hash:
#   nix store prefetch-file <url>
{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  date = "2026-08-13";
  shortRev = "2fdd90e";
in
stdenvNoCC.mkDerivation {
  pname = "roc-nightly";
  version = "${date}-${shortRev}";

  src = fetchurl {
    url = "https://github.com/roc-lang/nightlies/releases/download/nightly-${date}-${shortRev}/roc_nightly-linux_x86_64-${date}-${shortRev}.tar.gz";
    hash = "sha256-ODVmIwVdLpuhACHALiIe4gA/mmsua5u9/t+j53lPoPk=";
  };

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true; # prebuilt static binary

  installPhase = ''
    runHook preInstall
    install -Dm755 roc "$out/bin/roc"
    runHook postInstall
  '';

  meta = {
    description = "Roc nightly (new Zig compiler) prebuilt binary";
    homepage = "https://github.com/roc-lang/nightlies";
    license = lib.licenses.upl;
    mainProgram = "roc";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
