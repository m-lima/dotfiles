{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
let
  owner = "AlexandrosAlexiou";
  repo = "kotlin.nvim";
  rev = "d942826d58d25418da267ddd8b9a629dde95f44e";
in
vimUtils.buildVimPlugin {
  pname = "kotlin.nvim";
  version = "0-unstable-2020-08-14";
  src = fetchFromGitHub {
    inherit owner repo rev;
    hash = "sha256-XYILOb5MNKDiJpaa4x1OMc/tebFp/s6AlE88eFxUxHU=";
  };
  meta.homepage = "https://github.com/AlexandrosAlexiou/kotlin.nvim/";
  meta.license = lib.meta.getLicenseFromSpdxId "GPL-3.0-only";
  meta.hydraPlatforms = [ ];

  passthru.github = "${owner} ${repo} --rev ${rev}";
}
