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
    url = "https://github.com/keepassxreboot/keepassxc/releases/download/${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-arm64.dmg";
  in
  {
    pname = "KeePassXC";
    version = "2.8.0";
    nativeBuildInputs = [
      undmg
      unzip
    ];

    src = fetchurl {
      inherit url;
      hash = "sha256-Ij1cca5sEdSBksaf1YL9XxAEfpHrzrwBTeM6QlOblRk=";
    };

    sourceRoot = ".";

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
