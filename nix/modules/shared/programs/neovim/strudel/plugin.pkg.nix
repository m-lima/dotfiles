{
  lib,
  vimUtils,
  fetchFromGitHub,
}:
let
  owner = "gruvw";
  repo = "strudel.nvim";
  rev = "3a7e62c9048a318281328ad08d6269e50b884cd3";
in
vimUtils.buildVimPlugin {
  pname = "strudel.nvim";
  version = "1.0.0";
  src = fetchFromGitHub {
    inherit owner repo rev;
    hash = "sha256-qMcZYfQQiFWc+4gie4HncyL5+WJl3ojy+zB1dXlCrgA=";
  };
  meta.homepage = "https://github.com/gruvw/strudel.nvim/";
  meta.license = lib.meta.getLicenseFromSpdxId "GPL-3.0-only";
  meta.hydraPlatforms = [ ];

  passthru.github = "${owner} ${repo} --rev ${rev}";
}
