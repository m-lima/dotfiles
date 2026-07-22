{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "RustDesk";
  version = "1.4.9";
  nativeBuildInputs = [
    undmg
    unzip
  ];

  src =
    let
      name = lib.toLower finalAttrs.pname;
    in
    fetchurl {
      url = "https://github.com/${name}/${name}/releases/download/${finalAttrs.version}/${name}-${finalAttrs.version}-aarch64.dmg";
      hash = "sha256-95NVl7JH1CyPKi7XEXap9YaAGM2eGjO4CWQYpmjIyvA=";
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
