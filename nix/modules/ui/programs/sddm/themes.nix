{
  stdenv,
  fetchgit,
  sddm,
  qtbase,
  qtsvg,
  qtquickcontrols2,
  qtgraphicaleffects,
  ...
}: {
  sugarDark = stdenv.mkDerivation {
    name = "sddm-theme-sugar-dark";

    dontBuild = true;
    dontWrapQtApps = true;

    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -aR $src $out/share/sddm/themes/sugar-dark
    '';

    propagatedUserEnvPkgs = [
      sddm
      qtbase
      qtsvg
      qtgraphicaleffects
      qtquickcontrols2
    ];

    src = fetchgit {
      url = "https://github.com/MarianArlt/sddm-sugar-dark";
      rev = "ceb2c455663429be03ba62d9f898c571650ef7fe";
      hash = "sha256-flOspjpYezPvGZ6b4R/Mr18N7N3JdytCSwwu6mf4owQ=";
    };
  };
}
