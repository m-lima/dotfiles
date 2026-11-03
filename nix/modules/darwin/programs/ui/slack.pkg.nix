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
    url = "https://downloads.slack-edge.com/desktop-releases/mac/universal/${finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}-macOS.dmg";
  in
  {
    pname = "Slack";
    version = "4.52.178";
    nativeBuildInputs = [
      undmg
      unzip
    ];

    src = fetchurl {
      inherit url;
      hash = "sha256-iQnCIrgFVSwYs+hkANxrkAf4i5mtuhC8IQ0513Z+EW8=";
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
