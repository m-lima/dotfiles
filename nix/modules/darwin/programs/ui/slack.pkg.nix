{
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "Slack";
  version = "4.52.171";
  nativeBuildInputs = [
    undmg
    unzip
  ];

  src = fetchurl {
    url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-macOS.dmg";
    hash = "sha256-NpKHEr6tTeGQ2X7TlmGg1hHrSn6H8BK/RgOC6S7uI38=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv ${finalAttrs.pname}.app "$out/Applications/${finalAttrs.pname}.app"
    runHook postInstall
  '';

  outputs = [ "out" ];
})
