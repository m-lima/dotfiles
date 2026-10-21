{
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "Firefox ESR";
  version = "153.5.1esr";
  nativeBuildInputs = [
    undmg
    unzip
  ];

  src = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${finalAttrs.version}/mac/en-US/Firefox%20${finalAttrs.version}.dmg";
    hash = "sha256-Km1htXru15vm0/iMX71Qvla/HvL92XvNF3nIEeuCfWo=";
  };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv Firefox.app "$out/Applications/${finalAttrs.pname}.app"
    runHook postInstall
  '';

  outputs = [ "out" ];
})
