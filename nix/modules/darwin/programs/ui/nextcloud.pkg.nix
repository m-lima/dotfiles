{
  stdenvNoCC,
  fetchurl,
  makeBinaryWrapper,
  cpio,
  gzip,
  xar,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "Nextcloud";
  version = "34.0.5";

  src = fetchurl {
    url = "https://github.com/nextcloud-releases/desktop/releases/download/v${finalAttrs.version}/Nextcloud-${finalAttrs.version}.pkg";
    hash = "sha256-MLnfK7ONnFECGL92M+2Q1kB8CPSWGK7hTF/Vt6WS8XU=";
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
})
