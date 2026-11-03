{
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    url = "https://media.inkscape.org/dl/resources/file/${finalAttrs.pname}-${finalAttrs.version}_arm64.dmg";
  in
  {
    pname = "Inkscape";
    version = "1.4.4";
    nativeBuildInputs = [
      undmg
      unzip
    ];

    src = fetchurl {
      inherit url;
      hash = "sha256-6sypSrAeWUZ83VRSooZ8NzRFD5pM+zNGlWzJsH808/E=";
    };

    sourceRoot = ".";

    dontFixup = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      mv ${finalAttrs.pname}.app "$out/Applications/${finalAttrs.pname}.app"
      runHook postInstall
    '';

    outputs = [ "out" ];

    passthru = { inherit url; };
  }
)
