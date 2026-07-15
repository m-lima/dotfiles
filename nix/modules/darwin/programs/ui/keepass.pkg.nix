{
  stdenvNoCC,
  fetchurl,
  undmg,
  unzip,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "KeePassXC";
  version = "2.7.12";
  nativeBuildInputs = [
    undmg
    unzip
  ];

  src = fetchurl {
    url = "https://github.com/keepassxreboot/keepassxc/releases/download/${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-arm64.dmg";
    hash = "sha256-ZfT2NgcYDAoVeUtKQGj4XpntU5HIfB+5MSZI8bNv7UA=";
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
