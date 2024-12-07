{
  programs = {
    core = {
      neovim = {
        enable = true;
        plugins = [
          "go"
          "js"
          "lua"
          "nix"
          "python"
          "rust"
        ];
      };
    };
    direnv.enable = true;
  };
}
