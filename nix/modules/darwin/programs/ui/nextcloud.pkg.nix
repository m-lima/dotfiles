{
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  cpio,
  gzip,
  xar,
}:

stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    url = "https://github.com/nextcloud-releases/desktop/releases/download/v${finalAttrs.version}/Nextcloud-${finalAttrs.version}.pkg";
  in
  {
    pname = "Nextcloud";
    version = "35.0.2";

    src = fetchurl {
      inherit url;
      hash = "sha256-RibDI8saMfMircwK8JLU91Ou+bXJMMSXKKmgvdW+xCY=";
    };

    sourceRoot = ".";

    nativeBuildInputs = [
      makeBinaryWrapper
      cpio
      gzip
      xar
    ];

    unpackPhase = ''
      runHook preUnpack
      xar -xf $src
      cat ${finalAttrs.pname}.pkg/Payload | gunzip -dc | cpio -i
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      mv Applications/${finalAttrs.pname}.app $out/Applications/.
      makeWrapper $out/Applications/${finalAttrs.pname}.app/Contents/MacOS/${finalAttrs.pname} $out/bin/${finalAttrs.pname}
      runHook postInstall
    '';

    outputs = [ "out" ];

    passthru = { inherit url; };
  }
)
