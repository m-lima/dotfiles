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
  version = "1.5.0";
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
      hash = "sha256-OSmwpDIefQ9WGjFwWXmL6ILWXezFloHrdwYfjv5W+/Q=";
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
