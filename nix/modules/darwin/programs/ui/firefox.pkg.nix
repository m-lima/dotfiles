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
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${finalAttrs.version}/mac/en-US/Firefox%20${finalAttrs.version}.dmg";
  in
  {
    pname = "Firefox ESR";
    version = "153.6.0esr";
    nativeBuildInputs = [
      undmg
      unzip
    ];

    src = fetchurl {
      inherit url;
      hash = "sha256-5h9EkK5Mc7qKmP08VoL0DDw8MInjBwGNQ0FYP2BfaCg=";
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      mv Firefox.app "$out/Applications/${finalAttrs.pname}.app"
      runHook postInstall
    '';

    outputs = [ "out" ];

    passthru = { inherit url; };
  }
)
